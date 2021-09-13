#include <gdnative_api_struct.gen.h>
#include "main.h"

GDCALLINGCONV void *simple_constructor(godot_object *p_instance, void *p_method_data) {
    // In our constructor, allocate memory for our structure and fill
    // it with some data. Note that we use Godot's memory functions
    // so the memory gets tracked and then return the pointer to
    // our new structure. This pointer will act as our instance
    // identifier in case multiple objects are instantiated.
    return init_globals();
}
GDCALLINGCONV void simple_destructor(godot_object *p_instance, void *p_method_data, void *p_user_data) {
    // The destructor is called when Godot is done with our
    // object and we free our instances' member data.
    API->godot_free(p_user_data);
}

static void *p_init_handle;

void register_class(GDCALLINGCONV void *(*create_func)(godot_object *, void *), GDCALLINGCONV void (*destroy_func)(godot_object *, void *, void *)) {
    // We first tell the engine which classes are implemented by calling this.
    // * The first parameter here is the handle pointer given to us.
    // * The second is the name of our object class.
    // * The third is the type of object in Godot that we 'inherit' from;
    //   this is not true inheritance but it's close enough.
    // * Finally, the fourth and fifth parameters are descriptions
    //   for our constructor and destructor, respectively.
    nativescript_API->godot_nativescript_register_class(p_init_handle, p_class_name, "Reference",
                                                        (godot_instance_create_func) {create_func, NULL, NULL},
                                                        (godot_instance_destroy_func) {destroy_func, NULL, NULL});
}
void register_method(const char *p_name, GDCALLINGCONV godot_variant (*method)(godot_object *, void *, void *, int, godot_variant **), godot_method_rpc_mode rpc_mode) {
    // We then tell Godot about our methods by calling this for each
    // method of our class. In our case, this is just `get_data`.
    // * Our first parameter is yet again our handle pointer.
    // * The second is again the name of the object class we're registering.
    // * The third is the name of our function as it will be known to GDScript.
    // * The fourth is our attributes setting (see godot_method_rpc_mode enum in
    //   `godot_headers/nativescript/godot_nativescript.h` for possible values).
    // * The fifth and final parameter is a description of which function
    //   to call when the method gets called.
    nativescript_API->godot_nativescript_register_method(p_init_handle, p_class_name, p_name,
                                                         (godot_method_attributes) {rpc_mode},
                                                         (godot_instance_method) {method, NULL, NULL});
}

void GDN_EXPORT godot_gdnative_init(godot_gdnative_init_options *p_options) {
    // `gdnative_init` is a function that initializes our dynamic library.
    // Godot will give it a pointer to a structure that contains various bits of
    // information we may find useful among which the pointers to our API structures.
	API = p_options->api_struct;

	// Find NativeScript extensions.
	for (int i = 0; i < API->num_extensions; i++) {
		switch (API->extensions[i]->type) {
			case GDNATIVE_EXT_NATIVESCRIPT: {
                nativescript_API = (godot_gdnative_ext_nativescript_api_struct *)API->extensions[i];
			}; break;
			default:
				break;
		};
	};
}
void GDN_EXPORT godot_gdnative_terminate(godot_gdnative_terminate_options *p_options) {
    // `gdnative_terminate` which is called before the library is unloaded.
    // Godot will unload the library when no object uses it anymore.
	API = NULL;
    nativescript_API = NULL;
}
void GDN_EXPORT godot_nativescript_init(void *p_handle) {
    p_init_handle = p_handle;

    // register class, constructor & destructor
    register_class(&simple_constructor, &simple_destructor);

    // register methods
    init_nativescript_methods();
}

