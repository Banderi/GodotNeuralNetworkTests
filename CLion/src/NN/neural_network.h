#ifndef CLION_NEURAL_NETWORK_H
#define CLION_NEURAL_NETWORK_H

// NEURAL NETWORK!
typedef struct neuron {
    float activation = 0.0;
    float bias = 0.0;
    float *weights = nullptr; // array
    unsigned long long weights_total_count = 0;
} neuron;

typedef struct layer {
    bool allocated = false;
    unsigned int neuron_total_count = 0;
    neuron *neurons = nullptr; // array
} layer;

class neural_network {
public:
    bool allocated = false;
    layer layers[20]; // <-- an array of arrays of neurons -- each layer can contain many neurons.

    int layers_count = 0;
    unsigned long long neuron_total_count = 0;

    void allocate_memory(int layer, int neuron_count, int weights_count);

    neuron get_neuron(int layer, int index);
    void set_activation(int layer, int index, float a);
    void set_bias(int layer, int index, float b);
    void set_weight(int layer, int index, int w_index, float weight);

    void update_network(); // here the magic happens!!!!!!!
};

#ifdef __cplusplus
#define CEXTERN extern "C"
#else
#define CEXTERN
#endif

CEXTERN neural_network NN;


#endif //CLION_NEURAL_NETWORK_H
