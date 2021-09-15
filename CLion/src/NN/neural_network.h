#ifndef CLION_NEURAL_NETWORK_H
#define CLION_NEURAL_NETWORK_H

// NEURAL NETWORK!

typedef struct synapse_obj synapse_obj;

typedef struct neuron_obj {
    double potential = 0.0;
    double activation = 0.0;
    double bias = 0.0;
    synapse_obj *synapses = nullptr; // array
    unsigned long long synapses_total_count = 0;
} neuron_obj;

typedef struct synapse_obj {
    double weight = 0.0;
    neuron_obj *termination{};
} synapse_obj;

typedef struct layer_obj {
    bool allocated = false;
    unsigned int neuron_total_count = 0;
    neuron_obj *neurons = nullptr; // array
} layer_obj;

class neural_network {
public:
    bool allocated = false;
    layer_obj layers[20]; // <-- an array of arrays of neurons -- each layer can contain many neurons.

    int layers_count = 0;
    unsigned long long neuron_total_count = 0;

    void allocate_memory(int layer, int neuron_count, int next_layer_neur_count);
    void update_dendrites();

    neuron_obj *get_neuron(int layer, int index);
    void set_activation(int layer, int index, double a);
    void set_bias(int layer, int index, double b);
    void set_weight(int layer, int index, int w_index, double weight);

    bool update_network(); // here the magic happens!!!!!!!
};

#ifdef __cplusplus
#define CEXTERN extern "C"
#else
#define CEXTERN
#endif

CEXTERN neural_network NN;


#endif //CLION_NEURAL_NETWORK_H
