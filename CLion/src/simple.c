#include <gdnative_api_struct.gen.h>
#include <string.h>

typedef struct {
	char data[256];
} globals_struct;

// GDNative supports a large collection of functions for calling back
// into the main Godot executable. In order for your module to have
// access to these functions, GDNative provides your application with
// a struct containing pointers to all these functions.
const godot_gdnative_core_api_struct *API = NULL;
const godot_gdnative_ext_nativescript_api_struct *nativescript_API = NULL;

///////////////////////////// CONSTRUCTOR / DESTRUCTOR

GDCALLINGCONV void *simple_constructor(godot_object *p_instance, void *p_method_data) {
    // In our constructor, allocate memory for our structure and fill
    // it with some data. Note that we use Godot's memory functions
    // so the memory gets tracked and then return the pointer to
    // our new structure. This pointer will act as our instance
    // identifier in case multiple objects are instantiated.
    globals_struct *user_data = API->godot_alloc(sizeof(globals_struct));
    strcpy(user_data->data, "World from GDNative!");

    return user_data;
}
GDCALLINGCONV void simple_destructor(godot_object *p_instance, void *p_method_data, void *p_user_data) {
    // The destructor is called when Godot is done with our
    // object and we free our instances' member data.
    API->godot_free(p_user_data);
}

////////////////////////////////////// METHODS

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

///////////////////////////////// INIT / TERMINATE

static void *p_init_handle;
const char *p_class_name = "NNClass";

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
void register_method(const char *p_name, GDCALLINGCONV godot_variant (*method)(godot_object *, void *, void *, int, godot_variant **)) {
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
                                                         (godot_method_attributes) {GODOT_METHOD_RPC_MODE_DISABLED},
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
    register_method("get_test_string", &get_test_string);
    register_method("get_heartbeat", &get_heartbeat);
}

