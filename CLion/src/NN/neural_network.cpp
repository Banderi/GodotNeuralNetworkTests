#include "neural_network.h"
#include <cstdlib>

neural_network NN;

void neural_network::allocate_memory(int layer, int neuron_count, int next_layer_neur_count, int prev_layer_neur_count) {
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
        n->parent_dendrites = (synapse_obj**)calloc(prev_layer_neur_count, sizeof(synapse_obj*));
        n->parent_dendrites_total_count = prev_layer_neur_count;
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
                auto termination = get_neuron(l + 1, s);
                synapse->owner = neuron;
                synapse->termination = termination;
                termination->parent_dendrites[n] = synapse;
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

layer_obj *neural_network::inputs() {
    if (!allocated)
        return nullptr;
    return &layers[0];
}
layer_obj *neural_network::outputs() {
    if (!allocated)
        return nullptr;
    return &layers[layers_count - 1];
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
bool neural_network::update_backpropagation() {

    // for each layer (starting from the outputs, backwards)
    for (int l = layers_count - 1; l > 0; --l) {
        auto layer = layers[l];

        // these change PER LAYER
        double BIAS_coeff = 0.0;
        double WEIGHT_coeff = 0.6;
        double ACTIVATION_coeff = 0.7;
        if (l < layers_count - 1) {
            BIAS_coeff = 0.3;
            WEIGHT_coeff = 0.5;
            ACTIVATION_coeff = 0.4;
        }
        if (l == 1) {
            BIAS_coeff = 0.7;
            WEIGHT_coeff = 0.9;
            ACTIVATION_coeff = 0.0; // useless for the second layer (the first are inputs, so the propagation stops)
        }

        // for each neuron
        for (int n = 0; n < layer.neuron_total_count; ++n) {
            auto neuron = &layer.neurons[n];

            unsigned long long total_dendrites = neuron->parent_dendrites_total_count;
            double activ_goal_gradient = (neuron->activation_GOAL_FAVORABLE / (double)neuron->activation_GOAL_FAVORABLE_COUNTS) - neuron->activation; // this is ultimately the goal of the child neuron. how much should the total be changed by??
            double activ_goal_gradient_per_synapse = activ_goal_gradient / (double)total_dendrites; // this is the score goal, but scaled by the number of parent neurons.



            // child's BIAS
            neuron->bias = 0;
//            neuron->bias = score_gradient * BIAS_coeff - (double)total_dendrites;
////            neuron->bias += score_gradient * BIAS_coeff;
//            if (neuron->bias > 100.0) // clamp BIAS
//                neuron->bias = 100.0;
//            if (neuron->bias < -100.0)
//                neuron->bias = -100.0;


            // for each synapse (backwards)
            for (int s = 0; s < total_dendrites; ++s) {
                auto synapse = neuron->parent_dendrites[s];
                auto parent = synapse->owner;

                // TODO: MAGIC!

//                neuron->bias = 0;
//                // child's BIAS
////                neuron->bias += score_gradient * BIAS_coeff;
//                if (neuron->bias > 100.0) // clamp BIAS
//                    neuron->bias = 100.0;
//                if (neuron->bias < -100.0)
//                    neuron->bias = -100.0;
//
//                // synapse's WEIGHT
//                synapse->weight += score_gradient_per_synapse * (parent->activation+0.00) * WEIGHT_coeff;
//                if (synapse->weight > 1.0) // clamp WEIGHT
//                    synapse->weight = 1.0;
//                if (synapse->weight < -1.0)
//                    synapse->weight = -1.0;
//
//                // parent's ACTIVATION
//                parent->activation_GOAL_FAVORABLE = parent->activation; // default
//                parent->activation_GOAL_FAVORABLE = parent->activation + score_gradient_per_synapse * ACTIVATION_coeff;
////                parent->activation_GOAL_FAVORABLE = 1.0;


                // TODO: MAGIC!

                // synapse's WEIGHT
//                synapse->weight = 0.0;
                synapse->weight += activ_goal_gradient_per_synapse * parent->activation;// * WEIGHT_coeff;
                if (synapse->weight > 1.0) // clamp WEIGHT
                    synapse->weight = 1.0;
                if (synapse->weight < -1.0)
                    synapse->weight = -1.0;

                // parent's ACTIVATION
//                parent->activation_GOAL_FAVORABLE = parent->activation; // default
                double parent_new_goal = parent->activation + activ_goal_gradient * synapse->weight;
                parent->activation_GOAL_FAVORABLE += parent_new_goal;// * ACTIVATION_coeff;
                parent->activation_GOAL_FAVORABLE_COUNTS++;
            }
        }
    }
    return true;
}

double neural_network::get_result_cost() {
    double total_cost = 0.0;
    for (int n = 0; n < outputs()->neuron_total_count; ++n) {
        neuron_obj *neuron = &outputs()->neurons[n];
        double diff = neuron->activation - neuron->activation_GOAL_FAVORABLE;
        total_cost += (diff * diff);
    }
    return total_cost;
}
int neural_network::get_answer_digit() {
    struct {
        int digit = -2;
        double activation = 0.0;
    } n_highest, n_second_highest;

    for (int n = 0; n < outputs()->neuron_total_count; ++n) {
        const neuron_obj *check = &outputs()->neurons[n];
        if (check->activation > n_highest.activation) {
            n_second_highest = n_highest;
            n_highest.activation = check->activation;
            n_highest.digit = n;
        }
    }

    if (n_highest.activation > 0.5) { // threshold for number identification
        if (n_highest.activation - n_second_highest.activation > 0.2) // threshold for certainty
            return n_highest.digit; // fairly confident!
        else
            return -1; // unsure between multiple numbers.
    } else
        return -2; // nothing close to a number identified.
}