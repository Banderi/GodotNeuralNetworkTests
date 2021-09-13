#ifndef CLION_SIMPLE_H
#define CLION_SIMPLE_H


// hack to make C and C++ files work together
// without them trying to kill each other
#ifdef __cplusplus
#define CEXTERN extern "C"
#else
#define CEXTERN
#endif

CEXTERN const char *p_class_name;

// GDNative supports a large collection of functions for calling back
// into the main Godot executable. In order for your module to have
// access to these functions, GDNative provides your application with
// a struct containing pointers to all these functions.
CEXTERN const godot_gdnative_core_api_struct *API;
CEXTERN const godot_gdnative_ext_nativescript_api_struct *nativescript_API;

CEXTERN void *init_globals();
CEXTERN void init_nativescript_methods();

CEXTERN void register_class(GDCALLINGCONV void *(*create_func)(godot_object *, void *), GDCALLINGCONV void (*destroy_func)(godot_object *, void *, void *));
CEXTERN void register_method(const char *p_name, GDCALLINGCONV godot_variant (*method)(godot_object *, void *, void *, int, godot_variant **), godot_method_rpc_mode rpc_mode);

#endif //CLION_SIMPLE_H
