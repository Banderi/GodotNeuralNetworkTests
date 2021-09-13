#include <gdnative_api_struct.gen.h>
#include <string.h>

typedef struct globals_struct {
	char data[256];
} globals_struct;

// GDNative supports a large collection of functions for calling back
// into the main Godot executable. In order for your module to have
// access to these functions, GDNative provides your application with
// a struct containing pointers to all these functions.
const godot_gdnative_core_api_struct *api = NULL;
const godot_gdnative_ext_nativescript_api_struct *nativescript_api = NULL;

///////////////////////////// CONSTRUCTOR / DESTRUCTOR

GDCALLINGCONV void *simple_constructor(godot_object *p_instance, void *p_method_data) {
    // In our constructor, allocate memory for our structure and fill
    // it with some data. Note that we use Godot's memory functions
    // so the memory gets tracked and then return the pointer to
    // our new structure. This pointer will act as our instance
    // identifier in case multiple objects are instantiated.
    globals_struct *user_data = api->godot_alloc(sizeof(globals_struct));
    strcpy(user_data->data, "World from GDNative!");

    return user_data;
}
GDCALLINGCONV void simple_destructor(godot_object *p_instance, void *p_method_data, void *p_user_data) {
    // The destructor is called when Godot is done with our
    // object and we free our instances' member data.
    api->godot_free(p_user_data);
}

////////////////////////////////////// METHODS

godot_variant get_global_string(godot_object *p_instance, void *p_method_data, void *p_globals, int p_num_args, godot_variant **p_args) {
    // Data is always sent and returned as variants so in order to
    // return our data, which is a string, we first need to convert
    // our C string to a Godot string object, and then copy that
    // string object into the variant we are returning.
    godot_string str;
    godot_variant ret;

    api->godot_string_new(&str);
    api->godot_string_parse_utf8(&str, ((globals_struct *)(p_globals))->data);
    api->godot_variant_new_string(&ret, &str);
    api->godot_string_destroy(&str);

    return ret;
}

///////////////////////////////// INIT / TERMINATE

void GDN_EXPORT godot_gdnative_init(godot_gdnative_init_options *p_options) {
    // `gdnative_init` is a function that initializes our dynamic library.
    // Godot will give it a pointer to a structure that contains various bits of
    // information we may find useful among which the pointers to our API structures.
	api = p_options->api_struct;

	// Find NativeScript extensions.
	for (int i = 0; i < api->num_extensions; i++) {
		switch (api->extensions[i]->type) {
			case GDNATIVE_EXT_NATIVESCRIPT: {
				nativescript_api = (godot_gdnative_ext_nativescript_api_struct *)api->extensions[i];
			}; break;
			default:
				break;
		};
	};
}
void GDN_EXPORT godot_gdnative_terminate(godot_gdnative_terminate_options *p_options) {
    // `gdnative_terminate` which is called before the library is unloaded.
    // Godot will unload the library when no object uses it anymore.
	api = NULL;
	nativescript_api = NULL;
}
void GDN_EXPORT godot_nativescript_init(void *p_handle) {
    // `nativescript_init` is the most important function. Godot calls
    // this function as part of loading a GDNative library and communicates
    // back to the engine what objects we make available.

	// We first tell the engine which classes are implemented by calling this.
	// * The first parameter here is the handle pointer given to us.
	// * The second is the name of our object class.
	// * The third is the type of object in Godot that we 'inherit' from;
	//   this is not true inheritance but it's close enough.
	// * Finally, the fourth and fifth parameters are descriptions
	//   for our constructor and destructor, respectively.
	nativescript_api->godot_nativescript_register_class(p_handle, "NNClass", "Reference",
                            (godot_instance_create_func) { &simple_constructor, NULL, NULL },
                            (godot_instance_destroy_func) { &simple_destructor, NULL, NULL });

	// We then tell Godot about our methods by calling this for each
	// method of our class. In our case, this is just `get_data`.
	// * Our first parameter is yet again our handle pointer.
	// * The second is again the name of the object class we're registering.
	// * The third is the name of our function as it will be known to GDScript.
	// * The fourth is our attributes setting (see godot_method_rpc_mode enum in
	//   `godot_headers/nativescript/godot_nativescript.h` for possible values).
	// * The fifth and final parameter is a description of which function
	//   to call when the method gets called.
	nativescript_api->godot_nativescript_register_method(p_handle, "NNClass", "get_data",
                             (godot_method_attributes) { GODOT_METHOD_RPC_MODE_DISABLED },
                             (godot_instance_method) {&get_global_string, NULL, NULL });
}

