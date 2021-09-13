#include "neural_network.h"
#include <cstdlib>

neural_network NN;

void neural_network::allocate_memory(int layer, int neuron_count, int weights_count) {
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
    layers[layer].neurons = (neuron*)calloc(neuron_count, sizeof(neuron));
    layers[layer].neuron_total_count = neuron_count;

    // allocate memory for weights
    for (int i = 0; i < neuron_count; ++i) {
        neuron *n = &layers[layer].neurons[i];
        n->weights = (float*)calloc(weights_count, sizeof(float)); // oh boy...
        n->weights_total_count = weights_count;
    }

    neuron_total_count += neuron_count;

    // set layer as allocated.
    layers[layer].allocated = true;
}

neuron neural_network::get_neuron(int layer, int index) {
    return layers[layer].neurons[index];
}
void neural_network::set_activation(int layer, int index, float a) {
    auto l = &layers[layer];
    if (index >= l->neuron_total_count)
        return;
    auto n = &l->neurons[index];
    n->activation = a;
}
void neural_network::set_bias(int layer, int index, float b) {
    auto l = &layers[layer];
    if (index >= l->neuron_total_count)
        return;
    auto n = &l->neurons[index];
    n->bias = b;
}
void neural_network::set_weight(int layer, int index, int w_index, float weight) {
    auto l = &layers[layer];
    auto n = &l->neurons[index];
    if (w_index >= n->weights_total_count)
        return;
    n->weights[w_index] = weight;
}

void neural_network::update_network() {
    // TODO
}