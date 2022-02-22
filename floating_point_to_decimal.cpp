// C++ program to convert IEEE 754 floating point representation into decimal value

#include <bits/stdc++.h>
using namespace std;

typedef union
{

    float f;
    struct
    {

        // Order is important.
        // Here the members of the union data structure
        // use the same memory (32 bits).
        // The ordering is taken
        // from the LSB to the MSB.
        unsigned int mantissa : 23;
        unsigned int exponent : 8;
        unsigned int sign : 1;

    } raw;
} myfloat;

// Function to convert a binary array
// to the corresponding integer
unsigned int convertToInt(unsigned int *arr, int low, int high)
{
    unsigned int f = 0, i;
    for (i = high; i >= low; i--)
    {
        f = f + arr[i] * pow(2, high - i);
    }
    return f;
}

// Driver Code
int main()
{

    // Get the 32-bit floating point number
    unsigned int ieee[32] = {1,
                             1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1,
                             0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                             0, 0, 0, 0, 0, 0, 0, 0, 0};

    myfloat var;

    // Convert the least significant
    // mantissa part (23 bits)
    // to corresponding decimal integer
    unsigned int f = convertToInt(ieee, 9, 31);

    // Assign integer representation of mantissa
    var.raw.mantissa = f;

    // Convert the exponent part (8 bits)
    // to a corresponding decimal integer
    f = convertToInt(ieee, 1, 8);

    // Assign integer representation
    // of the exponent
    var.raw.exponent = f;

    // Assign sign bit
    var.raw.sign = ieee[0];

    cout << "The float value of the given IEEE-754 representation is : \n";
    cout << fixed << setprecision(6) << var.f << endl;
    return 0;
}

// This code is contributed by ShubhamSingh10
// Taken from geeks for geeks
