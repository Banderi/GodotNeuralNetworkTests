#include "neural_network.h"
#include <cstdlib>

neural_network NN;

void neural_network::allocate_memory(int layer, int neuron_count, int next_layer_neur_count) {
    // skip if already allocated.
    if (allocated)
        return;

    // max 20 layers... for now?
    if (layer >= 20)
        return;

    // layer is already allocated!
    if (layers[layer].allocated)
        return;

    // allocate memory for neurons
    layers[layer].neurons = (neuron_obj*)calloc(neuron_count, sizeof(neuron_obj));
    layers[layer].neuron_total_count = neuron_count;

    // allocate memory for weights
    for (int i = 0; i < neuron_count; ++i) {
        neuron_obj *n = &layers[layer].neurons[i];
        n->synapses = (synapse_obj*)calloc(next_layer_neur_count, sizeof(synapse_obj)); // oh boy...
        n->synapses_total_count = next_layer_neur_count;
    }

    neuron_total_count += neuron_count;

    // set layer as allocated.
    layers[layer].allocated = true;
}
void neural_network::update_dendrites() {

    // WARNING: this function ASSUMES that the indexes are CORRECT.

    // for each layer
    for (int l = 0; l < layers_count; ++l) {
        auto layer = &layers[l];
        // for each neuron
        for (int n = 0; n < layer->neuron_total_count; ++n) {
            auto neuron = &layer->neurons[n];

            // for each synapse
            for (int s = 0; s < neuron->synapses_total_count; ++s) {
                auto synapse = &neuron->synapses[s];
                synapse->termination = get_neuron(l + 1, s);
                int a = 1;
            }
        }
    }
}

neuron_obj *neural_network::get_neuron(int layer, int index) {
    return &layers[layer].neurons[index];
}
void neural_network::set_activation(int layer, int index, double a) {
    auto l = &layers[layer];
    if (index >= l->neuron_total_count)
        return;
    auto n = &l->neurons[index];
    n->activation = a;
}
void neural_network::set_bias(int layer, int index, double b) {
    auto l = &layers[layer];
    if (index >= l->neuron_total_count)
        return;
    auto n = &l->neurons[index];
    n->bias = b;
}
void neural_network::set_weight(int layer, int index, int w_index, double weight) {
    auto l = &layers[layer];
    auto n = &l->neurons[index];
    if (w_index >= n->synapses_total_count)
        return;
    n->synapses[w_index].weight = weight;
}

enum {
    NN_DIRECT,
    NN_CACHED_POINTERS,
    NN_MATRIX_MUL,
};

bool neural_network::update_network() {

    int method = NN_DIRECT;
    switch (method) {
        case NN_DIRECT:
        case NN_CACHED_POINTERS:

            // for each layer
            for (int l = 0; l < layers_count; ++l) {
                auto layer = &layers[l];
                // for each neuron
                for (int n = 0; n < layer->neuron_total_count; ++n) {
                    auto neuron = &layer->neurons[n];

                    ////// sum up potential!
                    if (l > 0) {
                        neuron->activation = neuron->bias + neuron->potential;

                        // ReLU
                        if (neuron->activation < 0.0)
                            neuron->activation = 0.0;

                        // reset potential
                        neuron->potential = 0.0;
                    }




                    // for each synapse
                    for (int s = 0; s < neuron->synapses_total_count; ++s) {
                        auto synapse = &neuron->synapses[s];
                        synapse->termination->potential += neuron->activation * synapse->weight;
                    }
                }
            }
            break;
        case NN_MATRIX_MUL:

            // TODO




            break;
    }
    return true;
}