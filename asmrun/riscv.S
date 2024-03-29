/***********************************************************************/
/*                                                                     */
/*                                OCaml                                */
/*                                                                     */
/*               Nicolas Ojeda Bar <n.oje.bar@gmail.com>               */
/*                                                                     */
/*  Copyright 2017 Institut National de Recherche en Informatique et   */
/*  en Automatique.  All rights reserved.  This file is distributed    */
/*  under the terms of the GNU Library General Public License, with    */
/*  the special exception on linking described in file ../LICENSE.     */
/*                                                                     */
/***********************************************************************/

/* Asm part of the runtime system, RISC-V processor, 64-bit mode */
/* Must be preprocessed by cpp */

#define TRAP_PTR s1
#define ALLOC_PTR s10
#define ALLOC_LIMIT s11
#define TMP0 t0
#define TMP1 t1
#define ARG t2

#if defined(MODEL_riscv64)
#define store sd
#define load ld
#define WSZ 8
#else
#define store sw
#define load lw
#define WSZ 4
#endif

#if defined(__PIC__)
        .option pic
#else
        .option nopic
#endif

        .section        .text
/* Invoke the garbage collector. */

        .globl  caml_system__code_begin
caml_system__code_begin:

        .align  2
        .globl  caml_call_gc
        .type   caml_call_gc, @function
caml_call_gc:
        /* Record return address */
        store   ra, caml_last_return_address, TMP0
        /* Record lowest stack address */
        mv      TMP1, sp
        store   sp, caml_bottom_of_stack, TMP0
.Lcaml_call_gc:
        /* Set up stack space, saving return address */
        /* (1 reg for RA, 1 reg for FP, 21 allocatable int regs, 20 caller-save float regs) * 8 */
        /* + 1 for alignment */
        addi    sp, sp, -0x160
        mv      s0, sp
        store   ra, 0x8(sp)
        store   s0, 0x0(sp)
        /* Save allocatable integer registers on the stack,
           in the order given in proc.ml */
        store   a0, 0x10(sp)
        store   a1, 0x18(sp)
        store   a2, 0x20(sp)
        store   a3, 0x28(sp)
        store   a4, 0x30(sp)
        store   a5, 0x38(sp)
        store   a6, 0x40(sp)
        store   a7, 0x48(sp)
        store   s2, 0x50(sp)
        store   s3, 0x58(sp)
        store   s4, 0x60(sp)
        store   s5, 0x68(sp)
        store   s6, 0x70(sp)
        store   s7, 0x78(sp)
        store   s8, 0x80(sp)
        store   s9, 0x88(sp)
        store   t2, 0x90(sp)
        store   t3, 0x98(sp)
        store   t4, 0xa0(sp)
        store   t5, 0xa8(sp)
        store   t6, 0xb0(sp)
        /* Save caller-save floating-point registers on the stack
           (callee-saves are preserved by caml_garbage_collection) */
        fsd     ft0, 0xb8(sp)
        fsd     ft1, 0xc0(sp)
        fsd     ft2, 0xc8(sp)
        fsd     ft3, 0xd0(sp)
        fsd     ft4, 0xd8(sp)
        fsd     ft5, 0xe0(sp)
        fsd     ft6, 0xe8(sp)
        fsd     ft7, 0xf0(sp)
        fsd     fa0, 0xf8(sp)
        fsd     fa1, 0x100(sp)
        fsd     fa2, 0x108(sp)
        fsd     fa3, 0x110(sp)
        fsd     fa4, 0x118(sp)
        fsd     fa5, 0x120(sp)
        fsd     fa6, 0x128(sp)
        fsd     fa7, 0x130(sp)
        fsd     ft8, 0x138(sp)
        fsd     ft9, 0x140(sp)
        fsd     ft9, 0x148(sp)
        fsd     ft10, 0x150(sp)
        fsd     ft11, 0x158(sp)
        /* Store pointer to saved integer registers in caml_gc_regs */
        addi    TMP1, sp, 16
        store   TMP1, caml_gc_regs, TMP0
        /* Save current allocation pointer for debugging purposes */
        store   ALLOC_PTR, caml_young_ptr, TMP0
        /* Save trap pointer in case an exception is raised during GC */
        store   TRAP_PTR, caml_exception_pointer, TMP0
        /* Call the garbage collector */
        call    caml_garbage_collection
        /* Restore registers */
        load    a0, 0x10(sp)
        load    a1, 0x18(sp)
        load    a2, 0x20(sp)
        load    a3, 0x28(sp)
        load    a4, 0x30(sp)
        load    a5, 0x38(sp)
        load    a6, 0x40(sp)
        load    a7, 0x48(sp)
        load    s2, 0x50(sp)
        load    s3, 0x58(sp)
        load    s4, 0x60(sp)
        load    s5, 0x68(sp)
        load    s6, 0x70(sp)
        load    s7, 0x78(sp)
        load    s8, 0x80(sp)
        load    s9, 0x88(sp)
        load    t2, 0x90(sp)
        load    t3, 0x98(sp)
        load    t4, 0xa0(sp)
        load    t5, 0xa8(sp)
        load    t6, 0xb0(sp)
        fld     ft0, 0xb8(sp)
        fld     ft1, 0xc0(sp)
        fld     ft2, 0xc8(sp)
        fld     ft3, 0xd0(sp)
        fld     ft4, 0xd8(sp)
        fld     ft5, 0xe0(sp)
        fld     ft6, 0xe8(sp)
        fld     ft7, 0xf0(sp)
        fld     fa0, 0xf8(sp)
        fld     fa1, 0x100(sp)
        fld     fa2, 0x108(sp)
        fld     fa3, 0x110(sp)
        fld     fa4, 0x118(sp)
        fld     fa5, 0x120(sp)
        fld     fa6, 0x128(sp)
        fld     fa7, 0x130(sp)
        fld     ft8, 0x138(sp)
        fld     ft9, 0x140(sp)
        fld     ft9, 0x148(sp)
        fld     ft10, 0x150(sp)
        fld     ft11, 0x158(sp)
        /* Reload new allocation pointer and allocation limit */
        load    ALLOC_PTR, caml_young_ptr
        load    ALLOC_LIMIT, caml_young_limit
        /* Free stack space and return to caller */
        load    ra, 0x8(sp)
        load    s0, 0x0(sp)
        addi    sp, sp, 0x160
        ret
        .size   caml_call_gc, .-caml_call_gc

/* Call a C function from OCaml */
/* Function to call is in ARG */

        .align  2
        .globl  caml_c_call
        .type   caml_c_call, @function
caml_c_call:
        /* Preserve return address in callee-save register s2 */
        mv      s2, ra
        /* Record lowest stack address and return address */
        store   ra, caml_last_return_address, TMP0
        store   sp, caml_bottom_of_stack, TMP0
        /* Make the exception handler alloc ptr available to the C code */
        store   ALLOC_PTR, caml_young_ptr, TMP0
        store   TRAP_PTR, caml_exception_pointer, TMP0
        /* Call the function */
        jalr    ARG
        /* Reload alloc ptr and alloc limit */
        load    ALLOC_PTR, caml_young_ptr
        load    ALLOC_LIMIT, caml_young_limit
        /* Return */
        jr      s2
        .size   caml_c_call, .-caml_c_call

/* Raise an exception from OCaml */
        .align  2
        .globl  caml_raise_exn
        .type   caml_raise_exn, @function
caml_raise_exn:
        /* Test if backtrace is active */
        lw      TMP1, caml_backtrace_active
        bnez    TMP1, 2f
1:      /* Cut stack at current trap handler */
        mv      sp, TRAP_PTR
        /* Pop previous handler and jump to it */
        load    TMP1, 8(sp)
        load    TRAP_PTR, 0(sp)
        addi    sp, sp, 16
        jr      TMP1
2:      /* Preserve exception bucket in callee-save register s2 */
        mv      s2, a0
        /* Stash the backtrace */
        mv      a1, ra
        mv      a2, sp
        mv      a3, TRAP_PTR
        call    caml_stash_backtrace
        /* Restore exception bucket and raise */
        mv      a0, s2
        j       1b
        .size   caml_raise_exn, .-caml_raise_exn

        .globl  caml_reraise_exn
        .type   caml_reraise_exn, @function

/* Raise an exception from C */

        .align  2
        .globl  caml_raise_exception
        .type   caml_raise_exception, @function
caml_raise_exception:
        load    TRAP_PTR, caml_exception_pointer
        load    ALLOC_PTR, caml_young_ptr
        load    ALLOC_LIMIT, caml_young_limit
        lw      TMP1, caml_backtrace_active
        bnez    TMP1, 2f
1:      /* Cut stack at current trap handler */
        mv      sp, TRAP_PTR
        load    TMP1, 8(sp)
        load    TRAP_PTR, 0(sp)
        addi    sp, sp, 16
        jr      TMP1
2:      /* Preserve exception bucket in callee-save register s2 */
        mv      s2, a0
        load    a1, caml_last_return_address
        load    a2, caml_bottom_of_stack
        mv      a3, TRAP_PTR
        call    caml_stash_backtrace
        mv      a0, s2
        j       1b
        .size   caml_raise_exception, .-caml_raise_exception

/* Start the OCaml program */

        .align  2
        .globl  caml_start_program
        .type   caml_start_program, @function
caml_start_program:

        la      ARG, caml_program
        /* Code shared with caml_callback* */
        /* Address of OCaml code to call is in ARG */
        /* Arguments to the OCaml code are in a0 ... a7 */
.Ljump_to_caml:
        /* Set up stack frame and save callee-save registers */
        addi    sp, sp, -0xd0
        store   ra, 0xc0(sp)
        store   s0, 0x0(sp)
        store   s1, 0x8(sp)
        store   s2, 0x10(sp)
        store   s3, 0x18(sp)
        store   s4, 0x20(sp)
        store   s5, 0x28(sp)
        store   s6, 0x30(sp)
        store   s7, 0x38(sp)
        store   s8, 0x40(sp)
        store   s9, 0x48(sp)
        store   s10, 0x50(sp)
        store   s11, 0x58(sp)
        fsd     fs0, 0x60(sp)
        fsd     fs1, 0x68(sp)
        fsd     fs2, 0x70(sp)
        fsd     fs3, 0x78(sp)
        fsd     fs4, 0x80(sp)
        fsd     fs5, 0x88(sp)
        fsd     fs6, 0x90(sp)
        fsd     fs7, 0x98(sp)
        fsd     fs8, 0xa0(sp)
        fsd     fs9, 0xa8(sp)
        fsd     fs10, 0xb0(sp)
        fsd     fs11, 0xb8(sp)
        addi    sp, sp, -32
        /* Setup a callback link on the stack */
        load    TMP1, caml_bottom_of_stack
        store   TMP1, 0(sp)
        load    TMP1, caml_last_return_address
        store   TMP1, 8(sp)
        load    TMP1, caml_gc_regs
        store   TMP1, 16(sp)
        /* set up a trap frame */
        addi    sp, sp, -16
        load    TMP1, caml_exception_pointer
        store   TMP1, 0(sp)
        lla     TMP0, .Ltrap_handler
        store   TMP0, 8(sp)
        mv      TRAP_PTR, sp
        load    ALLOC_PTR, caml_young_ptr
        load    ALLOC_LIMIT, caml_young_limit
        store   x0, caml_last_return_address, TMP0
        jalr    ARG
.Lcaml_retaddr:         /* pop trap frame, restoring caml_exception_pointer */
        load    TMP1, 0(sp)
        store   TMP1, caml_exception_pointer, TMP0
        addi    sp, sp, 16
.Lreturn_result:        /* pop callback link, restoring global variables */
        load    TMP1, 0(sp)
        store   TMP1, caml_bottom_of_stack, TMP0
        load    TMP1, 8(sp)
        store   TMP1, caml_last_return_address, TMP0
        load    TMP1, 16(sp)
        store   TMP1, caml_gc_regs, TMP0
        addi    sp, sp, 32
        /* Update allocation pointer */
        store   ALLOC_PTR, caml_young_ptr, TMP0
        /* reload callee-save registers and return */
        load    ra, 0xc0(sp)
        load    s0, 0x0(sp)
        load    s1, 0x8(sp)
        load    s2, 0x10(sp)
        load    s3, 0x18(sp)
        load    s4, 0x20(sp)
        load    s5, 0x28(sp)
        load    s6, 0x30(sp)
        load    s7, 0x38(sp)
        load    s8, 0x40(sp)
        load    s9, 0x48(sp)
        load    s10, 0x50(sp)
        load    s11, 0x58(sp)
        fld     fs0, 0x60(sp)
        fld     fs1, 0x68(sp)
        fld     fs2, 0x70(sp)
        fld     fs3, 0x78(sp)
        fld     fs4, 0x80(sp)
        fld     fs5, 0x88(sp)
        fld     fs6, 0x90(sp)
        fld     fs7, 0x98(sp)
        fld     fs8, 0xa0(sp)
        fld     fs9, 0xa8(sp)
        fld     fs10, 0xb0(sp)
        fld     fs11, 0xb8(sp)
        addi    sp, sp, 0xd0
        ret
.Ltrap_handler:
        store   TRAP_PTR, caml_exception_pointer, TMP0
        ori     a0, a0, 2
        j       .Lreturn_result
        .size   caml_start_program, .-caml_start_program

/* Callback from C to OCaml */

        .align  2
        .globl  caml_callback_exn
        .type   caml_callback_exn, @function
caml_callback_exn:
        /* Initial shuffling of arguments (a0 = closure, a1 = first arg) */
        mv      TMP1, a0
        mv      a0, a1          /* a0 = first arg */
        mv      a1, TMP1        /* a1 = closure environment */
        load    ARG, 0(TMP1)    /* code pointer */
        j       .Ljump_to_caml
        .size   caml_callback_exn, .-caml_callback_exn

        .align  2
        .globl  caml_callback2_exn
        .type   caml_callback2_exn, @function
caml_callback2_exn:
        /* Initial shuffling of arguments (a0 = closure, a1 = arg1, a2 = arg2) */
        mv      TMP1, a0
        mv      a0, a1
        mv      a1, a2
        mv      a2, TMP1
        la      ARG, caml_apply2
        j       .Ljump_to_caml
        .size   caml_callback2_exn, .-caml_callback2_exn

        .align  2
        .globl  caml_callback3_exn
        .type   caml_callback3_exn, @function
caml_callback3_exn:
        /* Initial shuffling of argumnets */
        /* (a0 = closure, a1 = arg1, a2 = arg2, a3 = arg3) */
        mv      TMP1, a0
        mv      a0, a1
        mv      a1, a2
        mv      a2, a3
        mv      a3, TMP1
        la      ARG, caml_apply3
        j       .Ljump_to_caml
        .size   caml_callback3_exn, .-caml_callback3_exn

        .align  2
        .globl  caml_ml_array_bound_error
        .type   caml_ml_array_bound_error, @function
caml_ml_array_bound_error:
        /* Load address of [caml_array_bound_error] in ARG */
        la      ARG, caml_array_bound_error
        /* Call that function */
        j       caml_c_call

        .globl  caml_system__code_end
caml_system__code_end:

/* GC roots for callback */

        .section .data
        .align  3
        .globl  caml_system__frametable
        .type   caml_system__frametable, @object
caml_system__frametable:
        .quad   1               /* one descriptor */
        .quad   .Lcaml_retaddr  /* return address into callback */
        .short  -1              /* negative frame size => use callback link */
        .short  0               /* no roots */
        .align  3
        .size   caml_system__frametable, .-caml_system__frametable
