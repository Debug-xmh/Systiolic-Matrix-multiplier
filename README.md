Thinking about the format alignment of input and output on the basis of systolic: I used a simple design to move the overall data down or right at the time of computation, so that there is no need to add additional registers or read conversion circuits, and only need to change the bit width of the data flowing to the right to the result bit width, which can realize the multiplexing of the array.

The following is the data flow at the input and output moments, and this design uses a custom unsigned pipeline multiplier

![TPU_v(1)](https://github.com/Debug-xmh/Systiolic-Matrix-multiplier/assets/73116861/a47f258e-2b72-4134-b11e-f48757f27595)
![TPU_v(2)](https://github.com/Debug-xmh/Systiolic-Matrix-multiplier/assets/73116861/ca0e71e9-9930-4354-a4bb-383e8f06c3bb)
![TPU_v(3)](https://github.com/Debug-xmh/Systiolic-Matrix-multiplier/assets/73116861/3cb8ccd8-8d77-4b08-ade8-3dc58cad6d09)
![TPU_v(4)](https://github.com/Debug-xmh/Systiolic-Matrix-multiplier/assets/73116861/d1f771ce-c6bc-490d-9af7-d6748da82b78)
![TPU_v(5)](https://github.com/Debug-xmh/Systiolic-Matrix-multiplier/assets/73116861/59b6b4c8-7243-4e9c-a57a-b99a80430ca3)
![TPU_v(6)](https://github.com/Debug-xmh/Systiolic-Matrix-multiplier/assets/73116861/072a8e64-6ea9-4c79-aaa7-960db45291f8)
