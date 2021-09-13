#include <gdnative_api_struct.gen.h>
#include <cstring>
#include "main.h"

const char *p_class_name = "NNClass";
const godot_gdnative_core_api_struct *API = nullptr;
const godot_gdnative_ext_nativescript_api_struct *nativescript_API = nullptr;

typedef struct {
    char data[256];
} globals_struct;

void *init_globals() {
    auto global_data = (globals_struct*)API->godot_alloc(sizeof(globals_struct));
    strcpy(global_data->data, "World from GDNative!");
    return (void*)global_data;
}

godot_variant get_test_string(godot_object *p_instance, void *p_method_data, void *p_globals, int p_num_args, godot_variant **p_args) {
    // Data is always sent and returned as variants so in order to
    // return our data, which is a string, we first need to convert
    // our C string to a Godot string object, and then copy that
    // string object into the variant we are returning.
    godot_string str;
    godot_variant ret;

    API->godot_string_new(&str);
    API->godot_string_parse_utf8(&str, ((globals_struct *)(p_globals))->data);
    API->godot_variant_new_string(&ret, &str);
    API->godot_string_destroy(&str);

    return ret;
}
godot_variant get_two(godot_object *p_instance, void *p_method_data, void *p_globals, int p_num_args, godot_variant **p_args) {
    godot_variant ret;
    API->godot_variant_new_int(&ret, 2);
    return ret;
}
godot_variant get_heartbeat(godot_object *p_instance, void *p_method_data, void *p_globals, int p_num_args, godot_variant **p_args) {
//    godot_variant ret;
//    API->godot_variant_new_int(&ret, 2);
//    godot_variant first_arg;
//    godot_string str;
//    API->godot_string_parse_utf8(&str, "hey");
//    API->godot_variant_new_string(&first_arg, &str);
//    API->godot_variant_new_int(&first_arg, 2);
//    first_arg = *(p_args[0]);

    godot_array arr;
    API->godot_array_new(&arr);
    for (int i = 0; i < p_num_args; ++i) {
        API->godot_array_push_back(&arr, (p_args[0]));
    }

    godot_variant ret;
    API->godot_variant_new_array(&ret, &arr);
    return ret;
}

void init_nativescript_methods() {

    // register methods
    register_method("get_test_string", &get_test_string);
    register_method("get_two", &get_two);
    register_method("get_heartbeat", &get_heartbeat);
}