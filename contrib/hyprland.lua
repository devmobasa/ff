-- Let fft initialize on the current workspace without taking focus. The
-- launcher moves the window to special:ff after its worker starts.
o.window("org\\.omarchy\\.fft\\..*", {
  no_initial_focus = true,
})
