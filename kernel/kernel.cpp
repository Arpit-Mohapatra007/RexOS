extern "C" void main(){
	volatile char* vga=(char*)0xB8000;
	const char* msg="Welcom To RexOS";
	int idx=0;
	while(msg[idx]!='\0'){
		vga[idx*2]=msg[idx];
		vga[idx*2+1]=0x34;
		idx++;
	}
	return;
}