#include "neural_network.h"

neural_network NN;

//bool allocated = false;
//int layers_count = 0;
//int neuron_total_count = 0;
//vector<vector<neuron>> layers; // <-- an array of arrays of neurons -- each layer can contain many neurons.

void neural_network::preallocate(int layer, int neuron_count, int weights_for_next_layer) {
    // skip if already allocated.
//    if (allocated)
//        return;
//
//    if (layers.size() < layer + 1)
//        layers.resize(layer + 1); // make space for a new layer, first!
//
//    auto curr_layer = layers.at(layer);
//    curr_layer.resize(neuron_count);
//
//    for (auto n : curr_layer) // Woooooaaaah we living in the FUTURE!!
//        n.weights.resize(weights_for_next_layer); // oh boy...
}
void neural_network::set_as_fully_allocated() {
    allocated = true;
}

neuron neural_network::get_neuron(int layer, int index) {
//    return layers.at(layer).at(index);
}
void neural_network::set_activation(int layer, int index, double a) {

}
void neural_network::set_bias(int layer, int index, double b) {

}
void neural_network::set_weight(int layer, int index, int w_index, double weight) {

}

void neural_network::update_network() {

}