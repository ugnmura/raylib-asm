format ELF64

public    main

extrn     InitWindow
extrn     WindowShouldClose
extrn     BeginDrawing
extrn     ClearBackground
extrn     DrawText
extrn     EndDrawing
extrn     DrawRectangle
extrn     SetTargetFPS
extrn     exit
extrn     rand
extrn     srand
extrn     time

WINDOW_WIDTH equ 800
WINDOW_HEIGHT equ 600
BALL_COUNT equ 10

struc ball_t 
{
    .x dd 0
    .y dd 0
    .dx dd 0
    .dy dd 0
    .r  dd 0
    .col dd 0
}

virtual at 0
  ball_t.dummy    ball_t
  ball_t.x        = ball_t.dummy.x
  ball_t.y        = ball_t.dummy.y
  ball_t.dx       = ball_t.dummy.dx
  ball_t.dy       = ball_t.dummy.dy
  ball_t.r        = ball_t.dummy.r
  ball_t.col      = ball_t.dummy.col
  ball_t.sizeof   = $
end virtual


section '.text' executable
main:
  push    rbp
  mov     rbp, rsp

  xor     rdi, rdi
  call    time
  mov     rdi, rax
  call    srand

  call    rand

  mov     rdi, WINDOW_WIDTH
  mov     rsi, WINDOW_HEIGHT
  mov     rdx, title
  call    InitWindow

  mov     rdi, 60
  call    SetTargetFPS
  
  mov     rax, balls
init_balls:
  mov     rdi, rax
  push    rax
  call    init_ball
  pop     rax

  add     rax, ball_t.sizeof
  cmp     rax, balls + (BALL_COUNT * ball_t.sizeof)
  jl      init_balls

draw:
  call    BeginDrawing

  mov     rdi, 0xFF000000
  call    ClearBackground

  call    draw_message


  mov     rax, balls
draw_balls:
  mov     rdi, rax
  push    rax
  call    move_ball
  pop     rax

  mov     rdi, rax
  push    rax
  call    draw_ball
  pop     rax

  add     rax, ball_t.sizeof
  cmp     rax, balls + (BALL_COUNT * ball_t.sizeof)
  jl      draw_balls


  call    EndDrawing

  call    WindowShouldClose
  cmp     rax, 0
  je      draw

  mov     rsp, rbp
  pop     rbp
  xor     rax, rax
  ret

draw_message:
  mov     rdi, title
  mov     rsi, 100
  mov     rdx, 100 
  mov     rcx, 30
  mov     r8, 0xFFFFFFFF
  call    DrawText
  ret 

init_ball:
  push    rdi
  call    rand
  pop     rdi
  and     rax, 0xFF
  mov     [rdi + ball_t.x], rax

  push    rdi
  call    rand
  pop     rdi
  and     rax, 0xFF
  mov     [rdi + ball_t.y], rax

  push    rdi
  call    rand
  pop     rdi
  and     rax, 0xF
  mov     [rdi + ball_t.dx], rax

  push    rdi
  call    rand
  pop     rdi
  and     rax, 0xF
  mov     [rdi + ball_t.dy], rax
  
  push    rdi
  call    rand
  pop     rdi
  and     rax, 0x7F
  mov     [rdi + ball_t.r], rax

  push    rdi
  call    rand
  pop     rdi
  or      eax, 0xFF000000
  mov     [rdi + ball_t.col], rax

  ret


draw_ball:
  mov     rax, rdi
  mov     edi, [rax + ball_t.x]
  mov     esi, [rax + ball_t.y]
  mov     edx, [rax + ball_t.r]
  mov     ecx, [rax + ball_t.r]
  mov     r8, [rax + ball_t.col]
  call    DrawRectangle
  ret

move_ball:
  mov     eax, [rdi + ball_t.dx]
  add     dword [rdi + ball_t.x], eax
  mov     eax, [rdi + ball_t.dy]
  add     dword [rdi + ball_t.y], eax

  mov     eax, WINDOW_WIDTH 
  sub     eax, [rdi + ball_t.r]
  cmp     dword [rdi + ball_t.x], eax
  jg      .reflect_dx
  cmp     dword [rdi + ball_t.x], 0
  jl      .reflect_dx
  jmp     .dx_done
.reflect_dx:
  neg     dword [rdi + ball_t.dx]
.dx_done:

  mov     eax, WINDOW_HEIGHT
  sub     eax, [rdi + ball_t.r]
  cmp     dword [rdi + ball_t.y], eax
  jg      .reflect_dy
  cmp     dword [rdi + ball_t.y], 0
  jl      .reflect_dy
  jmp     .dy_done
.reflect_dy:
  neg     dword [rdi + ball_t.dy]
.dy_done:
  ret

section '.data' executable

title db "Hello, Raylib from flat assembler!", 0

balls:
  times (BALL_COUNT * ball_t.sizeof) db 0
