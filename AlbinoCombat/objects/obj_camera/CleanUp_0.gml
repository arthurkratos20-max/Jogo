if (cam != -1) {
    if (view_camera[0] == cam) view_camera[0] = -1;
    camera_destroy(cam);
}
