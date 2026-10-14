local obs = obslua

local count = 0
local text_source_name = ""
local image_source_name = ""
local path_idle = ""
local path_pressed = ""
local hotkey_id = obs.OBS_INVALID_HOTKEY_ID

function update_text()
    local source = obs.obs_get_source_by_name(text_source_name)
    if source ~= nil then
        local settings = obs.obs_data_create()
        obs.obs_data_set_string(settings, "text","".. tostring(count))
        obs.obs_source_update(source, settings)
        obs.obs_data_release(settings)
        obs.obs_source_release(source)
    end
end

function set_image(path)
    local source = obs.obs_get_source_by_name(image_source_name)
    if source ~= nil then
        local settings = obs.obs_data_create()
        obs.obs_data_set_string(settings, "file", path)
        obs.obs_source_update(source, settings)
        obs.obs_data_release(settings)
        obs.obs_source_release(source)
    end
end

function on_hotkey(pressed)
    if pressed then
        count = count + 1
        update_text()
        set_image(path_pressed)
    else
        set_image(path_idle)
    end
end

function script_properties()
    local props = obs.obs_properties_create()

    obs.obs_properties_add_text(props, "text_source", "Text Source Name", obs.OBS_TEXT_DEFAULT)
    obs.obs_properties_add_text(props, "image_source", "Image Source Name", obs.OBS_TEXT_DEFAULT)

    obs.obs_properties_add_path(props, "path_idle", "Idle Image (Not Pressed)", obs.OBS_PATH_FILE, "*.png *.jpg *.jpeg", nil)
    obs.obs_properties_add_path(props, "path_pressed", "Pressed Image", obs.OBS_PATH_FILE, "*.png *.jpg *.jpeg", nil)

    obs.obs_properties_add_button(props, "reset_button", "Reset Counter", function()
        count = 0
        update_text()
        return true
    end)

    return props
end

function script_update(settings)
    text_source_name = obs.obs_data_get_string(settings, "text_source")
    image_source_name = obs.obs_data_get_string(settings, "image_source")
    path_idle = obs.obs_data_get_string(settings, "path_idle")
    path_pressed = obs.obs_data_get_string(settings, "path_pressed")

    set_image(path_idle)
    update_text()
end

function script_load(settings)
    hotkey_id = obs.obs_hotkey_register_frontend("counter_hotkey", "Counter Hotkey", on_hotkey)
    local hotkey_save_array = obs.obs_data_get_array(settings, "counter_hotkey")
    obs.obs_hotkey_load(hotkey_id, hotkey_save_array)
    obs.obs_data_array_release(hotkey_save_array)
end

function script_save(settings)
    local hotkey_save_array = obs.obs_hotkey_save(hotkey_id)
    obs.obs_data_set_array(settings, "counter_hotkey", hotkey_save_array)
    obs.obs_data_array_release(hotkey_save_array)
end
