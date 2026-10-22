view_enabled = true; view_visible[0] = true;
cam = camera_create_view(0, 0, 960, 540, 0, noone, -1, -1, -1, -1);
view_camera[0] = cam;
view_xport[0] = 0; view_yport[0] = 0; view_wport[0] = 1280; view_hport[0] = 720;
window_set_size(1280, 720); display_set_gui_size(960, 540);
cam_x = 320; cam_y = 280;
