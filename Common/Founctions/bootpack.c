void io_hlt(void);
void io_out8(int port, int data);
int io_load_eflags(void);
void io_store_eflags(int eflags);
void init_palette(void);
void set_palette(int start, int end, unsigned char *rgb);

void SysMain(void)
{
	int i;
	char *p;

	init_palette();

	p = (char *) 0xa0000;

	for (i = 0xa0000; i <= 0xaffff; i++) {
		p[i] = i & 0x0f
	}
	
	for (;;) {
		io_hlt();
	}
}

void init_palette(void)
{
	static unsigned char table_rgb[16 * 3] = {
		0x00, 0x00, 0x00, /* 0:BLACK */
		0xff, 0x00, 0x00, /* 1:BRIGHT_RED */
		0x00, 0xff, 0x00, /* 2:BRIGHT_GREEN */
		0xff, 0xff, 0x00, /* 3:BRIGHT_YELLOW */
		0x00, 0x00, 0xff, /* 4:BRIGHT_BLUE */
		0xff, 0x00, 0xff, /* 5:BRIGHT_PURPLE */
		0x00, 0xff, 0xff, /* 6:BRI_LIG_BLUE */
		0xff, 0xff, 0xff, /* 7:WHITE */
		0xc6, 0xc6, 0xc6, /* 8:BRIGHT_GREY */
		0x84, 0x00, 0x00, /* 9:GREY_RED */
		0x00, 0x84, 0x00, /* 10:GREY_GREEN */
		0x84, 0x84, 0x00, /* 11:GREY_YELLOW */
		0x00, 0x00, 0x84, /* 12:DAK_GRY_GREEN */
		0x84, 0x00, 0x84, /* 13:GREY_PURPLE */
		0x00, 0x84, 0x84, /* 14:DAK_GRY_YELLOW */
		0x84, 0x84, 0x84, /* 15:DAK_GREY */
	};
	set_palette(0, 15, table_rgb);
	return;

}

void set_palette(int start, int end, unsigned char *rgb)
{
	int i, eflags;
	eflags = io_load_eflags();
	io_cli();
	io_out8(0x03c8, start);
	for(i = start; i <= end; i++) {
		io_out8(0x03c9, rgb[0] / 4);
		io_out8(0x03c9, rgb[1] / 4);
		io_out8(0x03c9, rgb[2] / 4);
		rgb += 3;
	}
	io_store_eflags(eflags);
	return;
}

