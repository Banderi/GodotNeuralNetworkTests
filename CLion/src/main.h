//
// Created by Banderi on 9/13/2021.
//

#ifndef CLION_SIMPLE_H
#define CLION_SIMPLE_H

extern const char *p_class_name;
extern const godot_gdnative_core_api_struct *API;
extern const godot_gdnative_ext_nativescript_api_struct *nativescript_API;

#ifdef __cplusplus
#define CEXTERN extern "C"
#else
#define CEXTERN
#endif

CEXTERN void *init_globals();
CEXTERN void init_nativescript_methods();

CEXTERN void register_class(GDCALLINGCONV void *(*create_func)(godot_object *, void *), GDCALLINGCONV void (*destroy_func)(godot_object *, void *, void *));
CEXTERN void register_method(const char *p_name, GDCALLINGCONV godot_variant (*method)(godot_object *, void *, void *, int, godot_variant **));

#endif //CLION_SIMPLE_H
