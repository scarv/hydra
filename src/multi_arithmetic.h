int multi_add(const void *a, const void *b, void *res, int n_words);
int multi_sub(const void *a, const void *b, void *res, int n_words);
void multi_mult(const void *a, const void *b, void *res, int n_words);
void multi_xor(const void *a, const void *b, void *res, int n_words);

int multi_add_comp(const void *a, const void *b, void *res, int n_words, int n_cores);
void multi_xor_comp(const void *a, const void *b, void *res, int n_words, int n_cores);
