fasm main.asm && gcc -no-pie main.o -L. -lraylib -lm -ldl -lpthread -lGL -lrt -o main.out && ./main.out
