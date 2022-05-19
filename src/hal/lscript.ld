MEMORY
{
    ram         : ORIGIN = 0x00000000, LENGTH = 0x8000    /*  32 kB */
    stack       : ORIGIN = 0x00001F00, LENGTH = 0x100     /* 256  B */
}

SECTIONS {
	.prog : {
		. = 0x000000;
		*(.init);
		*(.text);
		*(*);
		. = ALIGN(4);

		FILL(0x0000);
 		. = LENGTH(ram);
		end = .;
	} > ram
}

