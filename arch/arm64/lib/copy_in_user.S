/*
 * Copy from user space to user space
 *
 * Copyright (C) 2012 ARM Ltd.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License version 2 as
 * published by the Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#include <linux/linkage.h>
#include <asm/assembler.h>

/*
 * Copy from user space to user space (alignment handled by the hardware)
 *
 * Parameters:
 *	x0 - to
 *	x1 - from
 *	x2 - n
 * Returns:
 *	x0 - bytes not copied
 */
ENTRY(__copy_in_user)
	add	x5, x0, x2			// upper user buffer boundary
	subs	x2, x2, #16
	b.mi	1f
0:
USER(9f, ldp	x3, x4, [x1], #16)
	subs	x2, x2, #16
USER(9f, stp	x3, x4, [x0], #16)
	b.pl	0b
1:	adds	x2, x2, #8
	b.mi	2f
USER(9f, ldr	x3, [x1], #8	)
	sub	x2, x2, #8
USER(9f, str	x3, [x0], #8	)
2:	adds	x2, x2, #4
	b.mi	3f
USER(9f, ldr	w3, [x1], #4	)
	sub	x2, x2, #4
USER(9f, str	w3, [x0], #4	)
3:	adds	x2, x2, #2
	b.mi	4f
USER(9f, ldrh	w3, [x1], #2	)
	sub	x2, x2, #2
USER(9f, strh	w3, [x0], #2	)
4:	adds	x2, x2, #1
	b.mi	5f
USER(9f, ldrb	w3, [x1]	)
USER(9f, strb	w3, [x0]	)
5:	mov	x0, #0
	ret
ENDPROC(__copy_in_user)

	.section .fixup,"ax"
	.align	2
9:	sub	x0, x5, x0			// bytes not copied
	ret
	.previous
