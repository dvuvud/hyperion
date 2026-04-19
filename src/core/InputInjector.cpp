#include "InputInjector.hpp"

#include <QtCore/QtGlobal>

#include <stdexcept>

#if defined(Q_OS_MAC)

#include <ApplicationServices/ApplicationServices.h>

namespace InputInjector {

static CGEventFlags toCGFlags(uint32_t mods) {
    CGEventFlags f = 0;
    if (mods & Mod_Shift)   f |= kCGEventFlagMaskShift;
    if (mods & Mod_Control) f |= kCGEventFlagMaskControl;
    if (mods & Mod_Alt)     f |= kCGEventFlagMaskAlternate;
    if (mods & Mod_Meta)    f |= kCGEventFlagMaskCommand;
    return f;
}

void sendKey(uint32_t key, bool press, uint32_t modifiers) {
    CGEventSourceRef src = CGEventSourceCreate(kCGEventSourceStateHIDSystemState);
    CGEventRef ev = CGEventCreateKeyboardEvent(src, static_cast<CGKeyCode>(key), press);
    CGEventSetFlags(ev, toCGFlags(modifiers));
    CGEventPost(kCGHIDEventTap, ev);
    CFRelease(ev);
    CFRelease(src);
}

void sendMouse(const MouseAction& a) {
    CGEventSourceRef src = CGEventSourceCreate(kCGEventSourceStateHIDSystemState);

    auto buttonFor = [&]() -> CGMouseButton {
        switch (a.button) {
            case MouseAction::Button::Left:   return kCGMouseButtonLeft;
            case MouseAction::Button::Right:  return kCGMouseButtonRight;
            case MouseAction::Button::Middle: return kCGMouseButtonCenter;
        }
        return kCGMouseButtonLeft;
    };

    CGPoint pos = CGPointMake(a.x, a.y);

    if (a.kind == MouseAction::Kind::Move) {
        CGEventRef ev = CGEventCreateMouseEvent(src, kCGEventMouseMoved, pos, kCGMouseButtonLeft);
        CGEventPost(kCGHIDEventTap, ev);
        CFRelease(ev);
    } else if (a.kind == MouseAction::Kind::Scroll) {
        CGEventRef ev = CGEventCreateScrollWheelEvent(
            src, kCGScrollEventUnitLine, 1, a.scrollDelta);
        CGEventPost(kCGHIDEventTap, ev);
        CFRelease(ev);
    } else {
        CGEventType downType, upType;
        switch (a.button) {
            case MouseAction::Button::Right:
                downType = kCGEventRightMouseDown; upType = kCGEventRightMouseUp; break;
            case MouseAction::Button::Middle:
                downType = kCGEventOtherMouseDown; upType = kCGEventOtherMouseUp; break;
            default:
                downType = kCGEventLeftMouseDown;  upType = kCGEventLeftMouseUp;  break;
        }

        if (a.kind == MouseAction::Kind::Press || a.kind == MouseAction::Kind::Click) {
            CGEventRef ev = CGEventCreateMouseEvent(src, downType, pos, buttonFor());
            CGEventPost(kCGHIDEventTap, ev);
            CFRelease(ev);
        }
        if (a.kind == MouseAction::Kind::Release || a.kind == MouseAction::Kind::Click) {
            CGEventRef ev = CGEventCreateMouseEvent(src, upType, pos, buttonFor());
            CGEventPost(kCGHIDEventTap, ev);
            CFRelease(ev);
        }
    }

    CFRelease(src);
}

}

#elif defined(Q_OS_WIN)

#define WIN32_LEAN_AND_MEAN
#include <windows.h>

namespace InputInjector {

static DWORD toWinMods(uint32_t mods) {
    return mods; // caller iterates flags
}

static void pressModifiers(uint32_t mods, bool down) {
    auto send = [&](WORD vk) {
        INPUT inp{};
        inp.type       = INPUT_KEYBOARD;
        inp.ki.wVk     = vk;
        inp.ki.dwFlags = down ? 0 : KEYEVENTF_KEYUP;
        SendInput(1, &inp, sizeof(INPUT));
    };
    if (mods & Mod_Shift)   send(VK_SHIFT);
    if (mods & Mod_Control) send(VK_CONTROL);
    if (mods & Mod_Alt)     send(VK_MENU);
    if (mods & Mod_Meta)    send(VK_LWIN);
}

void sendKey(uint32_t key, bool press, uint32_t modifiers) {
    if (press) pressModifiers(modifiers, true);

    INPUT inp{};
    inp.type       = INPUT_KEYBOARD;
    inp.ki.wVk     = static_cast<WORD>(key);
    inp.ki.dwFlags = press ? 0 : KEYEVENTF_KEYUP;
    SendInput(1, &inp, sizeof(INPUT));

    if (!press) pressModifiers(modifiers, false);
}

void sendMouse(const MouseAction& a) {
    if (a.kind == MouseAction::Kind::Move) {
        int sw = GetSystemMetrics(SM_CXVIRTUALSCREEN);
        int sh = GetSystemMetrics(SM_CYVIRTUALSCREEN);
        LONG ax = static_cast<LONG>((a.x * 65535) / sw);
        LONG ay = static_cast<LONG>((a.y * 65535) / sh);

        INPUT inp{};
        inp.type         = INPUT_MOUSE;
        inp.mi.dx        = ax;
        inp.mi.dy        = ay;
        inp.mi.dwFlags   = MOUSEEVENTF_MOVE | MOUSEEVENTF_ABSOLUTE | MOUSEEVENTF_VIRTUALDESK;
        SendInput(1, &inp, sizeof(INPUT));
        return;
    }

    if (a.kind == MouseAction::Kind::Scroll) {
        INPUT inp{};
        inp.type           = INPUT_MOUSE;
        inp.mi.mouseData   = static_cast<DWORD>(a.scrollDelta * WHEEL_DELTA);
        inp.mi.dwFlags     = MOUSEEVENTF_WHEEL;
        SendInput(1, &inp, sizeof(INPUT));
        return;
    }

    DWORD downFlag{}, upFlag{};
    switch (a.button) {
        case MouseAction::Button::Left:
            downFlag = MOUSEEVENTF_LEFTDOWN; upFlag = MOUSEEVENTF_LEFTUP; break;
        case MouseAction::Button::Right:
            downFlag = MOUSEEVENTF_RIGHTDOWN; upFlag = MOUSEEVENTF_RIGHTUP; break;
        case MouseAction::Button::Middle:
            downFlag = MOUSEEVENTF_MIDDLEDOWN; upFlag = MOUSEEVENTF_MIDDLEUP; break;
    }

    auto fire = [&](DWORD flags) {
        INPUT inp{};
        inp.type     = INPUT_MOUSE;
        inp.mi.dwFlags = flags;
        SendInput(1, &inp, sizeof(INPUT));
    };

    if (a.kind == MouseAction::Kind::Press  || a.kind == MouseAction::Kind::Click) fire(downFlag);
    if (a.kind == MouseAction::Kind::Release || a.kind == MouseAction::Kind::Click) fire(upFlag);
}

} // namespace InputInjector

#elif defined(Q_OS_LINUX)

#include <X11/Xlib.h>
#include <X11/extensions/XTest.h>
#include <X11/keysym.h>
#include <X11/XKBlib.h>
#include <stdexcept>

namespace InputInjector {

static Display* display() {
    static Display* dpy = []() -> Display* {
        Display* d = XOpenDisplay(nullptr);
        if (!d) throw std::runtime_error("InputInjector: cannot open X display");
        return d;
    }();
    return dpy;
}

static void flushX() { XFlush(display()); }

static unsigned int toX11Mods(uint32_t mods) {
    unsigned int m = 0;
    if (mods & Mod_Shift)   m |= ShiftMask;
    if (mods & Mod_Control) m |= ControlMask;
    if (mods & Mod_Alt)     m |= Mod1Mask;
    if (mods & Mod_Meta)    m |= Mod4Mask;   // Super / Win key
    return m;
}

static void pressX11Mod(Display* dpy, unsigned int mask, bool down) {
    KeySym ks = NoSymbol;
    if (mask == ShiftMask)   ks = XK_Shift_L;
    if (mask == ControlMask) ks = XK_Control_L;
    if (mask == Mod1Mask)    ks = XK_Alt_L;
    if (mask == Mod4Mask)    ks = XK_Super_L;
    if (ks == NoSymbol) return;
    KeyCode kc = XKeysymToKeycode(dpy, ks);
    XTestFakeKeyEvent(dpy, kc, down ? True : False, CurrentTime);
}

void sendKey(uint32_t key, bool press, uint32_t modifiers) {
    Display* dpy = display();
    KeyCode kc = XKeysymToKeycode(dpy, static_cast<KeySym>(key));
    if (!kc) return; // unmapped keysym

    unsigned int xmods = toX11Mods(modifiers);

    if (press) {
        // Hold modifiers first
        if (xmods & ShiftMask)   pressX11Mod(dpy, ShiftMask,   true);
        if (xmods & ControlMask) pressX11Mod(dpy, ControlMask, true);
        if (xmods & Mod1Mask)    pressX11Mod(dpy, Mod1Mask,    true);
        if (xmods & Mod4Mask)    pressX11Mod(dpy, Mod4Mask,    true);
    }

    XTestFakeKeyEvent(dpy, kc, press ? True : False, CurrentTime);

    if (!press) {
        // Release modifiers after the key-up
        if (xmods & ShiftMask)   pressX11Mod(dpy, ShiftMask,   false);
        if (xmods & ControlMask) pressX11Mod(dpy, ControlMask, false);
        if (xmods & Mod1Mask)    pressX11Mod(dpy, Mod1Mask,    false);
        if (xmods & Mod4Mask)    pressX11Mod(dpy, Mod4Mask,    false);
    }

    flushX();
}

void sendMouse(const MouseAction& a) {
    Display* dpy = display();

    if (a.kind == MouseAction::Kind::Move) {
        XTestFakeMotionEvent(dpy, -1, a.x, a.y, CurrentTime);
        flushX();
        return;
    }

    if (a.kind == MouseAction::Kind::Scroll) {
        // Button 4 = scroll up, Button 5 = scroll down
        unsigned int btn = a.scrollDelta >= 0 ? 4 : 5;
        int clicks = std::abs(a.scrollDelta);
        for (int i = 0; i < clicks; ++i) {
            XTestFakeButtonEvent(dpy, btn, True,  CurrentTime);
            XTestFakeButtonEvent(dpy, btn, False, CurrentTime);
        }
        flushX();
        return;
    }

    unsigned int btn = 1; // left
    switch (a.button) {
        case MouseAction::Button::Left:   btn = 1; break;
        case MouseAction::Button::Right:  btn = 3; break;
        case MouseAction::Button::Middle: btn = 2; break;
    }

    if (a.kind == MouseAction::Kind::Press || a.kind == MouseAction::Kind::Click)
        XTestFakeButtonEvent(dpy, btn, True,  CurrentTime);
    if (a.kind == MouseAction::Kind::Release || a.kind == MouseAction::Kind::Click)
        XTestFakeButtonEvent(dpy, btn, False, CurrentTime);

    flushX();
}

}

#else
    #error "InputInjector: unsupported platform"
#endif
