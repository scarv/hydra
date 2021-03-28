#define NUM_WORDS 16
#define NUM_BYTES (NUM_WORDS << 2)
#define NUM_BITS  (NUM_WORDS << 5)

const unsigned int x[NUM_WORDS] = {0x3A1AF8FC, 0xA2D9268C, 0x822227B2, 0xA6A4CB50,
                                   0x8996CA2C, 0x85500FA8, 0xB7AB363B, 0xAD992E92,
                                   0x8FD59971, 0x67859FEC, 0xA68B501B, 0x7EC21DDE,
                                   0x84D8B2A4, 0x7713980C, 0x2F53DAB3, 0x8CAA9499};

const unsigned int y[NUM_WORDS] = {0x804AA03A, 0x68EC5EEF, 0x8FB4B76B, 0x5DC271C7,
                                   0x7EDDB4D8, 0x33E03FA8, 0x3A620BA3, 0xBED15079,
                                   0x9B562908, 0x4AB8171A, 0xBD3F2ECB, 0x8FCBD263,
                                   0xC9916F8B, 0x519C9550, 0x8FA624D3, 0xB8DB578F};

const unsigned int N[NUM_WORDS] = {0x6A9F68D9, 0x6CF5BC55, 0x3758566C, 0xB64BC4FE,
                                   0x41C81734, 0xA79A9099, 0x70BE0834, 0xA6C77975,
                                   0xCC0DBB42, 0xB58209DD, 0x8D1587D9, 0x9B7A90B7,
                                   0x493479BD, 0xD0BDB037, 0xE74F36FE, 0xDFA496E7};

unsigned int r[NUM_WORDS * 2] = {0};

// Pre-calculated correct results
const unsigned int x_xor_y[NUM_WORDS] = {0xBA5058C6, 0xCA357863, 0x0D9690D9, 0xFB66BA97,
                                         0xF74B7EF4, 0xB6B03000, 0x8DC93D98, 0x13487EEB,
                                         0x1483B079, 0x2D3D88F6, 0x1BB47ED0, 0xF109CFBD,
                                         0x4D49DD2F, 0x268F0D5C, 0xA0F5FE60, 0x3471C316};

const unsigned int x_plus_y[NUM_WORDS + 1] = {0xBA659936, 0x0BC5857B, 0x11D6DF1E, 0x04673D18,
                                              0x08747F05, 0xB9304F51, 0xF20D41DE, 0x6C6A7F0B,
                                              0x2B2BC27A, 0xB23DB707, 0x63CA7EE6, 0x0E8DF042,
                                              0x4E6A2230, 0xC8B02D5D, 0xBEF9FF86, 0x4585EC28, 0x1};

const unsigned int y_minus_x[NUM_WORDS] = {0x462FA73E, 0xC6133863, 0x0D928FB8, 0xB71DA677,
                                           0xF546EAAB, 0xAE902FFF, 0x82B6D567, 0x113821E6,
                                           0x0B808F97, 0xE332772E, 0x16B3DEAF, 0x1109B485,
                                           0x44B8BCE7, 0xDA88FD44, 0x60524A1F, 0x2C30C2F6};

const unsigned int x_times_y[NUM_WORDS * 2] = {0xFE91E918, 0xEDCBA3A3, 0x4BD17FE3, 0x024220CB,
                                               0x79208C95, 0x2FE2D9CB, 0x5C2BD9FC, 0xF23B4D2A,
                                               0xF1551555, 0x61B3059A, 0x5B22A92E, 0x2A4FE873,
                                               0x1C415494, 0x954E8FAE, 0x9131F8BD, 0xA7157E36,
                                               0xFABC6B6E, 0x871225D6, 0x3C9F9A48, 0x2B2CF3D3,
                                               0x7B28A7D8, 0xEEE1FED2, 0xC97BE8DF, 0xB1F7F318,
                                               0x7DC899F0, 0x8AD08BF7, 0x417FD12B, 0x21F68304,
                                               0xCD710D84, 0x0B61AA39, 0x13C7666E, 0x659320D8};

const unsigned int x_exp_y_mod_N[NUM_WORDS] = {0x2C2F63DB, 0xE6769ADE, 0xE7FE9BE0, 0xC65DC658,
                                               0xFDF44097, 0xBF25B213, 0xDFDDFFB9, 0x64B056A3,
                                               0x881BF931, 0x992D2398, 0x9A520CA3, 0xDDF79D6E,
                                               0x5BBA0A42, 0x1A1057A9, 0xB0A2F1E4, 0x5649FF79};

const unsigned char aes_key[] = { 0x2b, 0x7e, 0x15, 0x16, 0x28, 0xae, 0xd2, 0xa6, 0xab, 0xf7, 0x15, 0x88, 0x09, 0xcf, 0x4f, 0x3c };
const unsigned char aes_out[] = { 0x3a, 0xd7, 0x7b, 0xb4, 0x0d, 0x7a, 0x36, 0x60, 0xa8, 0x9e, 0xca, 0xf3, 0x24, 0x66, 0xef, 0x97 };

unsigned char aes_in[]  = { 0x6b, 0xc1, 0xbe, 0xe2, 0x2e, 0x40, 0x9f, 0x96, 0xe9, 0x3d, 0x7e, 0x11, 0x73, 0x93, 0x17, 0x2a };