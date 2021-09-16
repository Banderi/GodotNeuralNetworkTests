#include <gdnative_api_struct.gen.h>
#include <cstring>
#include "main.h"
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

// empty objects
godot_variant empty_variant() {
    godot_variant ret;
    return ret;
}
godot_array empty_array() {
    godot_array arr;
    API->godot_array_new(&arr);
    return arr;
}

void free(godot_variant a) {
    API->godot_variant_destroy(&a);
}
void free(godot_array a) {
    API->godot_array_destroy(&a);
}
void free(godot_string a) {
    API->godot_string_destroy(&a);
}
void free(godot_object *a) {
    API->godot_object_destroy(&a);
}

int to_int(godot_variant a, bool dealloc = true) {
    auto ret = API->godot_variant_as_int(&a);
    if (dealloc)
        free(a);
    return ret;
}
int to_bool(godot_variant a, bool dealloc = true) {
    auto ret = API->godot_variant_as_bool(&a);
    if (dealloc)
        free(a);
    return ret;
}
int to_double(godot_variant a, bool dealloc = true) {
    auto ret = API->godot_variant_as_real(&a);
    if (dealloc)
        free(a);
    return ret;
}

// these are simple variable types. they don't require deallocation
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

// these are complex variant/object types -- they REQUIRE deallocation!!
godot_variant to_variant_unsafe(godot_string a, bool dealloc = true) {
    godot_variant ret;
    API->godot_variant_new_string(&ret, &a);
    if (dealloc)
        free(a);
    return ret;
}
godot_variant to_variant_unsafe(const char *a) {
    // first, declare, initialize and fill a string object
    godot_string str;
    API->godot_string_new(&str);
    API->godot_string_parse_utf8(&str, a);

    // then, transfer to variant
    godot_variant ret;
    API->godot_variant_new_string(&ret, &str);

    // remember to deallocate the object!
//    if (dealloc)
        free(str);
    return ret;
}
godot_variant to_variant_unsafe(godot_array a, bool dealloc = true) {
    godot_variant ret;
    API->godot_variant_new_array(&ret, &a);
    if (dealloc)
        free(a);
    return ret;
}
godot_variant to_variant_obj(godot_object *a, bool dealloc = true) {
    godot_variant ret;
    API->godot_variant_new_object(&ret, a);
    if (dealloc)
        free(a);
    return ret;
}

godot_array to_array(godot_variant a) {
    return API->godot_variant_as_array(&a);
}
void array_push_back(godot_array *arr, const godot_variant a, bool dealloc = true) {
    API->godot_array_push_back(arr, &a);
    if (dealloc)
        free(a);
}

godot_variant debug_line_text(const char *text, int num) {
    godot_array arr = empty_array();
    array_push_back(&arr, to_variant_unsafe(text));
    array_push_back(&arr, to_variant(num));
    return to_variant_unsafe(arr);
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

    ret = API->godot_array_get(&arr, param);
    free(arr);
    return ret;
}

//////////// NATIVESCRIPT CLASS MEMBER FUNCTIONS

godot_variant get_test_string(godot_object *p_instance, void *p_method_data, void *p_globals, int p_num_args, godot_variant **p_args) {

    godot_string data;
    godot_variant ret;

    API->godot_string_new(&data);
    API->godot_string_parse_utf8(&data, "test");
    API->godot_variant_new_string(&ret, &data);
    API->godot_string_destroy(&data);

    return ret;
//    return to_variant(((globals_struct *)(p_globals))->data);
}
godot_variant get_two(godot_object *p_instance, void *p_method_data, void *p_globals, int p_num_args, godot_variant **p_args) {

    // this DOES NOT create a leak...
//    godot_string data;
//    godot_variant ret;
//
//    API->godot_string_new(&data);
//    API->godot_string_parse_utf8(&data, "test");
//    API->godot_variant_new_string(&ret, &data);
//    API->godot_string_destroy(&data);
//    return ret;


    // .....................


    // this DOES NOT create a leak...
//    godot_variant ret;
//    for (int i = 0; i < 20; ++i) {
//        godot_string data;
//        API->godot_string_new(&data); // <--- this leaves behind a "phantom" string, but we already destroy it at the end of each loop.
//        API->godot_string_parse_utf8(&data, "test");
//
//        if (i > 0) // only destroy after the first loop - you can not destroy uninitialized objects!
//            API->godot_variant_destroy(&ret); // DESTROY the variant first if already initialized!!!!
//        API->godot_variant_new_string(&ret, &data); // <--- this leaves behind a "phantom" variant, so it needs to be destroyed!!
//
//        API->godot_string_destroy(&data);
//    }


    // .....................


    // this DOES NOT create a leak...
    auto arr = empty_array();
    for (int i = 0; i < 20; ++i) {
        auto b = empty_array();
        array_push_back(&b, to_variant(i));
        array_push_back(&arr, to_variant_unsafe(b));
    }

    return to_variant_unsafe(arr);
}
godot_variant get_heartbeat(godot_object *p_instance, void *p_method_data, void *p_globals, int p_num_args, godot_variant **p_args) {
    godot_array arr = constr_godot_array(p_args, p_num_args);
    return to_variant_unsafe(arr);
}

godot_variant load_neuron_values(godot_object *p_instance, void *p_method_data, void *p_globals, int p_num_args, godot_variant **p_args) {
    godot_array data = to_array(get_param(0, p_args, p_num_args));

    if (API->godot_array_size(&data) == 0) // empty!
        return debug_line_text("no data!!", 0);

    // for each layer...
    int layers_count = API->godot_array_size(&data);
    NN.layers_count = layers_count;
    for (int i = 0; i < layers_count; ++i) {
        const godot_array layer = to_array(API->godot_array_get(&data, i));
        int neurons_this_layer = API->godot_array_size(&layer); // layer size (num. of neurons in it)

        // calculate number of weights (neurons in the next layer & prev layer)
        int neurons_next_layer = 0;
        if (i + 1 < layers_count) {
            const godot_array next_layer = to_array(API->godot_array_get(&data, i + 1));
            neurons_next_layer = API->godot_array_size(&next_layer); // layer size (num. of neurons in it)
            free(next_layer);
        }
        int neurons_prev_layer = 0;
        if (i > 0) {
            const godot_array prev_layer = to_array(API->godot_array_get(&data, i - 1));
            neurons_prev_layer = API->godot_array_size(&prev_layer); // layer size (num. of neurons in it)
            free(prev_layer);
        }

        // allocate layer memory if necessary
        NN.allocate_memory(i, neurons_this_layer, neurons_next_layer, neurons_prev_layer);

        // for each neuron in the layer...
        for (int j = 0; j < neurons_this_layer; ++j) {
            const godot_array neuron = to_array(API->godot_array_get(&layer, j));

            const int neuron_arr_size_safety_check = API->godot_array_size(&neuron);

            if (neuron_arr_size_safety_check > 0) {
                const godot_variant activation = API->godot_array_get(&neuron, 0);
                NN.set_activation(i, j, API->godot_variant_as_real(&activation));
            }
            if (neuron_arr_size_safety_check > 1) {
                const godot_variant bias = API->godot_array_get(&neuron, 1);
                NN.set_bias(i, j, API->godot_variant_as_real(&bias));
            }
            if (neuron_arr_size_safety_check > 2 && !NN.allocated) {
                const godot_array weights = to_array(API->godot_array_get(&neuron, 2));
                int weights_per_neuron_this_layer = API->godot_array_size(&weights);

                // for each synapses' weight in the layer...
                for (int k = 0; k < weights_per_neuron_this_layer; ++k) {
                    const godot_variant weight = API->godot_array_get(&weights, k);
                    NN.set_weight(i, j, k, API->godot_variant_as_real(&weight));
                    free(weight);
                }
            }

//            free(neuron);
//            free(activation);
//            free(bias);
//            free(weights);
        }
        free(layer);
    }
    free(data);

    // set up synapse caches!
    NN.update_dendrites();

    NN.allocated = true;
    return empty_variant();
//    return debug_line_text("neurons_done:", NN.neuron_total_count);
}
godot_variant fetch_single_neuron(godot_object *p_instance, void *p_method_data, void *p_globals, int p_num_args, godot_variant **p_args) {
    int l = to_int(get_param(0, p_args, p_num_args));
    int n = to_int(get_param(1, p_args, p_num_args));

    auto neuron = NN.get_neuron(l, n);

    auto arr_n = empty_array();
    array_push_back(&arr_n, to_variant(neuron->activation));
    array_push_back(&arr_n, to_variant(neuron->bias));
    array_push_back(&arr_n, to_variant(neuron->activation_GOAL_FAVORABLE));

    return to_variant_unsafe(arr_n);
}
godot_variant fetch_neuron_synapse_weights(godot_object *p_instance, void *p_method_data, void *p_globals, int p_num_args, godot_variant **p_args) {
    int l = to_int(get_param(0, p_args, p_num_args));
    int n = to_int(get_param(1, p_args, p_num_args));

    auto neuron = NN.get_neuron(l, n);

    auto arr_s = empty_array();
    for (int s = 0; s < neuron->synapses_total_count; ++s)
        array_push_back(&arr_s, to_variant(neuron->synapses[s].weight));

    return to_variant_unsafe(arr_s);
}
godot_variant fetch_neuron_synapse_single(godot_object *p_instance, void *p_method_data, void *p_globals, int p_num_args, godot_variant **p_args) {
    int l = to_int(get_param(0, p_args, p_num_args));
    int n = to_int(get_param(1, p_args, p_num_args));
    int s = to_int(get_param(2, p_args, p_num_args));

    auto neuron = NN.get_neuron(l, n);

    return to_variant(neuron->synapses[s].weight);
}

godot_variant update(godot_object *p_instance, void *p_method_data, void *p_globals, int p_num_args, godot_variant **p_args) {
    bool success = NN.update_network();
    return to_variant(success);
}
godot_variant update_backpropagation(godot_object *p_instance, void *p_method_data, void *p_globals, int p_num_args, godot_variant **p_args) {
    auto favorable_results = to_array(get_param(0, p_args, p_num_args)); // <---- this is an ARRAY containing favorable values for the final layer

    // update activation_GOAL_FAVORABLE values for the last layer (outputs)
    for (int i = 0; i < API->godot_array_size(&favorable_results); ++i) {
        double value = to_double(API->godot_array_get(&favorable_results, i));
        NN.outputs()->neurons[i].activation_GOAL_FAVORABLE = value;
        NN.outputs()->neurons[i].activation_GOAL_FAVORABLE_COUNTS = 1;
    }

    bool success = NN.update_backpropagation();
    return to_variant(success);
}
godot_variant get_answer_digit(godot_object *p_instance, void *p_method_data, void *p_globals, int p_num_args, godot_variant **p_args) {
    int answer = NN.get_answer_digit();
    double cost = NN.get_result_cost();

    auto arr = empty_array();
    array_push_back(&arr, to_variant(answer));
    array_push_back(&arr, to_variant(cost));

    return to_variant_unsafe(arr);
}

void init_nativescript_methods() {

    // register methods
    register_method("get_test_string", &get_test_string);
    register_method("get_two", &get_two);
    register_method("get_heartbeat", &get_heartbeat);
    //
    register_method("load_neuron_values", &load_neuron_values);
    register_method("fetch_single_neuron", &fetch_single_neuron);
    register_method("fetch_neuron_synapse_weights", &fetch_neuron_synapse_weights);
    register_method("fetch_neuron_synapse_single", &fetch_neuron_synapse_single);
    register_method("update", &update);
    register_method("update_backpropagation", &update_backpropagation);
    //
    register_method("get_answer_digit", &get_answer_digit);
}