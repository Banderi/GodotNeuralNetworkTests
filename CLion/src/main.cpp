#include <gdnative_api_struct.gen.h>
#include <cstring>
#include "main.h"
//#include "NN/boilerplate.h"
#include "NN/neural_network.h"

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

///////// function overrides for default args
void register_method(const char *p_name, GDCALLINGCONV godot_variant (*method)(godot_object *, void *, void *, int, godot_variant **)) {
    return register_method(p_name, method, GODOT_METHOD_RPC_MODE_DISABLED);
}

godot_variant to_variant(int a) {
    godot_variant ret;
    API->godot_variant_new_int(&ret, a);
    return ret;
}
godot_variant to_variant(bool a) {
    godot_variant ret;
    API->godot_variant_new_bool(&ret, a);
    return ret;
}
godot_variant to_variant(double a) {
    godot_variant ret;
    API->godot_variant_new_real(&ret, a);
    return ret;
}
godot_variant to_variant(godot_string a) {
    godot_variant ret;
    API->godot_variant_new_string(&ret, &a);
    return ret;
}
godot_variant to_variant(const char *a) {
    // first, declare, initialize and fill a string object
    godot_string str;
    API->godot_string_new(&str);
    API->godot_string_parse_utf8(&str, a);

    // then, transfer to variant
    godot_variant ret;
    API->godot_variant_new_string(&ret, &str);

    // remember to deallocate the object!
    API->godot_string_destroy(&str);
    return ret;
}
godot_variant to_variant(godot_array a) {
    godot_variant ret;
    API->godot_variant_new_array(&ret, &a);
    return ret;
}
godot_variant to_variant(godot_object *a) {
    godot_variant ret;
    API->godot_variant_new_object(&ret, a);
    return ret;
}

godot_array to_array(godot_variant a) {
    return API->godot_variant_as_array(&a);
}
void array_push_back(godot_array *arr, const godot_variant a) {
    API->godot_array_push_back(arr, &a);
}

godot_variant debug_line_text(const char *text, int num) {
    godot_array arr;
    API->godot_array_new(&arr);
    auto t = to_variant(text);
    auto n = to_variant(num);
    array_push_back(&arr, t);
    array_push_back(&arr, n);
    return to_variant(arr);
}

godot_array constr_godot_array(godot_variant variants[], int num) {
    godot_array arr;
    API->godot_array_new(&arr);
    for (int i = 0; i < num; ++i)
        API->godot_array_push_back(&arr, &variants[i]);
    return arr;
}
godot_array constr_godot_array(godot_variant **variants, int num) {
    godot_array arr;
    API->godot_array_new(&arr);
    for (int i = 0; i < num; ++i)
        API->godot_array_push_back(&arr, variants[i]);
    return arr;
}

godot_variant get_param(int param, godot_variant **p_args, int p_num_args) {
    godot_variant ret;
    if (p_num_args == 0) // no parameters!
        return ret;
    godot_array arr = constr_godot_array(p_args, p_num_args);
    return API->godot_array_get(&arr, param);
}

//////////// NATIVESCRIPT CLASS MEMBER FUNCTIONS

godot_variant get_test_string(godot_object *p_instance, void *p_method_data, void *p_globals, int p_num_args, godot_variant **p_args) {
    return to_variant(((globals_struct *)(p_globals))->data);
}
godot_variant get_two(godot_object *p_instance, void *p_method_data, void *p_globals, int p_num_args, godot_variant **p_args) {
    return to_variant(2);
}
godot_variant get_heartbeat(godot_object *p_instance, void *p_method_data, void *p_globals, int p_num_args, godot_variant **p_args) {
    godot_array arr = constr_godot_array(p_args, p_num_args);
    return to_variant(arr);
}


godot_variant load_neuron_values(godot_object *p_instance, void *p_method_data, void *p_globals, int p_num_args, godot_variant **p_args) {
    godot_array data = to_array(get_param(0, p_args, p_num_args));
    godot_variant ret;
    if (API->godot_array_size(&data) == 0) // empty!
        return debug_line_text("no data!!", 0);

    int current_neuron = 0;

    // for each layer...
    int layers_count = API->godot_array_size(&data);
    for (int i = 0; i < layers_count; ++i) {
        godot_array layer = to_array(API->godot_array_get(&data, i));

        // for each neuron in the layer...
        int neurons_this_layer = API->godot_array_size(&layer); // layer size (num. of neurons in it)

        for (int j = 0; j < neurons_this_layer; ++j) {
            godot_array neuron = to_array(API->godot_array_get(&layer, j));

            const godot_variant activation = API->godot_array_get(&neuron, 0);
            const godot_variant bias = API->godot_array_get(&neuron, 1);
            const godot_array weights = to_array(API->godot_array_get(&neuron, 2));

//            bp_test();

            NN.set_activation(i, j, API->godot_variant_as_real(&activation));
            NN.set_bias(i, j, API->godot_variant_as_real(&bias));

            // for each synapses' weight in the layer...
            int weights_per_neuron_this_layer = API->godot_array_size(&weights);

            for (int k = 0; k < weights_per_neuron_this_layer; ++k) {
                const godot_variant weight = API->godot_array_get(&weights, k);
                NN.set_weight(i, j, k, API->godot_variant_as_real(&weight));
            }

            current_neuron++;
        }
    }

//    neuron_total_count = current_neuron;
    return debug_line_text("neurons_done:", current_neuron);
}
godot_variant retrieve_neuron_values(godot_object *p_instance, void *p_method_data, void *p_globals, int p_num_args, godot_variant **p_args) {
    godot_variant ret;
//    if (p_num_args == 0)
        return ret;

//    // get layer num
//    const godot_variant p = get_param(0, p_args, p_num_args);
//    int layer = API->godot_variant_as_int(&p);
//
//    // prepare array...
//    godot_array arr;
//    API->godot_array_new(&arr);
//
//    // go through the layer's stored neurons, build array with them
//    for (int i = starting_neuron_per_layer[layer]; i < starting_neuron_per_layer[layer] + neurons_per_layer[layer]; ++i) {
//        array_push_back(&arr, to_variant(neurons[i]));
//    }
//    return to_variant(arr);
}

void init_nativescript_methods() {

    // register methods
    register_method("get_test_string", &get_test_string);
    register_method("get_two", &get_two);
    register_method("get_heartbeat", &get_heartbeat);
    //
    register_method("load_neuron_values", &load_neuron_values);
    register_method("retrieve_neuron_values", &retrieve_neuron_values);
}