#ifndef CLION_NEURAL_NETWORK_H
#define CLION_NEURAL_NETWORK_H

#include <vector>
using namespace std;

// NEURAL NETWORK!
typedef struct neuron {
    double activation;
    double bias;
    vector<double> weights;
} neuron;

//double neurons[10000]; // NN test!
//int layers_count = 0;
//int neuron_total_count = 0;
//int neurons_per_layer[20] = {};
//int starting_neuron_per_layer[20] = {};

class neural_network {
private:
    bool allocated = false;
    int layers_count = 0;
    int neuron_total_count = 0;
//    vector<vector<neuron>> layers; // <-- an array of arrays of neurons -- each layer can contain many neurons.

public:
    void preallocate(int layer, int neuron_count, int weights_for_next_layer);
    void set_as_fully_allocated();

    neuron get_neuron(int layer, int index);
    void set_activation(int layer, int index, double a);
    void set_bias(int layer, int index, double b);
    void set_weight(int layer, int index, int w_index, double weight);

    void update_network(); // here the magic happens!!!!!!!
};

#ifdef __cplusplus
#define CEXTERN extern "C"
#else
#define CEXTERN
#endif
CEXTERN neural_network NN;

//neural_network NN_hidden;

//CEXTERN void *NN;


#endif //CLION_NEURAL_NETWORK_H
