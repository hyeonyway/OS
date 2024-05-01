
kernel:     file format elf32-i386


Disassembly of section .text:

80100000 <multiboot_header>:
80100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
80100006:	00 00                	add    %al,(%eax)
80100008:	fe 4f 52             	decb   0x52(%edi)
8010000b:	e4                   	.byte 0xe4

8010000c <wait_main>:
8010000c:	00 00                	add    %al,(%eax)
	...

80100010 <entry>:
  .long 0
# Entering xv6 on boot processor, with paging off.
.globl entry
entry:
  #Set Data Segment
  mov $0x10,%ax
80100010:	66 b8 10 00          	mov    $0x10,%ax
  mov %ax,%ds
80100014:	8e d8                	mov    %eax,%ds
  mov %ax,%es
80100016:	8e c0                	mov    %eax,%es
  mov %ax,%ss
80100018:	8e d0                	mov    %eax,%ss
  mov $0,%ax
8010001a:	66 b8 00 00          	mov    $0x0,%ax
  mov %ax,%fs
8010001e:	8e e0                	mov    %eax,%fs
  mov %ax,%gs
80100020:	8e e8                	mov    %eax,%gs

  #Turn off paing
  movl %cr0,%eax
80100022:	0f 20 c0             	mov    %cr0,%eax
  andl $0x7fffffff,%eax
80100025:	25 ff ff ff 7f       	and    $0x7fffffff,%eax
  movl %eax,%cr0 
8010002a:	0f 22 c0             	mov    %eax,%cr0

  #Set Page Table Base Address
  movl    $(V2P_WO(entrypgdir)), %eax
8010002d:	b8 00 e0 10 00       	mov    $0x10e000,%eax
  movl    %eax, %cr3
80100032:	0f 22 d8             	mov    %eax,%cr3
  
  #Disable IA32e mode
  movl $0x0c0000080,%ecx
80100035:	b9 80 00 00 c0       	mov    $0xc0000080,%ecx
  rdmsr
8010003a:	0f 32                	rdmsr  
  andl $0xFFFFFEFF,%eax
8010003c:	25 ff fe ff ff       	and    $0xfffffeff,%eax
  wrmsr
80100041:	0f 30                	wrmsr  

  # Turn on page size extension for 4Mbyte pages
  movl    %cr4, %eax
80100043:	0f 20 e0             	mov    %cr4,%eax
  orl     $(CR4_PSE), %eax
80100046:	83 c8 10             	or     $0x10,%eax
  andl    $0xFFFFFFDF, %eax
80100049:	83 e0 df             	and    $0xffffffdf,%eax
  movl    %eax, %cr4
8010004c:	0f 22 e0             	mov    %eax,%cr4

  #Turn on Paging
  movl    %cr0, %eax
8010004f:	0f 20 c0             	mov    %cr0,%eax
  orl     $0x80010001, %eax
80100052:	0d 01 00 01 80       	or     $0x80010001,%eax
  movl    %eax, %cr0
80100057:	0f 22 c0             	mov    %eax,%cr0




  # Set up the stack pointer.
  movl $(stack + KSTACKSIZE), %esp
8010005a:	bc b0 b1 11 80       	mov    $0x8011b1b0,%esp
  # Jump to main(), and switch to executing at
  # high addresses. The indirect call is needed because
  # the assembler produces a PC-relative instruction
  # for a direct jump.
#  jz .waiting_main
  movl $main, %edx
8010005f:	ba 49 38 10 80       	mov    $0x80103849,%edx
  jmp %edx
80100064:	ff e2                	jmp    *%edx

80100066 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
80100066:	55                   	push   %ebp
80100067:	89 e5                	mov    %esp,%ebp
80100069:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  initlock(&bcache.lock, "bcache");
8010006c:	83 ec 08             	sub    $0x8,%esp
8010006f:	68 80 a4 10 80       	push   $0x8010a480
80100074:	68 00 00 11 80       	push   $0x80110000
80100079:	e8 4d 4b 00 00       	call   80104bcb <initlock>
8010007e:	83 c4 10             	add    $0x10,%esp

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
80100081:	c7 05 4c 47 11 80 fc 	movl   $0x801146fc,0x8011474c
80100088:	46 11 80 
  bcache.head.next = &bcache.head;
8010008b:	c7 05 50 47 11 80 fc 	movl   $0x801146fc,0x80114750
80100092:	46 11 80 
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
80100095:	c7 45 f4 34 00 11 80 	movl   $0x80110034,-0xc(%ebp)
8010009c:	eb 47                	jmp    801000e5 <binit+0x7f>
    b->next = bcache.head.next;
8010009e:	8b 15 50 47 11 80    	mov    0x80114750,%edx
801000a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000a7:	89 50 54             	mov    %edx,0x54(%eax)
    b->prev = &bcache.head;
801000aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000ad:	c7 40 50 fc 46 11 80 	movl   $0x801146fc,0x50(%eax)
    initsleeplock(&b->lock, "buffer");
801000b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000b7:	83 c0 0c             	add    $0xc,%eax
801000ba:	83 ec 08             	sub    $0x8,%esp
801000bd:	68 87 a4 10 80       	push   $0x8010a487
801000c2:	50                   	push   %eax
801000c3:	e8 a6 49 00 00       	call   80104a6e <initsleeplock>
801000c8:	83 c4 10             	add    $0x10,%esp
    bcache.head.next->prev = b;
801000cb:	a1 50 47 11 80       	mov    0x80114750,%eax
801000d0:	8b 55 f4             	mov    -0xc(%ebp),%edx
801000d3:	89 50 50             	mov    %edx,0x50(%eax)
    bcache.head.next = b;
801000d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000d9:	a3 50 47 11 80       	mov    %eax,0x80114750
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
801000de:	81 45 f4 5c 02 00 00 	addl   $0x25c,-0xc(%ebp)
801000e5:	b8 fc 46 11 80       	mov    $0x801146fc,%eax
801000ea:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801000ed:	72 af                	jb     8010009e <binit+0x38>
  }
}
801000ef:	90                   	nop
801000f0:	90                   	nop
801000f1:	c9                   	leave  
801000f2:	c3                   	ret    

801000f3 <bget>:
// Look through buffer cache for block on device dev.
// If not found, allocate a buffer.
// In either case, return locked buffer.
static struct buf*
bget(uint dev, uint blockno)
{
801000f3:	55                   	push   %ebp
801000f4:	89 e5                	mov    %esp,%ebp
801000f6:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  acquire(&bcache.lock);
801000f9:	83 ec 0c             	sub    $0xc,%esp
801000fc:	68 00 00 11 80       	push   $0x80110000
80100101:	e8 e7 4a 00 00       	call   80104bed <acquire>
80100106:	83 c4 10             	add    $0x10,%esp

  // Is the block already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
80100109:	a1 50 47 11 80       	mov    0x80114750,%eax
8010010e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100111:	eb 58                	jmp    8010016b <bget+0x78>
    if(b->dev == dev && b->blockno == blockno){
80100113:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100116:	8b 40 04             	mov    0x4(%eax),%eax
80100119:	39 45 08             	cmp    %eax,0x8(%ebp)
8010011c:	75 44                	jne    80100162 <bget+0x6f>
8010011e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100121:	8b 40 08             	mov    0x8(%eax),%eax
80100124:	39 45 0c             	cmp    %eax,0xc(%ebp)
80100127:	75 39                	jne    80100162 <bget+0x6f>
      b->refcnt++;
80100129:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010012c:	8b 40 4c             	mov    0x4c(%eax),%eax
8010012f:	8d 50 01             	lea    0x1(%eax),%edx
80100132:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100135:	89 50 4c             	mov    %edx,0x4c(%eax)
      release(&bcache.lock);
80100138:	83 ec 0c             	sub    $0xc,%esp
8010013b:	68 00 00 11 80       	push   $0x80110000
80100140:	e8 16 4b 00 00       	call   80104c5b <release>
80100145:	83 c4 10             	add    $0x10,%esp
      acquiresleep(&b->lock);
80100148:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010014b:	83 c0 0c             	add    $0xc,%eax
8010014e:	83 ec 0c             	sub    $0xc,%esp
80100151:	50                   	push   %eax
80100152:	e8 53 49 00 00       	call   80104aaa <acquiresleep>
80100157:	83 c4 10             	add    $0x10,%esp
      return b;
8010015a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010015d:	e9 9d 00 00 00       	jmp    801001ff <bget+0x10c>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
80100162:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100165:	8b 40 54             	mov    0x54(%eax),%eax
80100168:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010016b:	81 7d f4 fc 46 11 80 	cmpl   $0x801146fc,-0xc(%ebp)
80100172:	75 9f                	jne    80100113 <bget+0x20>
  }

  // Not cached; recycle an unused buffer.
  // Even if refcnt==0, B_DIRTY indicates a buffer is in use
  // because log.c has modified it but not yet committed it.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100174:	a1 4c 47 11 80       	mov    0x8011474c,%eax
80100179:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010017c:	eb 6b                	jmp    801001e9 <bget+0xf6>
    if(b->refcnt == 0 && (b->flags & B_DIRTY) == 0) {
8010017e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100181:	8b 40 4c             	mov    0x4c(%eax),%eax
80100184:	85 c0                	test   %eax,%eax
80100186:	75 58                	jne    801001e0 <bget+0xed>
80100188:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010018b:	8b 00                	mov    (%eax),%eax
8010018d:	83 e0 04             	and    $0x4,%eax
80100190:	85 c0                	test   %eax,%eax
80100192:	75 4c                	jne    801001e0 <bget+0xed>
      b->dev = dev;
80100194:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100197:	8b 55 08             	mov    0x8(%ebp),%edx
8010019a:	89 50 04             	mov    %edx,0x4(%eax)
      b->blockno = blockno;
8010019d:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001a0:	8b 55 0c             	mov    0xc(%ebp),%edx
801001a3:	89 50 08             	mov    %edx,0x8(%eax)
      b->flags = 0;
801001a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001a9:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
      b->refcnt = 1;
801001af:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001b2:	c7 40 4c 01 00 00 00 	movl   $0x1,0x4c(%eax)
      release(&bcache.lock);
801001b9:	83 ec 0c             	sub    $0xc,%esp
801001bc:	68 00 00 11 80       	push   $0x80110000
801001c1:	e8 95 4a 00 00       	call   80104c5b <release>
801001c6:	83 c4 10             	add    $0x10,%esp
      acquiresleep(&b->lock);
801001c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001cc:	83 c0 0c             	add    $0xc,%eax
801001cf:	83 ec 0c             	sub    $0xc,%esp
801001d2:	50                   	push   %eax
801001d3:	e8 d2 48 00 00       	call   80104aaa <acquiresleep>
801001d8:	83 c4 10             	add    $0x10,%esp
      return b;
801001db:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001de:	eb 1f                	jmp    801001ff <bget+0x10c>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
801001e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001e3:	8b 40 50             	mov    0x50(%eax),%eax
801001e6:	89 45 f4             	mov    %eax,-0xc(%ebp)
801001e9:	81 7d f4 fc 46 11 80 	cmpl   $0x801146fc,-0xc(%ebp)
801001f0:	75 8c                	jne    8010017e <bget+0x8b>
    }
  }
  panic("bget: no buffers");
801001f2:	83 ec 0c             	sub    $0xc,%esp
801001f5:	68 8e a4 10 80       	push   $0x8010a48e
801001fa:	e8 aa 03 00 00       	call   801005a9 <panic>
}
801001ff:	c9                   	leave  
80100200:	c3                   	ret    

80100201 <bread>:

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
80100201:	55                   	push   %ebp
80100202:	89 e5                	mov    %esp,%ebp
80100204:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  b = bget(dev, blockno);
80100207:	83 ec 08             	sub    $0x8,%esp
8010020a:	ff 75 0c             	push   0xc(%ebp)
8010020d:	ff 75 08             	push   0x8(%ebp)
80100210:	e8 de fe ff ff       	call   801000f3 <bget>
80100215:	83 c4 10             	add    $0x10,%esp
80100218:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((b->flags & B_VALID) == 0) {
8010021b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010021e:	8b 00                	mov    (%eax),%eax
80100220:	83 e0 02             	and    $0x2,%eax
80100223:	85 c0                	test   %eax,%eax
80100225:	75 0e                	jne    80100235 <bread+0x34>
    iderw(b);
80100227:	83 ec 0c             	sub    $0xc,%esp
8010022a:	ff 75 f4             	push   -0xc(%ebp)
8010022d:	e8 f9 26 00 00       	call   8010292b <iderw>
80100232:	83 c4 10             	add    $0x10,%esp
  }
  return b;
80100235:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80100238:	c9                   	leave  
80100239:	c3                   	ret    

8010023a <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
8010023a:	55                   	push   %ebp
8010023b:	89 e5                	mov    %esp,%ebp
8010023d:	83 ec 08             	sub    $0x8,%esp
  if(!holdingsleep(&b->lock))
80100240:	8b 45 08             	mov    0x8(%ebp),%eax
80100243:	83 c0 0c             	add    $0xc,%eax
80100246:	83 ec 0c             	sub    $0xc,%esp
80100249:	50                   	push   %eax
8010024a:	e8 0d 49 00 00       	call   80104b5c <holdingsleep>
8010024f:	83 c4 10             	add    $0x10,%esp
80100252:	85 c0                	test   %eax,%eax
80100254:	75 0d                	jne    80100263 <bwrite+0x29>
    panic("bwrite");
80100256:	83 ec 0c             	sub    $0xc,%esp
80100259:	68 9f a4 10 80       	push   $0x8010a49f
8010025e:	e8 46 03 00 00       	call   801005a9 <panic>
  b->flags |= B_DIRTY;
80100263:	8b 45 08             	mov    0x8(%ebp),%eax
80100266:	8b 00                	mov    (%eax),%eax
80100268:	83 c8 04             	or     $0x4,%eax
8010026b:	89 c2                	mov    %eax,%edx
8010026d:	8b 45 08             	mov    0x8(%ebp),%eax
80100270:	89 10                	mov    %edx,(%eax)
  iderw(b);
80100272:	83 ec 0c             	sub    $0xc,%esp
80100275:	ff 75 08             	push   0x8(%ebp)
80100278:	e8 ae 26 00 00       	call   8010292b <iderw>
8010027d:	83 c4 10             	add    $0x10,%esp
}
80100280:	90                   	nop
80100281:	c9                   	leave  
80100282:	c3                   	ret    

80100283 <brelse>:

// Release a locked buffer.
// Move to the head of the MRU list.
void
brelse(struct buf *b)
{
80100283:	55                   	push   %ebp
80100284:	89 e5                	mov    %esp,%ebp
80100286:	83 ec 08             	sub    $0x8,%esp
  if(!holdingsleep(&b->lock))
80100289:	8b 45 08             	mov    0x8(%ebp),%eax
8010028c:	83 c0 0c             	add    $0xc,%eax
8010028f:	83 ec 0c             	sub    $0xc,%esp
80100292:	50                   	push   %eax
80100293:	e8 c4 48 00 00       	call   80104b5c <holdingsleep>
80100298:	83 c4 10             	add    $0x10,%esp
8010029b:	85 c0                	test   %eax,%eax
8010029d:	75 0d                	jne    801002ac <brelse+0x29>
    panic("brelse");
8010029f:	83 ec 0c             	sub    $0xc,%esp
801002a2:	68 a6 a4 10 80       	push   $0x8010a4a6
801002a7:	e8 fd 02 00 00       	call   801005a9 <panic>

  releasesleep(&b->lock);
801002ac:	8b 45 08             	mov    0x8(%ebp),%eax
801002af:	83 c0 0c             	add    $0xc,%eax
801002b2:	83 ec 0c             	sub    $0xc,%esp
801002b5:	50                   	push   %eax
801002b6:	e8 53 48 00 00       	call   80104b0e <releasesleep>
801002bb:	83 c4 10             	add    $0x10,%esp

  acquire(&bcache.lock);
801002be:	83 ec 0c             	sub    $0xc,%esp
801002c1:	68 00 00 11 80       	push   $0x80110000
801002c6:	e8 22 49 00 00       	call   80104bed <acquire>
801002cb:	83 c4 10             	add    $0x10,%esp
  b->refcnt--;
801002ce:	8b 45 08             	mov    0x8(%ebp),%eax
801002d1:	8b 40 4c             	mov    0x4c(%eax),%eax
801002d4:	8d 50 ff             	lea    -0x1(%eax),%edx
801002d7:	8b 45 08             	mov    0x8(%ebp),%eax
801002da:	89 50 4c             	mov    %edx,0x4c(%eax)
  if (b->refcnt == 0) {
801002dd:	8b 45 08             	mov    0x8(%ebp),%eax
801002e0:	8b 40 4c             	mov    0x4c(%eax),%eax
801002e3:	85 c0                	test   %eax,%eax
801002e5:	75 47                	jne    8010032e <brelse+0xab>
    // no one is waiting for it.
    b->next->prev = b->prev;
801002e7:	8b 45 08             	mov    0x8(%ebp),%eax
801002ea:	8b 40 54             	mov    0x54(%eax),%eax
801002ed:	8b 55 08             	mov    0x8(%ebp),%edx
801002f0:	8b 52 50             	mov    0x50(%edx),%edx
801002f3:	89 50 50             	mov    %edx,0x50(%eax)
    b->prev->next = b->next;
801002f6:	8b 45 08             	mov    0x8(%ebp),%eax
801002f9:	8b 40 50             	mov    0x50(%eax),%eax
801002fc:	8b 55 08             	mov    0x8(%ebp),%edx
801002ff:	8b 52 54             	mov    0x54(%edx),%edx
80100302:	89 50 54             	mov    %edx,0x54(%eax)
    b->next = bcache.head.next;
80100305:	8b 15 50 47 11 80    	mov    0x80114750,%edx
8010030b:	8b 45 08             	mov    0x8(%ebp),%eax
8010030e:	89 50 54             	mov    %edx,0x54(%eax)
    b->prev = &bcache.head;
80100311:	8b 45 08             	mov    0x8(%ebp),%eax
80100314:	c7 40 50 fc 46 11 80 	movl   $0x801146fc,0x50(%eax)
    bcache.head.next->prev = b;
8010031b:	a1 50 47 11 80       	mov    0x80114750,%eax
80100320:	8b 55 08             	mov    0x8(%ebp),%edx
80100323:	89 50 50             	mov    %edx,0x50(%eax)
    bcache.head.next = b;
80100326:	8b 45 08             	mov    0x8(%ebp),%eax
80100329:	a3 50 47 11 80       	mov    %eax,0x80114750
  }
  
  release(&bcache.lock);
8010032e:	83 ec 0c             	sub    $0xc,%esp
80100331:	68 00 00 11 80       	push   $0x80110000
80100336:	e8 20 49 00 00       	call   80104c5b <release>
8010033b:	83 c4 10             	add    $0x10,%esp
}
8010033e:	90                   	nop
8010033f:	c9                   	leave  
80100340:	c3                   	ret    

80100341 <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
80100341:	55                   	push   %ebp
80100342:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80100344:	fa                   	cli    
}
80100345:	90                   	nop
80100346:	5d                   	pop    %ebp
80100347:	c3                   	ret    

80100348 <printint>:
  int locking;
} cons;

static void
printint(int xx, int base, int sign)
{
80100348:	55                   	push   %ebp
80100349:	89 e5                	mov    %esp,%ebp
8010034b:	83 ec 28             	sub    $0x28,%esp
  static char digits[] = "0123456789abcdef";
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
8010034e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100352:	74 1c                	je     80100370 <printint+0x28>
80100354:	8b 45 08             	mov    0x8(%ebp),%eax
80100357:	c1 e8 1f             	shr    $0x1f,%eax
8010035a:	0f b6 c0             	movzbl %al,%eax
8010035d:	89 45 10             	mov    %eax,0x10(%ebp)
80100360:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100364:	74 0a                	je     80100370 <printint+0x28>
    x = -xx;
80100366:	8b 45 08             	mov    0x8(%ebp),%eax
80100369:	f7 d8                	neg    %eax
8010036b:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010036e:	eb 06                	jmp    80100376 <printint+0x2e>
  else
    x = xx;
80100370:	8b 45 08             	mov    0x8(%ebp),%eax
80100373:	89 45 f0             	mov    %eax,-0x10(%ebp)

  i = 0;
80100376:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
8010037d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80100380:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100383:	ba 00 00 00 00       	mov    $0x0,%edx
80100388:	f7 f1                	div    %ecx
8010038a:	89 d1                	mov    %edx,%ecx
8010038c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010038f:	8d 50 01             	lea    0x1(%eax),%edx
80100392:	89 55 f4             	mov    %edx,-0xc(%ebp)
80100395:	0f b6 91 04 d0 10 80 	movzbl -0x7fef2ffc(%ecx),%edx
8010039c:	88 54 05 e0          	mov    %dl,-0x20(%ebp,%eax,1)
  }while((x /= base) != 0);
801003a0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801003a3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801003a6:	ba 00 00 00 00       	mov    $0x0,%edx
801003ab:	f7 f1                	div    %ecx
801003ad:	89 45 f0             	mov    %eax,-0x10(%ebp)
801003b0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801003b4:	75 c7                	jne    8010037d <printint+0x35>

  if(sign)
801003b6:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801003ba:	74 2a                	je     801003e6 <printint+0x9e>
    buf[i++] = '-';
801003bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801003bf:	8d 50 01             	lea    0x1(%eax),%edx
801003c2:	89 55 f4             	mov    %edx,-0xc(%ebp)
801003c5:	c6 44 05 e0 2d       	movb   $0x2d,-0x20(%ebp,%eax,1)

  while(--i >= 0)
801003ca:	eb 1a                	jmp    801003e6 <printint+0x9e>
    consputc(buf[i]);
801003cc:	8d 55 e0             	lea    -0x20(%ebp),%edx
801003cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801003d2:	01 d0                	add    %edx,%eax
801003d4:	0f b6 00             	movzbl (%eax),%eax
801003d7:	0f be c0             	movsbl %al,%eax
801003da:	83 ec 0c             	sub    $0xc,%esp
801003dd:	50                   	push   %eax
801003de:	e8 8c 03 00 00       	call   8010076f <consputc>
801003e3:	83 c4 10             	add    $0x10,%esp
  while(--i >= 0)
801003e6:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
801003ea:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801003ee:	79 dc                	jns    801003cc <printint+0x84>
}
801003f0:	90                   	nop
801003f1:	90                   	nop
801003f2:	c9                   	leave  
801003f3:	c3                   	ret    

801003f4 <cprintf>:
//PAGEBREAK: 50

// Print to the console. only understands %d, %x, %p, %s.
void
cprintf(char *fmt, ...)
{
801003f4:	55                   	push   %ebp
801003f5:	89 e5                	mov    %esp,%ebp
801003f7:	83 ec 28             	sub    $0x28,%esp
  int i, c, locking;
  uint *argp;
  char *s;

  locking = cons.locking;
801003fa:	a1 34 4a 11 80       	mov    0x80114a34,%eax
801003ff:	89 45 e8             	mov    %eax,-0x18(%ebp)
  if(locking)
80100402:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80100406:	74 10                	je     80100418 <cprintf+0x24>
    acquire(&cons.lock);
80100408:	83 ec 0c             	sub    $0xc,%esp
8010040b:	68 00 4a 11 80       	push   $0x80114a00
80100410:	e8 d8 47 00 00       	call   80104bed <acquire>
80100415:	83 c4 10             	add    $0x10,%esp

  if (fmt == 0)
80100418:	8b 45 08             	mov    0x8(%ebp),%eax
8010041b:	85 c0                	test   %eax,%eax
8010041d:	75 0d                	jne    8010042c <cprintf+0x38>
    panic("null fmt");
8010041f:	83 ec 0c             	sub    $0xc,%esp
80100422:	68 ad a4 10 80       	push   $0x8010a4ad
80100427:	e8 7d 01 00 00       	call   801005a9 <panic>


  argp = (uint*)(void*)(&fmt + 1);
8010042c:	8d 45 0c             	lea    0xc(%ebp),%eax
8010042f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
80100432:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100439:	e9 2f 01 00 00       	jmp    8010056d <cprintf+0x179>
    if(c != '%'){
8010043e:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
80100442:	74 13                	je     80100457 <cprintf+0x63>
      consputc(c);
80100444:	83 ec 0c             	sub    $0xc,%esp
80100447:	ff 75 e4             	push   -0x1c(%ebp)
8010044a:	e8 20 03 00 00       	call   8010076f <consputc>
8010044f:	83 c4 10             	add    $0x10,%esp
      continue;
80100452:	e9 12 01 00 00       	jmp    80100569 <cprintf+0x175>
    }
    c = fmt[++i] & 0xff;
80100457:	8b 55 08             	mov    0x8(%ebp),%edx
8010045a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010045e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100461:	01 d0                	add    %edx,%eax
80100463:	0f b6 00             	movzbl (%eax),%eax
80100466:	0f be c0             	movsbl %al,%eax
80100469:	25 ff 00 00 00       	and    $0xff,%eax
8010046e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(c == 0)
80100471:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80100475:	0f 84 14 01 00 00    	je     8010058f <cprintf+0x19b>
      break;
    switch(c){
8010047b:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
8010047f:	74 5e                	je     801004df <cprintf+0xeb>
80100481:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
80100485:	0f 8f c2 00 00 00    	jg     8010054d <cprintf+0x159>
8010048b:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
8010048f:	74 6b                	je     801004fc <cprintf+0x108>
80100491:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
80100495:	0f 8f b2 00 00 00    	jg     8010054d <cprintf+0x159>
8010049b:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
8010049f:	74 3e                	je     801004df <cprintf+0xeb>
801004a1:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
801004a5:	0f 8f a2 00 00 00    	jg     8010054d <cprintf+0x159>
801004ab:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
801004af:	0f 84 89 00 00 00    	je     8010053e <cprintf+0x14a>
801004b5:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
801004b9:	0f 85 8e 00 00 00    	jne    8010054d <cprintf+0x159>
    case 'd':
      printint(*argp++, 10, 1);
801004bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
801004c2:	8d 50 04             	lea    0x4(%eax),%edx
801004c5:	89 55 f0             	mov    %edx,-0x10(%ebp)
801004c8:	8b 00                	mov    (%eax),%eax
801004ca:	83 ec 04             	sub    $0x4,%esp
801004cd:	6a 01                	push   $0x1
801004cf:	6a 0a                	push   $0xa
801004d1:	50                   	push   %eax
801004d2:	e8 71 fe ff ff       	call   80100348 <printint>
801004d7:	83 c4 10             	add    $0x10,%esp
      break;
801004da:	e9 8a 00 00 00       	jmp    80100569 <cprintf+0x175>
    case 'x':
    case 'p':
      printint(*argp++, 16, 0);
801004df:	8b 45 f0             	mov    -0x10(%ebp),%eax
801004e2:	8d 50 04             	lea    0x4(%eax),%edx
801004e5:	89 55 f0             	mov    %edx,-0x10(%ebp)
801004e8:	8b 00                	mov    (%eax),%eax
801004ea:	83 ec 04             	sub    $0x4,%esp
801004ed:	6a 00                	push   $0x0
801004ef:	6a 10                	push   $0x10
801004f1:	50                   	push   %eax
801004f2:	e8 51 fe ff ff       	call   80100348 <printint>
801004f7:	83 c4 10             	add    $0x10,%esp
      break;
801004fa:	eb 6d                	jmp    80100569 <cprintf+0x175>
    case 's':
      if((s = (char*)*argp++) == 0)
801004fc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801004ff:	8d 50 04             	lea    0x4(%eax),%edx
80100502:	89 55 f0             	mov    %edx,-0x10(%ebp)
80100505:	8b 00                	mov    (%eax),%eax
80100507:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010050a:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010050e:	75 22                	jne    80100532 <cprintf+0x13e>
        s = "(null)";
80100510:	c7 45 ec b6 a4 10 80 	movl   $0x8010a4b6,-0x14(%ebp)
      for(; *s; s++)
80100517:	eb 19                	jmp    80100532 <cprintf+0x13e>
        consputc(*s);
80100519:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010051c:	0f b6 00             	movzbl (%eax),%eax
8010051f:	0f be c0             	movsbl %al,%eax
80100522:	83 ec 0c             	sub    $0xc,%esp
80100525:	50                   	push   %eax
80100526:	e8 44 02 00 00       	call   8010076f <consputc>
8010052b:	83 c4 10             	add    $0x10,%esp
      for(; *s; s++)
8010052e:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80100532:	8b 45 ec             	mov    -0x14(%ebp),%eax
80100535:	0f b6 00             	movzbl (%eax),%eax
80100538:	84 c0                	test   %al,%al
8010053a:	75 dd                	jne    80100519 <cprintf+0x125>
      break;
8010053c:	eb 2b                	jmp    80100569 <cprintf+0x175>
    case '%':
      consputc('%');
8010053e:	83 ec 0c             	sub    $0xc,%esp
80100541:	6a 25                	push   $0x25
80100543:	e8 27 02 00 00       	call   8010076f <consputc>
80100548:	83 c4 10             	add    $0x10,%esp
      break;
8010054b:	eb 1c                	jmp    80100569 <cprintf+0x175>
    default:
      // Print unknown % sequence to draw attention.
      consputc('%');
8010054d:	83 ec 0c             	sub    $0xc,%esp
80100550:	6a 25                	push   $0x25
80100552:	e8 18 02 00 00       	call   8010076f <consputc>
80100557:	83 c4 10             	add    $0x10,%esp
      consputc(c);
8010055a:	83 ec 0c             	sub    $0xc,%esp
8010055d:	ff 75 e4             	push   -0x1c(%ebp)
80100560:	e8 0a 02 00 00       	call   8010076f <consputc>
80100565:	83 c4 10             	add    $0x10,%esp
      break;
80100568:	90                   	nop
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
80100569:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010056d:	8b 55 08             	mov    0x8(%ebp),%edx
80100570:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100573:	01 d0                	add    %edx,%eax
80100575:	0f b6 00             	movzbl (%eax),%eax
80100578:	0f be c0             	movsbl %al,%eax
8010057b:	25 ff 00 00 00       	and    $0xff,%eax
80100580:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80100583:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80100587:	0f 85 b1 fe ff ff    	jne    8010043e <cprintf+0x4a>
8010058d:	eb 01                	jmp    80100590 <cprintf+0x19c>
      break;
8010058f:	90                   	nop
    }
  }

  if(locking)
80100590:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80100594:	74 10                	je     801005a6 <cprintf+0x1b2>
    release(&cons.lock);
80100596:	83 ec 0c             	sub    $0xc,%esp
80100599:	68 00 4a 11 80       	push   $0x80114a00
8010059e:	e8 b8 46 00 00       	call   80104c5b <release>
801005a3:	83 c4 10             	add    $0x10,%esp
}
801005a6:	90                   	nop
801005a7:	c9                   	leave  
801005a8:	c3                   	ret    

801005a9 <panic>:

void
panic(char *s)
{
801005a9:	55                   	push   %ebp
801005aa:	89 e5                	mov    %esp,%ebp
801005ac:	83 ec 38             	sub    $0x38,%esp
  int i;
  uint pcs[10];

  cli();
801005af:	e8 8d fd ff ff       	call   80100341 <cli>
  cons.locking = 0;
801005b4:	c7 05 34 4a 11 80 00 	movl   $0x0,0x80114a34
801005bb:	00 00 00 
  // use lapiccpunum so that we can call panic from mycpu()
  cprintf("lapicid %d: panic: ", lapicid());
801005be:	e8 1b 2a 00 00       	call   80102fde <lapicid>
801005c3:	83 ec 08             	sub    $0x8,%esp
801005c6:	50                   	push   %eax
801005c7:	68 bd a4 10 80       	push   $0x8010a4bd
801005cc:	e8 23 fe ff ff       	call   801003f4 <cprintf>
801005d1:	83 c4 10             	add    $0x10,%esp
  cprintf(s);
801005d4:	8b 45 08             	mov    0x8(%ebp),%eax
801005d7:	83 ec 0c             	sub    $0xc,%esp
801005da:	50                   	push   %eax
801005db:	e8 14 fe ff ff       	call   801003f4 <cprintf>
801005e0:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
801005e3:	83 ec 0c             	sub    $0xc,%esp
801005e6:	68 d1 a4 10 80       	push   $0x8010a4d1
801005eb:	e8 04 fe ff ff       	call   801003f4 <cprintf>
801005f0:	83 c4 10             	add    $0x10,%esp
  getcallerpcs(&s, pcs);
801005f3:	83 ec 08             	sub    $0x8,%esp
801005f6:	8d 45 cc             	lea    -0x34(%ebp),%eax
801005f9:	50                   	push   %eax
801005fa:	8d 45 08             	lea    0x8(%ebp),%eax
801005fd:	50                   	push   %eax
801005fe:	e8 aa 46 00 00       	call   80104cad <getcallerpcs>
80100603:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<10; i++)
80100606:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010060d:	eb 1c                	jmp    8010062b <panic+0x82>
    cprintf(" %p", pcs[i]);
8010060f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100612:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
80100616:	83 ec 08             	sub    $0x8,%esp
80100619:	50                   	push   %eax
8010061a:	68 d3 a4 10 80       	push   $0x8010a4d3
8010061f:	e8 d0 fd ff ff       	call   801003f4 <cprintf>
80100624:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<10; i++)
80100627:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010062b:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
8010062f:	7e de                	jle    8010060f <panic+0x66>
  panicked = 1; // freeze other CPU
80100631:	c7 05 ec 49 11 80 01 	movl   $0x1,0x801149ec
80100638:	00 00 00 
  for(;;)
8010063b:	eb fe                	jmp    8010063b <panic+0x92>

8010063d <graphic_putc>:

#define CONSOLE_HORIZONTAL_MAX 53
#define CONSOLE_VERTICAL_MAX 20
int console_pos = CONSOLE_HORIZONTAL_MAX*(CONSOLE_VERTICAL_MAX);
//int console_pos = 0;
void graphic_putc(int c){
8010063d:	55                   	push   %ebp
8010063e:	89 e5                	mov    %esp,%ebp
80100640:	83 ec 18             	sub    $0x18,%esp
  if(c == '\n'){
80100643:	83 7d 08 0a          	cmpl   $0xa,0x8(%ebp)
80100647:	75 64                	jne    801006ad <graphic_putc+0x70>
    console_pos += CONSOLE_HORIZONTAL_MAX - console_pos%CONSOLE_HORIZONTAL_MAX;
80100649:	8b 0d 00 d0 10 80    	mov    0x8010d000,%ecx
8010064f:	ba ed 73 48 4d       	mov    $0x4d4873ed,%edx
80100654:	89 c8                	mov    %ecx,%eax
80100656:	f7 ea                	imul   %edx
80100658:	89 d0                	mov    %edx,%eax
8010065a:	c1 f8 04             	sar    $0x4,%eax
8010065d:	89 ca                	mov    %ecx,%edx
8010065f:	c1 fa 1f             	sar    $0x1f,%edx
80100662:	29 d0                	sub    %edx,%eax
80100664:	6b d0 35             	imul   $0x35,%eax,%edx
80100667:	89 c8                	mov    %ecx,%eax
80100669:	29 d0                	sub    %edx,%eax
8010066b:	ba 35 00 00 00       	mov    $0x35,%edx
80100670:	29 c2                	sub    %eax,%edx
80100672:	a1 00 d0 10 80       	mov    0x8010d000,%eax
80100677:	01 d0                	add    %edx,%eax
80100679:	a3 00 d0 10 80       	mov    %eax,0x8010d000
    if(console_pos >= CONSOLE_VERTICAL_MAX * CONSOLE_HORIZONTAL_MAX){
8010067e:	a1 00 d0 10 80       	mov    0x8010d000,%eax
80100683:	3d 23 04 00 00       	cmp    $0x423,%eax
80100688:	0f 8e de 00 00 00    	jle    8010076c <graphic_putc+0x12f>
      console_pos -= CONSOLE_HORIZONTAL_MAX;
8010068e:	a1 00 d0 10 80       	mov    0x8010d000,%eax
80100693:	83 e8 35             	sub    $0x35,%eax
80100696:	a3 00 d0 10 80       	mov    %eax,0x8010d000
      graphic_scroll_up(30);
8010069b:	83 ec 0c             	sub    $0xc,%esp
8010069e:	6a 1e                	push   $0x1e
801006a0:	e8 3a 7d 00 00       	call   801083df <graphic_scroll_up>
801006a5:	83 c4 10             	add    $0x10,%esp
    int x = (console_pos%CONSOLE_HORIZONTAL_MAX)*FONT_WIDTH + 2;
    int y = (console_pos/CONSOLE_HORIZONTAL_MAX)*FONT_HEIGHT;
    font_render(x,y,c);
    console_pos++;
  }
}
801006a8:	e9 bf 00 00 00       	jmp    8010076c <graphic_putc+0x12f>
  }else if(c == BACKSPACE){
801006ad:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
801006b4:	75 1f                	jne    801006d5 <graphic_putc+0x98>
    if(console_pos>0) --console_pos;
801006b6:	a1 00 d0 10 80       	mov    0x8010d000,%eax
801006bb:	85 c0                	test   %eax,%eax
801006bd:	0f 8e a9 00 00 00    	jle    8010076c <graphic_putc+0x12f>
801006c3:	a1 00 d0 10 80       	mov    0x8010d000,%eax
801006c8:	83 e8 01             	sub    $0x1,%eax
801006cb:	a3 00 d0 10 80       	mov    %eax,0x8010d000
}
801006d0:	e9 97 00 00 00       	jmp    8010076c <graphic_putc+0x12f>
    if(console_pos >= CONSOLE_VERTICAL_MAX * CONSOLE_HORIZONTAL_MAX){
801006d5:	a1 00 d0 10 80       	mov    0x8010d000,%eax
801006da:	3d 23 04 00 00       	cmp    $0x423,%eax
801006df:	7e 1a                	jle    801006fb <graphic_putc+0xbe>
      console_pos -= CONSOLE_HORIZONTAL_MAX;
801006e1:	a1 00 d0 10 80       	mov    0x8010d000,%eax
801006e6:	83 e8 35             	sub    $0x35,%eax
801006e9:	a3 00 d0 10 80       	mov    %eax,0x8010d000
      graphic_scroll_up(30);
801006ee:	83 ec 0c             	sub    $0xc,%esp
801006f1:	6a 1e                	push   $0x1e
801006f3:	e8 e7 7c 00 00       	call   801083df <graphic_scroll_up>
801006f8:	83 c4 10             	add    $0x10,%esp
    int x = (console_pos%CONSOLE_HORIZONTAL_MAX)*FONT_WIDTH + 2;
801006fb:	8b 0d 00 d0 10 80    	mov    0x8010d000,%ecx
80100701:	ba ed 73 48 4d       	mov    $0x4d4873ed,%edx
80100706:	89 c8                	mov    %ecx,%eax
80100708:	f7 ea                	imul   %edx
8010070a:	89 d0                	mov    %edx,%eax
8010070c:	c1 f8 04             	sar    $0x4,%eax
8010070f:	89 ca                	mov    %ecx,%edx
80100711:	c1 fa 1f             	sar    $0x1f,%edx
80100714:	29 d0                	sub    %edx,%eax
80100716:	6b d0 35             	imul   $0x35,%eax,%edx
80100719:	89 c8                	mov    %ecx,%eax
8010071b:	29 d0                	sub    %edx,%eax
8010071d:	89 c2                	mov    %eax,%edx
8010071f:	c1 e2 04             	shl    $0x4,%edx
80100722:	29 c2                	sub    %eax,%edx
80100724:	8d 42 02             	lea    0x2(%edx),%eax
80100727:	89 45 f4             	mov    %eax,-0xc(%ebp)
    int y = (console_pos/CONSOLE_HORIZONTAL_MAX)*FONT_HEIGHT;
8010072a:	8b 0d 00 d0 10 80    	mov    0x8010d000,%ecx
80100730:	ba ed 73 48 4d       	mov    $0x4d4873ed,%edx
80100735:	89 c8                	mov    %ecx,%eax
80100737:	f7 ea                	imul   %edx
80100739:	89 d0                	mov    %edx,%eax
8010073b:	c1 f8 04             	sar    $0x4,%eax
8010073e:	c1 f9 1f             	sar    $0x1f,%ecx
80100741:	89 ca                	mov    %ecx,%edx
80100743:	29 d0                	sub    %edx,%eax
80100745:	6b c0 1e             	imul   $0x1e,%eax,%eax
80100748:	89 45 f0             	mov    %eax,-0x10(%ebp)
    font_render(x,y,c);
8010074b:	83 ec 04             	sub    $0x4,%esp
8010074e:	ff 75 08             	push   0x8(%ebp)
80100751:	ff 75 f0             	push   -0x10(%ebp)
80100754:	ff 75 f4             	push   -0xc(%ebp)
80100757:	e8 ee 7c 00 00       	call   8010844a <font_render>
8010075c:	83 c4 10             	add    $0x10,%esp
    console_pos++;
8010075f:	a1 00 d0 10 80       	mov    0x8010d000,%eax
80100764:	83 c0 01             	add    $0x1,%eax
80100767:	a3 00 d0 10 80       	mov    %eax,0x8010d000
}
8010076c:	90                   	nop
8010076d:	c9                   	leave  
8010076e:	c3                   	ret    

8010076f <consputc>:


void
consputc(int c)
{
8010076f:	55                   	push   %ebp
80100770:	89 e5                	mov    %esp,%ebp
80100772:	83 ec 08             	sub    $0x8,%esp
  if(panicked){
80100775:	a1 ec 49 11 80       	mov    0x801149ec,%eax
8010077a:	85 c0                	test   %eax,%eax
8010077c:	74 07                	je     80100785 <consputc+0x16>
    cli();
8010077e:	e8 be fb ff ff       	call   80100341 <cli>
    for(;;)
80100783:	eb fe                	jmp    80100783 <consputc+0x14>
      ;
  }

  if(c == BACKSPACE){
80100785:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
8010078c:	75 29                	jne    801007b7 <consputc+0x48>
    uartputc('\b'); uartputc(' '); uartputc('\b');
8010078e:	83 ec 0c             	sub    $0xc,%esp
80100791:	6a 08                	push   $0x8
80100793:	e8 be 60 00 00       	call   80106856 <uartputc>
80100798:	83 c4 10             	add    $0x10,%esp
8010079b:	83 ec 0c             	sub    $0xc,%esp
8010079e:	6a 20                	push   $0x20
801007a0:	e8 b1 60 00 00       	call   80106856 <uartputc>
801007a5:	83 c4 10             	add    $0x10,%esp
801007a8:	83 ec 0c             	sub    $0xc,%esp
801007ab:	6a 08                	push   $0x8
801007ad:	e8 a4 60 00 00       	call   80106856 <uartputc>
801007b2:	83 c4 10             	add    $0x10,%esp
801007b5:	eb 0e                	jmp    801007c5 <consputc+0x56>
  } else {
    uartputc(c);
801007b7:	83 ec 0c             	sub    $0xc,%esp
801007ba:	ff 75 08             	push   0x8(%ebp)
801007bd:	e8 94 60 00 00       	call   80106856 <uartputc>
801007c2:	83 c4 10             	add    $0x10,%esp
  }
  graphic_putc(c);
801007c5:	83 ec 0c             	sub    $0xc,%esp
801007c8:	ff 75 08             	push   0x8(%ebp)
801007cb:	e8 6d fe ff ff       	call   8010063d <graphic_putc>
801007d0:	83 c4 10             	add    $0x10,%esp
}
801007d3:	90                   	nop
801007d4:	c9                   	leave  
801007d5:	c3                   	ret    

801007d6 <consoleintr>:

#define C(x)  ((x)-'@')  // Control-x

void
consoleintr(int (*getc)(void))
{
801007d6:	55                   	push   %ebp
801007d7:	89 e5                	mov    %esp,%ebp
801007d9:	83 ec 18             	sub    $0x18,%esp
  int c, doprocdump = 0;
801007dc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&cons.lock);
801007e3:	83 ec 0c             	sub    $0xc,%esp
801007e6:	68 00 4a 11 80       	push   $0x80114a00
801007eb:	e8 fd 43 00 00       	call   80104bed <acquire>
801007f0:	83 c4 10             	add    $0x10,%esp
  while((c = getc()) >= 0){
801007f3:	e9 50 01 00 00       	jmp    80100948 <consoleintr+0x172>
    switch(c){
801007f8:	83 7d f0 7f          	cmpl   $0x7f,-0x10(%ebp)
801007fc:	0f 84 81 00 00 00    	je     80100883 <consoleintr+0xad>
80100802:	83 7d f0 7f          	cmpl   $0x7f,-0x10(%ebp)
80100806:	0f 8f ac 00 00 00    	jg     801008b8 <consoleintr+0xe2>
8010080c:	83 7d f0 15          	cmpl   $0x15,-0x10(%ebp)
80100810:	74 43                	je     80100855 <consoleintr+0x7f>
80100812:	83 7d f0 15          	cmpl   $0x15,-0x10(%ebp)
80100816:	0f 8f 9c 00 00 00    	jg     801008b8 <consoleintr+0xe2>
8010081c:	83 7d f0 08          	cmpl   $0x8,-0x10(%ebp)
80100820:	74 61                	je     80100883 <consoleintr+0xad>
80100822:	83 7d f0 10          	cmpl   $0x10,-0x10(%ebp)
80100826:	0f 85 8c 00 00 00    	jne    801008b8 <consoleintr+0xe2>
    case C('P'):  // Process listing.
      // procdump() locks cons.lock indirectly; invoke later
      doprocdump = 1;
8010082c:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
      break;
80100833:	e9 10 01 00 00       	jmp    80100948 <consoleintr+0x172>
    case C('U'):  // Kill line.
      while(input.e != input.w &&
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
80100838:	a1 e8 49 11 80       	mov    0x801149e8,%eax
8010083d:	83 e8 01             	sub    $0x1,%eax
80100840:	a3 e8 49 11 80       	mov    %eax,0x801149e8
        consputc(BACKSPACE);
80100845:	83 ec 0c             	sub    $0xc,%esp
80100848:	68 00 01 00 00       	push   $0x100
8010084d:	e8 1d ff ff ff       	call   8010076f <consputc>
80100852:	83 c4 10             	add    $0x10,%esp
      while(input.e != input.w &&
80100855:	8b 15 e8 49 11 80    	mov    0x801149e8,%edx
8010085b:	a1 e4 49 11 80       	mov    0x801149e4,%eax
80100860:	39 c2                	cmp    %eax,%edx
80100862:	0f 84 e0 00 00 00    	je     80100948 <consoleintr+0x172>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
80100868:	a1 e8 49 11 80       	mov    0x801149e8,%eax
8010086d:	83 e8 01             	sub    $0x1,%eax
80100870:	83 e0 7f             	and    $0x7f,%eax
80100873:	0f b6 80 60 49 11 80 	movzbl -0x7feeb6a0(%eax),%eax
      while(input.e != input.w &&
8010087a:	3c 0a                	cmp    $0xa,%al
8010087c:	75 ba                	jne    80100838 <consoleintr+0x62>
      }
      break;
8010087e:	e9 c5 00 00 00       	jmp    80100948 <consoleintr+0x172>
    case C('H'): case '\x7f':  // Backspace
      if(input.e != input.w){
80100883:	8b 15 e8 49 11 80    	mov    0x801149e8,%edx
80100889:	a1 e4 49 11 80       	mov    0x801149e4,%eax
8010088e:	39 c2                	cmp    %eax,%edx
80100890:	0f 84 b2 00 00 00    	je     80100948 <consoleintr+0x172>
        input.e--;
80100896:	a1 e8 49 11 80       	mov    0x801149e8,%eax
8010089b:	83 e8 01             	sub    $0x1,%eax
8010089e:	a3 e8 49 11 80       	mov    %eax,0x801149e8
        consputc(BACKSPACE);
801008a3:	83 ec 0c             	sub    $0xc,%esp
801008a6:	68 00 01 00 00       	push   $0x100
801008ab:	e8 bf fe ff ff       	call   8010076f <consputc>
801008b0:	83 c4 10             	add    $0x10,%esp
      }
      break;
801008b3:	e9 90 00 00 00       	jmp    80100948 <consoleintr+0x172>
    default:
      if(c != 0 && input.e-input.r < INPUT_BUF){
801008b8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801008bc:	0f 84 85 00 00 00    	je     80100947 <consoleintr+0x171>
801008c2:	a1 e8 49 11 80       	mov    0x801149e8,%eax
801008c7:	8b 15 e0 49 11 80    	mov    0x801149e0,%edx
801008cd:	29 d0                	sub    %edx,%eax
801008cf:	83 f8 7f             	cmp    $0x7f,%eax
801008d2:	77 73                	ja     80100947 <consoleintr+0x171>
        c = (c == '\r') ? '\n' : c;
801008d4:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
801008d8:	74 05                	je     801008df <consoleintr+0x109>
801008da:	8b 45 f0             	mov    -0x10(%ebp),%eax
801008dd:	eb 05                	jmp    801008e4 <consoleintr+0x10e>
801008df:	b8 0a 00 00 00       	mov    $0xa,%eax
801008e4:	89 45 f0             	mov    %eax,-0x10(%ebp)
        input.buf[input.e++ % INPUT_BUF] = c;
801008e7:	a1 e8 49 11 80       	mov    0x801149e8,%eax
801008ec:	8d 50 01             	lea    0x1(%eax),%edx
801008ef:	89 15 e8 49 11 80    	mov    %edx,0x801149e8
801008f5:	83 e0 7f             	and    $0x7f,%eax
801008f8:	8b 55 f0             	mov    -0x10(%ebp),%edx
801008fb:	88 90 60 49 11 80    	mov    %dl,-0x7feeb6a0(%eax)
        consputc(c);
80100901:	83 ec 0c             	sub    $0xc,%esp
80100904:	ff 75 f0             	push   -0x10(%ebp)
80100907:	e8 63 fe ff ff       	call   8010076f <consputc>
8010090c:	83 c4 10             	add    $0x10,%esp
        if(c == '\n' || c == C('D') || input.e == input.r+INPUT_BUF){
8010090f:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
80100913:	74 18                	je     8010092d <consoleintr+0x157>
80100915:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
80100919:	74 12                	je     8010092d <consoleintr+0x157>
8010091b:	a1 e8 49 11 80       	mov    0x801149e8,%eax
80100920:	8b 15 e0 49 11 80    	mov    0x801149e0,%edx
80100926:	83 ea 80             	sub    $0xffffff80,%edx
80100929:	39 d0                	cmp    %edx,%eax
8010092b:	75 1a                	jne    80100947 <consoleintr+0x171>
          input.w = input.e;
8010092d:	a1 e8 49 11 80       	mov    0x801149e8,%eax
80100932:	a3 e4 49 11 80       	mov    %eax,0x801149e4
          wakeup(&input.r);
80100937:	83 ec 0c             	sub    $0xc,%esp
8010093a:	68 e0 49 11 80       	push   $0x801149e0
8010093f:	e8 6f 3f 00 00       	call   801048b3 <wakeup>
80100944:	83 c4 10             	add    $0x10,%esp
        }
      }
      break;
80100947:	90                   	nop
  while((c = getc()) >= 0){
80100948:	8b 45 08             	mov    0x8(%ebp),%eax
8010094b:	ff d0                	call   *%eax
8010094d:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100950:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80100954:	0f 89 9e fe ff ff    	jns    801007f8 <consoleintr+0x22>
    }
  }
  release(&cons.lock);
8010095a:	83 ec 0c             	sub    $0xc,%esp
8010095d:	68 00 4a 11 80       	push   $0x80114a00
80100962:	e8 f4 42 00 00       	call   80104c5b <release>
80100967:	83 c4 10             	add    $0x10,%esp
  if(doprocdump) {
8010096a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010096e:	74 05                	je     80100975 <consoleintr+0x19f>
    procdump();  // now call procdump() wo. cons.lock held
80100970:	e8 fc 3f 00 00       	call   80104971 <procdump>
  }
}
80100975:	90                   	nop
80100976:	c9                   	leave  
80100977:	c3                   	ret    

80100978 <consoleread>:

int
consoleread(struct inode *ip, char *dst, int n)
{
80100978:	55                   	push   %ebp
80100979:	89 e5                	mov    %esp,%ebp
8010097b:	83 ec 18             	sub    $0x18,%esp
  uint target;
  int c;

  iunlock(ip);
8010097e:	83 ec 0c             	sub    $0xc,%esp
80100981:	ff 75 08             	push   0x8(%ebp)
80100984:	e8 74 11 00 00       	call   80101afd <iunlock>
80100989:	83 c4 10             	add    $0x10,%esp
  target = n;
8010098c:	8b 45 10             	mov    0x10(%ebp),%eax
8010098f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  acquire(&cons.lock);
80100992:	83 ec 0c             	sub    $0xc,%esp
80100995:	68 00 4a 11 80       	push   $0x80114a00
8010099a:	e8 4e 42 00 00       	call   80104bed <acquire>
8010099f:	83 c4 10             	add    $0x10,%esp
  while(n > 0){
801009a2:	e9 ab 00 00 00       	jmp    80100a52 <consoleread+0xda>
    while(input.r == input.w){
      if(myproc()->killed){
801009a7:	e8 68 35 00 00       	call   80103f14 <myproc>
801009ac:	8b 40 24             	mov    0x24(%eax),%eax
801009af:	85 c0                	test   %eax,%eax
801009b1:	74 28                	je     801009db <consoleread+0x63>
        release(&cons.lock);
801009b3:	83 ec 0c             	sub    $0xc,%esp
801009b6:	68 00 4a 11 80       	push   $0x80114a00
801009bb:	e8 9b 42 00 00       	call   80104c5b <release>
801009c0:	83 c4 10             	add    $0x10,%esp
        ilock(ip);
801009c3:	83 ec 0c             	sub    $0xc,%esp
801009c6:	ff 75 08             	push   0x8(%ebp)
801009c9:	e8 1c 10 00 00       	call   801019ea <ilock>
801009ce:	83 c4 10             	add    $0x10,%esp
        return -1;
801009d1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801009d6:	e9 a9 00 00 00       	jmp    80100a84 <consoleread+0x10c>
      }
      sleep(&input.r, &cons.lock);
801009db:	83 ec 08             	sub    $0x8,%esp
801009de:	68 00 4a 11 80       	push   $0x80114a00
801009e3:	68 e0 49 11 80       	push   $0x801149e0
801009e8:	e8 dc 3d 00 00       	call   801047c9 <sleep>
801009ed:	83 c4 10             	add    $0x10,%esp
    while(input.r == input.w){
801009f0:	8b 15 e0 49 11 80    	mov    0x801149e0,%edx
801009f6:	a1 e4 49 11 80       	mov    0x801149e4,%eax
801009fb:	39 c2                	cmp    %eax,%edx
801009fd:	74 a8                	je     801009a7 <consoleread+0x2f>
    }
    c = input.buf[input.r++ % INPUT_BUF];
801009ff:	a1 e0 49 11 80       	mov    0x801149e0,%eax
80100a04:	8d 50 01             	lea    0x1(%eax),%edx
80100a07:	89 15 e0 49 11 80    	mov    %edx,0x801149e0
80100a0d:	83 e0 7f             	and    $0x7f,%eax
80100a10:	0f b6 80 60 49 11 80 	movzbl -0x7feeb6a0(%eax),%eax
80100a17:	0f be c0             	movsbl %al,%eax
80100a1a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(c == C('D')){  // EOF
80100a1d:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
80100a21:	75 17                	jne    80100a3a <consoleread+0xc2>
      if(n < target){
80100a23:	8b 45 10             	mov    0x10(%ebp),%eax
80100a26:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80100a29:	76 2f                	jbe    80100a5a <consoleread+0xe2>
        // Save ^D for next time, to make sure
        // caller gets a 0-byte result.
        input.r--;
80100a2b:	a1 e0 49 11 80       	mov    0x801149e0,%eax
80100a30:	83 e8 01             	sub    $0x1,%eax
80100a33:	a3 e0 49 11 80       	mov    %eax,0x801149e0
      }
      break;
80100a38:	eb 20                	jmp    80100a5a <consoleread+0xe2>
    }
    *dst++ = c;
80100a3a:	8b 45 0c             	mov    0xc(%ebp),%eax
80100a3d:	8d 50 01             	lea    0x1(%eax),%edx
80100a40:	89 55 0c             	mov    %edx,0xc(%ebp)
80100a43:	8b 55 f0             	mov    -0x10(%ebp),%edx
80100a46:	88 10                	mov    %dl,(%eax)
    --n;
80100a48:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
    if(c == '\n')
80100a4c:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
80100a50:	74 0b                	je     80100a5d <consoleread+0xe5>
  while(n > 0){
80100a52:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100a56:	7f 98                	jg     801009f0 <consoleread+0x78>
80100a58:	eb 04                	jmp    80100a5e <consoleread+0xe6>
      break;
80100a5a:	90                   	nop
80100a5b:	eb 01                	jmp    80100a5e <consoleread+0xe6>
      break;
80100a5d:	90                   	nop
  }
  release(&cons.lock);
80100a5e:	83 ec 0c             	sub    $0xc,%esp
80100a61:	68 00 4a 11 80       	push   $0x80114a00
80100a66:	e8 f0 41 00 00       	call   80104c5b <release>
80100a6b:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80100a6e:	83 ec 0c             	sub    $0xc,%esp
80100a71:	ff 75 08             	push   0x8(%ebp)
80100a74:	e8 71 0f 00 00       	call   801019ea <ilock>
80100a79:	83 c4 10             	add    $0x10,%esp

  return target - n;
80100a7c:	8b 55 10             	mov    0x10(%ebp),%edx
80100a7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100a82:	29 d0                	sub    %edx,%eax
}
80100a84:	c9                   	leave  
80100a85:	c3                   	ret    

80100a86 <consolewrite>:

int
consolewrite(struct inode *ip, char *buf, int n)
{
80100a86:	55                   	push   %ebp
80100a87:	89 e5                	mov    %esp,%ebp
80100a89:	83 ec 18             	sub    $0x18,%esp
  int i;

  iunlock(ip);
80100a8c:	83 ec 0c             	sub    $0xc,%esp
80100a8f:	ff 75 08             	push   0x8(%ebp)
80100a92:	e8 66 10 00 00       	call   80101afd <iunlock>
80100a97:	83 c4 10             	add    $0x10,%esp
  acquire(&cons.lock);
80100a9a:	83 ec 0c             	sub    $0xc,%esp
80100a9d:	68 00 4a 11 80       	push   $0x80114a00
80100aa2:	e8 46 41 00 00       	call   80104bed <acquire>
80100aa7:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++)
80100aaa:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100ab1:	eb 21                	jmp    80100ad4 <consolewrite+0x4e>
    consputc(buf[i] & 0xff);
80100ab3:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100ab6:	8b 45 0c             	mov    0xc(%ebp),%eax
80100ab9:	01 d0                	add    %edx,%eax
80100abb:	0f b6 00             	movzbl (%eax),%eax
80100abe:	0f be c0             	movsbl %al,%eax
80100ac1:	0f b6 c0             	movzbl %al,%eax
80100ac4:	83 ec 0c             	sub    $0xc,%esp
80100ac7:	50                   	push   %eax
80100ac8:	e8 a2 fc ff ff       	call   8010076f <consputc>
80100acd:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++)
80100ad0:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100ad4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100ad7:	3b 45 10             	cmp    0x10(%ebp),%eax
80100ada:	7c d7                	jl     80100ab3 <consolewrite+0x2d>
  release(&cons.lock);
80100adc:	83 ec 0c             	sub    $0xc,%esp
80100adf:	68 00 4a 11 80       	push   $0x80114a00
80100ae4:	e8 72 41 00 00       	call   80104c5b <release>
80100ae9:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80100aec:	83 ec 0c             	sub    $0xc,%esp
80100aef:	ff 75 08             	push   0x8(%ebp)
80100af2:	e8 f3 0e 00 00       	call   801019ea <ilock>
80100af7:	83 c4 10             	add    $0x10,%esp

  return n;
80100afa:	8b 45 10             	mov    0x10(%ebp),%eax
}
80100afd:	c9                   	leave  
80100afe:	c3                   	ret    

80100aff <consoleinit>:

void
consoleinit(void)
{
80100aff:	55                   	push   %ebp
80100b00:	89 e5                	mov    %esp,%ebp
80100b02:	83 ec 18             	sub    $0x18,%esp
  panicked = 0;
80100b05:	c7 05 ec 49 11 80 00 	movl   $0x0,0x801149ec
80100b0c:	00 00 00 
  initlock(&cons.lock, "console");
80100b0f:	83 ec 08             	sub    $0x8,%esp
80100b12:	68 d7 a4 10 80       	push   $0x8010a4d7
80100b17:	68 00 4a 11 80       	push   $0x80114a00
80100b1c:	e8 aa 40 00 00       	call   80104bcb <initlock>
80100b21:	83 c4 10             	add    $0x10,%esp

  devsw[CONSOLE].write = consolewrite;
80100b24:	c7 05 4c 4a 11 80 86 	movl   $0x80100a86,0x80114a4c
80100b2b:	0a 10 80 
  devsw[CONSOLE].read = consoleread;
80100b2e:	c7 05 48 4a 11 80 78 	movl   $0x80100978,0x80114a48
80100b35:	09 10 80 
  
  char *p;
  for(p="Starting XV6_UEFI...\n"; *p; p++)
80100b38:	c7 45 f4 df a4 10 80 	movl   $0x8010a4df,-0xc(%ebp)
80100b3f:	eb 19                	jmp    80100b5a <consoleinit+0x5b>
    graphic_putc(*p);
80100b41:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100b44:	0f b6 00             	movzbl (%eax),%eax
80100b47:	0f be c0             	movsbl %al,%eax
80100b4a:	83 ec 0c             	sub    $0xc,%esp
80100b4d:	50                   	push   %eax
80100b4e:	e8 ea fa ff ff       	call   8010063d <graphic_putc>
80100b53:	83 c4 10             	add    $0x10,%esp
  for(p="Starting XV6_UEFI...\n"; *p; p++)
80100b56:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100b5a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100b5d:	0f b6 00             	movzbl (%eax),%eax
80100b60:	84 c0                	test   %al,%al
80100b62:	75 dd                	jne    80100b41 <consoleinit+0x42>
  
  cons.locking = 1;
80100b64:	c7 05 34 4a 11 80 01 	movl   $0x1,0x80114a34
80100b6b:	00 00 00 

  ioapicenable(IRQ_KBD, 0);
80100b6e:	83 ec 08             	sub    $0x8,%esp
80100b71:	6a 00                	push   $0x0
80100b73:	6a 01                	push   $0x1
80100b75:	e8 98 1f 00 00       	call   80102b12 <ioapicenable>
80100b7a:	83 c4 10             	add    $0x10,%esp
}
80100b7d:	90                   	nop
80100b7e:	c9                   	leave  
80100b7f:	c3                   	ret    

80100b80 <exec>:
#include "x86.h"
#include "elf.h"

int
exec(char *path, char **argv)
{
80100b80:	55                   	push   %ebp
80100b81:	89 e5                	mov    %esp,%ebp
80100b83:	81 ec 18 01 00 00    	sub    $0x118,%esp
  uint argc, sz, sp, ustack[3+MAXARG+1];
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pde_t *pgdir, *oldpgdir;
  struct proc *curproc = myproc();
80100b89:	e8 86 33 00 00       	call   80103f14 <myproc>
80100b8e:	89 45 d0             	mov    %eax,-0x30(%ebp)

  begin_op();
80100b91:	e8 8a 29 00 00       	call   80103520 <begin_op>

  if((ip = namei(path)) == 0){
80100b96:	83 ec 0c             	sub    $0xc,%esp
80100b99:	ff 75 08             	push   0x8(%ebp)
80100b9c:	e8 7c 19 00 00       	call   8010251d <namei>
80100ba1:	83 c4 10             	add    $0x10,%esp
80100ba4:	89 45 d8             	mov    %eax,-0x28(%ebp)
80100ba7:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100bab:	75 1f                	jne    80100bcc <exec+0x4c>
    end_op();
80100bad:	e8 fa 29 00 00       	call   801035ac <end_op>
    cprintf("exec: fail\n");
80100bb2:	83 ec 0c             	sub    $0xc,%esp
80100bb5:	68 f5 a4 10 80       	push   $0x8010a4f5
80100bba:	e8 35 f8 ff ff       	call   801003f4 <cprintf>
80100bbf:	83 c4 10             	add    $0x10,%esp
    return -1;
80100bc2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100bc7:	e9 f1 03 00 00       	jmp    80100fbd <exec+0x43d>
  }
  ilock(ip);
80100bcc:	83 ec 0c             	sub    $0xc,%esp
80100bcf:	ff 75 d8             	push   -0x28(%ebp)
80100bd2:	e8 13 0e 00 00       	call   801019ea <ilock>
80100bd7:	83 c4 10             	add    $0x10,%esp
  pgdir = 0;
80100bda:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) != sizeof(elf))
80100be1:	6a 34                	push   $0x34
80100be3:	6a 00                	push   $0x0
80100be5:	8d 85 08 ff ff ff    	lea    -0xf8(%ebp),%eax
80100beb:	50                   	push   %eax
80100bec:	ff 75 d8             	push   -0x28(%ebp)
80100bef:	e8 e2 12 00 00       	call   80101ed6 <readi>
80100bf4:	83 c4 10             	add    $0x10,%esp
80100bf7:	83 f8 34             	cmp    $0x34,%eax
80100bfa:	0f 85 66 03 00 00    	jne    80100f66 <exec+0x3e6>
    goto bad;
  if(elf.magic != ELF_MAGIC)
80100c00:	8b 85 08 ff ff ff    	mov    -0xf8(%ebp),%eax
80100c06:	3d 7f 45 4c 46       	cmp    $0x464c457f,%eax
80100c0b:	0f 85 58 03 00 00    	jne    80100f69 <exec+0x3e9>
    goto bad;

  if((pgdir = setupkvm()) == 0)
80100c11:	e8 3c 6c 00 00       	call   80107852 <setupkvm>
80100c16:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80100c19:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100c1d:	0f 84 49 03 00 00    	je     80100f6c <exec+0x3ec>
    goto bad;

  // Load program into memory.
  sz = 0;
80100c23:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100c2a:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80100c31:	8b 85 24 ff ff ff    	mov    -0xdc(%ebp),%eax
80100c37:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100c3a:	e9 de 00 00 00       	jmp    80100d1d <exec+0x19d>
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
80100c3f:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100c42:	6a 20                	push   $0x20
80100c44:	50                   	push   %eax
80100c45:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
80100c4b:	50                   	push   %eax
80100c4c:	ff 75 d8             	push   -0x28(%ebp)
80100c4f:	e8 82 12 00 00       	call   80101ed6 <readi>
80100c54:	83 c4 10             	add    $0x10,%esp
80100c57:	83 f8 20             	cmp    $0x20,%eax
80100c5a:	0f 85 0f 03 00 00    	jne    80100f6f <exec+0x3ef>
      goto bad;
    if(ph.type != ELF_PROG_LOAD)
80100c60:	8b 85 e8 fe ff ff    	mov    -0x118(%ebp),%eax
80100c66:	83 f8 01             	cmp    $0x1,%eax
80100c69:	0f 85 a0 00 00 00    	jne    80100d0f <exec+0x18f>
      continue;
    if(ph.memsz < ph.filesz)
80100c6f:	8b 95 fc fe ff ff    	mov    -0x104(%ebp),%edx
80100c75:	8b 85 f8 fe ff ff    	mov    -0x108(%ebp),%eax
80100c7b:	39 c2                	cmp    %eax,%edx
80100c7d:	0f 82 ef 02 00 00    	jb     80100f72 <exec+0x3f2>
      goto bad;
    if(ph.vaddr + ph.memsz < ph.vaddr)
80100c83:	8b 95 f0 fe ff ff    	mov    -0x110(%ebp),%edx
80100c89:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax
80100c8f:	01 c2                	add    %eax,%edx
80100c91:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
80100c97:	39 c2                	cmp    %eax,%edx
80100c99:	0f 82 d6 02 00 00    	jb     80100f75 <exec+0x3f5>
      goto bad;
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
80100c9f:	8b 95 f0 fe ff ff    	mov    -0x110(%ebp),%edx
80100ca5:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax
80100cab:	01 d0                	add    %edx,%eax
80100cad:	83 ec 04             	sub    $0x4,%esp
80100cb0:	50                   	push   %eax
80100cb1:	ff 75 e0             	push   -0x20(%ebp)
80100cb4:	ff 75 d4             	push   -0x2c(%ebp)
80100cb7:	e8 8f 6f 00 00       	call   80107c4b <allocuvm>
80100cbc:	83 c4 10             	add    $0x10,%esp
80100cbf:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100cc2:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100cc6:	0f 84 ac 02 00 00    	je     80100f78 <exec+0x3f8>
      goto bad;
    if(ph.vaddr % PGSIZE != 0)
80100ccc:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
80100cd2:	25 ff 0f 00 00       	and    $0xfff,%eax
80100cd7:	85 c0                	test   %eax,%eax
80100cd9:	0f 85 9c 02 00 00    	jne    80100f7b <exec+0x3fb>
      goto bad;
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
80100cdf:	8b 95 f8 fe ff ff    	mov    -0x108(%ebp),%edx
80100ce5:	8b 85 ec fe ff ff    	mov    -0x114(%ebp),%eax
80100ceb:	8b 8d f0 fe ff ff    	mov    -0x110(%ebp),%ecx
80100cf1:	83 ec 0c             	sub    $0xc,%esp
80100cf4:	52                   	push   %edx
80100cf5:	50                   	push   %eax
80100cf6:	ff 75 d8             	push   -0x28(%ebp)
80100cf9:	51                   	push   %ecx
80100cfa:	ff 75 d4             	push   -0x2c(%ebp)
80100cfd:	e8 7c 6e 00 00       	call   80107b7e <loaduvm>
80100d02:	83 c4 20             	add    $0x20,%esp
80100d05:	85 c0                	test   %eax,%eax
80100d07:	0f 88 71 02 00 00    	js     80100f7e <exec+0x3fe>
80100d0d:	eb 01                	jmp    80100d10 <exec+0x190>
      continue;
80100d0f:	90                   	nop
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100d10:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80100d14:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100d17:	83 c0 20             	add    $0x20,%eax
80100d1a:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100d1d:	0f b7 85 34 ff ff ff 	movzwl -0xcc(%ebp),%eax
80100d24:	0f b7 c0             	movzwl %ax,%eax
80100d27:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80100d2a:	0f 8c 0f ff ff ff    	jl     80100c3f <exec+0xbf>
      goto bad;
  }
  iunlockput(ip);
80100d30:	83 ec 0c             	sub    $0xc,%esp
80100d33:	ff 75 d8             	push   -0x28(%ebp)
80100d36:	e8 e0 0e 00 00       	call   80101c1b <iunlockput>
80100d3b:	83 c4 10             	add    $0x10,%esp
  end_op();
80100d3e:	e8 69 28 00 00       	call   801035ac <end_op>
  ip = 0;
80100d43:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)

  // Allocate two pages at the next page boundary.
  // Make the first inaccessible.  Use the second as the user stack.
  sz = PGROUNDUP(sz);
80100d4a:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d4d:	05 ff 0f 00 00       	add    $0xfff,%eax
80100d52:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80100d57:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
80100d5a:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d5d:	05 00 20 00 00       	add    $0x2000,%eax
80100d62:	83 ec 04             	sub    $0x4,%esp
80100d65:	50                   	push   %eax
80100d66:	ff 75 e0             	push   -0x20(%ebp)
80100d69:	ff 75 d4             	push   -0x2c(%ebp)
80100d6c:	e8 da 6e 00 00       	call   80107c4b <allocuvm>
80100d71:	83 c4 10             	add    $0x10,%esp
80100d74:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100d77:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100d7b:	0f 84 00 02 00 00    	je     80100f81 <exec+0x401>
    goto bad;
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
80100d81:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d84:	2d 00 20 00 00       	sub    $0x2000,%eax
80100d89:	83 ec 08             	sub    $0x8,%esp
80100d8c:	50                   	push   %eax
80100d8d:	ff 75 d4             	push   -0x2c(%ebp)
80100d90:	e8 18 71 00 00       	call   80107ead <clearpteu>
80100d95:	83 c4 10             	add    $0x10,%esp
  sp = sz;
80100d98:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d9b:	89 45 dc             	mov    %eax,-0x24(%ebp)

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100d9e:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80100da5:	e9 96 00 00 00       	jmp    80100e40 <exec+0x2c0>
    if(argc >= MAXARG)
80100daa:	83 7d e4 1f          	cmpl   $0x1f,-0x1c(%ebp)
80100dae:	0f 87 d0 01 00 00    	ja     80100f84 <exec+0x404>
      goto bad;
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
80100db4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100db7:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100dbe:	8b 45 0c             	mov    0xc(%ebp),%eax
80100dc1:	01 d0                	add    %edx,%eax
80100dc3:	8b 00                	mov    (%eax),%eax
80100dc5:	83 ec 0c             	sub    $0xc,%esp
80100dc8:	50                   	push   %eax
80100dc9:	e8 e3 42 00 00       	call   801050b1 <strlen>
80100dce:	83 c4 10             	add    $0x10,%esp
80100dd1:	89 c2                	mov    %eax,%edx
80100dd3:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100dd6:	29 d0                	sub    %edx,%eax
80100dd8:	83 e8 01             	sub    $0x1,%eax
80100ddb:	83 e0 fc             	and    $0xfffffffc,%eax
80100dde:	89 45 dc             	mov    %eax,-0x24(%ebp)
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80100de1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100de4:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100deb:	8b 45 0c             	mov    0xc(%ebp),%eax
80100dee:	01 d0                	add    %edx,%eax
80100df0:	8b 00                	mov    (%eax),%eax
80100df2:	83 ec 0c             	sub    $0xc,%esp
80100df5:	50                   	push   %eax
80100df6:	e8 b6 42 00 00       	call   801050b1 <strlen>
80100dfb:	83 c4 10             	add    $0x10,%esp
80100dfe:	83 c0 01             	add    $0x1,%eax
80100e01:	89 c2                	mov    %eax,%edx
80100e03:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e06:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
80100e0d:	8b 45 0c             	mov    0xc(%ebp),%eax
80100e10:	01 c8                	add    %ecx,%eax
80100e12:	8b 00                	mov    (%eax),%eax
80100e14:	52                   	push   %edx
80100e15:	50                   	push   %eax
80100e16:	ff 75 dc             	push   -0x24(%ebp)
80100e19:	ff 75 d4             	push   -0x2c(%ebp)
80100e1c:	e8 2b 72 00 00       	call   8010804c <copyout>
80100e21:	83 c4 10             	add    $0x10,%esp
80100e24:	85 c0                	test   %eax,%eax
80100e26:	0f 88 5b 01 00 00    	js     80100f87 <exec+0x407>
      goto bad;
    ustack[3+argc] = sp;
80100e2c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e2f:	8d 50 03             	lea    0x3(%eax),%edx
80100e32:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100e35:	89 84 95 3c ff ff ff 	mov    %eax,-0xc4(%ebp,%edx,4)
  for(argc = 0; argv[argc]; argc++) {
80100e3c:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80100e40:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e43:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100e4a:	8b 45 0c             	mov    0xc(%ebp),%eax
80100e4d:	01 d0                	add    %edx,%eax
80100e4f:	8b 00                	mov    (%eax),%eax
80100e51:	85 c0                	test   %eax,%eax
80100e53:	0f 85 51 ff ff ff    	jne    80100daa <exec+0x22a>
  }
  ustack[3+argc] = 0;
80100e59:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e5c:	83 c0 03             	add    $0x3,%eax
80100e5f:	c7 84 85 3c ff ff ff 	movl   $0x0,-0xc4(%ebp,%eax,4)
80100e66:	00 00 00 00 

  ustack[0] = 0xffffffff;  // fake return PC
80100e6a:	c7 85 3c ff ff ff ff 	movl   $0xffffffff,-0xc4(%ebp)
80100e71:	ff ff ff 
  ustack[1] = argc;
80100e74:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e77:	89 85 40 ff ff ff    	mov    %eax,-0xc0(%ebp)
  ustack[2] = sp - (argc+1)*4;  // argv pointer
80100e7d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e80:	83 c0 01             	add    $0x1,%eax
80100e83:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100e8a:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100e8d:	29 d0                	sub    %edx,%eax
80100e8f:	89 85 44 ff ff ff    	mov    %eax,-0xbc(%ebp)

  sp -= (3+argc+1) * 4;
80100e95:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e98:	83 c0 04             	add    $0x4,%eax
80100e9b:	c1 e0 02             	shl    $0x2,%eax
80100e9e:	29 45 dc             	sub    %eax,-0x24(%ebp)
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
80100ea1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100ea4:	83 c0 04             	add    $0x4,%eax
80100ea7:	c1 e0 02             	shl    $0x2,%eax
80100eaa:	50                   	push   %eax
80100eab:	8d 85 3c ff ff ff    	lea    -0xc4(%ebp),%eax
80100eb1:	50                   	push   %eax
80100eb2:	ff 75 dc             	push   -0x24(%ebp)
80100eb5:	ff 75 d4             	push   -0x2c(%ebp)
80100eb8:	e8 8f 71 00 00       	call   8010804c <copyout>
80100ebd:	83 c4 10             	add    $0x10,%esp
80100ec0:	85 c0                	test   %eax,%eax
80100ec2:	0f 88 c2 00 00 00    	js     80100f8a <exec+0x40a>
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80100ec8:	8b 45 08             	mov    0x8(%ebp),%eax
80100ecb:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100ece:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100ed1:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100ed4:	eb 17                	jmp    80100eed <exec+0x36d>
    if(*s == '/')
80100ed6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100ed9:	0f b6 00             	movzbl (%eax),%eax
80100edc:	3c 2f                	cmp    $0x2f,%al
80100ede:	75 09                	jne    80100ee9 <exec+0x369>
      last = s+1;
80100ee0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100ee3:	83 c0 01             	add    $0x1,%eax
80100ee6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(last=s=path; *s; s++)
80100ee9:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100eed:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100ef0:	0f b6 00             	movzbl (%eax),%eax
80100ef3:	84 c0                	test   %al,%al
80100ef5:	75 df                	jne    80100ed6 <exec+0x356>
  safestrcpy(curproc->name, last, sizeof(curproc->name));
80100ef7:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100efa:	83 c0 6c             	add    $0x6c,%eax
80100efd:	83 ec 04             	sub    $0x4,%esp
80100f00:	6a 10                	push   $0x10
80100f02:	ff 75 f0             	push   -0x10(%ebp)
80100f05:	50                   	push   %eax
80100f06:	e8 5b 41 00 00       	call   80105066 <safestrcpy>
80100f0b:	83 c4 10             	add    $0x10,%esp

  // Commit to the user image.
  oldpgdir = curproc->pgdir;
80100f0e:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f11:	8b 40 04             	mov    0x4(%eax),%eax
80100f14:	89 45 cc             	mov    %eax,-0x34(%ebp)
  curproc->pgdir = pgdir;
80100f17:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f1a:	8b 55 d4             	mov    -0x2c(%ebp),%edx
80100f1d:	89 50 04             	mov    %edx,0x4(%eax)
  curproc->sz = sz;
80100f20:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f23:	8b 55 e0             	mov    -0x20(%ebp),%edx
80100f26:	89 10                	mov    %edx,(%eax)
  curproc->tf->eip = elf.entry;  // main
80100f28:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f2b:	8b 40 18             	mov    0x18(%eax),%eax
80100f2e:	8b 95 20 ff ff ff    	mov    -0xe0(%ebp),%edx
80100f34:	89 50 38             	mov    %edx,0x38(%eax)
  curproc->tf->esp = sp;
80100f37:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f3a:	8b 40 18             	mov    0x18(%eax),%eax
80100f3d:	8b 55 dc             	mov    -0x24(%ebp),%edx
80100f40:	89 50 44             	mov    %edx,0x44(%eax)
  switchuvm(curproc);
80100f43:	83 ec 0c             	sub    $0xc,%esp
80100f46:	ff 75 d0             	push   -0x30(%ebp)
80100f49:	e8 21 6a 00 00       	call   8010796f <switchuvm>
80100f4e:	83 c4 10             	add    $0x10,%esp
  freevm(oldpgdir);
80100f51:	83 ec 0c             	sub    $0xc,%esp
80100f54:	ff 75 cc             	push   -0x34(%ebp)
80100f57:	e8 b8 6e 00 00       	call   80107e14 <freevm>
80100f5c:	83 c4 10             	add    $0x10,%esp
  return 0;
80100f5f:	b8 00 00 00 00       	mov    $0x0,%eax
80100f64:	eb 57                	jmp    80100fbd <exec+0x43d>
    goto bad;
80100f66:	90                   	nop
80100f67:	eb 22                	jmp    80100f8b <exec+0x40b>
    goto bad;
80100f69:	90                   	nop
80100f6a:	eb 1f                	jmp    80100f8b <exec+0x40b>
    goto bad;
80100f6c:	90                   	nop
80100f6d:	eb 1c                	jmp    80100f8b <exec+0x40b>
      goto bad;
80100f6f:	90                   	nop
80100f70:	eb 19                	jmp    80100f8b <exec+0x40b>
      goto bad;
80100f72:	90                   	nop
80100f73:	eb 16                	jmp    80100f8b <exec+0x40b>
      goto bad;
80100f75:	90                   	nop
80100f76:	eb 13                	jmp    80100f8b <exec+0x40b>
      goto bad;
80100f78:	90                   	nop
80100f79:	eb 10                	jmp    80100f8b <exec+0x40b>
      goto bad;
80100f7b:	90                   	nop
80100f7c:	eb 0d                	jmp    80100f8b <exec+0x40b>
      goto bad;
80100f7e:	90                   	nop
80100f7f:	eb 0a                	jmp    80100f8b <exec+0x40b>
    goto bad;
80100f81:	90                   	nop
80100f82:	eb 07                	jmp    80100f8b <exec+0x40b>
      goto bad;
80100f84:	90                   	nop
80100f85:	eb 04                	jmp    80100f8b <exec+0x40b>
      goto bad;
80100f87:	90                   	nop
80100f88:	eb 01                	jmp    80100f8b <exec+0x40b>
    goto bad;
80100f8a:	90                   	nop

 bad:
  if(pgdir)
80100f8b:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100f8f:	74 0e                	je     80100f9f <exec+0x41f>
    freevm(pgdir);
80100f91:	83 ec 0c             	sub    $0xc,%esp
80100f94:	ff 75 d4             	push   -0x2c(%ebp)
80100f97:	e8 78 6e 00 00       	call   80107e14 <freevm>
80100f9c:	83 c4 10             	add    $0x10,%esp
  if(ip){
80100f9f:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100fa3:	74 13                	je     80100fb8 <exec+0x438>
    iunlockput(ip);
80100fa5:	83 ec 0c             	sub    $0xc,%esp
80100fa8:	ff 75 d8             	push   -0x28(%ebp)
80100fab:	e8 6b 0c 00 00       	call   80101c1b <iunlockput>
80100fb0:	83 c4 10             	add    $0x10,%esp
    end_op();
80100fb3:	e8 f4 25 00 00       	call   801035ac <end_op>
  }
  return -1;
80100fb8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80100fbd:	c9                   	leave  
80100fbe:	c3                   	ret    

80100fbf <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
80100fbf:	55                   	push   %ebp
80100fc0:	89 e5                	mov    %esp,%ebp
80100fc2:	83 ec 08             	sub    $0x8,%esp
  initlock(&ftable.lock, "ftable");
80100fc5:	83 ec 08             	sub    $0x8,%esp
80100fc8:	68 01 a5 10 80       	push   $0x8010a501
80100fcd:	68 a0 4a 11 80       	push   $0x80114aa0
80100fd2:	e8 f4 3b 00 00       	call   80104bcb <initlock>
80100fd7:	83 c4 10             	add    $0x10,%esp
}
80100fda:	90                   	nop
80100fdb:	c9                   	leave  
80100fdc:	c3                   	ret    

80100fdd <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
80100fdd:	55                   	push   %ebp
80100fde:	89 e5                	mov    %esp,%ebp
80100fe0:	83 ec 18             	sub    $0x18,%esp
  struct file *f;

  acquire(&ftable.lock);
80100fe3:	83 ec 0c             	sub    $0xc,%esp
80100fe6:	68 a0 4a 11 80       	push   $0x80114aa0
80100feb:	e8 fd 3b 00 00       	call   80104bed <acquire>
80100ff0:	83 c4 10             	add    $0x10,%esp
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80100ff3:	c7 45 f4 d4 4a 11 80 	movl   $0x80114ad4,-0xc(%ebp)
80100ffa:	eb 2d                	jmp    80101029 <filealloc+0x4c>
    if(f->ref == 0){
80100ffc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100fff:	8b 40 04             	mov    0x4(%eax),%eax
80101002:	85 c0                	test   %eax,%eax
80101004:	75 1f                	jne    80101025 <filealloc+0x48>
      f->ref = 1;
80101006:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101009:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
      release(&ftable.lock);
80101010:	83 ec 0c             	sub    $0xc,%esp
80101013:	68 a0 4a 11 80       	push   $0x80114aa0
80101018:	e8 3e 3c 00 00       	call   80104c5b <release>
8010101d:	83 c4 10             	add    $0x10,%esp
      return f;
80101020:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101023:	eb 23                	jmp    80101048 <filealloc+0x6b>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80101025:	83 45 f4 18          	addl   $0x18,-0xc(%ebp)
80101029:	b8 34 54 11 80       	mov    $0x80115434,%eax
8010102e:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80101031:	72 c9                	jb     80100ffc <filealloc+0x1f>
    }
  }
  release(&ftable.lock);
80101033:	83 ec 0c             	sub    $0xc,%esp
80101036:	68 a0 4a 11 80       	push   $0x80114aa0
8010103b:	e8 1b 3c 00 00       	call   80104c5b <release>
80101040:	83 c4 10             	add    $0x10,%esp
  return 0;
80101043:	b8 00 00 00 00       	mov    $0x0,%eax
}
80101048:	c9                   	leave  
80101049:	c3                   	ret    

8010104a <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
8010104a:	55                   	push   %ebp
8010104b:	89 e5                	mov    %esp,%ebp
8010104d:	83 ec 08             	sub    $0x8,%esp
  acquire(&ftable.lock);
80101050:	83 ec 0c             	sub    $0xc,%esp
80101053:	68 a0 4a 11 80       	push   $0x80114aa0
80101058:	e8 90 3b 00 00       	call   80104bed <acquire>
8010105d:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
80101060:	8b 45 08             	mov    0x8(%ebp),%eax
80101063:	8b 40 04             	mov    0x4(%eax),%eax
80101066:	85 c0                	test   %eax,%eax
80101068:	7f 0d                	jg     80101077 <filedup+0x2d>
    panic("filedup");
8010106a:	83 ec 0c             	sub    $0xc,%esp
8010106d:	68 08 a5 10 80       	push   $0x8010a508
80101072:	e8 32 f5 ff ff       	call   801005a9 <panic>
  f->ref++;
80101077:	8b 45 08             	mov    0x8(%ebp),%eax
8010107a:	8b 40 04             	mov    0x4(%eax),%eax
8010107d:	8d 50 01             	lea    0x1(%eax),%edx
80101080:	8b 45 08             	mov    0x8(%ebp),%eax
80101083:	89 50 04             	mov    %edx,0x4(%eax)
  release(&ftable.lock);
80101086:	83 ec 0c             	sub    $0xc,%esp
80101089:	68 a0 4a 11 80       	push   $0x80114aa0
8010108e:	e8 c8 3b 00 00       	call   80104c5b <release>
80101093:	83 c4 10             	add    $0x10,%esp
  return f;
80101096:	8b 45 08             	mov    0x8(%ebp),%eax
}
80101099:	c9                   	leave  
8010109a:	c3                   	ret    

8010109b <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
8010109b:	55                   	push   %ebp
8010109c:	89 e5                	mov    %esp,%ebp
8010109e:	83 ec 28             	sub    $0x28,%esp
  struct file ff;

  acquire(&ftable.lock);
801010a1:	83 ec 0c             	sub    $0xc,%esp
801010a4:	68 a0 4a 11 80       	push   $0x80114aa0
801010a9:	e8 3f 3b 00 00       	call   80104bed <acquire>
801010ae:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
801010b1:	8b 45 08             	mov    0x8(%ebp),%eax
801010b4:	8b 40 04             	mov    0x4(%eax),%eax
801010b7:	85 c0                	test   %eax,%eax
801010b9:	7f 0d                	jg     801010c8 <fileclose+0x2d>
    panic("fileclose");
801010bb:	83 ec 0c             	sub    $0xc,%esp
801010be:	68 10 a5 10 80       	push   $0x8010a510
801010c3:	e8 e1 f4 ff ff       	call   801005a9 <panic>
  if(--f->ref > 0){
801010c8:	8b 45 08             	mov    0x8(%ebp),%eax
801010cb:	8b 40 04             	mov    0x4(%eax),%eax
801010ce:	8d 50 ff             	lea    -0x1(%eax),%edx
801010d1:	8b 45 08             	mov    0x8(%ebp),%eax
801010d4:	89 50 04             	mov    %edx,0x4(%eax)
801010d7:	8b 45 08             	mov    0x8(%ebp),%eax
801010da:	8b 40 04             	mov    0x4(%eax),%eax
801010dd:	85 c0                	test   %eax,%eax
801010df:	7e 15                	jle    801010f6 <fileclose+0x5b>
    release(&ftable.lock);
801010e1:	83 ec 0c             	sub    $0xc,%esp
801010e4:	68 a0 4a 11 80       	push   $0x80114aa0
801010e9:	e8 6d 3b 00 00       	call   80104c5b <release>
801010ee:	83 c4 10             	add    $0x10,%esp
801010f1:	e9 8b 00 00 00       	jmp    80101181 <fileclose+0xe6>
    return;
  }
  ff = *f;
801010f6:	8b 45 08             	mov    0x8(%ebp),%eax
801010f9:	8b 10                	mov    (%eax),%edx
801010fb:	89 55 e0             	mov    %edx,-0x20(%ebp)
801010fe:	8b 50 04             	mov    0x4(%eax),%edx
80101101:	89 55 e4             	mov    %edx,-0x1c(%ebp)
80101104:	8b 50 08             	mov    0x8(%eax),%edx
80101107:	89 55 e8             	mov    %edx,-0x18(%ebp)
8010110a:	8b 50 0c             	mov    0xc(%eax),%edx
8010110d:	89 55 ec             	mov    %edx,-0x14(%ebp)
80101110:	8b 50 10             	mov    0x10(%eax),%edx
80101113:	89 55 f0             	mov    %edx,-0x10(%ebp)
80101116:	8b 40 14             	mov    0x14(%eax),%eax
80101119:	89 45 f4             	mov    %eax,-0xc(%ebp)
  f->ref = 0;
8010111c:	8b 45 08             	mov    0x8(%ebp),%eax
8010111f:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  f->type = FD_NONE;
80101126:	8b 45 08             	mov    0x8(%ebp),%eax
80101129:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  release(&ftable.lock);
8010112f:	83 ec 0c             	sub    $0xc,%esp
80101132:	68 a0 4a 11 80       	push   $0x80114aa0
80101137:	e8 1f 3b 00 00       	call   80104c5b <release>
8010113c:	83 c4 10             	add    $0x10,%esp

  if(ff.type == FD_PIPE)
8010113f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101142:	83 f8 01             	cmp    $0x1,%eax
80101145:	75 19                	jne    80101160 <fileclose+0xc5>
    pipeclose(ff.pipe, ff.writable);
80101147:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
8010114b:	0f be d0             	movsbl %al,%edx
8010114e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101151:	83 ec 08             	sub    $0x8,%esp
80101154:	52                   	push   %edx
80101155:	50                   	push   %eax
80101156:	e8 48 2a 00 00       	call   80103ba3 <pipeclose>
8010115b:	83 c4 10             	add    $0x10,%esp
8010115e:	eb 21                	jmp    80101181 <fileclose+0xe6>
  else if(ff.type == FD_INODE){
80101160:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101163:	83 f8 02             	cmp    $0x2,%eax
80101166:	75 19                	jne    80101181 <fileclose+0xe6>
    begin_op();
80101168:	e8 b3 23 00 00       	call   80103520 <begin_op>
    iput(ff.ip);
8010116d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101170:	83 ec 0c             	sub    $0xc,%esp
80101173:	50                   	push   %eax
80101174:	e8 d2 09 00 00       	call   80101b4b <iput>
80101179:	83 c4 10             	add    $0x10,%esp
    end_op();
8010117c:	e8 2b 24 00 00       	call   801035ac <end_op>
  }
}
80101181:	c9                   	leave  
80101182:	c3                   	ret    

80101183 <filestat>:

// Get metadata about file f.
int
filestat(struct file *f, struct stat *st)
{
80101183:	55                   	push   %ebp
80101184:	89 e5                	mov    %esp,%ebp
80101186:	83 ec 08             	sub    $0x8,%esp
  if(f->type == FD_INODE){
80101189:	8b 45 08             	mov    0x8(%ebp),%eax
8010118c:	8b 00                	mov    (%eax),%eax
8010118e:	83 f8 02             	cmp    $0x2,%eax
80101191:	75 40                	jne    801011d3 <filestat+0x50>
    ilock(f->ip);
80101193:	8b 45 08             	mov    0x8(%ebp),%eax
80101196:	8b 40 10             	mov    0x10(%eax),%eax
80101199:	83 ec 0c             	sub    $0xc,%esp
8010119c:	50                   	push   %eax
8010119d:	e8 48 08 00 00       	call   801019ea <ilock>
801011a2:	83 c4 10             	add    $0x10,%esp
    stati(f->ip, st);
801011a5:	8b 45 08             	mov    0x8(%ebp),%eax
801011a8:	8b 40 10             	mov    0x10(%eax),%eax
801011ab:	83 ec 08             	sub    $0x8,%esp
801011ae:	ff 75 0c             	push   0xc(%ebp)
801011b1:	50                   	push   %eax
801011b2:	e8 d9 0c 00 00       	call   80101e90 <stati>
801011b7:	83 c4 10             	add    $0x10,%esp
    iunlock(f->ip);
801011ba:	8b 45 08             	mov    0x8(%ebp),%eax
801011bd:	8b 40 10             	mov    0x10(%eax),%eax
801011c0:	83 ec 0c             	sub    $0xc,%esp
801011c3:	50                   	push   %eax
801011c4:	e8 34 09 00 00       	call   80101afd <iunlock>
801011c9:	83 c4 10             	add    $0x10,%esp
    return 0;
801011cc:	b8 00 00 00 00       	mov    $0x0,%eax
801011d1:	eb 05                	jmp    801011d8 <filestat+0x55>
  }
  return -1;
801011d3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801011d8:	c9                   	leave  
801011d9:	c3                   	ret    

801011da <fileread>:

// Read from file f.
int
fileread(struct file *f, char *addr, int n)
{
801011da:	55                   	push   %ebp
801011db:	89 e5                	mov    %esp,%ebp
801011dd:	83 ec 18             	sub    $0x18,%esp
  int r;

  if(f->readable == 0)
801011e0:	8b 45 08             	mov    0x8(%ebp),%eax
801011e3:	0f b6 40 08          	movzbl 0x8(%eax),%eax
801011e7:	84 c0                	test   %al,%al
801011e9:	75 0a                	jne    801011f5 <fileread+0x1b>
    return -1;
801011eb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801011f0:	e9 9b 00 00 00       	jmp    80101290 <fileread+0xb6>
  if(f->type == FD_PIPE)
801011f5:	8b 45 08             	mov    0x8(%ebp),%eax
801011f8:	8b 00                	mov    (%eax),%eax
801011fa:	83 f8 01             	cmp    $0x1,%eax
801011fd:	75 1a                	jne    80101219 <fileread+0x3f>
    return piperead(f->pipe, addr, n);
801011ff:	8b 45 08             	mov    0x8(%ebp),%eax
80101202:	8b 40 0c             	mov    0xc(%eax),%eax
80101205:	83 ec 04             	sub    $0x4,%esp
80101208:	ff 75 10             	push   0x10(%ebp)
8010120b:	ff 75 0c             	push   0xc(%ebp)
8010120e:	50                   	push   %eax
8010120f:	e8 3c 2b 00 00       	call   80103d50 <piperead>
80101214:	83 c4 10             	add    $0x10,%esp
80101217:	eb 77                	jmp    80101290 <fileread+0xb6>
  if(f->type == FD_INODE){
80101219:	8b 45 08             	mov    0x8(%ebp),%eax
8010121c:	8b 00                	mov    (%eax),%eax
8010121e:	83 f8 02             	cmp    $0x2,%eax
80101221:	75 60                	jne    80101283 <fileread+0xa9>
    ilock(f->ip);
80101223:	8b 45 08             	mov    0x8(%ebp),%eax
80101226:	8b 40 10             	mov    0x10(%eax),%eax
80101229:	83 ec 0c             	sub    $0xc,%esp
8010122c:	50                   	push   %eax
8010122d:	e8 b8 07 00 00       	call   801019ea <ilock>
80101232:	83 c4 10             	add    $0x10,%esp
    if((r = readi(f->ip, addr, f->off, n)) > 0)
80101235:	8b 4d 10             	mov    0x10(%ebp),%ecx
80101238:	8b 45 08             	mov    0x8(%ebp),%eax
8010123b:	8b 50 14             	mov    0x14(%eax),%edx
8010123e:	8b 45 08             	mov    0x8(%ebp),%eax
80101241:	8b 40 10             	mov    0x10(%eax),%eax
80101244:	51                   	push   %ecx
80101245:	52                   	push   %edx
80101246:	ff 75 0c             	push   0xc(%ebp)
80101249:	50                   	push   %eax
8010124a:	e8 87 0c 00 00       	call   80101ed6 <readi>
8010124f:	83 c4 10             	add    $0x10,%esp
80101252:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101255:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101259:	7e 11                	jle    8010126c <fileread+0x92>
      f->off += r;
8010125b:	8b 45 08             	mov    0x8(%ebp),%eax
8010125e:	8b 50 14             	mov    0x14(%eax),%edx
80101261:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101264:	01 c2                	add    %eax,%edx
80101266:	8b 45 08             	mov    0x8(%ebp),%eax
80101269:	89 50 14             	mov    %edx,0x14(%eax)
    iunlock(f->ip);
8010126c:	8b 45 08             	mov    0x8(%ebp),%eax
8010126f:	8b 40 10             	mov    0x10(%eax),%eax
80101272:	83 ec 0c             	sub    $0xc,%esp
80101275:	50                   	push   %eax
80101276:	e8 82 08 00 00       	call   80101afd <iunlock>
8010127b:	83 c4 10             	add    $0x10,%esp
    return r;
8010127e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101281:	eb 0d                	jmp    80101290 <fileread+0xb6>
  }
  panic("fileread");
80101283:	83 ec 0c             	sub    $0xc,%esp
80101286:	68 1a a5 10 80       	push   $0x8010a51a
8010128b:	e8 19 f3 ff ff       	call   801005a9 <panic>
}
80101290:	c9                   	leave  
80101291:	c3                   	ret    

80101292 <filewrite>:

//PAGEBREAK!
// Write to file f.
int
filewrite(struct file *f, char *addr, int n)
{
80101292:	55                   	push   %ebp
80101293:	89 e5                	mov    %esp,%ebp
80101295:	53                   	push   %ebx
80101296:	83 ec 14             	sub    $0x14,%esp
  int r;

  if(f->writable == 0)
80101299:	8b 45 08             	mov    0x8(%ebp),%eax
8010129c:	0f b6 40 09          	movzbl 0x9(%eax),%eax
801012a0:	84 c0                	test   %al,%al
801012a2:	75 0a                	jne    801012ae <filewrite+0x1c>
    return -1;
801012a4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801012a9:	e9 1b 01 00 00       	jmp    801013c9 <filewrite+0x137>
  if(f->type == FD_PIPE)
801012ae:	8b 45 08             	mov    0x8(%ebp),%eax
801012b1:	8b 00                	mov    (%eax),%eax
801012b3:	83 f8 01             	cmp    $0x1,%eax
801012b6:	75 1d                	jne    801012d5 <filewrite+0x43>
    return pipewrite(f->pipe, addr, n);
801012b8:	8b 45 08             	mov    0x8(%ebp),%eax
801012bb:	8b 40 0c             	mov    0xc(%eax),%eax
801012be:	83 ec 04             	sub    $0x4,%esp
801012c1:	ff 75 10             	push   0x10(%ebp)
801012c4:	ff 75 0c             	push   0xc(%ebp)
801012c7:	50                   	push   %eax
801012c8:	e8 81 29 00 00       	call   80103c4e <pipewrite>
801012cd:	83 c4 10             	add    $0x10,%esp
801012d0:	e9 f4 00 00 00       	jmp    801013c9 <filewrite+0x137>
  if(f->type == FD_INODE){
801012d5:	8b 45 08             	mov    0x8(%ebp),%eax
801012d8:	8b 00                	mov    (%eax),%eax
801012da:	83 f8 02             	cmp    $0x2,%eax
801012dd:	0f 85 d9 00 00 00    	jne    801013bc <filewrite+0x12a>
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * 512;
801012e3:	c7 45 ec 00 06 00 00 	movl   $0x600,-0x14(%ebp)
    int i = 0;
801012ea:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while(i < n){
801012f1:	e9 a3 00 00 00       	jmp    80101399 <filewrite+0x107>
      int n1 = n - i;
801012f6:	8b 45 10             	mov    0x10(%ebp),%eax
801012f9:	2b 45 f4             	sub    -0xc(%ebp),%eax
801012fc:	89 45 f0             	mov    %eax,-0x10(%ebp)
      if(n1 > max)
801012ff:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101302:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80101305:	7e 06                	jle    8010130d <filewrite+0x7b>
        n1 = max;
80101307:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010130a:	89 45 f0             	mov    %eax,-0x10(%ebp)

      begin_op();
8010130d:	e8 0e 22 00 00       	call   80103520 <begin_op>
      ilock(f->ip);
80101312:	8b 45 08             	mov    0x8(%ebp),%eax
80101315:	8b 40 10             	mov    0x10(%eax),%eax
80101318:	83 ec 0c             	sub    $0xc,%esp
8010131b:	50                   	push   %eax
8010131c:	e8 c9 06 00 00       	call   801019ea <ilock>
80101321:	83 c4 10             	add    $0x10,%esp
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
80101324:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80101327:	8b 45 08             	mov    0x8(%ebp),%eax
8010132a:	8b 50 14             	mov    0x14(%eax),%edx
8010132d:	8b 5d f4             	mov    -0xc(%ebp),%ebx
80101330:	8b 45 0c             	mov    0xc(%ebp),%eax
80101333:	01 c3                	add    %eax,%ebx
80101335:	8b 45 08             	mov    0x8(%ebp),%eax
80101338:	8b 40 10             	mov    0x10(%eax),%eax
8010133b:	51                   	push   %ecx
8010133c:	52                   	push   %edx
8010133d:	53                   	push   %ebx
8010133e:	50                   	push   %eax
8010133f:	e8 e7 0c 00 00       	call   8010202b <writei>
80101344:	83 c4 10             	add    $0x10,%esp
80101347:	89 45 e8             	mov    %eax,-0x18(%ebp)
8010134a:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
8010134e:	7e 11                	jle    80101361 <filewrite+0xcf>
        f->off += r;
80101350:	8b 45 08             	mov    0x8(%ebp),%eax
80101353:	8b 50 14             	mov    0x14(%eax),%edx
80101356:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101359:	01 c2                	add    %eax,%edx
8010135b:	8b 45 08             	mov    0x8(%ebp),%eax
8010135e:	89 50 14             	mov    %edx,0x14(%eax)
      iunlock(f->ip);
80101361:	8b 45 08             	mov    0x8(%ebp),%eax
80101364:	8b 40 10             	mov    0x10(%eax),%eax
80101367:	83 ec 0c             	sub    $0xc,%esp
8010136a:	50                   	push   %eax
8010136b:	e8 8d 07 00 00       	call   80101afd <iunlock>
80101370:	83 c4 10             	add    $0x10,%esp
      end_op();
80101373:	e8 34 22 00 00       	call   801035ac <end_op>

      if(r < 0)
80101378:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
8010137c:	78 29                	js     801013a7 <filewrite+0x115>
        break;
      if(r != n1)
8010137e:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101381:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80101384:	74 0d                	je     80101393 <filewrite+0x101>
        panic("short filewrite");
80101386:	83 ec 0c             	sub    $0xc,%esp
80101389:	68 23 a5 10 80       	push   $0x8010a523
8010138e:	e8 16 f2 ff ff       	call   801005a9 <panic>
      i += r;
80101393:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101396:	01 45 f4             	add    %eax,-0xc(%ebp)
    while(i < n){
80101399:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010139c:	3b 45 10             	cmp    0x10(%ebp),%eax
8010139f:	0f 8c 51 ff ff ff    	jl     801012f6 <filewrite+0x64>
801013a5:	eb 01                	jmp    801013a8 <filewrite+0x116>
        break;
801013a7:	90                   	nop
    }
    return i == n ? n : -1;
801013a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801013ab:	3b 45 10             	cmp    0x10(%ebp),%eax
801013ae:	75 05                	jne    801013b5 <filewrite+0x123>
801013b0:	8b 45 10             	mov    0x10(%ebp),%eax
801013b3:	eb 14                	jmp    801013c9 <filewrite+0x137>
801013b5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801013ba:	eb 0d                	jmp    801013c9 <filewrite+0x137>
  }
  panic("filewrite");
801013bc:	83 ec 0c             	sub    $0xc,%esp
801013bf:	68 33 a5 10 80       	push   $0x8010a533
801013c4:	e8 e0 f1 ff ff       	call   801005a9 <panic>
}
801013c9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801013cc:	c9                   	leave  
801013cd:	c3                   	ret    

801013ce <readsb>:
struct superblock sb; 

// Read the super block.
void
readsb(int dev, struct superblock *sb)
{
801013ce:	55                   	push   %ebp
801013cf:	89 e5                	mov    %esp,%ebp
801013d1:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;

  bp = bread(dev, 1);
801013d4:	8b 45 08             	mov    0x8(%ebp),%eax
801013d7:	83 ec 08             	sub    $0x8,%esp
801013da:	6a 01                	push   $0x1
801013dc:	50                   	push   %eax
801013dd:	e8 1f ee ff ff       	call   80100201 <bread>
801013e2:	83 c4 10             	add    $0x10,%esp
801013e5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove(sb, bp->data, sizeof(*sb));
801013e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801013eb:	83 c0 5c             	add    $0x5c,%eax
801013ee:	83 ec 04             	sub    $0x4,%esp
801013f1:	6a 1c                	push   $0x1c
801013f3:	50                   	push   %eax
801013f4:	ff 75 0c             	push   0xc(%ebp)
801013f7:	e8 26 3b 00 00       	call   80104f22 <memmove>
801013fc:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
801013ff:	83 ec 0c             	sub    $0xc,%esp
80101402:	ff 75 f4             	push   -0xc(%ebp)
80101405:	e8 79 ee ff ff       	call   80100283 <brelse>
8010140a:	83 c4 10             	add    $0x10,%esp
}
8010140d:	90                   	nop
8010140e:	c9                   	leave  
8010140f:	c3                   	ret    

80101410 <bzero>:

// Zero a block.
static void
bzero(int dev, int bno)
{
80101410:	55                   	push   %ebp
80101411:	89 e5                	mov    %esp,%ebp
80101413:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;

  bp = bread(dev, bno);
80101416:	8b 55 0c             	mov    0xc(%ebp),%edx
80101419:	8b 45 08             	mov    0x8(%ebp),%eax
8010141c:	83 ec 08             	sub    $0x8,%esp
8010141f:	52                   	push   %edx
80101420:	50                   	push   %eax
80101421:	e8 db ed ff ff       	call   80100201 <bread>
80101426:	83 c4 10             	add    $0x10,%esp
80101429:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(bp->data, 0, BSIZE);
8010142c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010142f:	83 c0 5c             	add    $0x5c,%eax
80101432:	83 ec 04             	sub    $0x4,%esp
80101435:	68 00 02 00 00       	push   $0x200
8010143a:	6a 00                	push   $0x0
8010143c:	50                   	push   %eax
8010143d:	e8 21 3a 00 00       	call   80104e63 <memset>
80101442:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
80101445:	83 ec 0c             	sub    $0xc,%esp
80101448:	ff 75 f4             	push   -0xc(%ebp)
8010144b:	e8 09 23 00 00       	call   80103759 <log_write>
80101450:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
80101453:	83 ec 0c             	sub    $0xc,%esp
80101456:	ff 75 f4             	push   -0xc(%ebp)
80101459:	e8 25 ee ff ff       	call   80100283 <brelse>
8010145e:	83 c4 10             	add    $0x10,%esp
}
80101461:	90                   	nop
80101462:	c9                   	leave  
80101463:	c3                   	ret    

80101464 <balloc>:
// Blocks.

// Allocate a zeroed disk block.
static uint
balloc(uint dev)
{
80101464:	55                   	push   %ebp
80101465:	89 e5                	mov    %esp,%ebp
80101467:	83 ec 18             	sub    $0x18,%esp
  int b, bi, m;
  struct buf *bp;

  bp = 0;
8010146a:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(b = 0; b < sb.size; b += BPB){
80101471:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101478:	e9 0b 01 00 00       	jmp    80101588 <balloc+0x124>
    bp = bread(dev, BBLOCK(b, sb));
8010147d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101480:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
80101486:	85 c0                	test   %eax,%eax
80101488:	0f 48 c2             	cmovs  %edx,%eax
8010148b:	c1 f8 0c             	sar    $0xc,%eax
8010148e:	89 c2                	mov    %eax,%edx
80101490:	a1 58 54 11 80       	mov    0x80115458,%eax
80101495:	01 d0                	add    %edx,%eax
80101497:	83 ec 08             	sub    $0x8,%esp
8010149a:	50                   	push   %eax
8010149b:	ff 75 08             	push   0x8(%ebp)
8010149e:	e8 5e ed ff ff       	call   80100201 <bread>
801014a3:	83 c4 10             	add    $0x10,%esp
801014a6:	89 45 ec             	mov    %eax,-0x14(%ebp)
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
801014a9:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801014b0:	e9 9e 00 00 00       	jmp    80101553 <balloc+0xef>
      m = 1 << (bi % 8);
801014b5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801014b8:	83 e0 07             	and    $0x7,%eax
801014bb:	ba 01 00 00 00       	mov    $0x1,%edx
801014c0:	89 c1                	mov    %eax,%ecx
801014c2:	d3 e2                	shl    %cl,%edx
801014c4:	89 d0                	mov    %edx,%eax
801014c6:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if((bp->data[bi/8] & m) == 0){  // Is block free?
801014c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801014cc:	8d 50 07             	lea    0x7(%eax),%edx
801014cf:	85 c0                	test   %eax,%eax
801014d1:	0f 48 c2             	cmovs  %edx,%eax
801014d4:	c1 f8 03             	sar    $0x3,%eax
801014d7:	89 c2                	mov    %eax,%edx
801014d9:	8b 45 ec             	mov    -0x14(%ebp),%eax
801014dc:	0f b6 44 10 5c       	movzbl 0x5c(%eax,%edx,1),%eax
801014e1:	0f b6 c0             	movzbl %al,%eax
801014e4:	23 45 e8             	and    -0x18(%ebp),%eax
801014e7:	85 c0                	test   %eax,%eax
801014e9:	75 64                	jne    8010154f <balloc+0xeb>
        bp->data[bi/8] |= m;  // Mark block in use.
801014eb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801014ee:	8d 50 07             	lea    0x7(%eax),%edx
801014f1:	85 c0                	test   %eax,%eax
801014f3:	0f 48 c2             	cmovs  %edx,%eax
801014f6:	c1 f8 03             	sar    $0x3,%eax
801014f9:	8b 55 ec             	mov    -0x14(%ebp),%edx
801014fc:	0f b6 54 02 5c       	movzbl 0x5c(%edx,%eax,1),%edx
80101501:	89 d1                	mov    %edx,%ecx
80101503:	8b 55 e8             	mov    -0x18(%ebp),%edx
80101506:	09 ca                	or     %ecx,%edx
80101508:	89 d1                	mov    %edx,%ecx
8010150a:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010150d:	88 4c 02 5c          	mov    %cl,0x5c(%edx,%eax,1)
        log_write(bp);
80101511:	83 ec 0c             	sub    $0xc,%esp
80101514:	ff 75 ec             	push   -0x14(%ebp)
80101517:	e8 3d 22 00 00       	call   80103759 <log_write>
8010151c:	83 c4 10             	add    $0x10,%esp
        brelse(bp);
8010151f:	83 ec 0c             	sub    $0xc,%esp
80101522:	ff 75 ec             	push   -0x14(%ebp)
80101525:	e8 59 ed ff ff       	call   80100283 <brelse>
8010152a:	83 c4 10             	add    $0x10,%esp
        bzero(dev, b + bi);
8010152d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101530:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101533:	01 c2                	add    %eax,%edx
80101535:	8b 45 08             	mov    0x8(%ebp),%eax
80101538:	83 ec 08             	sub    $0x8,%esp
8010153b:	52                   	push   %edx
8010153c:	50                   	push   %eax
8010153d:	e8 ce fe ff ff       	call   80101410 <bzero>
80101542:	83 c4 10             	add    $0x10,%esp
        return b + bi;
80101545:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101548:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010154b:	01 d0                	add    %edx,%eax
8010154d:	eb 57                	jmp    801015a6 <balloc+0x142>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
8010154f:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80101553:	81 7d f0 ff 0f 00 00 	cmpl   $0xfff,-0x10(%ebp)
8010155a:	7f 17                	jg     80101573 <balloc+0x10f>
8010155c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010155f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101562:	01 d0                	add    %edx,%eax
80101564:	89 c2                	mov    %eax,%edx
80101566:	a1 40 54 11 80       	mov    0x80115440,%eax
8010156b:	39 c2                	cmp    %eax,%edx
8010156d:	0f 82 42 ff ff ff    	jb     801014b5 <balloc+0x51>
      }
    }
    brelse(bp);
80101573:	83 ec 0c             	sub    $0xc,%esp
80101576:	ff 75 ec             	push   -0x14(%ebp)
80101579:	e8 05 ed ff ff       	call   80100283 <brelse>
8010157e:	83 c4 10             	add    $0x10,%esp
  for(b = 0; b < sb.size; b += BPB){
80101581:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80101588:	8b 15 40 54 11 80    	mov    0x80115440,%edx
8010158e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101591:	39 c2                	cmp    %eax,%edx
80101593:	0f 87 e4 fe ff ff    	ja     8010147d <balloc+0x19>
  }
  panic("balloc: out of blocks");
80101599:	83 ec 0c             	sub    $0xc,%esp
8010159c:	68 40 a5 10 80       	push   $0x8010a540
801015a1:	e8 03 f0 ff ff       	call   801005a9 <panic>
}
801015a6:	c9                   	leave  
801015a7:	c3                   	ret    

801015a8 <bfree>:

// Free a disk block.
static void
bfree(int dev, uint b)
{
801015a8:	55                   	push   %ebp
801015a9:	89 e5                	mov    %esp,%ebp
801015ab:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  int bi, m;

  readsb(dev, &sb);
801015ae:	83 ec 08             	sub    $0x8,%esp
801015b1:	68 40 54 11 80       	push   $0x80115440
801015b6:	ff 75 08             	push   0x8(%ebp)
801015b9:	e8 10 fe ff ff       	call   801013ce <readsb>
801015be:	83 c4 10             	add    $0x10,%esp
  bp = bread(dev, BBLOCK(b, sb));
801015c1:	8b 45 0c             	mov    0xc(%ebp),%eax
801015c4:	c1 e8 0c             	shr    $0xc,%eax
801015c7:	89 c2                	mov    %eax,%edx
801015c9:	a1 58 54 11 80       	mov    0x80115458,%eax
801015ce:	01 c2                	add    %eax,%edx
801015d0:	8b 45 08             	mov    0x8(%ebp),%eax
801015d3:	83 ec 08             	sub    $0x8,%esp
801015d6:	52                   	push   %edx
801015d7:	50                   	push   %eax
801015d8:	e8 24 ec ff ff       	call   80100201 <bread>
801015dd:	83 c4 10             	add    $0x10,%esp
801015e0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  bi = b % BPB;
801015e3:	8b 45 0c             	mov    0xc(%ebp),%eax
801015e6:	25 ff 0f 00 00       	and    $0xfff,%eax
801015eb:	89 45 f0             	mov    %eax,-0x10(%ebp)
  m = 1 << (bi % 8);
801015ee:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015f1:	83 e0 07             	and    $0x7,%eax
801015f4:	ba 01 00 00 00       	mov    $0x1,%edx
801015f9:	89 c1                	mov    %eax,%ecx
801015fb:	d3 e2                	shl    %cl,%edx
801015fd:	89 d0                	mov    %edx,%eax
801015ff:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((bp->data[bi/8] & m) == 0)
80101602:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101605:	8d 50 07             	lea    0x7(%eax),%edx
80101608:	85 c0                	test   %eax,%eax
8010160a:	0f 48 c2             	cmovs  %edx,%eax
8010160d:	c1 f8 03             	sar    $0x3,%eax
80101610:	89 c2                	mov    %eax,%edx
80101612:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101615:	0f b6 44 10 5c       	movzbl 0x5c(%eax,%edx,1),%eax
8010161a:	0f b6 c0             	movzbl %al,%eax
8010161d:	23 45 ec             	and    -0x14(%ebp),%eax
80101620:	85 c0                	test   %eax,%eax
80101622:	75 0d                	jne    80101631 <bfree+0x89>
    panic("freeing free block");
80101624:	83 ec 0c             	sub    $0xc,%esp
80101627:	68 56 a5 10 80       	push   $0x8010a556
8010162c:	e8 78 ef ff ff       	call   801005a9 <panic>
  bp->data[bi/8] &= ~m;
80101631:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101634:	8d 50 07             	lea    0x7(%eax),%edx
80101637:	85 c0                	test   %eax,%eax
80101639:	0f 48 c2             	cmovs  %edx,%eax
8010163c:	c1 f8 03             	sar    $0x3,%eax
8010163f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101642:	0f b6 54 02 5c       	movzbl 0x5c(%edx,%eax,1),%edx
80101647:	89 d1                	mov    %edx,%ecx
80101649:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010164c:	f7 d2                	not    %edx
8010164e:	21 ca                	and    %ecx,%edx
80101650:	89 d1                	mov    %edx,%ecx
80101652:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101655:	88 4c 02 5c          	mov    %cl,0x5c(%edx,%eax,1)
  log_write(bp);
80101659:	83 ec 0c             	sub    $0xc,%esp
8010165c:	ff 75 f4             	push   -0xc(%ebp)
8010165f:	e8 f5 20 00 00       	call   80103759 <log_write>
80101664:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
80101667:	83 ec 0c             	sub    $0xc,%esp
8010166a:	ff 75 f4             	push   -0xc(%ebp)
8010166d:	e8 11 ec ff ff       	call   80100283 <brelse>
80101672:	83 c4 10             	add    $0x10,%esp
}
80101675:	90                   	nop
80101676:	c9                   	leave  
80101677:	c3                   	ret    

80101678 <iinit>:
  struct inode inode[NINODE];
} icache;

void
iinit(int dev)
{
80101678:	55                   	push   %ebp
80101679:	89 e5                	mov    %esp,%ebp
8010167b:	57                   	push   %edi
8010167c:	56                   	push   %esi
8010167d:	53                   	push   %ebx
8010167e:	83 ec 2c             	sub    $0x2c,%esp
  int i = 0;
80101681:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  
  initlock(&icache.lock, "icache");
80101688:	83 ec 08             	sub    $0x8,%esp
8010168b:	68 69 a5 10 80       	push   $0x8010a569
80101690:	68 60 54 11 80       	push   $0x80115460
80101695:	e8 31 35 00 00       	call   80104bcb <initlock>
8010169a:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NINODE; i++) {
8010169d:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
801016a4:	eb 2d                	jmp    801016d3 <iinit+0x5b>
    initsleeplock(&icache.inode[i].lock, "inode");
801016a6:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801016a9:	89 d0                	mov    %edx,%eax
801016ab:	c1 e0 03             	shl    $0x3,%eax
801016ae:	01 d0                	add    %edx,%eax
801016b0:	c1 e0 04             	shl    $0x4,%eax
801016b3:	83 c0 30             	add    $0x30,%eax
801016b6:	05 60 54 11 80       	add    $0x80115460,%eax
801016bb:	83 c0 10             	add    $0x10,%eax
801016be:	83 ec 08             	sub    $0x8,%esp
801016c1:	68 70 a5 10 80       	push   $0x8010a570
801016c6:	50                   	push   %eax
801016c7:	e8 a2 33 00 00       	call   80104a6e <initsleeplock>
801016cc:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NINODE; i++) {
801016cf:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
801016d3:	83 7d e4 31          	cmpl   $0x31,-0x1c(%ebp)
801016d7:	7e cd                	jle    801016a6 <iinit+0x2e>
  }

  readsb(dev, &sb);
801016d9:	83 ec 08             	sub    $0x8,%esp
801016dc:	68 40 54 11 80       	push   $0x80115440
801016e1:	ff 75 08             	push   0x8(%ebp)
801016e4:	e8 e5 fc ff ff       	call   801013ce <readsb>
801016e9:	83 c4 10             	add    $0x10,%esp
  cprintf("sb: size %d nblocks %d ninodes %d nlog %d logstart %d\
801016ec:	a1 58 54 11 80       	mov    0x80115458,%eax
801016f1:	89 45 d4             	mov    %eax,-0x2c(%ebp)
801016f4:	8b 3d 54 54 11 80    	mov    0x80115454,%edi
801016fa:	8b 35 50 54 11 80    	mov    0x80115450,%esi
80101700:	8b 1d 4c 54 11 80    	mov    0x8011544c,%ebx
80101706:	8b 0d 48 54 11 80    	mov    0x80115448,%ecx
8010170c:	8b 15 44 54 11 80    	mov    0x80115444,%edx
80101712:	a1 40 54 11 80       	mov    0x80115440,%eax
80101717:	ff 75 d4             	push   -0x2c(%ebp)
8010171a:	57                   	push   %edi
8010171b:	56                   	push   %esi
8010171c:	53                   	push   %ebx
8010171d:	51                   	push   %ecx
8010171e:	52                   	push   %edx
8010171f:	50                   	push   %eax
80101720:	68 78 a5 10 80       	push   $0x8010a578
80101725:	e8 ca ec ff ff       	call   801003f4 <cprintf>
8010172a:	83 c4 20             	add    $0x20,%esp
 inodestart %d bmap start %d\n", sb.size, sb.nblocks,
          sb.ninodes, sb.nlog, sb.logstart, sb.inodestart,
          sb.bmapstart);
}
8010172d:	90                   	nop
8010172e:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101731:	5b                   	pop    %ebx
80101732:	5e                   	pop    %esi
80101733:	5f                   	pop    %edi
80101734:	5d                   	pop    %ebp
80101735:	c3                   	ret    

80101736 <ialloc>:
// Allocate an inode on device dev.
// Mark it as allocated by  giving it type type.
// Returns an unlocked but allocated and referenced inode.
struct inode*
ialloc(uint dev, short type)
{
80101736:	55                   	push   %ebp
80101737:	89 e5                	mov    %esp,%ebp
80101739:	83 ec 28             	sub    $0x28,%esp
8010173c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010173f:	66 89 45 e4          	mov    %ax,-0x1c(%ebp)
  int inum;
  struct buf *bp;
  struct dinode *dip;

  for(inum = 1; inum < sb.ninodes; inum++){
80101743:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
8010174a:	e9 9e 00 00 00       	jmp    801017ed <ialloc+0xb7>
    bp = bread(dev, IBLOCK(inum, sb));
8010174f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101752:	c1 e8 03             	shr    $0x3,%eax
80101755:	89 c2                	mov    %eax,%edx
80101757:	a1 54 54 11 80       	mov    0x80115454,%eax
8010175c:	01 d0                	add    %edx,%eax
8010175e:	83 ec 08             	sub    $0x8,%esp
80101761:	50                   	push   %eax
80101762:	ff 75 08             	push   0x8(%ebp)
80101765:	e8 97 ea ff ff       	call   80100201 <bread>
8010176a:	83 c4 10             	add    $0x10,%esp
8010176d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    dip = (struct dinode*)bp->data + inum%IPB;
80101770:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101773:	8d 50 5c             	lea    0x5c(%eax),%edx
80101776:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101779:	83 e0 07             	and    $0x7,%eax
8010177c:	c1 e0 06             	shl    $0x6,%eax
8010177f:	01 d0                	add    %edx,%eax
80101781:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(dip->type == 0){  // a free inode
80101784:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101787:	0f b7 00             	movzwl (%eax),%eax
8010178a:	66 85 c0             	test   %ax,%ax
8010178d:	75 4c                	jne    801017db <ialloc+0xa5>
      memset(dip, 0, sizeof(*dip));
8010178f:	83 ec 04             	sub    $0x4,%esp
80101792:	6a 40                	push   $0x40
80101794:	6a 00                	push   $0x0
80101796:	ff 75 ec             	push   -0x14(%ebp)
80101799:	e8 c5 36 00 00       	call   80104e63 <memset>
8010179e:	83 c4 10             	add    $0x10,%esp
      dip->type = type;
801017a1:	8b 45 ec             	mov    -0x14(%ebp),%eax
801017a4:	0f b7 55 e4          	movzwl -0x1c(%ebp),%edx
801017a8:	66 89 10             	mov    %dx,(%eax)
      log_write(bp);   // mark it allocated on the disk
801017ab:	83 ec 0c             	sub    $0xc,%esp
801017ae:	ff 75 f0             	push   -0x10(%ebp)
801017b1:	e8 a3 1f 00 00       	call   80103759 <log_write>
801017b6:	83 c4 10             	add    $0x10,%esp
      brelse(bp);
801017b9:	83 ec 0c             	sub    $0xc,%esp
801017bc:	ff 75 f0             	push   -0x10(%ebp)
801017bf:	e8 bf ea ff ff       	call   80100283 <brelse>
801017c4:	83 c4 10             	add    $0x10,%esp
      return iget(dev, inum);
801017c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017ca:	83 ec 08             	sub    $0x8,%esp
801017cd:	50                   	push   %eax
801017ce:	ff 75 08             	push   0x8(%ebp)
801017d1:	e8 f8 00 00 00       	call   801018ce <iget>
801017d6:	83 c4 10             	add    $0x10,%esp
801017d9:	eb 30                	jmp    8010180b <ialloc+0xd5>
    }
    brelse(bp);
801017db:	83 ec 0c             	sub    $0xc,%esp
801017de:	ff 75 f0             	push   -0x10(%ebp)
801017e1:	e8 9d ea ff ff       	call   80100283 <brelse>
801017e6:	83 c4 10             	add    $0x10,%esp
  for(inum = 1; inum < sb.ninodes; inum++){
801017e9:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801017ed:	8b 15 48 54 11 80    	mov    0x80115448,%edx
801017f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017f6:	39 c2                	cmp    %eax,%edx
801017f8:	0f 87 51 ff ff ff    	ja     8010174f <ialloc+0x19>
  }
  panic("ialloc: no inodes");
801017fe:	83 ec 0c             	sub    $0xc,%esp
80101801:	68 cb a5 10 80       	push   $0x8010a5cb
80101806:	e8 9e ed ff ff       	call   801005a9 <panic>
}
8010180b:	c9                   	leave  
8010180c:	c3                   	ret    

8010180d <iupdate>:
// Must be called after every change to an ip->xxx field
// that lives on disk, since i-node cache is write-through.
// Caller must hold ip->lock.
void
iupdate(struct inode *ip)
{
8010180d:	55                   	push   %ebp
8010180e:	89 e5                	mov    %esp,%ebp
80101810:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  struct dinode *dip;

  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101813:	8b 45 08             	mov    0x8(%ebp),%eax
80101816:	8b 40 04             	mov    0x4(%eax),%eax
80101819:	c1 e8 03             	shr    $0x3,%eax
8010181c:	89 c2                	mov    %eax,%edx
8010181e:	a1 54 54 11 80       	mov    0x80115454,%eax
80101823:	01 c2                	add    %eax,%edx
80101825:	8b 45 08             	mov    0x8(%ebp),%eax
80101828:	8b 00                	mov    (%eax),%eax
8010182a:	83 ec 08             	sub    $0x8,%esp
8010182d:	52                   	push   %edx
8010182e:	50                   	push   %eax
8010182f:	e8 cd e9 ff ff       	call   80100201 <bread>
80101834:	83 c4 10             	add    $0x10,%esp
80101837:	89 45 f4             	mov    %eax,-0xc(%ebp)
  dip = (struct dinode*)bp->data + ip->inum%IPB;
8010183a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010183d:	8d 50 5c             	lea    0x5c(%eax),%edx
80101840:	8b 45 08             	mov    0x8(%ebp),%eax
80101843:	8b 40 04             	mov    0x4(%eax),%eax
80101846:	83 e0 07             	and    $0x7,%eax
80101849:	c1 e0 06             	shl    $0x6,%eax
8010184c:	01 d0                	add    %edx,%eax
8010184e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dip->type = ip->type;
80101851:	8b 45 08             	mov    0x8(%ebp),%eax
80101854:	0f b7 50 50          	movzwl 0x50(%eax),%edx
80101858:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010185b:	66 89 10             	mov    %dx,(%eax)
  dip->major = ip->major;
8010185e:	8b 45 08             	mov    0x8(%ebp),%eax
80101861:	0f b7 50 52          	movzwl 0x52(%eax),%edx
80101865:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101868:	66 89 50 02          	mov    %dx,0x2(%eax)
  dip->minor = ip->minor;
8010186c:	8b 45 08             	mov    0x8(%ebp),%eax
8010186f:	0f b7 50 54          	movzwl 0x54(%eax),%edx
80101873:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101876:	66 89 50 04          	mov    %dx,0x4(%eax)
  dip->nlink = ip->nlink;
8010187a:	8b 45 08             	mov    0x8(%ebp),%eax
8010187d:	0f b7 50 56          	movzwl 0x56(%eax),%edx
80101881:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101884:	66 89 50 06          	mov    %dx,0x6(%eax)
  dip->size = ip->size;
80101888:	8b 45 08             	mov    0x8(%ebp),%eax
8010188b:	8b 50 58             	mov    0x58(%eax),%edx
8010188e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101891:	89 50 08             	mov    %edx,0x8(%eax)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
80101894:	8b 45 08             	mov    0x8(%ebp),%eax
80101897:	8d 50 5c             	lea    0x5c(%eax),%edx
8010189a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010189d:	83 c0 0c             	add    $0xc,%eax
801018a0:	83 ec 04             	sub    $0x4,%esp
801018a3:	6a 34                	push   $0x34
801018a5:	52                   	push   %edx
801018a6:	50                   	push   %eax
801018a7:	e8 76 36 00 00       	call   80104f22 <memmove>
801018ac:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
801018af:	83 ec 0c             	sub    $0xc,%esp
801018b2:	ff 75 f4             	push   -0xc(%ebp)
801018b5:	e8 9f 1e 00 00       	call   80103759 <log_write>
801018ba:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
801018bd:	83 ec 0c             	sub    $0xc,%esp
801018c0:	ff 75 f4             	push   -0xc(%ebp)
801018c3:	e8 bb e9 ff ff       	call   80100283 <brelse>
801018c8:	83 c4 10             	add    $0x10,%esp
}
801018cb:	90                   	nop
801018cc:	c9                   	leave  
801018cd:	c3                   	ret    

801018ce <iget>:
// Find the inode with number inum on device dev
// and return the in-memory copy. Does not lock
// the inode and does not read it from disk.
static struct inode*
iget(uint dev, uint inum)
{
801018ce:	55                   	push   %ebp
801018cf:	89 e5                	mov    %esp,%ebp
801018d1:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip, *empty;

  acquire(&icache.lock);
801018d4:	83 ec 0c             	sub    $0xc,%esp
801018d7:	68 60 54 11 80       	push   $0x80115460
801018dc:	e8 0c 33 00 00       	call   80104bed <acquire>
801018e1:	83 c4 10             	add    $0x10,%esp

  // Is the inode already cached?
  empty = 0;
801018e4:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
801018eb:	c7 45 f4 94 54 11 80 	movl   $0x80115494,-0xc(%ebp)
801018f2:	eb 60                	jmp    80101954 <iget+0x86>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
801018f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018f7:	8b 40 08             	mov    0x8(%eax),%eax
801018fa:	85 c0                	test   %eax,%eax
801018fc:	7e 39                	jle    80101937 <iget+0x69>
801018fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101901:	8b 00                	mov    (%eax),%eax
80101903:	39 45 08             	cmp    %eax,0x8(%ebp)
80101906:	75 2f                	jne    80101937 <iget+0x69>
80101908:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010190b:	8b 40 04             	mov    0x4(%eax),%eax
8010190e:	39 45 0c             	cmp    %eax,0xc(%ebp)
80101911:	75 24                	jne    80101937 <iget+0x69>
      ip->ref++;
80101913:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101916:	8b 40 08             	mov    0x8(%eax),%eax
80101919:	8d 50 01             	lea    0x1(%eax),%edx
8010191c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010191f:	89 50 08             	mov    %edx,0x8(%eax)
      release(&icache.lock);
80101922:	83 ec 0c             	sub    $0xc,%esp
80101925:	68 60 54 11 80       	push   $0x80115460
8010192a:	e8 2c 33 00 00       	call   80104c5b <release>
8010192f:	83 c4 10             	add    $0x10,%esp
      return ip;
80101932:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101935:	eb 77                	jmp    801019ae <iget+0xe0>
    }
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
80101937:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010193b:	75 10                	jne    8010194d <iget+0x7f>
8010193d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101940:	8b 40 08             	mov    0x8(%eax),%eax
80101943:	85 c0                	test   %eax,%eax
80101945:	75 06                	jne    8010194d <iget+0x7f>
      empty = ip;
80101947:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010194a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
8010194d:	81 45 f4 90 00 00 00 	addl   $0x90,-0xc(%ebp)
80101954:	81 7d f4 b4 70 11 80 	cmpl   $0x801170b4,-0xc(%ebp)
8010195b:	72 97                	jb     801018f4 <iget+0x26>
  }

  // Recycle an inode cache entry.
  if(empty == 0)
8010195d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80101961:	75 0d                	jne    80101970 <iget+0xa2>
    panic("iget: no inodes");
80101963:	83 ec 0c             	sub    $0xc,%esp
80101966:	68 dd a5 10 80       	push   $0x8010a5dd
8010196b:	e8 39 ec ff ff       	call   801005a9 <panic>

  ip = empty;
80101970:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101973:	89 45 f4             	mov    %eax,-0xc(%ebp)
  ip->dev = dev;
80101976:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101979:	8b 55 08             	mov    0x8(%ebp),%edx
8010197c:	89 10                	mov    %edx,(%eax)
  ip->inum = inum;
8010197e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101981:	8b 55 0c             	mov    0xc(%ebp),%edx
80101984:	89 50 04             	mov    %edx,0x4(%eax)
  ip->ref = 1;
80101987:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010198a:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
  ip->valid = 0;
80101991:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101994:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
  release(&icache.lock);
8010199b:	83 ec 0c             	sub    $0xc,%esp
8010199e:	68 60 54 11 80       	push   $0x80115460
801019a3:	e8 b3 32 00 00       	call   80104c5b <release>
801019a8:	83 c4 10             	add    $0x10,%esp

  return ip;
801019ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801019ae:	c9                   	leave  
801019af:	c3                   	ret    

801019b0 <idup>:

// Increment reference count for ip.
// Returns ip to enable ip = idup(ip1) idiom.
struct inode*
idup(struct inode *ip)
{
801019b0:	55                   	push   %ebp
801019b1:	89 e5                	mov    %esp,%ebp
801019b3:	83 ec 08             	sub    $0x8,%esp
  acquire(&icache.lock);
801019b6:	83 ec 0c             	sub    $0xc,%esp
801019b9:	68 60 54 11 80       	push   $0x80115460
801019be:	e8 2a 32 00 00       	call   80104bed <acquire>
801019c3:	83 c4 10             	add    $0x10,%esp
  ip->ref++;
801019c6:	8b 45 08             	mov    0x8(%ebp),%eax
801019c9:	8b 40 08             	mov    0x8(%eax),%eax
801019cc:	8d 50 01             	lea    0x1(%eax),%edx
801019cf:	8b 45 08             	mov    0x8(%ebp),%eax
801019d2:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
801019d5:	83 ec 0c             	sub    $0xc,%esp
801019d8:	68 60 54 11 80       	push   $0x80115460
801019dd:	e8 79 32 00 00       	call   80104c5b <release>
801019e2:	83 c4 10             	add    $0x10,%esp
  return ip;
801019e5:	8b 45 08             	mov    0x8(%ebp),%eax
}
801019e8:	c9                   	leave  
801019e9:	c3                   	ret    

801019ea <ilock>:

// Lock the given inode.
// Reads the inode from disk if necessary.
void
ilock(struct inode *ip)
{
801019ea:	55                   	push   %ebp
801019eb:	89 e5                	mov    %esp,%ebp
801019ed:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  struct dinode *dip;

  if(ip == 0 || ip->ref < 1)
801019f0:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801019f4:	74 0a                	je     80101a00 <ilock+0x16>
801019f6:	8b 45 08             	mov    0x8(%ebp),%eax
801019f9:	8b 40 08             	mov    0x8(%eax),%eax
801019fc:	85 c0                	test   %eax,%eax
801019fe:	7f 0d                	jg     80101a0d <ilock+0x23>
    panic("ilock");
80101a00:	83 ec 0c             	sub    $0xc,%esp
80101a03:	68 ed a5 10 80       	push   $0x8010a5ed
80101a08:	e8 9c eb ff ff       	call   801005a9 <panic>

  acquiresleep(&ip->lock);
80101a0d:	8b 45 08             	mov    0x8(%ebp),%eax
80101a10:	83 c0 0c             	add    $0xc,%eax
80101a13:	83 ec 0c             	sub    $0xc,%esp
80101a16:	50                   	push   %eax
80101a17:	e8 8e 30 00 00       	call   80104aaa <acquiresleep>
80101a1c:	83 c4 10             	add    $0x10,%esp

  if(ip->valid == 0){
80101a1f:	8b 45 08             	mov    0x8(%ebp),%eax
80101a22:	8b 40 4c             	mov    0x4c(%eax),%eax
80101a25:	85 c0                	test   %eax,%eax
80101a27:	0f 85 cd 00 00 00    	jne    80101afa <ilock+0x110>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101a2d:	8b 45 08             	mov    0x8(%ebp),%eax
80101a30:	8b 40 04             	mov    0x4(%eax),%eax
80101a33:	c1 e8 03             	shr    $0x3,%eax
80101a36:	89 c2                	mov    %eax,%edx
80101a38:	a1 54 54 11 80       	mov    0x80115454,%eax
80101a3d:	01 c2                	add    %eax,%edx
80101a3f:	8b 45 08             	mov    0x8(%ebp),%eax
80101a42:	8b 00                	mov    (%eax),%eax
80101a44:	83 ec 08             	sub    $0x8,%esp
80101a47:	52                   	push   %edx
80101a48:	50                   	push   %eax
80101a49:	e8 b3 e7 ff ff       	call   80100201 <bread>
80101a4e:	83 c4 10             	add    $0x10,%esp
80101a51:	89 45 f4             	mov    %eax,-0xc(%ebp)
    dip = (struct dinode*)bp->data + ip->inum%IPB;
80101a54:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a57:	8d 50 5c             	lea    0x5c(%eax),%edx
80101a5a:	8b 45 08             	mov    0x8(%ebp),%eax
80101a5d:	8b 40 04             	mov    0x4(%eax),%eax
80101a60:	83 e0 07             	and    $0x7,%eax
80101a63:	c1 e0 06             	shl    $0x6,%eax
80101a66:	01 d0                	add    %edx,%eax
80101a68:	89 45 f0             	mov    %eax,-0x10(%ebp)
    ip->type = dip->type;
80101a6b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a6e:	0f b7 10             	movzwl (%eax),%edx
80101a71:	8b 45 08             	mov    0x8(%ebp),%eax
80101a74:	66 89 50 50          	mov    %dx,0x50(%eax)
    ip->major = dip->major;
80101a78:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a7b:	0f b7 50 02          	movzwl 0x2(%eax),%edx
80101a7f:	8b 45 08             	mov    0x8(%ebp),%eax
80101a82:	66 89 50 52          	mov    %dx,0x52(%eax)
    ip->minor = dip->minor;
80101a86:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a89:	0f b7 50 04          	movzwl 0x4(%eax),%edx
80101a8d:	8b 45 08             	mov    0x8(%ebp),%eax
80101a90:	66 89 50 54          	mov    %dx,0x54(%eax)
    ip->nlink = dip->nlink;
80101a94:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a97:	0f b7 50 06          	movzwl 0x6(%eax),%edx
80101a9b:	8b 45 08             	mov    0x8(%ebp),%eax
80101a9e:	66 89 50 56          	mov    %dx,0x56(%eax)
    ip->size = dip->size;
80101aa2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101aa5:	8b 50 08             	mov    0x8(%eax),%edx
80101aa8:	8b 45 08             	mov    0x8(%ebp),%eax
80101aab:	89 50 58             	mov    %edx,0x58(%eax)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
80101aae:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ab1:	8d 50 0c             	lea    0xc(%eax),%edx
80101ab4:	8b 45 08             	mov    0x8(%ebp),%eax
80101ab7:	83 c0 5c             	add    $0x5c,%eax
80101aba:	83 ec 04             	sub    $0x4,%esp
80101abd:	6a 34                	push   $0x34
80101abf:	52                   	push   %edx
80101ac0:	50                   	push   %eax
80101ac1:	e8 5c 34 00 00       	call   80104f22 <memmove>
80101ac6:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80101ac9:	83 ec 0c             	sub    $0xc,%esp
80101acc:	ff 75 f4             	push   -0xc(%ebp)
80101acf:	e8 af e7 ff ff       	call   80100283 <brelse>
80101ad4:	83 c4 10             	add    $0x10,%esp
    ip->valid = 1;
80101ad7:	8b 45 08             	mov    0x8(%ebp),%eax
80101ada:	c7 40 4c 01 00 00 00 	movl   $0x1,0x4c(%eax)
    if(ip->type == 0)
80101ae1:	8b 45 08             	mov    0x8(%ebp),%eax
80101ae4:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80101ae8:	66 85 c0             	test   %ax,%ax
80101aeb:	75 0d                	jne    80101afa <ilock+0x110>
      panic("ilock: no type");
80101aed:	83 ec 0c             	sub    $0xc,%esp
80101af0:	68 f3 a5 10 80       	push   $0x8010a5f3
80101af5:	e8 af ea ff ff       	call   801005a9 <panic>
  }
}
80101afa:	90                   	nop
80101afb:	c9                   	leave  
80101afc:	c3                   	ret    

80101afd <iunlock>:

// Unlock the given inode.
void
iunlock(struct inode *ip)
{
80101afd:	55                   	push   %ebp
80101afe:	89 e5                	mov    %esp,%ebp
80101b00:	83 ec 08             	sub    $0x8,%esp
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
80101b03:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101b07:	74 20                	je     80101b29 <iunlock+0x2c>
80101b09:	8b 45 08             	mov    0x8(%ebp),%eax
80101b0c:	83 c0 0c             	add    $0xc,%eax
80101b0f:	83 ec 0c             	sub    $0xc,%esp
80101b12:	50                   	push   %eax
80101b13:	e8 44 30 00 00       	call   80104b5c <holdingsleep>
80101b18:	83 c4 10             	add    $0x10,%esp
80101b1b:	85 c0                	test   %eax,%eax
80101b1d:	74 0a                	je     80101b29 <iunlock+0x2c>
80101b1f:	8b 45 08             	mov    0x8(%ebp),%eax
80101b22:	8b 40 08             	mov    0x8(%eax),%eax
80101b25:	85 c0                	test   %eax,%eax
80101b27:	7f 0d                	jg     80101b36 <iunlock+0x39>
    panic("iunlock");
80101b29:	83 ec 0c             	sub    $0xc,%esp
80101b2c:	68 02 a6 10 80       	push   $0x8010a602
80101b31:	e8 73 ea ff ff       	call   801005a9 <panic>

  releasesleep(&ip->lock);
80101b36:	8b 45 08             	mov    0x8(%ebp),%eax
80101b39:	83 c0 0c             	add    $0xc,%eax
80101b3c:	83 ec 0c             	sub    $0xc,%esp
80101b3f:	50                   	push   %eax
80101b40:	e8 c9 2f 00 00       	call   80104b0e <releasesleep>
80101b45:	83 c4 10             	add    $0x10,%esp
}
80101b48:	90                   	nop
80101b49:	c9                   	leave  
80101b4a:	c3                   	ret    

80101b4b <iput>:
// to it, free the inode (and its content) on disk.
// All calls to iput() must be inside a transaction in
// case it has to free the inode.
void
iput(struct inode *ip)
{
80101b4b:	55                   	push   %ebp
80101b4c:	89 e5                	mov    %esp,%ebp
80101b4e:	83 ec 18             	sub    $0x18,%esp
  acquiresleep(&ip->lock);
80101b51:	8b 45 08             	mov    0x8(%ebp),%eax
80101b54:	83 c0 0c             	add    $0xc,%eax
80101b57:	83 ec 0c             	sub    $0xc,%esp
80101b5a:	50                   	push   %eax
80101b5b:	e8 4a 2f 00 00       	call   80104aaa <acquiresleep>
80101b60:	83 c4 10             	add    $0x10,%esp
  if(ip->valid && ip->nlink == 0){
80101b63:	8b 45 08             	mov    0x8(%ebp),%eax
80101b66:	8b 40 4c             	mov    0x4c(%eax),%eax
80101b69:	85 c0                	test   %eax,%eax
80101b6b:	74 6a                	je     80101bd7 <iput+0x8c>
80101b6d:	8b 45 08             	mov    0x8(%ebp),%eax
80101b70:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80101b74:	66 85 c0             	test   %ax,%ax
80101b77:	75 5e                	jne    80101bd7 <iput+0x8c>
    acquire(&icache.lock);
80101b79:	83 ec 0c             	sub    $0xc,%esp
80101b7c:	68 60 54 11 80       	push   $0x80115460
80101b81:	e8 67 30 00 00       	call   80104bed <acquire>
80101b86:	83 c4 10             	add    $0x10,%esp
    int r = ip->ref;
80101b89:	8b 45 08             	mov    0x8(%ebp),%eax
80101b8c:	8b 40 08             	mov    0x8(%eax),%eax
80101b8f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    release(&icache.lock);
80101b92:	83 ec 0c             	sub    $0xc,%esp
80101b95:	68 60 54 11 80       	push   $0x80115460
80101b9a:	e8 bc 30 00 00       	call   80104c5b <release>
80101b9f:	83 c4 10             	add    $0x10,%esp
    if(r == 1){
80101ba2:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
80101ba6:	75 2f                	jne    80101bd7 <iput+0x8c>
      // inode has no links and no other references: truncate and free.
      itrunc(ip);
80101ba8:	83 ec 0c             	sub    $0xc,%esp
80101bab:	ff 75 08             	push   0x8(%ebp)
80101bae:	e8 ad 01 00 00       	call   80101d60 <itrunc>
80101bb3:	83 c4 10             	add    $0x10,%esp
      ip->type = 0;
80101bb6:	8b 45 08             	mov    0x8(%ebp),%eax
80101bb9:	66 c7 40 50 00 00    	movw   $0x0,0x50(%eax)
      iupdate(ip);
80101bbf:	83 ec 0c             	sub    $0xc,%esp
80101bc2:	ff 75 08             	push   0x8(%ebp)
80101bc5:	e8 43 fc ff ff       	call   8010180d <iupdate>
80101bca:	83 c4 10             	add    $0x10,%esp
      ip->valid = 0;
80101bcd:	8b 45 08             	mov    0x8(%ebp),%eax
80101bd0:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
    }
  }
  releasesleep(&ip->lock);
80101bd7:	8b 45 08             	mov    0x8(%ebp),%eax
80101bda:	83 c0 0c             	add    $0xc,%eax
80101bdd:	83 ec 0c             	sub    $0xc,%esp
80101be0:	50                   	push   %eax
80101be1:	e8 28 2f 00 00       	call   80104b0e <releasesleep>
80101be6:	83 c4 10             	add    $0x10,%esp

  acquire(&icache.lock);
80101be9:	83 ec 0c             	sub    $0xc,%esp
80101bec:	68 60 54 11 80       	push   $0x80115460
80101bf1:	e8 f7 2f 00 00       	call   80104bed <acquire>
80101bf6:	83 c4 10             	add    $0x10,%esp
  ip->ref--;
80101bf9:	8b 45 08             	mov    0x8(%ebp),%eax
80101bfc:	8b 40 08             	mov    0x8(%eax),%eax
80101bff:	8d 50 ff             	lea    -0x1(%eax),%edx
80101c02:	8b 45 08             	mov    0x8(%ebp),%eax
80101c05:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101c08:	83 ec 0c             	sub    $0xc,%esp
80101c0b:	68 60 54 11 80       	push   $0x80115460
80101c10:	e8 46 30 00 00       	call   80104c5b <release>
80101c15:	83 c4 10             	add    $0x10,%esp
}
80101c18:	90                   	nop
80101c19:	c9                   	leave  
80101c1a:	c3                   	ret    

80101c1b <iunlockput>:

// Common idiom: unlock, then put.
void
iunlockput(struct inode *ip)
{
80101c1b:	55                   	push   %ebp
80101c1c:	89 e5                	mov    %esp,%ebp
80101c1e:	83 ec 08             	sub    $0x8,%esp
  iunlock(ip);
80101c21:	83 ec 0c             	sub    $0xc,%esp
80101c24:	ff 75 08             	push   0x8(%ebp)
80101c27:	e8 d1 fe ff ff       	call   80101afd <iunlock>
80101c2c:	83 c4 10             	add    $0x10,%esp
  iput(ip);
80101c2f:	83 ec 0c             	sub    $0xc,%esp
80101c32:	ff 75 08             	push   0x8(%ebp)
80101c35:	e8 11 ff ff ff       	call   80101b4b <iput>
80101c3a:	83 c4 10             	add    $0x10,%esp
}
80101c3d:	90                   	nop
80101c3e:	c9                   	leave  
80101c3f:	c3                   	ret    

80101c40 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
80101c40:	55                   	push   %ebp
80101c41:	89 e5                	mov    %esp,%ebp
80101c43:	83 ec 18             	sub    $0x18,%esp
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
80101c46:	83 7d 0c 0b          	cmpl   $0xb,0xc(%ebp)
80101c4a:	77 42                	ja     80101c8e <bmap+0x4e>
    if((addr = ip->addrs[bn]) == 0)
80101c4c:	8b 45 08             	mov    0x8(%ebp),%eax
80101c4f:	8b 55 0c             	mov    0xc(%ebp),%edx
80101c52:	83 c2 14             	add    $0x14,%edx
80101c55:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101c59:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101c5c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101c60:	75 24                	jne    80101c86 <bmap+0x46>
      ip->addrs[bn] = addr = balloc(ip->dev);
80101c62:	8b 45 08             	mov    0x8(%ebp),%eax
80101c65:	8b 00                	mov    (%eax),%eax
80101c67:	83 ec 0c             	sub    $0xc,%esp
80101c6a:	50                   	push   %eax
80101c6b:	e8 f4 f7 ff ff       	call   80101464 <balloc>
80101c70:	83 c4 10             	add    $0x10,%esp
80101c73:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101c76:	8b 45 08             	mov    0x8(%ebp),%eax
80101c79:	8b 55 0c             	mov    0xc(%ebp),%edx
80101c7c:	8d 4a 14             	lea    0x14(%edx),%ecx
80101c7f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101c82:	89 54 88 0c          	mov    %edx,0xc(%eax,%ecx,4)
    return addr;
80101c86:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101c89:	e9 d0 00 00 00       	jmp    80101d5e <bmap+0x11e>
  }
  bn -= NDIRECT;
80101c8e:	83 6d 0c 0c          	subl   $0xc,0xc(%ebp)

  if(bn < NINDIRECT){
80101c92:	83 7d 0c 7f          	cmpl   $0x7f,0xc(%ebp)
80101c96:	0f 87 b5 00 00 00    	ja     80101d51 <bmap+0x111>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
80101c9c:	8b 45 08             	mov    0x8(%ebp),%eax
80101c9f:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101ca5:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101ca8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101cac:	75 20                	jne    80101cce <bmap+0x8e>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
80101cae:	8b 45 08             	mov    0x8(%ebp),%eax
80101cb1:	8b 00                	mov    (%eax),%eax
80101cb3:	83 ec 0c             	sub    $0xc,%esp
80101cb6:	50                   	push   %eax
80101cb7:	e8 a8 f7 ff ff       	call   80101464 <balloc>
80101cbc:	83 c4 10             	add    $0x10,%esp
80101cbf:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101cc2:	8b 45 08             	mov    0x8(%ebp),%eax
80101cc5:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101cc8:	89 90 8c 00 00 00    	mov    %edx,0x8c(%eax)
    bp = bread(ip->dev, addr);
80101cce:	8b 45 08             	mov    0x8(%ebp),%eax
80101cd1:	8b 00                	mov    (%eax),%eax
80101cd3:	83 ec 08             	sub    $0x8,%esp
80101cd6:	ff 75 f4             	push   -0xc(%ebp)
80101cd9:	50                   	push   %eax
80101cda:	e8 22 e5 ff ff       	call   80100201 <bread>
80101cdf:	83 c4 10             	add    $0x10,%esp
80101ce2:	89 45 f0             	mov    %eax,-0x10(%ebp)
    a = (uint*)bp->data;
80101ce5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ce8:	83 c0 5c             	add    $0x5c,%eax
80101ceb:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if((addr = a[bn]) == 0){
80101cee:	8b 45 0c             	mov    0xc(%ebp),%eax
80101cf1:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101cf8:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101cfb:	01 d0                	add    %edx,%eax
80101cfd:	8b 00                	mov    (%eax),%eax
80101cff:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101d02:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101d06:	75 36                	jne    80101d3e <bmap+0xfe>
      a[bn] = addr = balloc(ip->dev);
80101d08:	8b 45 08             	mov    0x8(%ebp),%eax
80101d0b:	8b 00                	mov    (%eax),%eax
80101d0d:	83 ec 0c             	sub    $0xc,%esp
80101d10:	50                   	push   %eax
80101d11:	e8 4e f7 ff ff       	call   80101464 <balloc>
80101d16:	83 c4 10             	add    $0x10,%esp
80101d19:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101d1c:	8b 45 0c             	mov    0xc(%ebp),%eax
80101d1f:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101d26:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101d29:	01 c2                	add    %eax,%edx
80101d2b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101d2e:	89 02                	mov    %eax,(%edx)
      log_write(bp);
80101d30:	83 ec 0c             	sub    $0xc,%esp
80101d33:	ff 75 f0             	push   -0x10(%ebp)
80101d36:	e8 1e 1a 00 00       	call   80103759 <log_write>
80101d3b:	83 c4 10             	add    $0x10,%esp
    }
    brelse(bp);
80101d3e:	83 ec 0c             	sub    $0xc,%esp
80101d41:	ff 75 f0             	push   -0x10(%ebp)
80101d44:	e8 3a e5 ff ff       	call   80100283 <brelse>
80101d49:	83 c4 10             	add    $0x10,%esp
    return addr;
80101d4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101d4f:	eb 0d                	jmp    80101d5e <bmap+0x11e>
  }

  panic("bmap: out of range");
80101d51:	83 ec 0c             	sub    $0xc,%esp
80101d54:	68 0a a6 10 80       	push   $0x8010a60a
80101d59:	e8 4b e8 ff ff       	call   801005a9 <panic>
}
80101d5e:	c9                   	leave  
80101d5f:	c3                   	ret    

80101d60 <itrunc>:
// to it (no directory entries referring to it)
// and has no in-memory reference to it (is
// not an open file or current directory).
static void
itrunc(struct inode *ip)
{
80101d60:	55                   	push   %ebp
80101d61:	89 e5                	mov    %esp,%ebp
80101d63:	83 ec 18             	sub    $0x18,%esp
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101d66:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101d6d:	eb 45                	jmp    80101db4 <itrunc+0x54>
    if(ip->addrs[i]){
80101d6f:	8b 45 08             	mov    0x8(%ebp),%eax
80101d72:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101d75:	83 c2 14             	add    $0x14,%edx
80101d78:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101d7c:	85 c0                	test   %eax,%eax
80101d7e:	74 30                	je     80101db0 <itrunc+0x50>
      bfree(ip->dev, ip->addrs[i]);
80101d80:	8b 45 08             	mov    0x8(%ebp),%eax
80101d83:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101d86:	83 c2 14             	add    $0x14,%edx
80101d89:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101d8d:	8b 55 08             	mov    0x8(%ebp),%edx
80101d90:	8b 12                	mov    (%edx),%edx
80101d92:	83 ec 08             	sub    $0x8,%esp
80101d95:	50                   	push   %eax
80101d96:	52                   	push   %edx
80101d97:	e8 0c f8 ff ff       	call   801015a8 <bfree>
80101d9c:	83 c4 10             	add    $0x10,%esp
      ip->addrs[i] = 0;
80101d9f:	8b 45 08             	mov    0x8(%ebp),%eax
80101da2:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101da5:	83 c2 14             	add    $0x14,%edx
80101da8:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
80101daf:	00 
  for(i = 0; i < NDIRECT; i++){
80101db0:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101db4:	83 7d f4 0b          	cmpl   $0xb,-0xc(%ebp)
80101db8:	7e b5                	jle    80101d6f <itrunc+0xf>
    }
  }

  if(ip->addrs[NDIRECT]){
80101dba:	8b 45 08             	mov    0x8(%ebp),%eax
80101dbd:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101dc3:	85 c0                	test   %eax,%eax
80101dc5:	0f 84 aa 00 00 00    	je     80101e75 <itrunc+0x115>
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
80101dcb:	8b 45 08             	mov    0x8(%ebp),%eax
80101dce:	8b 90 8c 00 00 00    	mov    0x8c(%eax),%edx
80101dd4:	8b 45 08             	mov    0x8(%ebp),%eax
80101dd7:	8b 00                	mov    (%eax),%eax
80101dd9:	83 ec 08             	sub    $0x8,%esp
80101ddc:	52                   	push   %edx
80101ddd:	50                   	push   %eax
80101dde:	e8 1e e4 ff ff       	call   80100201 <bread>
80101de3:	83 c4 10             	add    $0x10,%esp
80101de6:	89 45 ec             	mov    %eax,-0x14(%ebp)
    a = (uint*)bp->data;
80101de9:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101dec:	83 c0 5c             	add    $0x5c,%eax
80101def:	89 45 e8             	mov    %eax,-0x18(%ebp)
    for(j = 0; j < NINDIRECT; j++){
80101df2:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80101df9:	eb 3c                	jmp    80101e37 <itrunc+0xd7>
      if(a[j])
80101dfb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101dfe:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101e05:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101e08:	01 d0                	add    %edx,%eax
80101e0a:	8b 00                	mov    (%eax),%eax
80101e0c:	85 c0                	test   %eax,%eax
80101e0e:	74 23                	je     80101e33 <itrunc+0xd3>
        bfree(ip->dev, a[j]);
80101e10:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101e13:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101e1a:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101e1d:	01 d0                	add    %edx,%eax
80101e1f:	8b 00                	mov    (%eax),%eax
80101e21:	8b 55 08             	mov    0x8(%ebp),%edx
80101e24:	8b 12                	mov    (%edx),%edx
80101e26:	83 ec 08             	sub    $0x8,%esp
80101e29:	50                   	push   %eax
80101e2a:	52                   	push   %edx
80101e2b:	e8 78 f7 ff ff       	call   801015a8 <bfree>
80101e30:	83 c4 10             	add    $0x10,%esp
    for(j = 0; j < NINDIRECT; j++){
80101e33:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80101e37:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101e3a:	83 f8 7f             	cmp    $0x7f,%eax
80101e3d:	76 bc                	jbe    80101dfb <itrunc+0x9b>
    }
    brelse(bp);
80101e3f:	83 ec 0c             	sub    $0xc,%esp
80101e42:	ff 75 ec             	push   -0x14(%ebp)
80101e45:	e8 39 e4 ff ff       	call   80100283 <brelse>
80101e4a:	83 c4 10             	add    $0x10,%esp
    bfree(ip->dev, ip->addrs[NDIRECT]);
80101e4d:	8b 45 08             	mov    0x8(%ebp),%eax
80101e50:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101e56:	8b 55 08             	mov    0x8(%ebp),%edx
80101e59:	8b 12                	mov    (%edx),%edx
80101e5b:	83 ec 08             	sub    $0x8,%esp
80101e5e:	50                   	push   %eax
80101e5f:	52                   	push   %edx
80101e60:	e8 43 f7 ff ff       	call   801015a8 <bfree>
80101e65:	83 c4 10             	add    $0x10,%esp
    ip->addrs[NDIRECT] = 0;
80101e68:	8b 45 08             	mov    0x8(%ebp),%eax
80101e6b:	c7 80 8c 00 00 00 00 	movl   $0x0,0x8c(%eax)
80101e72:	00 00 00 
  }

  ip->size = 0;
80101e75:	8b 45 08             	mov    0x8(%ebp),%eax
80101e78:	c7 40 58 00 00 00 00 	movl   $0x0,0x58(%eax)
  iupdate(ip);
80101e7f:	83 ec 0c             	sub    $0xc,%esp
80101e82:	ff 75 08             	push   0x8(%ebp)
80101e85:	e8 83 f9 ff ff       	call   8010180d <iupdate>
80101e8a:	83 c4 10             	add    $0x10,%esp
}
80101e8d:	90                   	nop
80101e8e:	c9                   	leave  
80101e8f:	c3                   	ret    

80101e90 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
80101e90:	55                   	push   %ebp
80101e91:	89 e5                	mov    %esp,%ebp
  st->dev = ip->dev;
80101e93:	8b 45 08             	mov    0x8(%ebp),%eax
80101e96:	8b 00                	mov    (%eax),%eax
80101e98:	89 c2                	mov    %eax,%edx
80101e9a:	8b 45 0c             	mov    0xc(%ebp),%eax
80101e9d:	89 50 04             	mov    %edx,0x4(%eax)
  st->ino = ip->inum;
80101ea0:	8b 45 08             	mov    0x8(%ebp),%eax
80101ea3:	8b 50 04             	mov    0x4(%eax),%edx
80101ea6:	8b 45 0c             	mov    0xc(%ebp),%eax
80101ea9:	89 50 08             	mov    %edx,0x8(%eax)
  st->type = ip->type;
80101eac:	8b 45 08             	mov    0x8(%ebp),%eax
80101eaf:	0f b7 50 50          	movzwl 0x50(%eax),%edx
80101eb3:	8b 45 0c             	mov    0xc(%ebp),%eax
80101eb6:	66 89 10             	mov    %dx,(%eax)
  st->nlink = ip->nlink;
80101eb9:	8b 45 08             	mov    0x8(%ebp),%eax
80101ebc:	0f b7 50 56          	movzwl 0x56(%eax),%edx
80101ec0:	8b 45 0c             	mov    0xc(%ebp),%eax
80101ec3:	66 89 50 0c          	mov    %dx,0xc(%eax)
  st->size = ip->size;
80101ec7:	8b 45 08             	mov    0x8(%ebp),%eax
80101eca:	8b 50 58             	mov    0x58(%eax),%edx
80101ecd:	8b 45 0c             	mov    0xc(%ebp),%eax
80101ed0:	89 50 10             	mov    %edx,0x10(%eax)
}
80101ed3:	90                   	nop
80101ed4:	5d                   	pop    %ebp
80101ed5:	c3                   	ret    

80101ed6 <readi>:
//PAGEBREAK!
// Read data from inode.
// Caller must hold ip->lock.
int
readi(struct inode *ip, char *dst, uint off, uint n)
{
80101ed6:	55                   	push   %ebp
80101ed7:	89 e5                	mov    %esp,%ebp
80101ed9:	83 ec 18             	sub    $0x18,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80101edc:	8b 45 08             	mov    0x8(%ebp),%eax
80101edf:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80101ee3:	66 83 f8 03          	cmp    $0x3,%ax
80101ee7:	75 5c                	jne    80101f45 <readi+0x6f>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
80101ee9:	8b 45 08             	mov    0x8(%ebp),%eax
80101eec:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101ef0:	66 85 c0             	test   %ax,%ax
80101ef3:	78 20                	js     80101f15 <readi+0x3f>
80101ef5:	8b 45 08             	mov    0x8(%ebp),%eax
80101ef8:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101efc:	66 83 f8 09          	cmp    $0x9,%ax
80101f00:	7f 13                	jg     80101f15 <readi+0x3f>
80101f02:	8b 45 08             	mov    0x8(%ebp),%eax
80101f05:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101f09:	98                   	cwtl   
80101f0a:	8b 04 c5 40 4a 11 80 	mov    -0x7feeb5c0(,%eax,8),%eax
80101f11:	85 c0                	test   %eax,%eax
80101f13:	75 0a                	jne    80101f1f <readi+0x49>
      return -1;
80101f15:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101f1a:	e9 0a 01 00 00       	jmp    80102029 <readi+0x153>
    return devsw[ip->major].read(ip, dst, n);
80101f1f:	8b 45 08             	mov    0x8(%ebp),%eax
80101f22:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101f26:	98                   	cwtl   
80101f27:	8b 04 c5 40 4a 11 80 	mov    -0x7feeb5c0(,%eax,8),%eax
80101f2e:	8b 55 14             	mov    0x14(%ebp),%edx
80101f31:	83 ec 04             	sub    $0x4,%esp
80101f34:	52                   	push   %edx
80101f35:	ff 75 0c             	push   0xc(%ebp)
80101f38:	ff 75 08             	push   0x8(%ebp)
80101f3b:	ff d0                	call   *%eax
80101f3d:	83 c4 10             	add    $0x10,%esp
80101f40:	e9 e4 00 00 00       	jmp    80102029 <readi+0x153>
  }

  if(off > ip->size || off + n < off)
80101f45:	8b 45 08             	mov    0x8(%ebp),%eax
80101f48:	8b 40 58             	mov    0x58(%eax),%eax
80101f4b:	39 45 10             	cmp    %eax,0x10(%ebp)
80101f4e:	77 0d                	ja     80101f5d <readi+0x87>
80101f50:	8b 55 10             	mov    0x10(%ebp),%edx
80101f53:	8b 45 14             	mov    0x14(%ebp),%eax
80101f56:	01 d0                	add    %edx,%eax
80101f58:	39 45 10             	cmp    %eax,0x10(%ebp)
80101f5b:	76 0a                	jbe    80101f67 <readi+0x91>
    return -1;
80101f5d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101f62:	e9 c2 00 00 00       	jmp    80102029 <readi+0x153>
  if(off + n > ip->size)
80101f67:	8b 55 10             	mov    0x10(%ebp),%edx
80101f6a:	8b 45 14             	mov    0x14(%ebp),%eax
80101f6d:	01 c2                	add    %eax,%edx
80101f6f:	8b 45 08             	mov    0x8(%ebp),%eax
80101f72:	8b 40 58             	mov    0x58(%eax),%eax
80101f75:	39 c2                	cmp    %eax,%edx
80101f77:	76 0c                	jbe    80101f85 <readi+0xaf>
    n = ip->size - off;
80101f79:	8b 45 08             	mov    0x8(%ebp),%eax
80101f7c:	8b 40 58             	mov    0x58(%eax),%eax
80101f7f:	2b 45 10             	sub    0x10(%ebp),%eax
80101f82:	89 45 14             	mov    %eax,0x14(%ebp)

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80101f85:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101f8c:	e9 89 00 00 00       	jmp    8010201a <readi+0x144>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80101f91:	8b 45 10             	mov    0x10(%ebp),%eax
80101f94:	c1 e8 09             	shr    $0x9,%eax
80101f97:	83 ec 08             	sub    $0x8,%esp
80101f9a:	50                   	push   %eax
80101f9b:	ff 75 08             	push   0x8(%ebp)
80101f9e:	e8 9d fc ff ff       	call   80101c40 <bmap>
80101fa3:	83 c4 10             	add    $0x10,%esp
80101fa6:	8b 55 08             	mov    0x8(%ebp),%edx
80101fa9:	8b 12                	mov    (%edx),%edx
80101fab:	83 ec 08             	sub    $0x8,%esp
80101fae:	50                   	push   %eax
80101faf:	52                   	push   %edx
80101fb0:	e8 4c e2 ff ff       	call   80100201 <bread>
80101fb5:	83 c4 10             	add    $0x10,%esp
80101fb8:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
80101fbb:	8b 45 10             	mov    0x10(%ebp),%eax
80101fbe:	25 ff 01 00 00       	and    $0x1ff,%eax
80101fc3:	ba 00 02 00 00       	mov    $0x200,%edx
80101fc8:	29 c2                	sub    %eax,%edx
80101fca:	8b 45 14             	mov    0x14(%ebp),%eax
80101fcd:	2b 45 f4             	sub    -0xc(%ebp),%eax
80101fd0:	39 c2                	cmp    %eax,%edx
80101fd2:	0f 46 c2             	cmovbe %edx,%eax
80101fd5:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dst, bp->data + off%BSIZE, m);
80101fd8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101fdb:	8d 50 5c             	lea    0x5c(%eax),%edx
80101fde:	8b 45 10             	mov    0x10(%ebp),%eax
80101fe1:	25 ff 01 00 00       	and    $0x1ff,%eax
80101fe6:	01 d0                	add    %edx,%eax
80101fe8:	83 ec 04             	sub    $0x4,%esp
80101feb:	ff 75 ec             	push   -0x14(%ebp)
80101fee:	50                   	push   %eax
80101fef:	ff 75 0c             	push   0xc(%ebp)
80101ff2:	e8 2b 2f 00 00       	call   80104f22 <memmove>
80101ff7:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80101ffa:	83 ec 0c             	sub    $0xc,%esp
80101ffd:	ff 75 f0             	push   -0x10(%ebp)
80102000:	e8 7e e2 ff ff       	call   80100283 <brelse>
80102005:	83 c4 10             	add    $0x10,%esp
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80102008:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010200b:	01 45 f4             	add    %eax,-0xc(%ebp)
8010200e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102011:	01 45 10             	add    %eax,0x10(%ebp)
80102014:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102017:	01 45 0c             	add    %eax,0xc(%ebp)
8010201a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010201d:	3b 45 14             	cmp    0x14(%ebp),%eax
80102020:	0f 82 6b ff ff ff    	jb     80101f91 <readi+0xbb>
  }
  return n;
80102026:	8b 45 14             	mov    0x14(%ebp),%eax
}
80102029:	c9                   	leave  
8010202a:	c3                   	ret    

8010202b <writei>:
// PAGEBREAK!
// Write data to inode.
// Caller must hold ip->lock.
int
writei(struct inode *ip, char *src, uint off, uint n)
{
8010202b:	55                   	push   %ebp
8010202c:	89 e5                	mov    %esp,%ebp
8010202e:	83 ec 18             	sub    $0x18,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80102031:	8b 45 08             	mov    0x8(%ebp),%eax
80102034:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80102038:	66 83 f8 03          	cmp    $0x3,%ax
8010203c:	75 5c                	jne    8010209a <writei+0x6f>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
8010203e:	8b 45 08             	mov    0x8(%ebp),%eax
80102041:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80102045:	66 85 c0             	test   %ax,%ax
80102048:	78 20                	js     8010206a <writei+0x3f>
8010204a:	8b 45 08             	mov    0x8(%ebp),%eax
8010204d:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80102051:	66 83 f8 09          	cmp    $0x9,%ax
80102055:	7f 13                	jg     8010206a <writei+0x3f>
80102057:	8b 45 08             	mov    0x8(%ebp),%eax
8010205a:	0f b7 40 52          	movzwl 0x52(%eax),%eax
8010205e:	98                   	cwtl   
8010205f:	8b 04 c5 44 4a 11 80 	mov    -0x7feeb5bc(,%eax,8),%eax
80102066:	85 c0                	test   %eax,%eax
80102068:	75 0a                	jne    80102074 <writei+0x49>
      return -1;
8010206a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010206f:	e9 3b 01 00 00       	jmp    801021af <writei+0x184>
    return devsw[ip->major].write(ip, src, n);
80102074:	8b 45 08             	mov    0x8(%ebp),%eax
80102077:	0f b7 40 52          	movzwl 0x52(%eax),%eax
8010207b:	98                   	cwtl   
8010207c:	8b 04 c5 44 4a 11 80 	mov    -0x7feeb5bc(,%eax,8),%eax
80102083:	8b 55 14             	mov    0x14(%ebp),%edx
80102086:	83 ec 04             	sub    $0x4,%esp
80102089:	52                   	push   %edx
8010208a:	ff 75 0c             	push   0xc(%ebp)
8010208d:	ff 75 08             	push   0x8(%ebp)
80102090:	ff d0                	call   *%eax
80102092:	83 c4 10             	add    $0x10,%esp
80102095:	e9 15 01 00 00       	jmp    801021af <writei+0x184>
  }

  if(off > ip->size || off + n < off)
8010209a:	8b 45 08             	mov    0x8(%ebp),%eax
8010209d:	8b 40 58             	mov    0x58(%eax),%eax
801020a0:	39 45 10             	cmp    %eax,0x10(%ebp)
801020a3:	77 0d                	ja     801020b2 <writei+0x87>
801020a5:	8b 55 10             	mov    0x10(%ebp),%edx
801020a8:	8b 45 14             	mov    0x14(%ebp),%eax
801020ab:	01 d0                	add    %edx,%eax
801020ad:	39 45 10             	cmp    %eax,0x10(%ebp)
801020b0:	76 0a                	jbe    801020bc <writei+0x91>
    return -1;
801020b2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801020b7:	e9 f3 00 00 00       	jmp    801021af <writei+0x184>
  if(off + n > MAXFILE*BSIZE)
801020bc:	8b 55 10             	mov    0x10(%ebp),%edx
801020bf:	8b 45 14             	mov    0x14(%ebp),%eax
801020c2:	01 d0                	add    %edx,%eax
801020c4:	3d 00 18 01 00       	cmp    $0x11800,%eax
801020c9:	76 0a                	jbe    801020d5 <writei+0xaa>
    return -1;
801020cb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801020d0:	e9 da 00 00 00       	jmp    801021af <writei+0x184>

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
801020d5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801020dc:	e9 97 00 00 00       	jmp    80102178 <writei+0x14d>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
801020e1:	8b 45 10             	mov    0x10(%ebp),%eax
801020e4:	c1 e8 09             	shr    $0x9,%eax
801020e7:	83 ec 08             	sub    $0x8,%esp
801020ea:	50                   	push   %eax
801020eb:	ff 75 08             	push   0x8(%ebp)
801020ee:	e8 4d fb ff ff       	call   80101c40 <bmap>
801020f3:	83 c4 10             	add    $0x10,%esp
801020f6:	8b 55 08             	mov    0x8(%ebp),%edx
801020f9:	8b 12                	mov    (%edx),%edx
801020fb:	83 ec 08             	sub    $0x8,%esp
801020fe:	50                   	push   %eax
801020ff:	52                   	push   %edx
80102100:	e8 fc e0 ff ff       	call   80100201 <bread>
80102105:	83 c4 10             	add    $0x10,%esp
80102108:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
8010210b:	8b 45 10             	mov    0x10(%ebp),%eax
8010210e:	25 ff 01 00 00       	and    $0x1ff,%eax
80102113:	ba 00 02 00 00       	mov    $0x200,%edx
80102118:	29 c2                	sub    %eax,%edx
8010211a:	8b 45 14             	mov    0x14(%ebp),%eax
8010211d:	2b 45 f4             	sub    -0xc(%ebp),%eax
80102120:	39 c2                	cmp    %eax,%edx
80102122:	0f 46 c2             	cmovbe %edx,%eax
80102125:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(bp->data + off%BSIZE, src, m);
80102128:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010212b:	8d 50 5c             	lea    0x5c(%eax),%edx
8010212e:	8b 45 10             	mov    0x10(%ebp),%eax
80102131:	25 ff 01 00 00       	and    $0x1ff,%eax
80102136:	01 d0                	add    %edx,%eax
80102138:	83 ec 04             	sub    $0x4,%esp
8010213b:	ff 75 ec             	push   -0x14(%ebp)
8010213e:	ff 75 0c             	push   0xc(%ebp)
80102141:	50                   	push   %eax
80102142:	e8 db 2d 00 00       	call   80104f22 <memmove>
80102147:	83 c4 10             	add    $0x10,%esp
    log_write(bp);
8010214a:	83 ec 0c             	sub    $0xc,%esp
8010214d:	ff 75 f0             	push   -0x10(%ebp)
80102150:	e8 04 16 00 00       	call   80103759 <log_write>
80102155:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80102158:	83 ec 0c             	sub    $0xc,%esp
8010215b:	ff 75 f0             	push   -0x10(%ebp)
8010215e:	e8 20 e1 ff ff       	call   80100283 <brelse>
80102163:	83 c4 10             	add    $0x10,%esp
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
80102166:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102169:	01 45 f4             	add    %eax,-0xc(%ebp)
8010216c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010216f:	01 45 10             	add    %eax,0x10(%ebp)
80102172:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102175:	01 45 0c             	add    %eax,0xc(%ebp)
80102178:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010217b:	3b 45 14             	cmp    0x14(%ebp),%eax
8010217e:	0f 82 5d ff ff ff    	jb     801020e1 <writei+0xb6>
  }

  if(n > 0 && off > ip->size){
80102184:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80102188:	74 22                	je     801021ac <writei+0x181>
8010218a:	8b 45 08             	mov    0x8(%ebp),%eax
8010218d:	8b 40 58             	mov    0x58(%eax),%eax
80102190:	39 45 10             	cmp    %eax,0x10(%ebp)
80102193:	76 17                	jbe    801021ac <writei+0x181>
    ip->size = off;
80102195:	8b 45 08             	mov    0x8(%ebp),%eax
80102198:	8b 55 10             	mov    0x10(%ebp),%edx
8010219b:	89 50 58             	mov    %edx,0x58(%eax)
    iupdate(ip);
8010219e:	83 ec 0c             	sub    $0xc,%esp
801021a1:	ff 75 08             	push   0x8(%ebp)
801021a4:	e8 64 f6 ff ff       	call   8010180d <iupdate>
801021a9:	83 c4 10             	add    $0x10,%esp
  }
  return n;
801021ac:	8b 45 14             	mov    0x14(%ebp),%eax
}
801021af:	c9                   	leave  
801021b0:	c3                   	ret    

801021b1 <namecmp>:
//PAGEBREAK!
// Directories

int
namecmp(const char *s, const char *t)
{
801021b1:	55                   	push   %ebp
801021b2:	89 e5                	mov    %esp,%ebp
801021b4:	83 ec 08             	sub    $0x8,%esp
  return strncmp(s, t, DIRSIZ);
801021b7:	83 ec 04             	sub    $0x4,%esp
801021ba:	6a 0e                	push   $0xe
801021bc:	ff 75 0c             	push   0xc(%ebp)
801021bf:	ff 75 08             	push   0x8(%ebp)
801021c2:	e8 f1 2d 00 00       	call   80104fb8 <strncmp>
801021c7:	83 c4 10             	add    $0x10,%esp
}
801021ca:	c9                   	leave  
801021cb:	c3                   	ret    

801021cc <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
801021cc:	55                   	push   %ebp
801021cd:	89 e5                	mov    %esp,%ebp
801021cf:	83 ec 28             	sub    $0x28,%esp
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
801021d2:	8b 45 08             	mov    0x8(%ebp),%eax
801021d5:	0f b7 40 50          	movzwl 0x50(%eax),%eax
801021d9:	66 83 f8 01          	cmp    $0x1,%ax
801021dd:	74 0d                	je     801021ec <dirlookup+0x20>
    panic("dirlookup not DIR");
801021df:	83 ec 0c             	sub    $0xc,%esp
801021e2:	68 1d a6 10 80       	push   $0x8010a61d
801021e7:	e8 bd e3 ff ff       	call   801005a9 <panic>

  for(off = 0; off < dp->size; off += sizeof(de)){
801021ec:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801021f3:	eb 7b                	jmp    80102270 <dirlookup+0xa4>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801021f5:	6a 10                	push   $0x10
801021f7:	ff 75 f4             	push   -0xc(%ebp)
801021fa:	8d 45 e0             	lea    -0x20(%ebp),%eax
801021fd:	50                   	push   %eax
801021fe:	ff 75 08             	push   0x8(%ebp)
80102201:	e8 d0 fc ff ff       	call   80101ed6 <readi>
80102206:	83 c4 10             	add    $0x10,%esp
80102209:	83 f8 10             	cmp    $0x10,%eax
8010220c:	74 0d                	je     8010221b <dirlookup+0x4f>
      panic("dirlookup read");
8010220e:	83 ec 0c             	sub    $0xc,%esp
80102211:	68 2f a6 10 80       	push   $0x8010a62f
80102216:	e8 8e e3 ff ff       	call   801005a9 <panic>
    if(de.inum == 0)
8010221b:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
8010221f:	66 85 c0             	test   %ax,%ax
80102222:	74 47                	je     8010226b <dirlookup+0x9f>
      continue;
    if(namecmp(name, de.name) == 0){
80102224:	83 ec 08             	sub    $0x8,%esp
80102227:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010222a:	83 c0 02             	add    $0x2,%eax
8010222d:	50                   	push   %eax
8010222e:	ff 75 0c             	push   0xc(%ebp)
80102231:	e8 7b ff ff ff       	call   801021b1 <namecmp>
80102236:	83 c4 10             	add    $0x10,%esp
80102239:	85 c0                	test   %eax,%eax
8010223b:	75 2f                	jne    8010226c <dirlookup+0xa0>
      // entry matches path element
      if(poff)
8010223d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80102241:	74 08                	je     8010224b <dirlookup+0x7f>
        *poff = off;
80102243:	8b 45 10             	mov    0x10(%ebp),%eax
80102246:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102249:	89 10                	mov    %edx,(%eax)
      inum = de.inum;
8010224b:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
8010224f:	0f b7 c0             	movzwl %ax,%eax
80102252:	89 45 f0             	mov    %eax,-0x10(%ebp)
      return iget(dp->dev, inum);
80102255:	8b 45 08             	mov    0x8(%ebp),%eax
80102258:	8b 00                	mov    (%eax),%eax
8010225a:	83 ec 08             	sub    $0x8,%esp
8010225d:	ff 75 f0             	push   -0x10(%ebp)
80102260:	50                   	push   %eax
80102261:	e8 68 f6 ff ff       	call   801018ce <iget>
80102266:	83 c4 10             	add    $0x10,%esp
80102269:	eb 19                	jmp    80102284 <dirlookup+0xb8>
      continue;
8010226b:	90                   	nop
  for(off = 0; off < dp->size; off += sizeof(de)){
8010226c:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80102270:	8b 45 08             	mov    0x8(%ebp),%eax
80102273:	8b 40 58             	mov    0x58(%eax),%eax
80102276:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80102279:	0f 82 76 ff ff ff    	jb     801021f5 <dirlookup+0x29>
    }
  }

  return 0;
8010227f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102284:	c9                   	leave  
80102285:	c3                   	ret    

80102286 <dirlink>:

// Write a new directory entry (name, inum) into the directory dp.
int
dirlink(struct inode *dp, char *name, uint inum)
{
80102286:	55                   	push   %ebp
80102287:	89 e5                	mov    %esp,%ebp
80102289:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;
  struct inode *ip;

  // Check that name is not present.
  if((ip = dirlookup(dp, name, 0)) != 0){
8010228c:	83 ec 04             	sub    $0x4,%esp
8010228f:	6a 00                	push   $0x0
80102291:	ff 75 0c             	push   0xc(%ebp)
80102294:	ff 75 08             	push   0x8(%ebp)
80102297:	e8 30 ff ff ff       	call   801021cc <dirlookup>
8010229c:	83 c4 10             	add    $0x10,%esp
8010229f:	89 45 f0             	mov    %eax,-0x10(%ebp)
801022a2:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801022a6:	74 18                	je     801022c0 <dirlink+0x3a>
    iput(ip);
801022a8:	83 ec 0c             	sub    $0xc,%esp
801022ab:	ff 75 f0             	push   -0x10(%ebp)
801022ae:	e8 98 f8 ff ff       	call   80101b4b <iput>
801022b3:	83 c4 10             	add    $0x10,%esp
    return -1;
801022b6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801022bb:	e9 9c 00 00 00       	jmp    8010235c <dirlink+0xd6>
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
801022c0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801022c7:	eb 39                	jmp    80102302 <dirlink+0x7c>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801022c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801022cc:	6a 10                	push   $0x10
801022ce:	50                   	push   %eax
801022cf:	8d 45 e0             	lea    -0x20(%ebp),%eax
801022d2:	50                   	push   %eax
801022d3:	ff 75 08             	push   0x8(%ebp)
801022d6:	e8 fb fb ff ff       	call   80101ed6 <readi>
801022db:	83 c4 10             	add    $0x10,%esp
801022de:	83 f8 10             	cmp    $0x10,%eax
801022e1:	74 0d                	je     801022f0 <dirlink+0x6a>
      panic("dirlink read");
801022e3:	83 ec 0c             	sub    $0xc,%esp
801022e6:	68 3e a6 10 80       	push   $0x8010a63e
801022eb:	e8 b9 e2 ff ff       	call   801005a9 <panic>
    if(de.inum == 0)
801022f0:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
801022f4:	66 85 c0             	test   %ax,%ax
801022f7:	74 18                	je     80102311 <dirlink+0x8b>
  for(off = 0; off < dp->size; off += sizeof(de)){
801022f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801022fc:	83 c0 10             	add    $0x10,%eax
801022ff:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102302:	8b 45 08             	mov    0x8(%ebp),%eax
80102305:	8b 50 58             	mov    0x58(%eax),%edx
80102308:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010230b:	39 c2                	cmp    %eax,%edx
8010230d:	77 ba                	ja     801022c9 <dirlink+0x43>
8010230f:	eb 01                	jmp    80102312 <dirlink+0x8c>
      break;
80102311:	90                   	nop
  }

  strncpy(de.name, name, DIRSIZ);
80102312:	83 ec 04             	sub    $0x4,%esp
80102315:	6a 0e                	push   $0xe
80102317:	ff 75 0c             	push   0xc(%ebp)
8010231a:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010231d:	83 c0 02             	add    $0x2,%eax
80102320:	50                   	push   %eax
80102321:	e8 e8 2c 00 00       	call   8010500e <strncpy>
80102326:	83 c4 10             	add    $0x10,%esp
  de.inum = inum;
80102329:	8b 45 10             	mov    0x10(%ebp),%eax
8010232c:	66 89 45 e0          	mov    %ax,-0x20(%ebp)
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102330:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102333:	6a 10                	push   $0x10
80102335:	50                   	push   %eax
80102336:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102339:	50                   	push   %eax
8010233a:	ff 75 08             	push   0x8(%ebp)
8010233d:	e8 e9 fc ff ff       	call   8010202b <writei>
80102342:	83 c4 10             	add    $0x10,%esp
80102345:	83 f8 10             	cmp    $0x10,%eax
80102348:	74 0d                	je     80102357 <dirlink+0xd1>
    panic("dirlink");
8010234a:	83 ec 0c             	sub    $0xc,%esp
8010234d:	68 4b a6 10 80       	push   $0x8010a64b
80102352:	e8 52 e2 ff ff       	call   801005a9 <panic>

  return 0;
80102357:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010235c:	c9                   	leave  
8010235d:	c3                   	ret    

8010235e <skipelem>:
//   skipelem("a", name) = "", setting name = "a"
//   skipelem("", name) = skipelem("////", name) = 0
//
static char*
skipelem(char *path, char *name)
{
8010235e:	55                   	push   %ebp
8010235f:	89 e5                	mov    %esp,%ebp
80102361:	83 ec 18             	sub    $0x18,%esp
  char *s;
  int len;

  while(*path == '/')
80102364:	eb 04                	jmp    8010236a <skipelem+0xc>
    path++;
80102366:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path == '/')
8010236a:	8b 45 08             	mov    0x8(%ebp),%eax
8010236d:	0f b6 00             	movzbl (%eax),%eax
80102370:	3c 2f                	cmp    $0x2f,%al
80102372:	74 f2                	je     80102366 <skipelem+0x8>
  if(*path == 0)
80102374:	8b 45 08             	mov    0x8(%ebp),%eax
80102377:	0f b6 00             	movzbl (%eax),%eax
8010237a:	84 c0                	test   %al,%al
8010237c:	75 07                	jne    80102385 <skipelem+0x27>
    return 0;
8010237e:	b8 00 00 00 00       	mov    $0x0,%eax
80102383:	eb 77                	jmp    801023fc <skipelem+0x9e>
  s = path;
80102385:	8b 45 08             	mov    0x8(%ebp),%eax
80102388:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(*path != '/' && *path != 0)
8010238b:	eb 04                	jmp    80102391 <skipelem+0x33>
    path++;
8010238d:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path != '/' && *path != 0)
80102391:	8b 45 08             	mov    0x8(%ebp),%eax
80102394:	0f b6 00             	movzbl (%eax),%eax
80102397:	3c 2f                	cmp    $0x2f,%al
80102399:	74 0a                	je     801023a5 <skipelem+0x47>
8010239b:	8b 45 08             	mov    0x8(%ebp),%eax
8010239e:	0f b6 00             	movzbl (%eax),%eax
801023a1:	84 c0                	test   %al,%al
801023a3:	75 e8                	jne    8010238d <skipelem+0x2f>
  len = path - s;
801023a5:	8b 45 08             	mov    0x8(%ebp),%eax
801023a8:	2b 45 f4             	sub    -0xc(%ebp),%eax
801023ab:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(len >= DIRSIZ)
801023ae:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
801023b2:	7e 15                	jle    801023c9 <skipelem+0x6b>
    memmove(name, s, DIRSIZ);
801023b4:	83 ec 04             	sub    $0x4,%esp
801023b7:	6a 0e                	push   $0xe
801023b9:	ff 75 f4             	push   -0xc(%ebp)
801023bc:	ff 75 0c             	push   0xc(%ebp)
801023bf:	e8 5e 2b 00 00       	call   80104f22 <memmove>
801023c4:	83 c4 10             	add    $0x10,%esp
801023c7:	eb 26                	jmp    801023ef <skipelem+0x91>
  else {
    memmove(name, s, len);
801023c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801023cc:	83 ec 04             	sub    $0x4,%esp
801023cf:	50                   	push   %eax
801023d0:	ff 75 f4             	push   -0xc(%ebp)
801023d3:	ff 75 0c             	push   0xc(%ebp)
801023d6:	e8 47 2b 00 00       	call   80104f22 <memmove>
801023db:	83 c4 10             	add    $0x10,%esp
    name[len] = 0;
801023de:	8b 55 f0             	mov    -0x10(%ebp),%edx
801023e1:	8b 45 0c             	mov    0xc(%ebp),%eax
801023e4:	01 d0                	add    %edx,%eax
801023e6:	c6 00 00             	movb   $0x0,(%eax)
  }
  while(*path == '/')
801023e9:	eb 04                	jmp    801023ef <skipelem+0x91>
    path++;
801023eb:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path == '/')
801023ef:	8b 45 08             	mov    0x8(%ebp),%eax
801023f2:	0f b6 00             	movzbl (%eax),%eax
801023f5:	3c 2f                	cmp    $0x2f,%al
801023f7:	74 f2                	je     801023eb <skipelem+0x8d>
  return path;
801023f9:	8b 45 08             	mov    0x8(%ebp),%eax
}
801023fc:	c9                   	leave  
801023fd:	c3                   	ret    

801023fe <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
801023fe:	55                   	push   %ebp
801023ff:	89 e5                	mov    %esp,%ebp
80102401:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip, *next;

  if(*path == '/')
80102404:	8b 45 08             	mov    0x8(%ebp),%eax
80102407:	0f b6 00             	movzbl (%eax),%eax
8010240a:	3c 2f                	cmp    $0x2f,%al
8010240c:	75 17                	jne    80102425 <namex+0x27>
    ip = iget(ROOTDEV, ROOTINO);
8010240e:	83 ec 08             	sub    $0x8,%esp
80102411:	6a 01                	push   $0x1
80102413:	6a 01                	push   $0x1
80102415:	e8 b4 f4 ff ff       	call   801018ce <iget>
8010241a:	83 c4 10             	add    $0x10,%esp
8010241d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102420:	e9 ba 00 00 00       	jmp    801024df <namex+0xe1>
  else
    ip = idup(myproc()->cwd);
80102425:	e8 ea 1a 00 00       	call   80103f14 <myproc>
8010242a:	8b 40 68             	mov    0x68(%eax),%eax
8010242d:	83 ec 0c             	sub    $0xc,%esp
80102430:	50                   	push   %eax
80102431:	e8 7a f5 ff ff       	call   801019b0 <idup>
80102436:	83 c4 10             	add    $0x10,%esp
80102439:	89 45 f4             	mov    %eax,-0xc(%ebp)

  while((path = skipelem(path, name)) != 0){
8010243c:	e9 9e 00 00 00       	jmp    801024df <namex+0xe1>
    ilock(ip);
80102441:	83 ec 0c             	sub    $0xc,%esp
80102444:	ff 75 f4             	push   -0xc(%ebp)
80102447:	e8 9e f5 ff ff       	call   801019ea <ilock>
8010244c:	83 c4 10             	add    $0x10,%esp
    if(ip->type != T_DIR){
8010244f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102452:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80102456:	66 83 f8 01          	cmp    $0x1,%ax
8010245a:	74 18                	je     80102474 <namex+0x76>
      iunlockput(ip);
8010245c:	83 ec 0c             	sub    $0xc,%esp
8010245f:	ff 75 f4             	push   -0xc(%ebp)
80102462:	e8 b4 f7 ff ff       	call   80101c1b <iunlockput>
80102467:	83 c4 10             	add    $0x10,%esp
      return 0;
8010246a:	b8 00 00 00 00       	mov    $0x0,%eax
8010246f:	e9 a7 00 00 00       	jmp    8010251b <namex+0x11d>
    }
    if(nameiparent && *path == '\0'){
80102474:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102478:	74 20                	je     8010249a <namex+0x9c>
8010247a:	8b 45 08             	mov    0x8(%ebp),%eax
8010247d:	0f b6 00             	movzbl (%eax),%eax
80102480:	84 c0                	test   %al,%al
80102482:	75 16                	jne    8010249a <namex+0x9c>
      // Stop one level early.
      iunlock(ip);
80102484:	83 ec 0c             	sub    $0xc,%esp
80102487:	ff 75 f4             	push   -0xc(%ebp)
8010248a:	e8 6e f6 ff ff       	call   80101afd <iunlock>
8010248f:	83 c4 10             	add    $0x10,%esp
      return ip;
80102492:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102495:	e9 81 00 00 00       	jmp    8010251b <namex+0x11d>
    }
    if((next = dirlookup(ip, name, 0)) == 0){
8010249a:	83 ec 04             	sub    $0x4,%esp
8010249d:	6a 00                	push   $0x0
8010249f:	ff 75 10             	push   0x10(%ebp)
801024a2:	ff 75 f4             	push   -0xc(%ebp)
801024a5:	e8 22 fd ff ff       	call   801021cc <dirlookup>
801024aa:	83 c4 10             	add    $0x10,%esp
801024ad:	89 45 f0             	mov    %eax,-0x10(%ebp)
801024b0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801024b4:	75 15                	jne    801024cb <namex+0xcd>
      iunlockput(ip);
801024b6:	83 ec 0c             	sub    $0xc,%esp
801024b9:	ff 75 f4             	push   -0xc(%ebp)
801024bc:	e8 5a f7 ff ff       	call   80101c1b <iunlockput>
801024c1:	83 c4 10             	add    $0x10,%esp
      return 0;
801024c4:	b8 00 00 00 00       	mov    $0x0,%eax
801024c9:	eb 50                	jmp    8010251b <namex+0x11d>
    }
    iunlockput(ip);
801024cb:	83 ec 0c             	sub    $0xc,%esp
801024ce:	ff 75 f4             	push   -0xc(%ebp)
801024d1:	e8 45 f7 ff ff       	call   80101c1b <iunlockput>
801024d6:	83 c4 10             	add    $0x10,%esp
    ip = next;
801024d9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801024dc:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while((path = skipelem(path, name)) != 0){
801024df:	83 ec 08             	sub    $0x8,%esp
801024e2:	ff 75 10             	push   0x10(%ebp)
801024e5:	ff 75 08             	push   0x8(%ebp)
801024e8:	e8 71 fe ff ff       	call   8010235e <skipelem>
801024ed:	83 c4 10             	add    $0x10,%esp
801024f0:	89 45 08             	mov    %eax,0x8(%ebp)
801024f3:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801024f7:	0f 85 44 ff ff ff    	jne    80102441 <namex+0x43>
  }
  if(nameiparent){
801024fd:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102501:	74 15                	je     80102518 <namex+0x11a>
    iput(ip);
80102503:	83 ec 0c             	sub    $0xc,%esp
80102506:	ff 75 f4             	push   -0xc(%ebp)
80102509:	e8 3d f6 ff ff       	call   80101b4b <iput>
8010250e:	83 c4 10             	add    $0x10,%esp
    return 0;
80102511:	b8 00 00 00 00       	mov    $0x0,%eax
80102516:	eb 03                	jmp    8010251b <namex+0x11d>
  }
  return ip;
80102518:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010251b:	c9                   	leave  
8010251c:	c3                   	ret    

8010251d <namei>:

struct inode*
namei(char *path)
{
8010251d:	55                   	push   %ebp
8010251e:	89 e5                	mov    %esp,%ebp
80102520:	83 ec 18             	sub    $0x18,%esp
  char name[DIRSIZ];
  return namex(path, 0, name);
80102523:	83 ec 04             	sub    $0x4,%esp
80102526:	8d 45 ea             	lea    -0x16(%ebp),%eax
80102529:	50                   	push   %eax
8010252a:	6a 00                	push   $0x0
8010252c:	ff 75 08             	push   0x8(%ebp)
8010252f:	e8 ca fe ff ff       	call   801023fe <namex>
80102534:	83 c4 10             	add    $0x10,%esp
}
80102537:	c9                   	leave  
80102538:	c3                   	ret    

80102539 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
80102539:	55                   	push   %ebp
8010253a:	89 e5                	mov    %esp,%ebp
8010253c:	83 ec 08             	sub    $0x8,%esp
  return namex(path, 1, name);
8010253f:	83 ec 04             	sub    $0x4,%esp
80102542:	ff 75 0c             	push   0xc(%ebp)
80102545:	6a 01                	push   $0x1
80102547:	ff 75 08             	push   0x8(%ebp)
8010254a:	e8 af fe ff ff       	call   801023fe <namex>
8010254f:	83 c4 10             	add    $0x10,%esp
}
80102552:	c9                   	leave  
80102553:	c3                   	ret    

80102554 <inb>:
{
80102554:	55                   	push   %ebp
80102555:	89 e5                	mov    %esp,%ebp
80102557:	83 ec 14             	sub    $0x14,%esp
8010255a:	8b 45 08             	mov    0x8(%ebp),%eax
8010255d:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102561:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102565:	89 c2                	mov    %eax,%edx
80102567:	ec                   	in     (%dx),%al
80102568:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
8010256b:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
8010256f:	c9                   	leave  
80102570:	c3                   	ret    

80102571 <insl>:
{
80102571:	55                   	push   %ebp
80102572:	89 e5                	mov    %esp,%ebp
80102574:	57                   	push   %edi
80102575:	53                   	push   %ebx
  asm volatile("cld; rep insl" :
80102576:	8b 55 08             	mov    0x8(%ebp),%edx
80102579:	8b 4d 0c             	mov    0xc(%ebp),%ecx
8010257c:	8b 45 10             	mov    0x10(%ebp),%eax
8010257f:	89 cb                	mov    %ecx,%ebx
80102581:	89 df                	mov    %ebx,%edi
80102583:	89 c1                	mov    %eax,%ecx
80102585:	fc                   	cld    
80102586:	f3 6d                	rep insl (%dx),%es:(%edi)
80102588:	89 c8                	mov    %ecx,%eax
8010258a:	89 fb                	mov    %edi,%ebx
8010258c:	89 5d 0c             	mov    %ebx,0xc(%ebp)
8010258f:	89 45 10             	mov    %eax,0x10(%ebp)
}
80102592:	90                   	nop
80102593:	5b                   	pop    %ebx
80102594:	5f                   	pop    %edi
80102595:	5d                   	pop    %ebp
80102596:	c3                   	ret    

80102597 <outb>:
{
80102597:	55                   	push   %ebp
80102598:	89 e5                	mov    %esp,%ebp
8010259a:	83 ec 08             	sub    $0x8,%esp
8010259d:	8b 45 08             	mov    0x8(%ebp),%eax
801025a0:	8b 55 0c             	mov    0xc(%ebp),%edx
801025a3:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
801025a7:	89 d0                	mov    %edx,%eax
801025a9:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801025ac:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801025b0:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801025b4:	ee                   	out    %al,(%dx)
}
801025b5:	90                   	nop
801025b6:	c9                   	leave  
801025b7:	c3                   	ret    

801025b8 <outsl>:
{
801025b8:	55                   	push   %ebp
801025b9:	89 e5                	mov    %esp,%ebp
801025bb:	56                   	push   %esi
801025bc:	53                   	push   %ebx
  asm volatile("cld; rep outsl" :
801025bd:	8b 55 08             	mov    0x8(%ebp),%edx
801025c0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801025c3:	8b 45 10             	mov    0x10(%ebp),%eax
801025c6:	89 cb                	mov    %ecx,%ebx
801025c8:	89 de                	mov    %ebx,%esi
801025ca:	89 c1                	mov    %eax,%ecx
801025cc:	fc                   	cld    
801025cd:	f3 6f                	rep outsl %ds:(%esi),(%dx)
801025cf:	89 c8                	mov    %ecx,%eax
801025d1:	89 f3                	mov    %esi,%ebx
801025d3:	89 5d 0c             	mov    %ebx,0xc(%ebp)
801025d6:	89 45 10             	mov    %eax,0x10(%ebp)
}
801025d9:	90                   	nop
801025da:	5b                   	pop    %ebx
801025db:	5e                   	pop    %esi
801025dc:	5d                   	pop    %ebp
801025dd:	c3                   	ret    

801025de <idewait>:
static void idestart(struct buf*);

// Wait for IDE disk to become ready.
static int
idewait(int checkerr)
{
801025de:	55                   	push   %ebp
801025df:	89 e5                	mov    %esp,%ebp
801025e1:	83 ec 10             	sub    $0x10,%esp
  int r;

  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
801025e4:	90                   	nop
801025e5:	68 f7 01 00 00       	push   $0x1f7
801025ea:	e8 65 ff ff ff       	call   80102554 <inb>
801025ef:	83 c4 04             	add    $0x4,%esp
801025f2:	0f b6 c0             	movzbl %al,%eax
801025f5:	89 45 fc             	mov    %eax,-0x4(%ebp)
801025f8:	8b 45 fc             	mov    -0x4(%ebp),%eax
801025fb:	25 c0 00 00 00       	and    $0xc0,%eax
80102600:	83 f8 40             	cmp    $0x40,%eax
80102603:	75 e0                	jne    801025e5 <idewait+0x7>
    ;
  if(checkerr && (r & (IDE_DF|IDE_ERR)) != 0)
80102605:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80102609:	74 11                	je     8010261c <idewait+0x3e>
8010260b:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010260e:	83 e0 21             	and    $0x21,%eax
80102611:	85 c0                	test   %eax,%eax
80102613:	74 07                	je     8010261c <idewait+0x3e>
    return -1;
80102615:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010261a:	eb 05                	jmp    80102621 <idewait+0x43>
  return 0;
8010261c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102621:	c9                   	leave  
80102622:	c3                   	ret    

80102623 <ideinit>:

void
ideinit(void)
{
80102623:	55                   	push   %ebp
80102624:	89 e5                	mov    %esp,%ebp
80102626:	83 ec 18             	sub    $0x18,%esp
  int i;

  initlock(&idelock, "ide");
80102629:	83 ec 08             	sub    $0x8,%esp
8010262c:	68 53 a6 10 80       	push   $0x8010a653
80102631:	68 c0 70 11 80       	push   $0x801170c0
80102636:	e8 90 25 00 00       	call   80104bcb <initlock>
8010263b:	83 c4 10             	add    $0x10,%esp
  ioapicenable(IRQ_IDE, ncpu - 1);
8010263e:	a1 80 9e 11 80       	mov    0x80119e80,%eax
80102643:	83 e8 01             	sub    $0x1,%eax
80102646:	83 ec 08             	sub    $0x8,%esp
80102649:	50                   	push   %eax
8010264a:	6a 0e                	push   $0xe
8010264c:	e8 c1 04 00 00       	call   80102b12 <ioapicenable>
80102651:	83 c4 10             	add    $0x10,%esp
  idewait(0);
80102654:	83 ec 0c             	sub    $0xc,%esp
80102657:	6a 00                	push   $0x0
80102659:	e8 80 ff ff ff       	call   801025de <idewait>
8010265e:	83 c4 10             	add    $0x10,%esp

  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
80102661:	83 ec 08             	sub    $0x8,%esp
80102664:	68 f0 00 00 00       	push   $0xf0
80102669:	68 f6 01 00 00       	push   $0x1f6
8010266e:	e8 24 ff ff ff       	call   80102597 <outb>
80102673:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<1000; i++){
80102676:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010267d:	eb 24                	jmp    801026a3 <ideinit+0x80>
    if(inb(0x1f7) != 0){
8010267f:	83 ec 0c             	sub    $0xc,%esp
80102682:	68 f7 01 00 00       	push   $0x1f7
80102687:	e8 c8 fe ff ff       	call   80102554 <inb>
8010268c:	83 c4 10             	add    $0x10,%esp
8010268f:	84 c0                	test   %al,%al
80102691:	74 0c                	je     8010269f <ideinit+0x7c>
      havedisk1 = 1;
80102693:	c7 05 f8 70 11 80 01 	movl   $0x1,0x801170f8
8010269a:	00 00 00 
      break;
8010269d:	eb 0d                	jmp    801026ac <ideinit+0x89>
  for(i=0; i<1000; i++){
8010269f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801026a3:	81 7d f4 e7 03 00 00 	cmpl   $0x3e7,-0xc(%ebp)
801026aa:	7e d3                	jle    8010267f <ideinit+0x5c>
    }
  }

  // Switch back to disk 0.
  outb(0x1f6, 0xe0 | (0<<4));
801026ac:	83 ec 08             	sub    $0x8,%esp
801026af:	68 e0 00 00 00       	push   $0xe0
801026b4:	68 f6 01 00 00       	push   $0x1f6
801026b9:	e8 d9 fe ff ff       	call   80102597 <outb>
801026be:	83 c4 10             	add    $0x10,%esp
}
801026c1:	90                   	nop
801026c2:	c9                   	leave  
801026c3:	c3                   	ret    

801026c4 <idestart>:

// Start the request for b.  Caller must hold idelock.
static void
idestart(struct buf *b)
{
801026c4:	55                   	push   %ebp
801026c5:	89 e5                	mov    %esp,%ebp
801026c7:	83 ec 18             	sub    $0x18,%esp
  if(b == 0)
801026ca:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801026ce:	75 0d                	jne    801026dd <idestart+0x19>
    panic("idestart");
801026d0:	83 ec 0c             	sub    $0xc,%esp
801026d3:	68 57 a6 10 80       	push   $0x8010a657
801026d8:	e8 cc de ff ff       	call   801005a9 <panic>
  if(b->blockno >= FSSIZE)
801026dd:	8b 45 08             	mov    0x8(%ebp),%eax
801026e0:	8b 40 08             	mov    0x8(%eax),%eax
801026e3:	3d e7 03 00 00       	cmp    $0x3e7,%eax
801026e8:	76 0d                	jbe    801026f7 <idestart+0x33>
    panic("incorrect blockno");
801026ea:	83 ec 0c             	sub    $0xc,%esp
801026ed:	68 60 a6 10 80       	push   $0x8010a660
801026f2:	e8 b2 de ff ff       	call   801005a9 <panic>
  int sector_per_block =  BSIZE/SECTOR_SIZE;
801026f7:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
  int sector = b->blockno * sector_per_block;
801026fe:	8b 45 08             	mov    0x8(%ebp),%eax
80102701:	8b 50 08             	mov    0x8(%eax),%edx
80102704:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102707:	0f af c2             	imul   %edx,%eax
8010270a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  int read_cmd = (sector_per_block == 1) ? IDE_CMD_READ :  IDE_CMD_RDMUL;
8010270d:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
80102711:	75 07                	jne    8010271a <idestart+0x56>
80102713:	b8 20 00 00 00       	mov    $0x20,%eax
80102718:	eb 05                	jmp    8010271f <idestart+0x5b>
8010271a:	b8 c4 00 00 00       	mov    $0xc4,%eax
8010271f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int write_cmd = (sector_per_block == 1) ? IDE_CMD_WRITE : IDE_CMD_WRMUL;
80102722:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
80102726:	75 07                	jne    8010272f <idestart+0x6b>
80102728:	b8 30 00 00 00       	mov    $0x30,%eax
8010272d:	eb 05                	jmp    80102734 <idestart+0x70>
8010272f:	b8 c5 00 00 00       	mov    $0xc5,%eax
80102734:	89 45 e8             	mov    %eax,-0x18(%ebp)

  if (sector_per_block > 7) panic("idestart");
80102737:	83 7d f4 07          	cmpl   $0x7,-0xc(%ebp)
8010273b:	7e 0d                	jle    8010274a <idestart+0x86>
8010273d:	83 ec 0c             	sub    $0xc,%esp
80102740:	68 57 a6 10 80       	push   $0x8010a657
80102745:	e8 5f de ff ff       	call   801005a9 <panic>

  idewait(0);
8010274a:	83 ec 0c             	sub    $0xc,%esp
8010274d:	6a 00                	push   $0x0
8010274f:	e8 8a fe ff ff       	call   801025de <idewait>
80102754:	83 c4 10             	add    $0x10,%esp
  outb(0x3f6, 0);  // generate interrupt
80102757:	83 ec 08             	sub    $0x8,%esp
8010275a:	6a 00                	push   $0x0
8010275c:	68 f6 03 00 00       	push   $0x3f6
80102761:	e8 31 fe ff ff       	call   80102597 <outb>
80102766:	83 c4 10             	add    $0x10,%esp
  outb(0x1f2, sector_per_block);  // number of sectors
80102769:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010276c:	0f b6 c0             	movzbl %al,%eax
8010276f:	83 ec 08             	sub    $0x8,%esp
80102772:	50                   	push   %eax
80102773:	68 f2 01 00 00       	push   $0x1f2
80102778:	e8 1a fe ff ff       	call   80102597 <outb>
8010277d:	83 c4 10             	add    $0x10,%esp
  outb(0x1f3, sector & 0xff);
80102780:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102783:	0f b6 c0             	movzbl %al,%eax
80102786:	83 ec 08             	sub    $0x8,%esp
80102789:	50                   	push   %eax
8010278a:	68 f3 01 00 00       	push   $0x1f3
8010278f:	e8 03 fe ff ff       	call   80102597 <outb>
80102794:	83 c4 10             	add    $0x10,%esp
  outb(0x1f4, (sector >> 8) & 0xff);
80102797:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010279a:	c1 f8 08             	sar    $0x8,%eax
8010279d:	0f b6 c0             	movzbl %al,%eax
801027a0:	83 ec 08             	sub    $0x8,%esp
801027a3:	50                   	push   %eax
801027a4:	68 f4 01 00 00       	push   $0x1f4
801027a9:	e8 e9 fd ff ff       	call   80102597 <outb>
801027ae:	83 c4 10             	add    $0x10,%esp
  outb(0x1f5, (sector >> 16) & 0xff);
801027b1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801027b4:	c1 f8 10             	sar    $0x10,%eax
801027b7:	0f b6 c0             	movzbl %al,%eax
801027ba:	83 ec 08             	sub    $0x8,%esp
801027bd:	50                   	push   %eax
801027be:	68 f5 01 00 00       	push   $0x1f5
801027c3:	e8 cf fd ff ff       	call   80102597 <outb>
801027c8:	83 c4 10             	add    $0x10,%esp
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((sector>>24)&0x0f));
801027cb:	8b 45 08             	mov    0x8(%ebp),%eax
801027ce:	8b 40 04             	mov    0x4(%eax),%eax
801027d1:	c1 e0 04             	shl    $0x4,%eax
801027d4:	83 e0 10             	and    $0x10,%eax
801027d7:	89 c2                	mov    %eax,%edx
801027d9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801027dc:	c1 f8 18             	sar    $0x18,%eax
801027df:	83 e0 0f             	and    $0xf,%eax
801027e2:	09 d0                	or     %edx,%eax
801027e4:	83 c8 e0             	or     $0xffffffe0,%eax
801027e7:	0f b6 c0             	movzbl %al,%eax
801027ea:	83 ec 08             	sub    $0x8,%esp
801027ed:	50                   	push   %eax
801027ee:	68 f6 01 00 00       	push   $0x1f6
801027f3:	e8 9f fd ff ff       	call   80102597 <outb>
801027f8:	83 c4 10             	add    $0x10,%esp
  if(b->flags & B_DIRTY){
801027fb:	8b 45 08             	mov    0x8(%ebp),%eax
801027fe:	8b 00                	mov    (%eax),%eax
80102800:	83 e0 04             	and    $0x4,%eax
80102803:	85 c0                	test   %eax,%eax
80102805:	74 35                	je     8010283c <idestart+0x178>
    outb(0x1f7, write_cmd);
80102807:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010280a:	0f b6 c0             	movzbl %al,%eax
8010280d:	83 ec 08             	sub    $0x8,%esp
80102810:	50                   	push   %eax
80102811:	68 f7 01 00 00       	push   $0x1f7
80102816:	e8 7c fd ff ff       	call   80102597 <outb>
8010281b:	83 c4 10             	add    $0x10,%esp
    outsl(0x1f0, b->data, BSIZE/4);
8010281e:	8b 45 08             	mov    0x8(%ebp),%eax
80102821:	83 c0 5c             	add    $0x5c,%eax
80102824:	83 ec 04             	sub    $0x4,%esp
80102827:	68 80 00 00 00       	push   $0x80
8010282c:	50                   	push   %eax
8010282d:	68 f0 01 00 00       	push   $0x1f0
80102832:	e8 81 fd ff ff       	call   801025b8 <outsl>
80102837:	83 c4 10             	add    $0x10,%esp
  } else {
    outb(0x1f7, read_cmd);
  }
}
8010283a:	eb 17                	jmp    80102853 <idestart+0x18f>
    outb(0x1f7, read_cmd);
8010283c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010283f:	0f b6 c0             	movzbl %al,%eax
80102842:	83 ec 08             	sub    $0x8,%esp
80102845:	50                   	push   %eax
80102846:	68 f7 01 00 00       	push   $0x1f7
8010284b:	e8 47 fd ff ff       	call   80102597 <outb>
80102850:	83 c4 10             	add    $0x10,%esp
}
80102853:	90                   	nop
80102854:	c9                   	leave  
80102855:	c3                   	ret    

80102856 <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
80102856:	55                   	push   %ebp
80102857:	89 e5                	mov    %esp,%ebp
80102859:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  // First queued buffer is the active request.
  acquire(&idelock);
8010285c:	83 ec 0c             	sub    $0xc,%esp
8010285f:	68 c0 70 11 80       	push   $0x801170c0
80102864:	e8 84 23 00 00       	call   80104bed <acquire>
80102869:	83 c4 10             	add    $0x10,%esp

  if((b = idequeue) == 0){
8010286c:	a1 f4 70 11 80       	mov    0x801170f4,%eax
80102871:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102874:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102878:	75 15                	jne    8010288f <ideintr+0x39>
    release(&idelock);
8010287a:	83 ec 0c             	sub    $0xc,%esp
8010287d:	68 c0 70 11 80       	push   $0x801170c0
80102882:	e8 d4 23 00 00       	call   80104c5b <release>
80102887:	83 c4 10             	add    $0x10,%esp
    return;
8010288a:	e9 9a 00 00 00       	jmp    80102929 <ideintr+0xd3>
  }
  idequeue = b->qnext;
8010288f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102892:	8b 40 58             	mov    0x58(%eax),%eax
80102895:	a3 f4 70 11 80       	mov    %eax,0x801170f4

  // Read data if needed.
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
8010289a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010289d:	8b 00                	mov    (%eax),%eax
8010289f:	83 e0 04             	and    $0x4,%eax
801028a2:	85 c0                	test   %eax,%eax
801028a4:	75 2d                	jne    801028d3 <ideintr+0x7d>
801028a6:	83 ec 0c             	sub    $0xc,%esp
801028a9:	6a 01                	push   $0x1
801028ab:	e8 2e fd ff ff       	call   801025de <idewait>
801028b0:	83 c4 10             	add    $0x10,%esp
801028b3:	85 c0                	test   %eax,%eax
801028b5:	78 1c                	js     801028d3 <ideintr+0x7d>
    insl(0x1f0, b->data, BSIZE/4);
801028b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028ba:	83 c0 5c             	add    $0x5c,%eax
801028bd:	83 ec 04             	sub    $0x4,%esp
801028c0:	68 80 00 00 00       	push   $0x80
801028c5:	50                   	push   %eax
801028c6:	68 f0 01 00 00       	push   $0x1f0
801028cb:	e8 a1 fc ff ff       	call   80102571 <insl>
801028d0:	83 c4 10             	add    $0x10,%esp

  // Wake process waiting for this buf.
  b->flags |= B_VALID;
801028d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028d6:	8b 00                	mov    (%eax),%eax
801028d8:	83 c8 02             	or     $0x2,%eax
801028db:	89 c2                	mov    %eax,%edx
801028dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028e0:	89 10                	mov    %edx,(%eax)
  b->flags &= ~B_DIRTY;
801028e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028e5:	8b 00                	mov    (%eax),%eax
801028e7:	83 e0 fb             	and    $0xfffffffb,%eax
801028ea:	89 c2                	mov    %eax,%edx
801028ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028ef:	89 10                	mov    %edx,(%eax)
  wakeup(b);
801028f1:	83 ec 0c             	sub    $0xc,%esp
801028f4:	ff 75 f4             	push   -0xc(%ebp)
801028f7:	e8 b7 1f 00 00       	call   801048b3 <wakeup>
801028fc:	83 c4 10             	add    $0x10,%esp

  // Start disk on next buf in queue.
  if(idequeue != 0)
801028ff:	a1 f4 70 11 80       	mov    0x801170f4,%eax
80102904:	85 c0                	test   %eax,%eax
80102906:	74 11                	je     80102919 <ideintr+0xc3>
    idestart(idequeue);
80102908:	a1 f4 70 11 80       	mov    0x801170f4,%eax
8010290d:	83 ec 0c             	sub    $0xc,%esp
80102910:	50                   	push   %eax
80102911:	e8 ae fd ff ff       	call   801026c4 <idestart>
80102916:	83 c4 10             	add    $0x10,%esp

  release(&idelock);
80102919:	83 ec 0c             	sub    $0xc,%esp
8010291c:	68 c0 70 11 80       	push   $0x801170c0
80102921:	e8 35 23 00 00       	call   80104c5b <release>
80102926:	83 c4 10             	add    $0x10,%esp
}
80102929:	c9                   	leave  
8010292a:	c3                   	ret    

8010292b <iderw>:
// Sync buf with disk.
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
8010292b:	55                   	push   %ebp
8010292c:	89 e5                	mov    %esp,%ebp
8010292e:	83 ec 18             	sub    $0x18,%esp
  struct buf **pp;
#if IDE_DEBUG
  cprintf("b->dev: %x havedisk1: %x\n",b->dev,havedisk1);
80102931:	8b 15 f8 70 11 80    	mov    0x801170f8,%edx
80102937:	8b 45 08             	mov    0x8(%ebp),%eax
8010293a:	8b 40 04             	mov    0x4(%eax),%eax
8010293d:	83 ec 04             	sub    $0x4,%esp
80102940:	52                   	push   %edx
80102941:	50                   	push   %eax
80102942:	68 72 a6 10 80       	push   $0x8010a672
80102947:	e8 a8 da ff ff       	call   801003f4 <cprintf>
8010294c:	83 c4 10             	add    $0x10,%esp
#endif
  if(!holdingsleep(&b->lock))
8010294f:	8b 45 08             	mov    0x8(%ebp),%eax
80102952:	83 c0 0c             	add    $0xc,%eax
80102955:	83 ec 0c             	sub    $0xc,%esp
80102958:	50                   	push   %eax
80102959:	e8 fe 21 00 00       	call   80104b5c <holdingsleep>
8010295e:	83 c4 10             	add    $0x10,%esp
80102961:	85 c0                	test   %eax,%eax
80102963:	75 0d                	jne    80102972 <iderw+0x47>
    panic("iderw: buf not locked");
80102965:	83 ec 0c             	sub    $0xc,%esp
80102968:	68 8c a6 10 80       	push   $0x8010a68c
8010296d:	e8 37 dc ff ff       	call   801005a9 <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
80102972:	8b 45 08             	mov    0x8(%ebp),%eax
80102975:	8b 00                	mov    (%eax),%eax
80102977:	83 e0 06             	and    $0x6,%eax
8010297a:	83 f8 02             	cmp    $0x2,%eax
8010297d:	75 0d                	jne    8010298c <iderw+0x61>
    panic("iderw: nothing to do");
8010297f:	83 ec 0c             	sub    $0xc,%esp
80102982:	68 a2 a6 10 80       	push   $0x8010a6a2
80102987:	e8 1d dc ff ff       	call   801005a9 <panic>
  if(b->dev != 0 && !havedisk1)
8010298c:	8b 45 08             	mov    0x8(%ebp),%eax
8010298f:	8b 40 04             	mov    0x4(%eax),%eax
80102992:	85 c0                	test   %eax,%eax
80102994:	74 16                	je     801029ac <iderw+0x81>
80102996:	a1 f8 70 11 80       	mov    0x801170f8,%eax
8010299b:	85 c0                	test   %eax,%eax
8010299d:	75 0d                	jne    801029ac <iderw+0x81>
    panic("iderw: ide disk 1 not present");
8010299f:	83 ec 0c             	sub    $0xc,%esp
801029a2:	68 b7 a6 10 80       	push   $0x8010a6b7
801029a7:	e8 fd db ff ff       	call   801005a9 <panic>

  acquire(&idelock);  //DOC:acquire-lock
801029ac:	83 ec 0c             	sub    $0xc,%esp
801029af:	68 c0 70 11 80       	push   $0x801170c0
801029b4:	e8 34 22 00 00       	call   80104bed <acquire>
801029b9:	83 c4 10             	add    $0x10,%esp

  // Append b to idequeue.
  b->qnext = 0;
801029bc:	8b 45 08             	mov    0x8(%ebp),%eax
801029bf:	c7 40 58 00 00 00 00 	movl   $0x0,0x58(%eax)
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
801029c6:	c7 45 f4 f4 70 11 80 	movl   $0x801170f4,-0xc(%ebp)
801029cd:	eb 0b                	jmp    801029da <iderw+0xaf>
801029cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801029d2:	8b 00                	mov    (%eax),%eax
801029d4:	83 c0 58             	add    $0x58,%eax
801029d7:	89 45 f4             	mov    %eax,-0xc(%ebp)
801029da:	8b 45 f4             	mov    -0xc(%ebp),%eax
801029dd:	8b 00                	mov    (%eax),%eax
801029df:	85 c0                	test   %eax,%eax
801029e1:	75 ec                	jne    801029cf <iderw+0xa4>
    ;
  *pp = b;
801029e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801029e6:	8b 55 08             	mov    0x8(%ebp),%edx
801029e9:	89 10                	mov    %edx,(%eax)

  // Start disk if necessary.
  if(idequeue == b)
801029eb:	a1 f4 70 11 80       	mov    0x801170f4,%eax
801029f0:	39 45 08             	cmp    %eax,0x8(%ebp)
801029f3:	75 23                	jne    80102a18 <iderw+0xed>
    idestart(b);
801029f5:	83 ec 0c             	sub    $0xc,%esp
801029f8:	ff 75 08             	push   0x8(%ebp)
801029fb:	e8 c4 fc ff ff       	call   801026c4 <idestart>
80102a00:	83 c4 10             	add    $0x10,%esp

  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80102a03:	eb 13                	jmp    80102a18 <iderw+0xed>
    sleep(b, &idelock);
80102a05:	83 ec 08             	sub    $0x8,%esp
80102a08:	68 c0 70 11 80       	push   $0x801170c0
80102a0d:	ff 75 08             	push   0x8(%ebp)
80102a10:	e8 b4 1d 00 00       	call   801047c9 <sleep>
80102a15:	83 c4 10             	add    $0x10,%esp
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80102a18:	8b 45 08             	mov    0x8(%ebp),%eax
80102a1b:	8b 00                	mov    (%eax),%eax
80102a1d:	83 e0 06             	and    $0x6,%eax
80102a20:	83 f8 02             	cmp    $0x2,%eax
80102a23:	75 e0                	jne    80102a05 <iderw+0xda>
  }


  release(&idelock);
80102a25:	83 ec 0c             	sub    $0xc,%esp
80102a28:	68 c0 70 11 80       	push   $0x801170c0
80102a2d:	e8 29 22 00 00       	call   80104c5b <release>
80102a32:	83 c4 10             	add    $0x10,%esp
}
80102a35:	90                   	nop
80102a36:	c9                   	leave  
80102a37:	c3                   	ret    

80102a38 <ioapicread>:
  uint data;
};

static uint
ioapicread(int reg)
{
80102a38:	55                   	push   %ebp
80102a39:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102a3b:	a1 fc 70 11 80       	mov    0x801170fc,%eax
80102a40:	8b 55 08             	mov    0x8(%ebp),%edx
80102a43:	89 10                	mov    %edx,(%eax)
  return ioapic->data;
80102a45:	a1 fc 70 11 80       	mov    0x801170fc,%eax
80102a4a:	8b 40 10             	mov    0x10(%eax),%eax
}
80102a4d:	5d                   	pop    %ebp
80102a4e:	c3                   	ret    

80102a4f <ioapicwrite>:

static void
ioapicwrite(int reg, uint data)
{
80102a4f:	55                   	push   %ebp
80102a50:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102a52:	a1 fc 70 11 80       	mov    0x801170fc,%eax
80102a57:	8b 55 08             	mov    0x8(%ebp),%edx
80102a5a:	89 10                	mov    %edx,(%eax)
  ioapic->data = data;
80102a5c:	a1 fc 70 11 80       	mov    0x801170fc,%eax
80102a61:	8b 55 0c             	mov    0xc(%ebp),%edx
80102a64:	89 50 10             	mov    %edx,0x10(%eax)
}
80102a67:	90                   	nop
80102a68:	5d                   	pop    %ebp
80102a69:	c3                   	ret    

80102a6a <ioapicinit>:

void
ioapicinit(void)
{
80102a6a:	55                   	push   %ebp
80102a6b:	89 e5                	mov    %esp,%ebp
80102a6d:	83 ec 18             	sub    $0x18,%esp
  int i, id, maxintr;

  ioapic = (volatile struct ioapic*)IOAPIC;
80102a70:	c7 05 fc 70 11 80 00 	movl   $0xfec00000,0x801170fc
80102a77:	00 c0 fe 
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
80102a7a:	6a 01                	push   $0x1
80102a7c:	e8 b7 ff ff ff       	call   80102a38 <ioapicread>
80102a81:	83 c4 04             	add    $0x4,%esp
80102a84:	c1 e8 10             	shr    $0x10,%eax
80102a87:	25 ff 00 00 00       	and    $0xff,%eax
80102a8c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  id = ioapicread(REG_ID) >> 24;
80102a8f:	6a 00                	push   $0x0
80102a91:	e8 a2 ff ff ff       	call   80102a38 <ioapicread>
80102a96:	83 c4 04             	add    $0x4,%esp
80102a99:	c1 e8 18             	shr    $0x18,%eax
80102a9c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(id != ioapicid)
80102a9f:	0f b6 05 84 9e 11 80 	movzbl 0x80119e84,%eax
80102aa6:	0f b6 c0             	movzbl %al,%eax
80102aa9:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80102aac:	74 10                	je     80102abe <ioapicinit+0x54>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
80102aae:	83 ec 0c             	sub    $0xc,%esp
80102ab1:	68 d8 a6 10 80       	push   $0x8010a6d8
80102ab6:	e8 39 d9 ff ff       	call   801003f4 <cprintf>
80102abb:	83 c4 10             	add    $0x10,%esp

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
80102abe:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102ac5:	eb 3f                	jmp    80102b06 <ioapicinit+0x9c>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
80102ac7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102aca:	83 c0 20             	add    $0x20,%eax
80102acd:	0d 00 00 01 00       	or     $0x10000,%eax
80102ad2:	89 c2                	mov    %eax,%edx
80102ad4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ad7:	83 c0 08             	add    $0x8,%eax
80102ada:	01 c0                	add    %eax,%eax
80102adc:	83 ec 08             	sub    $0x8,%esp
80102adf:	52                   	push   %edx
80102ae0:	50                   	push   %eax
80102ae1:	e8 69 ff ff ff       	call   80102a4f <ioapicwrite>
80102ae6:	83 c4 10             	add    $0x10,%esp
    ioapicwrite(REG_TABLE+2*i+1, 0);
80102ae9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102aec:	83 c0 08             	add    $0x8,%eax
80102aef:	01 c0                	add    %eax,%eax
80102af1:	83 c0 01             	add    $0x1,%eax
80102af4:	83 ec 08             	sub    $0x8,%esp
80102af7:	6a 00                	push   $0x0
80102af9:	50                   	push   %eax
80102afa:	e8 50 ff ff ff       	call   80102a4f <ioapicwrite>
80102aff:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i <= maxintr; i++){
80102b02:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102b06:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b09:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80102b0c:	7e b9                	jle    80102ac7 <ioapicinit+0x5d>
  }
}
80102b0e:	90                   	nop
80102b0f:	90                   	nop
80102b10:	c9                   	leave  
80102b11:	c3                   	ret    

80102b12 <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
80102b12:	55                   	push   %ebp
80102b13:	89 e5                	mov    %esp,%ebp
  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
80102b15:	8b 45 08             	mov    0x8(%ebp),%eax
80102b18:	83 c0 20             	add    $0x20,%eax
80102b1b:	89 c2                	mov    %eax,%edx
80102b1d:	8b 45 08             	mov    0x8(%ebp),%eax
80102b20:	83 c0 08             	add    $0x8,%eax
80102b23:	01 c0                	add    %eax,%eax
80102b25:	52                   	push   %edx
80102b26:	50                   	push   %eax
80102b27:	e8 23 ff ff ff       	call   80102a4f <ioapicwrite>
80102b2c:	83 c4 08             	add    $0x8,%esp
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
80102b2f:	8b 45 0c             	mov    0xc(%ebp),%eax
80102b32:	c1 e0 18             	shl    $0x18,%eax
80102b35:	89 c2                	mov    %eax,%edx
80102b37:	8b 45 08             	mov    0x8(%ebp),%eax
80102b3a:	83 c0 08             	add    $0x8,%eax
80102b3d:	01 c0                	add    %eax,%eax
80102b3f:	83 c0 01             	add    $0x1,%eax
80102b42:	52                   	push   %edx
80102b43:	50                   	push   %eax
80102b44:	e8 06 ff ff ff       	call   80102a4f <ioapicwrite>
80102b49:	83 c4 08             	add    $0x8,%esp
}
80102b4c:	90                   	nop
80102b4d:	c9                   	leave  
80102b4e:	c3                   	ret    

80102b4f <kinit1>:
// the pages mapped by entrypgdir on free list.
// 2. main() calls kinit2() with the rest of the physical pages
// after installing a full page table that maps them on all cores.
void
kinit1(void *vstart, void *vend)
{
80102b4f:	55                   	push   %ebp
80102b50:	89 e5                	mov    %esp,%ebp
80102b52:	83 ec 08             	sub    $0x8,%esp
  initlock(&kmem.lock, "kmem");
80102b55:	83 ec 08             	sub    $0x8,%esp
80102b58:	68 0a a7 10 80       	push   $0x8010a70a
80102b5d:	68 00 71 11 80       	push   $0x80117100
80102b62:	e8 64 20 00 00       	call   80104bcb <initlock>
80102b67:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 0;
80102b6a:	c7 05 34 71 11 80 00 	movl   $0x0,0x80117134
80102b71:	00 00 00 
  freerange(vstart, vend);
80102b74:	83 ec 08             	sub    $0x8,%esp
80102b77:	ff 75 0c             	push   0xc(%ebp)
80102b7a:	ff 75 08             	push   0x8(%ebp)
80102b7d:	e8 2a 00 00 00       	call   80102bac <freerange>
80102b82:	83 c4 10             	add    $0x10,%esp
}
80102b85:	90                   	nop
80102b86:	c9                   	leave  
80102b87:	c3                   	ret    

80102b88 <kinit2>:

void
kinit2(void *vstart, void *vend)
{
80102b88:	55                   	push   %ebp
80102b89:	89 e5                	mov    %esp,%ebp
80102b8b:	83 ec 08             	sub    $0x8,%esp
  freerange(vstart, vend);
80102b8e:	83 ec 08             	sub    $0x8,%esp
80102b91:	ff 75 0c             	push   0xc(%ebp)
80102b94:	ff 75 08             	push   0x8(%ebp)
80102b97:	e8 10 00 00 00       	call   80102bac <freerange>
80102b9c:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 1;
80102b9f:	c7 05 34 71 11 80 01 	movl   $0x1,0x80117134
80102ba6:	00 00 00 
}
80102ba9:	90                   	nop
80102baa:	c9                   	leave  
80102bab:	c3                   	ret    

80102bac <freerange>:

void
freerange(void *vstart, void *vend)
{
80102bac:	55                   	push   %ebp
80102bad:	89 e5                	mov    %esp,%ebp
80102baf:	83 ec 18             	sub    $0x18,%esp
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
80102bb2:	8b 45 08             	mov    0x8(%ebp),%eax
80102bb5:	05 ff 0f 00 00       	add    $0xfff,%eax
80102bba:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80102bbf:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102bc2:	eb 15                	jmp    80102bd9 <freerange+0x2d>
    kfree(p);
80102bc4:	83 ec 0c             	sub    $0xc,%esp
80102bc7:	ff 75 f4             	push   -0xc(%ebp)
80102bca:	e8 1b 00 00 00       	call   80102bea <kfree>
80102bcf:	83 c4 10             	add    $0x10,%esp
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102bd2:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80102bd9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102bdc:	05 00 10 00 00       	add    $0x1000,%eax
80102be1:	39 45 0c             	cmp    %eax,0xc(%ebp)
80102be4:	73 de                	jae    80102bc4 <freerange+0x18>
}
80102be6:	90                   	nop
80102be7:	90                   	nop
80102be8:	c9                   	leave  
80102be9:	c3                   	ret    

80102bea <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
80102bea:	55                   	push   %ebp
80102beb:	89 e5                	mov    %esp,%ebp
80102bed:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if((uint)v % PGSIZE || v < end || V2P(v) >= PHYSTOP)
80102bf0:	8b 45 08             	mov    0x8(%ebp),%eax
80102bf3:	25 ff 0f 00 00       	and    $0xfff,%eax
80102bf8:	85 c0                	test   %eax,%eax
80102bfa:	75 18                	jne    80102c14 <kfree+0x2a>
80102bfc:	81 7d 08 00 c0 11 80 	cmpl   $0x8011c000,0x8(%ebp)
80102c03:	72 0f                	jb     80102c14 <kfree+0x2a>
80102c05:	8b 45 08             	mov    0x8(%ebp),%eax
80102c08:	05 00 00 00 80       	add    $0x80000000,%eax
80102c0d:	3d ff ff ff 1f       	cmp    $0x1fffffff,%eax
80102c12:	76 0d                	jbe    80102c21 <kfree+0x37>
    panic("kfree");
80102c14:	83 ec 0c             	sub    $0xc,%esp
80102c17:	68 0f a7 10 80       	push   $0x8010a70f
80102c1c:	e8 88 d9 ff ff       	call   801005a9 <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
80102c21:	83 ec 04             	sub    $0x4,%esp
80102c24:	68 00 10 00 00       	push   $0x1000
80102c29:	6a 01                	push   $0x1
80102c2b:	ff 75 08             	push   0x8(%ebp)
80102c2e:	e8 30 22 00 00       	call   80104e63 <memset>
80102c33:	83 c4 10             	add    $0x10,%esp

  if(kmem.use_lock)
80102c36:	a1 34 71 11 80       	mov    0x80117134,%eax
80102c3b:	85 c0                	test   %eax,%eax
80102c3d:	74 10                	je     80102c4f <kfree+0x65>
    acquire(&kmem.lock);
80102c3f:	83 ec 0c             	sub    $0xc,%esp
80102c42:	68 00 71 11 80       	push   $0x80117100
80102c47:	e8 a1 1f 00 00       	call   80104bed <acquire>
80102c4c:	83 c4 10             	add    $0x10,%esp
  r = (struct run*)v;
80102c4f:	8b 45 08             	mov    0x8(%ebp),%eax
80102c52:	89 45 f4             	mov    %eax,-0xc(%ebp)
  r->next = kmem.freelist;
80102c55:	8b 15 38 71 11 80    	mov    0x80117138,%edx
80102c5b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c5e:	89 10                	mov    %edx,(%eax)
  kmem.freelist = r;
80102c60:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c63:	a3 38 71 11 80       	mov    %eax,0x80117138
  if(kmem.use_lock)
80102c68:	a1 34 71 11 80       	mov    0x80117134,%eax
80102c6d:	85 c0                	test   %eax,%eax
80102c6f:	74 10                	je     80102c81 <kfree+0x97>
    release(&kmem.lock);
80102c71:	83 ec 0c             	sub    $0xc,%esp
80102c74:	68 00 71 11 80       	push   $0x80117100
80102c79:	e8 dd 1f 00 00       	call   80104c5b <release>
80102c7e:	83 c4 10             	add    $0x10,%esp
}
80102c81:	90                   	nop
80102c82:	c9                   	leave  
80102c83:	c3                   	ret    

80102c84 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
80102c84:	55                   	push   %ebp
80102c85:	89 e5                	mov    %esp,%ebp
80102c87:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if(kmem.use_lock)
80102c8a:	a1 34 71 11 80       	mov    0x80117134,%eax
80102c8f:	85 c0                	test   %eax,%eax
80102c91:	74 10                	je     80102ca3 <kalloc+0x1f>
    acquire(&kmem.lock);
80102c93:	83 ec 0c             	sub    $0xc,%esp
80102c96:	68 00 71 11 80       	push   $0x80117100
80102c9b:	e8 4d 1f 00 00       	call   80104bed <acquire>
80102ca0:	83 c4 10             	add    $0x10,%esp
  r = kmem.freelist;
80102ca3:	a1 38 71 11 80       	mov    0x80117138,%eax
80102ca8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(r)
80102cab:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102caf:	74 0a                	je     80102cbb <kalloc+0x37>
    kmem.freelist = r->next;
80102cb1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102cb4:	8b 00                	mov    (%eax),%eax
80102cb6:	a3 38 71 11 80       	mov    %eax,0x80117138
  if(kmem.use_lock)
80102cbb:	a1 34 71 11 80       	mov    0x80117134,%eax
80102cc0:	85 c0                	test   %eax,%eax
80102cc2:	74 10                	je     80102cd4 <kalloc+0x50>
    release(&kmem.lock);
80102cc4:	83 ec 0c             	sub    $0xc,%esp
80102cc7:	68 00 71 11 80       	push   $0x80117100
80102ccc:	e8 8a 1f 00 00       	call   80104c5b <release>
80102cd1:	83 c4 10             	add    $0x10,%esp
  return (char*)r;
80102cd4:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102cd7:	c9                   	leave  
80102cd8:	c3                   	ret    

80102cd9 <inb>:
{
80102cd9:	55                   	push   %ebp
80102cda:	89 e5                	mov    %esp,%ebp
80102cdc:	83 ec 14             	sub    $0x14,%esp
80102cdf:	8b 45 08             	mov    0x8(%ebp),%eax
80102ce2:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102ce6:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102cea:	89 c2                	mov    %eax,%edx
80102cec:	ec                   	in     (%dx),%al
80102ced:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102cf0:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102cf4:	c9                   	leave  
80102cf5:	c3                   	ret    

80102cf6 <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
80102cf6:	55                   	push   %ebp
80102cf7:	89 e5                	mov    %esp,%ebp
80102cf9:	83 ec 10             	sub    $0x10,%esp
  static uchar *charcode[4] = {
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
80102cfc:	6a 64                	push   $0x64
80102cfe:	e8 d6 ff ff ff       	call   80102cd9 <inb>
80102d03:	83 c4 04             	add    $0x4,%esp
80102d06:	0f b6 c0             	movzbl %al,%eax
80102d09:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((st & KBS_DIB) == 0)
80102d0c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102d0f:	83 e0 01             	and    $0x1,%eax
80102d12:	85 c0                	test   %eax,%eax
80102d14:	75 0a                	jne    80102d20 <kbdgetc+0x2a>
    return -1;
80102d16:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102d1b:	e9 23 01 00 00       	jmp    80102e43 <kbdgetc+0x14d>
  data = inb(KBDATAP);
80102d20:	6a 60                	push   $0x60
80102d22:	e8 b2 ff ff ff       	call   80102cd9 <inb>
80102d27:	83 c4 04             	add    $0x4,%esp
80102d2a:	0f b6 c0             	movzbl %al,%eax
80102d2d:	89 45 fc             	mov    %eax,-0x4(%ebp)

  if(data == 0xE0){
80102d30:	81 7d fc e0 00 00 00 	cmpl   $0xe0,-0x4(%ebp)
80102d37:	75 17                	jne    80102d50 <kbdgetc+0x5a>
    shift |= E0ESC;
80102d39:	a1 3c 71 11 80       	mov    0x8011713c,%eax
80102d3e:	83 c8 40             	or     $0x40,%eax
80102d41:	a3 3c 71 11 80       	mov    %eax,0x8011713c
    return 0;
80102d46:	b8 00 00 00 00       	mov    $0x0,%eax
80102d4b:	e9 f3 00 00 00       	jmp    80102e43 <kbdgetc+0x14d>
  } else if(data & 0x80){
80102d50:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102d53:	25 80 00 00 00       	and    $0x80,%eax
80102d58:	85 c0                	test   %eax,%eax
80102d5a:	74 45                	je     80102da1 <kbdgetc+0xab>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
80102d5c:	a1 3c 71 11 80       	mov    0x8011713c,%eax
80102d61:	83 e0 40             	and    $0x40,%eax
80102d64:	85 c0                	test   %eax,%eax
80102d66:	75 08                	jne    80102d70 <kbdgetc+0x7a>
80102d68:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102d6b:	83 e0 7f             	and    $0x7f,%eax
80102d6e:	eb 03                	jmp    80102d73 <kbdgetc+0x7d>
80102d70:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102d73:	89 45 fc             	mov    %eax,-0x4(%ebp)
    shift &= ~(shiftcode[data] | E0ESC);
80102d76:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102d79:	05 20 d0 10 80       	add    $0x8010d020,%eax
80102d7e:	0f b6 00             	movzbl (%eax),%eax
80102d81:	83 c8 40             	or     $0x40,%eax
80102d84:	0f b6 c0             	movzbl %al,%eax
80102d87:	f7 d0                	not    %eax
80102d89:	89 c2                	mov    %eax,%edx
80102d8b:	a1 3c 71 11 80       	mov    0x8011713c,%eax
80102d90:	21 d0                	and    %edx,%eax
80102d92:	a3 3c 71 11 80       	mov    %eax,0x8011713c
    return 0;
80102d97:	b8 00 00 00 00       	mov    $0x0,%eax
80102d9c:	e9 a2 00 00 00       	jmp    80102e43 <kbdgetc+0x14d>
  } else if(shift & E0ESC){
80102da1:	a1 3c 71 11 80       	mov    0x8011713c,%eax
80102da6:	83 e0 40             	and    $0x40,%eax
80102da9:	85 c0                	test   %eax,%eax
80102dab:	74 14                	je     80102dc1 <kbdgetc+0xcb>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
80102dad:	81 4d fc 80 00 00 00 	orl    $0x80,-0x4(%ebp)
    shift &= ~E0ESC;
80102db4:	a1 3c 71 11 80       	mov    0x8011713c,%eax
80102db9:	83 e0 bf             	and    $0xffffffbf,%eax
80102dbc:	a3 3c 71 11 80       	mov    %eax,0x8011713c
  }

  shift |= shiftcode[data];
80102dc1:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102dc4:	05 20 d0 10 80       	add    $0x8010d020,%eax
80102dc9:	0f b6 00             	movzbl (%eax),%eax
80102dcc:	0f b6 d0             	movzbl %al,%edx
80102dcf:	a1 3c 71 11 80       	mov    0x8011713c,%eax
80102dd4:	09 d0                	or     %edx,%eax
80102dd6:	a3 3c 71 11 80       	mov    %eax,0x8011713c
  shift ^= togglecode[data];
80102ddb:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102dde:	05 20 d1 10 80       	add    $0x8010d120,%eax
80102de3:	0f b6 00             	movzbl (%eax),%eax
80102de6:	0f b6 d0             	movzbl %al,%edx
80102de9:	a1 3c 71 11 80       	mov    0x8011713c,%eax
80102dee:	31 d0                	xor    %edx,%eax
80102df0:	a3 3c 71 11 80       	mov    %eax,0x8011713c
  c = charcode[shift & (CTL | SHIFT)][data];
80102df5:	a1 3c 71 11 80       	mov    0x8011713c,%eax
80102dfa:	83 e0 03             	and    $0x3,%eax
80102dfd:	8b 14 85 20 d5 10 80 	mov    -0x7fef2ae0(,%eax,4),%edx
80102e04:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102e07:	01 d0                	add    %edx,%eax
80102e09:	0f b6 00             	movzbl (%eax),%eax
80102e0c:	0f b6 c0             	movzbl %al,%eax
80102e0f:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(shift & CAPSLOCK){
80102e12:	a1 3c 71 11 80       	mov    0x8011713c,%eax
80102e17:	83 e0 08             	and    $0x8,%eax
80102e1a:	85 c0                	test   %eax,%eax
80102e1c:	74 22                	je     80102e40 <kbdgetc+0x14a>
    if('a' <= c && c <= 'z')
80102e1e:	83 7d f8 60          	cmpl   $0x60,-0x8(%ebp)
80102e22:	76 0c                	jbe    80102e30 <kbdgetc+0x13a>
80102e24:	83 7d f8 7a          	cmpl   $0x7a,-0x8(%ebp)
80102e28:	77 06                	ja     80102e30 <kbdgetc+0x13a>
      c += 'A' - 'a';
80102e2a:	83 6d f8 20          	subl   $0x20,-0x8(%ebp)
80102e2e:	eb 10                	jmp    80102e40 <kbdgetc+0x14a>
    else if('A' <= c && c <= 'Z')
80102e30:	83 7d f8 40          	cmpl   $0x40,-0x8(%ebp)
80102e34:	76 0a                	jbe    80102e40 <kbdgetc+0x14a>
80102e36:	83 7d f8 5a          	cmpl   $0x5a,-0x8(%ebp)
80102e3a:	77 04                	ja     80102e40 <kbdgetc+0x14a>
      c += 'a' - 'A';
80102e3c:	83 45 f8 20          	addl   $0x20,-0x8(%ebp)
  }
  return c;
80102e40:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80102e43:	c9                   	leave  
80102e44:	c3                   	ret    

80102e45 <kbdintr>:

void
kbdintr(void)
{
80102e45:	55                   	push   %ebp
80102e46:	89 e5                	mov    %esp,%ebp
80102e48:	83 ec 08             	sub    $0x8,%esp
  consoleintr(kbdgetc);
80102e4b:	83 ec 0c             	sub    $0xc,%esp
80102e4e:	68 f6 2c 10 80       	push   $0x80102cf6
80102e53:	e8 7e d9 ff ff       	call   801007d6 <consoleintr>
80102e58:	83 c4 10             	add    $0x10,%esp
}
80102e5b:	90                   	nop
80102e5c:	c9                   	leave  
80102e5d:	c3                   	ret    

80102e5e <inb>:
{
80102e5e:	55                   	push   %ebp
80102e5f:	89 e5                	mov    %esp,%ebp
80102e61:	83 ec 14             	sub    $0x14,%esp
80102e64:	8b 45 08             	mov    0x8(%ebp),%eax
80102e67:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102e6b:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102e6f:	89 c2                	mov    %eax,%edx
80102e71:	ec                   	in     (%dx),%al
80102e72:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102e75:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102e79:	c9                   	leave  
80102e7a:	c3                   	ret    

80102e7b <outb>:
{
80102e7b:	55                   	push   %ebp
80102e7c:	89 e5                	mov    %esp,%ebp
80102e7e:	83 ec 08             	sub    $0x8,%esp
80102e81:	8b 45 08             	mov    0x8(%ebp),%eax
80102e84:	8b 55 0c             	mov    0xc(%ebp),%edx
80102e87:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80102e8b:	89 d0                	mov    %edx,%eax
80102e8d:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102e90:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80102e94:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80102e98:	ee                   	out    %al,(%dx)
}
80102e99:	90                   	nop
80102e9a:	c9                   	leave  
80102e9b:	c3                   	ret    

80102e9c <lapicw>:
volatile uint *lapic;  // Initialized in mp.c

//PAGEBREAK!
static void
lapicw(int index, int value)
{
80102e9c:	55                   	push   %ebp
80102e9d:	89 e5                	mov    %esp,%ebp
  lapic[index] = value;
80102e9f:	8b 15 40 71 11 80    	mov    0x80117140,%edx
80102ea5:	8b 45 08             	mov    0x8(%ebp),%eax
80102ea8:	c1 e0 02             	shl    $0x2,%eax
80102eab:	01 c2                	add    %eax,%edx
80102ead:	8b 45 0c             	mov    0xc(%ebp),%eax
80102eb0:	89 02                	mov    %eax,(%edx)
  lapic[ID];  // wait for write to finish, by reading
80102eb2:	a1 40 71 11 80       	mov    0x80117140,%eax
80102eb7:	83 c0 20             	add    $0x20,%eax
80102eba:	8b 00                	mov    (%eax),%eax
}
80102ebc:	90                   	nop
80102ebd:	5d                   	pop    %ebp
80102ebe:	c3                   	ret    

80102ebf <lapicinit>:

void
lapicinit(void)
{
80102ebf:	55                   	push   %ebp
80102ec0:	89 e5                	mov    %esp,%ebp
  if(!lapic)
80102ec2:	a1 40 71 11 80       	mov    0x80117140,%eax
80102ec7:	85 c0                	test   %eax,%eax
80102ec9:	0f 84 0c 01 00 00    	je     80102fdb <lapicinit+0x11c>
    return;

  // Enable local APIC; set spurious interrupt vector.
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
80102ecf:	68 3f 01 00 00       	push   $0x13f
80102ed4:	6a 3c                	push   $0x3c
80102ed6:	e8 c1 ff ff ff       	call   80102e9c <lapicw>
80102edb:	83 c4 08             	add    $0x8,%esp

  // The timer repeatedly counts down at bus frequency
  // from lapic[TICR] and then issues an interrupt.
  // If xv6 cared more about precise timekeeping,
  // TICR would be calibrated using an external time source.
  lapicw(TDCR, X1);
80102ede:	6a 0b                	push   $0xb
80102ee0:	68 f8 00 00 00       	push   $0xf8
80102ee5:	e8 b2 ff ff ff       	call   80102e9c <lapicw>
80102eea:	83 c4 08             	add    $0x8,%esp
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
80102eed:	68 20 00 02 00       	push   $0x20020
80102ef2:	68 c8 00 00 00       	push   $0xc8
80102ef7:	e8 a0 ff ff ff       	call   80102e9c <lapicw>
80102efc:	83 c4 08             	add    $0x8,%esp
  lapicw(TICR, 10000000);
80102eff:	68 80 96 98 00       	push   $0x989680
80102f04:	68 e0 00 00 00       	push   $0xe0
80102f09:	e8 8e ff ff ff       	call   80102e9c <lapicw>
80102f0e:	83 c4 08             	add    $0x8,%esp

  // Disable logical interrupt lines.
  lapicw(LINT0, MASKED);
80102f11:	68 00 00 01 00       	push   $0x10000
80102f16:	68 d4 00 00 00       	push   $0xd4
80102f1b:	e8 7c ff ff ff       	call   80102e9c <lapicw>
80102f20:	83 c4 08             	add    $0x8,%esp
  lapicw(LINT1, MASKED);
80102f23:	68 00 00 01 00       	push   $0x10000
80102f28:	68 d8 00 00 00       	push   $0xd8
80102f2d:	e8 6a ff ff ff       	call   80102e9c <lapicw>
80102f32:	83 c4 08             	add    $0x8,%esp

  // Disable performance counter overflow interrupts
  // on machines that provide that interrupt entry.
  if(((lapic[VER]>>16) & 0xFF) >= 4)
80102f35:	a1 40 71 11 80       	mov    0x80117140,%eax
80102f3a:	83 c0 30             	add    $0x30,%eax
80102f3d:	8b 00                	mov    (%eax),%eax
80102f3f:	c1 e8 10             	shr    $0x10,%eax
80102f42:	25 fc 00 00 00       	and    $0xfc,%eax
80102f47:	85 c0                	test   %eax,%eax
80102f49:	74 12                	je     80102f5d <lapicinit+0x9e>
    lapicw(PCINT, MASKED);
80102f4b:	68 00 00 01 00       	push   $0x10000
80102f50:	68 d0 00 00 00       	push   $0xd0
80102f55:	e8 42 ff ff ff       	call   80102e9c <lapicw>
80102f5a:	83 c4 08             	add    $0x8,%esp

  // Map error interrupt to IRQ_ERROR.
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
80102f5d:	6a 33                	push   $0x33
80102f5f:	68 dc 00 00 00       	push   $0xdc
80102f64:	e8 33 ff ff ff       	call   80102e9c <lapicw>
80102f69:	83 c4 08             	add    $0x8,%esp

  // Clear error status register (requires back-to-back writes).
  lapicw(ESR, 0);
80102f6c:	6a 00                	push   $0x0
80102f6e:	68 a0 00 00 00       	push   $0xa0
80102f73:	e8 24 ff ff ff       	call   80102e9c <lapicw>
80102f78:	83 c4 08             	add    $0x8,%esp
  lapicw(ESR, 0);
80102f7b:	6a 00                	push   $0x0
80102f7d:	68 a0 00 00 00       	push   $0xa0
80102f82:	e8 15 ff ff ff       	call   80102e9c <lapicw>
80102f87:	83 c4 08             	add    $0x8,%esp

  // Ack any outstanding interrupts.
  lapicw(EOI, 0);
80102f8a:	6a 00                	push   $0x0
80102f8c:	6a 2c                	push   $0x2c
80102f8e:	e8 09 ff ff ff       	call   80102e9c <lapicw>
80102f93:	83 c4 08             	add    $0x8,%esp

  // Send an Init Level De-Assert to synchronise arbitration ID's.
  lapicw(ICRHI, 0);
80102f96:	6a 00                	push   $0x0
80102f98:	68 c4 00 00 00       	push   $0xc4
80102f9d:	e8 fa fe ff ff       	call   80102e9c <lapicw>
80102fa2:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, BCAST | INIT | LEVEL);
80102fa5:	68 00 85 08 00       	push   $0x88500
80102faa:	68 c0 00 00 00       	push   $0xc0
80102faf:	e8 e8 fe ff ff       	call   80102e9c <lapicw>
80102fb4:	83 c4 08             	add    $0x8,%esp
  while(lapic[ICRLO] & DELIVS)
80102fb7:	90                   	nop
80102fb8:	a1 40 71 11 80       	mov    0x80117140,%eax
80102fbd:	05 00 03 00 00       	add    $0x300,%eax
80102fc2:	8b 00                	mov    (%eax),%eax
80102fc4:	25 00 10 00 00       	and    $0x1000,%eax
80102fc9:	85 c0                	test   %eax,%eax
80102fcb:	75 eb                	jne    80102fb8 <lapicinit+0xf9>
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
80102fcd:	6a 00                	push   $0x0
80102fcf:	6a 20                	push   $0x20
80102fd1:	e8 c6 fe ff ff       	call   80102e9c <lapicw>
80102fd6:	83 c4 08             	add    $0x8,%esp
80102fd9:	eb 01                	jmp    80102fdc <lapicinit+0x11d>
    return;
80102fdb:	90                   	nop
}
80102fdc:	c9                   	leave  
80102fdd:	c3                   	ret    

80102fde <lapicid>:

int
lapicid(void)
{
80102fde:	55                   	push   %ebp
80102fdf:	89 e5                	mov    %esp,%ebp

  if (!lapic){
80102fe1:	a1 40 71 11 80       	mov    0x80117140,%eax
80102fe6:	85 c0                	test   %eax,%eax
80102fe8:	75 07                	jne    80102ff1 <lapicid+0x13>
    return 0;
80102fea:	b8 00 00 00 00       	mov    $0x0,%eax
80102fef:	eb 0d                	jmp    80102ffe <lapicid+0x20>
  }
  return lapic[ID] >> 24;
80102ff1:	a1 40 71 11 80       	mov    0x80117140,%eax
80102ff6:	83 c0 20             	add    $0x20,%eax
80102ff9:	8b 00                	mov    (%eax),%eax
80102ffb:	c1 e8 18             	shr    $0x18,%eax
}
80102ffe:	5d                   	pop    %ebp
80102fff:	c3                   	ret    

80103000 <lapiceoi>:

// Acknowledge interrupt.
void
lapiceoi(void)
{
80103000:	55                   	push   %ebp
80103001:	89 e5                	mov    %esp,%ebp
  if(lapic)
80103003:	a1 40 71 11 80       	mov    0x80117140,%eax
80103008:	85 c0                	test   %eax,%eax
8010300a:	74 0c                	je     80103018 <lapiceoi+0x18>
    lapicw(EOI, 0);
8010300c:	6a 00                	push   $0x0
8010300e:	6a 2c                	push   $0x2c
80103010:	e8 87 fe ff ff       	call   80102e9c <lapicw>
80103015:	83 c4 08             	add    $0x8,%esp
}
80103018:	90                   	nop
80103019:	c9                   	leave  
8010301a:	c3                   	ret    

8010301b <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
void
microdelay(int us)
{
8010301b:	55                   	push   %ebp
8010301c:	89 e5                	mov    %esp,%ebp
}
8010301e:	90                   	nop
8010301f:	5d                   	pop    %ebp
80103020:	c3                   	ret    

80103021 <lapicstartap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapicstartap(uchar apicid, uint addr)
{
80103021:	55                   	push   %ebp
80103022:	89 e5                	mov    %esp,%ebp
80103024:	83 ec 14             	sub    $0x14,%esp
80103027:	8b 45 08             	mov    0x8(%ebp),%eax
8010302a:	88 45 ec             	mov    %al,-0x14(%ebp)
  ushort *wrv;

  // "The BSP must initialize CMOS shutdown code to 0AH
  // and the warm reset vector (DWORD based at 40:67) to point at
  // the AP startup code prior to the [universal startup algorithm]."
  outb(CMOS_PORT, 0xF);  // offset 0xF is shutdown code
8010302d:	6a 0f                	push   $0xf
8010302f:	6a 70                	push   $0x70
80103031:	e8 45 fe ff ff       	call   80102e7b <outb>
80103036:	83 c4 08             	add    $0x8,%esp
  outb(CMOS_PORT+1, 0x0A);
80103039:	6a 0a                	push   $0xa
8010303b:	6a 71                	push   $0x71
8010303d:	e8 39 fe ff ff       	call   80102e7b <outb>
80103042:	83 c4 08             	add    $0x8,%esp
  wrv = (ushort*)P2V((0x40<<4 | 0x67));  // Warm reset vector
80103045:	c7 45 f8 67 04 00 80 	movl   $0x80000467,-0x8(%ebp)
  wrv[0] = 0;
8010304c:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010304f:	66 c7 00 00 00       	movw   $0x0,(%eax)
  wrv[1] = addr >> 4;
80103054:	8b 45 0c             	mov    0xc(%ebp),%eax
80103057:	c1 e8 04             	shr    $0x4,%eax
8010305a:	89 c2                	mov    %eax,%edx
8010305c:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010305f:	83 c0 02             	add    $0x2,%eax
80103062:	66 89 10             	mov    %dx,(%eax)

  // "Universal startup algorithm."
  // Send INIT (level-triggered) interrupt to reset other CPU.
  lapicw(ICRHI, apicid<<24);
80103065:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80103069:	c1 e0 18             	shl    $0x18,%eax
8010306c:	50                   	push   %eax
8010306d:	68 c4 00 00 00       	push   $0xc4
80103072:	e8 25 fe ff ff       	call   80102e9c <lapicw>
80103077:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
8010307a:	68 00 c5 00 00       	push   $0xc500
8010307f:	68 c0 00 00 00       	push   $0xc0
80103084:	e8 13 fe ff ff       	call   80102e9c <lapicw>
80103089:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
8010308c:	68 c8 00 00 00       	push   $0xc8
80103091:	e8 85 ff ff ff       	call   8010301b <microdelay>
80103096:	83 c4 04             	add    $0x4,%esp
  lapicw(ICRLO, INIT | LEVEL);
80103099:	68 00 85 00 00       	push   $0x8500
8010309e:	68 c0 00 00 00       	push   $0xc0
801030a3:	e8 f4 fd ff ff       	call   80102e9c <lapicw>
801030a8:	83 c4 08             	add    $0x8,%esp
  microdelay(100);    // should be 10ms, but too slow in Bochs!
801030ab:	6a 64                	push   $0x64
801030ad:	e8 69 ff ff ff       	call   8010301b <microdelay>
801030b2:	83 c4 04             	add    $0x4,%esp
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
801030b5:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801030bc:	eb 3d                	jmp    801030fb <lapicstartap+0xda>
    lapicw(ICRHI, apicid<<24);
801030be:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
801030c2:	c1 e0 18             	shl    $0x18,%eax
801030c5:	50                   	push   %eax
801030c6:	68 c4 00 00 00       	push   $0xc4
801030cb:	e8 cc fd ff ff       	call   80102e9c <lapicw>
801030d0:	83 c4 08             	add    $0x8,%esp
    lapicw(ICRLO, STARTUP | (addr>>12));
801030d3:	8b 45 0c             	mov    0xc(%ebp),%eax
801030d6:	c1 e8 0c             	shr    $0xc,%eax
801030d9:	80 cc 06             	or     $0x6,%ah
801030dc:	50                   	push   %eax
801030dd:	68 c0 00 00 00       	push   $0xc0
801030e2:	e8 b5 fd ff ff       	call   80102e9c <lapicw>
801030e7:	83 c4 08             	add    $0x8,%esp
    microdelay(200);
801030ea:	68 c8 00 00 00       	push   $0xc8
801030ef:	e8 27 ff ff ff       	call   8010301b <microdelay>
801030f4:	83 c4 04             	add    $0x4,%esp
  for(i = 0; i < 2; i++){
801030f7:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801030fb:	83 7d fc 01          	cmpl   $0x1,-0x4(%ebp)
801030ff:	7e bd                	jle    801030be <lapicstartap+0x9d>
  }
}
80103101:	90                   	nop
80103102:	90                   	nop
80103103:	c9                   	leave  
80103104:	c3                   	ret    

80103105 <cmos_read>:
#define DAY     0x07
#define MONTH   0x08
#define YEAR    0x09

static uint cmos_read(uint reg)
{
80103105:	55                   	push   %ebp
80103106:	89 e5                	mov    %esp,%ebp
  outb(CMOS_PORT,  reg);
80103108:	8b 45 08             	mov    0x8(%ebp),%eax
8010310b:	0f b6 c0             	movzbl %al,%eax
8010310e:	50                   	push   %eax
8010310f:	6a 70                	push   $0x70
80103111:	e8 65 fd ff ff       	call   80102e7b <outb>
80103116:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
80103119:	68 c8 00 00 00       	push   $0xc8
8010311e:	e8 f8 fe ff ff       	call   8010301b <microdelay>
80103123:	83 c4 04             	add    $0x4,%esp

  return inb(CMOS_RETURN);
80103126:	6a 71                	push   $0x71
80103128:	e8 31 fd ff ff       	call   80102e5e <inb>
8010312d:	83 c4 04             	add    $0x4,%esp
80103130:	0f b6 c0             	movzbl %al,%eax
}
80103133:	c9                   	leave  
80103134:	c3                   	ret    

80103135 <fill_rtcdate>:

static void fill_rtcdate(struct rtcdate *r)
{
80103135:	55                   	push   %ebp
80103136:	89 e5                	mov    %esp,%ebp
  r->second = cmos_read(SECS);
80103138:	6a 00                	push   $0x0
8010313a:	e8 c6 ff ff ff       	call   80103105 <cmos_read>
8010313f:	83 c4 04             	add    $0x4,%esp
80103142:	8b 55 08             	mov    0x8(%ebp),%edx
80103145:	89 02                	mov    %eax,(%edx)
  r->minute = cmos_read(MINS);
80103147:	6a 02                	push   $0x2
80103149:	e8 b7 ff ff ff       	call   80103105 <cmos_read>
8010314e:	83 c4 04             	add    $0x4,%esp
80103151:	8b 55 08             	mov    0x8(%ebp),%edx
80103154:	89 42 04             	mov    %eax,0x4(%edx)
  r->hour   = cmos_read(HOURS);
80103157:	6a 04                	push   $0x4
80103159:	e8 a7 ff ff ff       	call   80103105 <cmos_read>
8010315e:	83 c4 04             	add    $0x4,%esp
80103161:	8b 55 08             	mov    0x8(%ebp),%edx
80103164:	89 42 08             	mov    %eax,0x8(%edx)
  r->day    = cmos_read(DAY);
80103167:	6a 07                	push   $0x7
80103169:	e8 97 ff ff ff       	call   80103105 <cmos_read>
8010316e:	83 c4 04             	add    $0x4,%esp
80103171:	8b 55 08             	mov    0x8(%ebp),%edx
80103174:	89 42 0c             	mov    %eax,0xc(%edx)
  r->month  = cmos_read(MONTH);
80103177:	6a 08                	push   $0x8
80103179:	e8 87 ff ff ff       	call   80103105 <cmos_read>
8010317e:	83 c4 04             	add    $0x4,%esp
80103181:	8b 55 08             	mov    0x8(%ebp),%edx
80103184:	89 42 10             	mov    %eax,0x10(%edx)
  r->year   = cmos_read(YEAR);
80103187:	6a 09                	push   $0x9
80103189:	e8 77 ff ff ff       	call   80103105 <cmos_read>
8010318e:	83 c4 04             	add    $0x4,%esp
80103191:	8b 55 08             	mov    0x8(%ebp),%edx
80103194:	89 42 14             	mov    %eax,0x14(%edx)
}
80103197:	90                   	nop
80103198:	c9                   	leave  
80103199:	c3                   	ret    

8010319a <cmostime>:

// qemu seems to use 24-hour GWT and the values are BCD encoded
void cmostime(struct rtcdate *r)
{
8010319a:	55                   	push   %ebp
8010319b:	89 e5                	mov    %esp,%ebp
8010319d:	83 ec 48             	sub    $0x48,%esp
  struct rtcdate t1, t2;
  int sb, bcd;

  sb = cmos_read(CMOS_STATB);
801031a0:	6a 0b                	push   $0xb
801031a2:	e8 5e ff ff ff       	call   80103105 <cmos_read>
801031a7:	83 c4 04             	add    $0x4,%esp
801031aa:	89 45 f4             	mov    %eax,-0xc(%ebp)

  bcd = (sb & (1 << 2)) == 0;
801031ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
801031b0:	83 e0 04             	and    $0x4,%eax
801031b3:	85 c0                	test   %eax,%eax
801031b5:	0f 94 c0             	sete   %al
801031b8:	0f b6 c0             	movzbl %al,%eax
801031bb:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // make sure CMOS doesn't modify time while we read it
  for(;;) {
    fill_rtcdate(&t1);
801031be:	8d 45 d8             	lea    -0x28(%ebp),%eax
801031c1:	50                   	push   %eax
801031c2:	e8 6e ff ff ff       	call   80103135 <fill_rtcdate>
801031c7:	83 c4 04             	add    $0x4,%esp
    if(cmos_read(CMOS_STATA) & CMOS_UIP)
801031ca:	6a 0a                	push   $0xa
801031cc:	e8 34 ff ff ff       	call   80103105 <cmos_read>
801031d1:	83 c4 04             	add    $0x4,%esp
801031d4:	25 80 00 00 00       	and    $0x80,%eax
801031d9:	85 c0                	test   %eax,%eax
801031db:	75 27                	jne    80103204 <cmostime+0x6a>
        continue;
    fill_rtcdate(&t2);
801031dd:	8d 45 c0             	lea    -0x40(%ebp),%eax
801031e0:	50                   	push   %eax
801031e1:	e8 4f ff ff ff       	call   80103135 <fill_rtcdate>
801031e6:	83 c4 04             	add    $0x4,%esp
    if(memcmp(&t1, &t2, sizeof(t1)) == 0)
801031e9:	83 ec 04             	sub    $0x4,%esp
801031ec:	6a 18                	push   $0x18
801031ee:	8d 45 c0             	lea    -0x40(%ebp),%eax
801031f1:	50                   	push   %eax
801031f2:	8d 45 d8             	lea    -0x28(%ebp),%eax
801031f5:	50                   	push   %eax
801031f6:	e8 cf 1c 00 00       	call   80104eca <memcmp>
801031fb:	83 c4 10             	add    $0x10,%esp
801031fe:	85 c0                	test   %eax,%eax
80103200:	74 05                	je     80103207 <cmostime+0x6d>
80103202:	eb ba                	jmp    801031be <cmostime+0x24>
        continue;
80103204:	90                   	nop
    fill_rtcdate(&t1);
80103205:	eb b7                	jmp    801031be <cmostime+0x24>
      break;
80103207:	90                   	nop
  }

  // convert
  if(bcd) {
80103208:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010320c:	0f 84 b4 00 00 00    	je     801032c6 <cmostime+0x12c>
#define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
    CONV(second);
80103212:	8b 45 d8             	mov    -0x28(%ebp),%eax
80103215:	c1 e8 04             	shr    $0x4,%eax
80103218:	89 c2                	mov    %eax,%edx
8010321a:	89 d0                	mov    %edx,%eax
8010321c:	c1 e0 02             	shl    $0x2,%eax
8010321f:	01 d0                	add    %edx,%eax
80103221:	01 c0                	add    %eax,%eax
80103223:	89 c2                	mov    %eax,%edx
80103225:	8b 45 d8             	mov    -0x28(%ebp),%eax
80103228:	83 e0 0f             	and    $0xf,%eax
8010322b:	01 d0                	add    %edx,%eax
8010322d:	89 45 d8             	mov    %eax,-0x28(%ebp)
    CONV(minute);
80103230:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103233:	c1 e8 04             	shr    $0x4,%eax
80103236:	89 c2                	mov    %eax,%edx
80103238:	89 d0                	mov    %edx,%eax
8010323a:	c1 e0 02             	shl    $0x2,%eax
8010323d:	01 d0                	add    %edx,%eax
8010323f:	01 c0                	add    %eax,%eax
80103241:	89 c2                	mov    %eax,%edx
80103243:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103246:	83 e0 0f             	and    $0xf,%eax
80103249:	01 d0                	add    %edx,%eax
8010324b:	89 45 dc             	mov    %eax,-0x24(%ebp)
    CONV(hour  );
8010324e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103251:	c1 e8 04             	shr    $0x4,%eax
80103254:	89 c2                	mov    %eax,%edx
80103256:	89 d0                	mov    %edx,%eax
80103258:	c1 e0 02             	shl    $0x2,%eax
8010325b:	01 d0                	add    %edx,%eax
8010325d:	01 c0                	add    %eax,%eax
8010325f:	89 c2                	mov    %eax,%edx
80103261:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103264:	83 e0 0f             	and    $0xf,%eax
80103267:	01 d0                	add    %edx,%eax
80103269:	89 45 e0             	mov    %eax,-0x20(%ebp)
    CONV(day   );
8010326c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010326f:	c1 e8 04             	shr    $0x4,%eax
80103272:	89 c2                	mov    %eax,%edx
80103274:	89 d0                	mov    %edx,%eax
80103276:	c1 e0 02             	shl    $0x2,%eax
80103279:	01 d0                	add    %edx,%eax
8010327b:	01 c0                	add    %eax,%eax
8010327d:	89 c2                	mov    %eax,%edx
8010327f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103282:	83 e0 0f             	and    $0xf,%eax
80103285:	01 d0                	add    %edx,%eax
80103287:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    CONV(month );
8010328a:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010328d:	c1 e8 04             	shr    $0x4,%eax
80103290:	89 c2                	mov    %eax,%edx
80103292:	89 d0                	mov    %edx,%eax
80103294:	c1 e0 02             	shl    $0x2,%eax
80103297:	01 d0                	add    %edx,%eax
80103299:	01 c0                	add    %eax,%eax
8010329b:	89 c2                	mov    %eax,%edx
8010329d:	8b 45 e8             	mov    -0x18(%ebp),%eax
801032a0:	83 e0 0f             	and    $0xf,%eax
801032a3:	01 d0                	add    %edx,%eax
801032a5:	89 45 e8             	mov    %eax,-0x18(%ebp)
    CONV(year  );
801032a8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801032ab:	c1 e8 04             	shr    $0x4,%eax
801032ae:	89 c2                	mov    %eax,%edx
801032b0:	89 d0                	mov    %edx,%eax
801032b2:	c1 e0 02             	shl    $0x2,%eax
801032b5:	01 d0                	add    %edx,%eax
801032b7:	01 c0                	add    %eax,%eax
801032b9:	89 c2                	mov    %eax,%edx
801032bb:	8b 45 ec             	mov    -0x14(%ebp),%eax
801032be:	83 e0 0f             	and    $0xf,%eax
801032c1:	01 d0                	add    %edx,%eax
801032c3:	89 45 ec             	mov    %eax,-0x14(%ebp)
#undef     CONV
  }

  *r = t1;
801032c6:	8b 45 08             	mov    0x8(%ebp),%eax
801032c9:	8b 55 d8             	mov    -0x28(%ebp),%edx
801032cc:	89 10                	mov    %edx,(%eax)
801032ce:	8b 55 dc             	mov    -0x24(%ebp),%edx
801032d1:	89 50 04             	mov    %edx,0x4(%eax)
801032d4:	8b 55 e0             	mov    -0x20(%ebp),%edx
801032d7:	89 50 08             	mov    %edx,0x8(%eax)
801032da:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801032dd:	89 50 0c             	mov    %edx,0xc(%eax)
801032e0:	8b 55 e8             	mov    -0x18(%ebp),%edx
801032e3:	89 50 10             	mov    %edx,0x10(%eax)
801032e6:	8b 55 ec             	mov    -0x14(%ebp),%edx
801032e9:	89 50 14             	mov    %edx,0x14(%eax)
  r->year += 2000;
801032ec:	8b 45 08             	mov    0x8(%ebp),%eax
801032ef:	8b 40 14             	mov    0x14(%eax),%eax
801032f2:	8d 90 d0 07 00 00    	lea    0x7d0(%eax),%edx
801032f8:	8b 45 08             	mov    0x8(%ebp),%eax
801032fb:	89 50 14             	mov    %edx,0x14(%eax)
}
801032fe:	90                   	nop
801032ff:	c9                   	leave  
80103300:	c3                   	ret    

80103301 <initlog>:
static void recover_from_log(void);
static void commit();

void
initlog(int dev)
{
80103301:	55                   	push   %ebp
80103302:	89 e5                	mov    %esp,%ebp
80103304:	83 ec 28             	sub    $0x28,%esp
  if (sizeof(struct logheader) >= BSIZE)
    panic("initlog: too big logheader");

  struct superblock sb;
  initlock(&log.lock, "log");
80103307:	83 ec 08             	sub    $0x8,%esp
8010330a:	68 15 a7 10 80       	push   $0x8010a715
8010330f:	68 60 71 11 80       	push   $0x80117160
80103314:	e8 b2 18 00 00       	call   80104bcb <initlock>
80103319:	83 c4 10             	add    $0x10,%esp
  readsb(dev, &sb);
8010331c:	83 ec 08             	sub    $0x8,%esp
8010331f:	8d 45 dc             	lea    -0x24(%ebp),%eax
80103322:	50                   	push   %eax
80103323:	ff 75 08             	push   0x8(%ebp)
80103326:	e8 a3 e0 ff ff       	call   801013ce <readsb>
8010332b:	83 c4 10             	add    $0x10,%esp
  log.start = sb.logstart;
8010332e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103331:	a3 94 71 11 80       	mov    %eax,0x80117194
  log.size = sb.nlog;
80103336:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103339:	a3 98 71 11 80       	mov    %eax,0x80117198
  log.dev = dev;
8010333e:	8b 45 08             	mov    0x8(%ebp),%eax
80103341:	a3 a4 71 11 80       	mov    %eax,0x801171a4
  recover_from_log();
80103346:	e8 b3 01 00 00       	call   801034fe <recover_from_log>
}
8010334b:	90                   	nop
8010334c:	c9                   	leave  
8010334d:	c3                   	ret    

8010334e <install_trans>:

// Copy committed blocks from log to their home location
static void
install_trans(void)
{
8010334e:	55                   	push   %ebp
8010334f:	89 e5                	mov    %esp,%ebp
80103351:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103354:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010335b:	e9 95 00 00 00       	jmp    801033f5 <install_trans+0xa7>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
80103360:	8b 15 94 71 11 80    	mov    0x80117194,%edx
80103366:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103369:	01 d0                	add    %edx,%eax
8010336b:	83 c0 01             	add    $0x1,%eax
8010336e:	89 c2                	mov    %eax,%edx
80103370:	a1 a4 71 11 80       	mov    0x801171a4,%eax
80103375:	83 ec 08             	sub    $0x8,%esp
80103378:	52                   	push   %edx
80103379:	50                   	push   %eax
8010337a:	e8 82 ce ff ff       	call   80100201 <bread>
8010337f:	83 c4 10             	add    $0x10,%esp
80103382:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
80103385:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103388:	83 c0 10             	add    $0x10,%eax
8010338b:	8b 04 85 6c 71 11 80 	mov    -0x7fee8e94(,%eax,4),%eax
80103392:	89 c2                	mov    %eax,%edx
80103394:	a1 a4 71 11 80       	mov    0x801171a4,%eax
80103399:	83 ec 08             	sub    $0x8,%esp
8010339c:	52                   	push   %edx
8010339d:	50                   	push   %eax
8010339e:	e8 5e ce ff ff       	call   80100201 <bread>
801033a3:	83 c4 10             	add    $0x10,%esp
801033a6:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
801033a9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801033ac:	8d 50 5c             	lea    0x5c(%eax),%edx
801033af:	8b 45 ec             	mov    -0x14(%ebp),%eax
801033b2:	83 c0 5c             	add    $0x5c,%eax
801033b5:	83 ec 04             	sub    $0x4,%esp
801033b8:	68 00 02 00 00       	push   $0x200
801033bd:	52                   	push   %edx
801033be:	50                   	push   %eax
801033bf:	e8 5e 1b 00 00       	call   80104f22 <memmove>
801033c4:	83 c4 10             	add    $0x10,%esp
    bwrite(dbuf);  // write dst to disk
801033c7:	83 ec 0c             	sub    $0xc,%esp
801033ca:	ff 75 ec             	push   -0x14(%ebp)
801033cd:	e8 68 ce ff ff       	call   8010023a <bwrite>
801033d2:	83 c4 10             	add    $0x10,%esp
    brelse(lbuf);
801033d5:	83 ec 0c             	sub    $0xc,%esp
801033d8:	ff 75 f0             	push   -0x10(%ebp)
801033db:	e8 a3 ce ff ff       	call   80100283 <brelse>
801033e0:	83 c4 10             	add    $0x10,%esp
    brelse(dbuf);
801033e3:	83 ec 0c             	sub    $0xc,%esp
801033e6:	ff 75 ec             	push   -0x14(%ebp)
801033e9:	e8 95 ce ff ff       	call   80100283 <brelse>
801033ee:	83 c4 10             	add    $0x10,%esp
  for (tail = 0; tail < log.lh.n; tail++) {
801033f1:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801033f5:	a1 a8 71 11 80       	mov    0x801171a8,%eax
801033fa:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801033fd:	0f 8c 5d ff ff ff    	jl     80103360 <install_trans+0x12>
  }
}
80103403:	90                   	nop
80103404:	90                   	nop
80103405:	c9                   	leave  
80103406:	c3                   	ret    

80103407 <read_head>:

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
80103407:	55                   	push   %ebp
80103408:	89 e5                	mov    %esp,%ebp
8010340a:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
8010340d:	a1 94 71 11 80       	mov    0x80117194,%eax
80103412:	89 c2                	mov    %eax,%edx
80103414:	a1 a4 71 11 80       	mov    0x801171a4,%eax
80103419:	83 ec 08             	sub    $0x8,%esp
8010341c:	52                   	push   %edx
8010341d:	50                   	push   %eax
8010341e:	e8 de cd ff ff       	call   80100201 <bread>
80103423:	83 c4 10             	add    $0x10,%esp
80103426:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *lh = (struct logheader *) (buf->data);
80103429:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010342c:	83 c0 5c             	add    $0x5c,%eax
8010342f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  log.lh.n = lh->n;
80103432:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103435:	8b 00                	mov    (%eax),%eax
80103437:	a3 a8 71 11 80       	mov    %eax,0x801171a8
  for (i = 0; i < log.lh.n; i++) {
8010343c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103443:	eb 1b                	jmp    80103460 <read_head+0x59>
    log.lh.block[i] = lh->block[i];
80103445:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103448:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010344b:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
8010344f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103452:	83 c2 10             	add    $0x10,%edx
80103455:	89 04 95 6c 71 11 80 	mov    %eax,-0x7fee8e94(,%edx,4)
  for (i = 0; i < log.lh.n; i++) {
8010345c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103460:	a1 a8 71 11 80       	mov    0x801171a8,%eax
80103465:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103468:	7c db                	jl     80103445 <read_head+0x3e>
  }
  brelse(buf);
8010346a:	83 ec 0c             	sub    $0xc,%esp
8010346d:	ff 75 f0             	push   -0x10(%ebp)
80103470:	e8 0e ce ff ff       	call   80100283 <brelse>
80103475:	83 c4 10             	add    $0x10,%esp
}
80103478:	90                   	nop
80103479:	c9                   	leave  
8010347a:	c3                   	ret    

8010347b <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
8010347b:	55                   	push   %ebp
8010347c:	89 e5                	mov    %esp,%ebp
8010347e:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
80103481:	a1 94 71 11 80       	mov    0x80117194,%eax
80103486:	89 c2                	mov    %eax,%edx
80103488:	a1 a4 71 11 80       	mov    0x801171a4,%eax
8010348d:	83 ec 08             	sub    $0x8,%esp
80103490:	52                   	push   %edx
80103491:	50                   	push   %eax
80103492:	e8 6a cd ff ff       	call   80100201 <bread>
80103497:	83 c4 10             	add    $0x10,%esp
8010349a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *hb = (struct logheader *) (buf->data);
8010349d:	8b 45 f0             	mov    -0x10(%ebp),%eax
801034a0:	83 c0 5c             	add    $0x5c,%eax
801034a3:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  hb->n = log.lh.n;
801034a6:	8b 15 a8 71 11 80    	mov    0x801171a8,%edx
801034ac:	8b 45 ec             	mov    -0x14(%ebp),%eax
801034af:	89 10                	mov    %edx,(%eax)
  for (i = 0; i < log.lh.n; i++) {
801034b1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801034b8:	eb 1b                	jmp    801034d5 <write_head+0x5a>
    hb->block[i] = log.lh.block[i];
801034ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
801034bd:	83 c0 10             	add    $0x10,%eax
801034c0:	8b 0c 85 6c 71 11 80 	mov    -0x7fee8e94(,%eax,4),%ecx
801034c7:	8b 45 ec             	mov    -0x14(%ebp),%eax
801034ca:	8b 55 f4             	mov    -0xc(%ebp),%edx
801034cd:	89 4c 90 04          	mov    %ecx,0x4(%eax,%edx,4)
  for (i = 0; i < log.lh.n; i++) {
801034d1:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801034d5:	a1 a8 71 11 80       	mov    0x801171a8,%eax
801034da:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801034dd:	7c db                	jl     801034ba <write_head+0x3f>
  }
  bwrite(buf);
801034df:	83 ec 0c             	sub    $0xc,%esp
801034e2:	ff 75 f0             	push   -0x10(%ebp)
801034e5:	e8 50 cd ff ff       	call   8010023a <bwrite>
801034ea:	83 c4 10             	add    $0x10,%esp
  brelse(buf);
801034ed:	83 ec 0c             	sub    $0xc,%esp
801034f0:	ff 75 f0             	push   -0x10(%ebp)
801034f3:	e8 8b cd ff ff       	call   80100283 <brelse>
801034f8:	83 c4 10             	add    $0x10,%esp
}
801034fb:	90                   	nop
801034fc:	c9                   	leave  
801034fd:	c3                   	ret    

801034fe <recover_from_log>:

static void
recover_from_log(void)
{
801034fe:	55                   	push   %ebp
801034ff:	89 e5                	mov    %esp,%ebp
80103501:	83 ec 08             	sub    $0x8,%esp
  read_head();
80103504:	e8 fe fe ff ff       	call   80103407 <read_head>
  install_trans(); // if committed, copy from log to disk
80103509:	e8 40 fe ff ff       	call   8010334e <install_trans>
  log.lh.n = 0;
8010350e:	c7 05 a8 71 11 80 00 	movl   $0x0,0x801171a8
80103515:	00 00 00 
  write_head(); // clear the log
80103518:	e8 5e ff ff ff       	call   8010347b <write_head>
}
8010351d:	90                   	nop
8010351e:	c9                   	leave  
8010351f:	c3                   	ret    

80103520 <begin_op>:

// called at the start of each FS system call.
void
begin_op(void)
{
80103520:	55                   	push   %ebp
80103521:	89 e5                	mov    %esp,%ebp
80103523:	83 ec 08             	sub    $0x8,%esp
  acquire(&log.lock);
80103526:	83 ec 0c             	sub    $0xc,%esp
80103529:	68 60 71 11 80       	push   $0x80117160
8010352e:	e8 ba 16 00 00       	call   80104bed <acquire>
80103533:	83 c4 10             	add    $0x10,%esp
  while(1){
    if(log.committing){
80103536:	a1 a0 71 11 80       	mov    0x801171a0,%eax
8010353b:	85 c0                	test   %eax,%eax
8010353d:	74 17                	je     80103556 <begin_op+0x36>
      sleep(&log, &log.lock);
8010353f:	83 ec 08             	sub    $0x8,%esp
80103542:	68 60 71 11 80       	push   $0x80117160
80103547:	68 60 71 11 80       	push   $0x80117160
8010354c:	e8 78 12 00 00       	call   801047c9 <sleep>
80103551:	83 c4 10             	add    $0x10,%esp
80103554:	eb e0                	jmp    80103536 <begin_op+0x16>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
80103556:	8b 0d a8 71 11 80    	mov    0x801171a8,%ecx
8010355c:	a1 9c 71 11 80       	mov    0x8011719c,%eax
80103561:	8d 50 01             	lea    0x1(%eax),%edx
80103564:	89 d0                	mov    %edx,%eax
80103566:	c1 e0 02             	shl    $0x2,%eax
80103569:	01 d0                	add    %edx,%eax
8010356b:	01 c0                	add    %eax,%eax
8010356d:	01 c8                	add    %ecx,%eax
8010356f:	83 f8 1e             	cmp    $0x1e,%eax
80103572:	7e 17                	jle    8010358b <begin_op+0x6b>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
80103574:	83 ec 08             	sub    $0x8,%esp
80103577:	68 60 71 11 80       	push   $0x80117160
8010357c:	68 60 71 11 80       	push   $0x80117160
80103581:	e8 43 12 00 00       	call   801047c9 <sleep>
80103586:	83 c4 10             	add    $0x10,%esp
80103589:	eb ab                	jmp    80103536 <begin_op+0x16>
    } else {
      log.outstanding += 1;
8010358b:	a1 9c 71 11 80       	mov    0x8011719c,%eax
80103590:	83 c0 01             	add    $0x1,%eax
80103593:	a3 9c 71 11 80       	mov    %eax,0x8011719c
      release(&log.lock);
80103598:	83 ec 0c             	sub    $0xc,%esp
8010359b:	68 60 71 11 80       	push   $0x80117160
801035a0:	e8 b6 16 00 00       	call   80104c5b <release>
801035a5:	83 c4 10             	add    $0x10,%esp
      break;
801035a8:	90                   	nop
    }
  }
}
801035a9:	90                   	nop
801035aa:	c9                   	leave  
801035ab:	c3                   	ret    

801035ac <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
801035ac:	55                   	push   %ebp
801035ad:	89 e5                	mov    %esp,%ebp
801035af:	83 ec 18             	sub    $0x18,%esp
  int do_commit = 0;
801035b2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&log.lock);
801035b9:	83 ec 0c             	sub    $0xc,%esp
801035bc:	68 60 71 11 80       	push   $0x80117160
801035c1:	e8 27 16 00 00       	call   80104bed <acquire>
801035c6:	83 c4 10             	add    $0x10,%esp
  log.outstanding -= 1;
801035c9:	a1 9c 71 11 80       	mov    0x8011719c,%eax
801035ce:	83 e8 01             	sub    $0x1,%eax
801035d1:	a3 9c 71 11 80       	mov    %eax,0x8011719c
  if(log.committing)
801035d6:	a1 a0 71 11 80       	mov    0x801171a0,%eax
801035db:	85 c0                	test   %eax,%eax
801035dd:	74 0d                	je     801035ec <end_op+0x40>
    panic("log.committing");
801035df:	83 ec 0c             	sub    $0xc,%esp
801035e2:	68 19 a7 10 80       	push   $0x8010a719
801035e7:	e8 bd cf ff ff       	call   801005a9 <panic>
  if(log.outstanding == 0){
801035ec:	a1 9c 71 11 80       	mov    0x8011719c,%eax
801035f1:	85 c0                	test   %eax,%eax
801035f3:	75 13                	jne    80103608 <end_op+0x5c>
    do_commit = 1;
801035f5:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
    log.committing = 1;
801035fc:	c7 05 a0 71 11 80 01 	movl   $0x1,0x801171a0
80103603:	00 00 00 
80103606:	eb 10                	jmp    80103618 <end_op+0x6c>
  } else {
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
80103608:	83 ec 0c             	sub    $0xc,%esp
8010360b:	68 60 71 11 80       	push   $0x80117160
80103610:	e8 9e 12 00 00       	call   801048b3 <wakeup>
80103615:	83 c4 10             	add    $0x10,%esp
  }
  release(&log.lock);
80103618:	83 ec 0c             	sub    $0xc,%esp
8010361b:	68 60 71 11 80       	push   $0x80117160
80103620:	e8 36 16 00 00       	call   80104c5b <release>
80103625:	83 c4 10             	add    $0x10,%esp

  if(do_commit){
80103628:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010362c:	74 3f                	je     8010366d <end_op+0xc1>
    // call commit w/o holding locks, since not allowed
    // to sleep with locks.
    commit();
8010362e:	e8 f6 00 00 00       	call   80103729 <commit>
    acquire(&log.lock);
80103633:	83 ec 0c             	sub    $0xc,%esp
80103636:	68 60 71 11 80       	push   $0x80117160
8010363b:	e8 ad 15 00 00       	call   80104bed <acquire>
80103640:	83 c4 10             	add    $0x10,%esp
    log.committing = 0;
80103643:	c7 05 a0 71 11 80 00 	movl   $0x0,0x801171a0
8010364a:	00 00 00 
    wakeup(&log);
8010364d:	83 ec 0c             	sub    $0xc,%esp
80103650:	68 60 71 11 80       	push   $0x80117160
80103655:	e8 59 12 00 00       	call   801048b3 <wakeup>
8010365a:	83 c4 10             	add    $0x10,%esp
    release(&log.lock);
8010365d:	83 ec 0c             	sub    $0xc,%esp
80103660:	68 60 71 11 80       	push   $0x80117160
80103665:	e8 f1 15 00 00       	call   80104c5b <release>
8010366a:	83 c4 10             	add    $0x10,%esp
  }
}
8010366d:	90                   	nop
8010366e:	c9                   	leave  
8010366f:	c3                   	ret    

80103670 <write_log>:

// Copy modified blocks from cache to log.
static void
write_log(void)
{
80103670:	55                   	push   %ebp
80103671:	89 e5                	mov    %esp,%ebp
80103673:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103676:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010367d:	e9 95 00 00 00       	jmp    80103717 <write_log+0xa7>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
80103682:	8b 15 94 71 11 80    	mov    0x80117194,%edx
80103688:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010368b:	01 d0                	add    %edx,%eax
8010368d:	83 c0 01             	add    $0x1,%eax
80103690:	89 c2                	mov    %eax,%edx
80103692:	a1 a4 71 11 80       	mov    0x801171a4,%eax
80103697:	83 ec 08             	sub    $0x8,%esp
8010369a:	52                   	push   %edx
8010369b:	50                   	push   %eax
8010369c:	e8 60 cb ff ff       	call   80100201 <bread>
801036a1:	83 c4 10             	add    $0x10,%esp
801036a4:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
801036a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801036aa:	83 c0 10             	add    $0x10,%eax
801036ad:	8b 04 85 6c 71 11 80 	mov    -0x7fee8e94(,%eax,4),%eax
801036b4:	89 c2                	mov    %eax,%edx
801036b6:	a1 a4 71 11 80       	mov    0x801171a4,%eax
801036bb:	83 ec 08             	sub    $0x8,%esp
801036be:	52                   	push   %edx
801036bf:	50                   	push   %eax
801036c0:	e8 3c cb ff ff       	call   80100201 <bread>
801036c5:	83 c4 10             	add    $0x10,%esp
801036c8:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(to->data, from->data, BSIZE);
801036cb:	8b 45 ec             	mov    -0x14(%ebp),%eax
801036ce:	8d 50 5c             	lea    0x5c(%eax),%edx
801036d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801036d4:	83 c0 5c             	add    $0x5c,%eax
801036d7:	83 ec 04             	sub    $0x4,%esp
801036da:	68 00 02 00 00       	push   $0x200
801036df:	52                   	push   %edx
801036e0:	50                   	push   %eax
801036e1:	e8 3c 18 00 00       	call   80104f22 <memmove>
801036e6:	83 c4 10             	add    $0x10,%esp
    bwrite(to);  // write the log
801036e9:	83 ec 0c             	sub    $0xc,%esp
801036ec:	ff 75 f0             	push   -0x10(%ebp)
801036ef:	e8 46 cb ff ff       	call   8010023a <bwrite>
801036f4:	83 c4 10             	add    $0x10,%esp
    brelse(from);
801036f7:	83 ec 0c             	sub    $0xc,%esp
801036fa:	ff 75 ec             	push   -0x14(%ebp)
801036fd:	e8 81 cb ff ff       	call   80100283 <brelse>
80103702:	83 c4 10             	add    $0x10,%esp
    brelse(to);
80103705:	83 ec 0c             	sub    $0xc,%esp
80103708:	ff 75 f0             	push   -0x10(%ebp)
8010370b:	e8 73 cb ff ff       	call   80100283 <brelse>
80103710:	83 c4 10             	add    $0x10,%esp
  for (tail = 0; tail < log.lh.n; tail++) {
80103713:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103717:	a1 a8 71 11 80       	mov    0x801171a8,%eax
8010371c:	39 45 f4             	cmp    %eax,-0xc(%ebp)
8010371f:	0f 8c 5d ff ff ff    	jl     80103682 <write_log+0x12>
  }
}
80103725:	90                   	nop
80103726:	90                   	nop
80103727:	c9                   	leave  
80103728:	c3                   	ret    

80103729 <commit>:

static void
commit()
{
80103729:	55                   	push   %ebp
8010372a:	89 e5                	mov    %esp,%ebp
8010372c:	83 ec 08             	sub    $0x8,%esp
  if (log.lh.n > 0) {
8010372f:	a1 a8 71 11 80       	mov    0x801171a8,%eax
80103734:	85 c0                	test   %eax,%eax
80103736:	7e 1e                	jle    80103756 <commit+0x2d>
    write_log();     // Write modified blocks from cache to log
80103738:	e8 33 ff ff ff       	call   80103670 <write_log>
    write_head();    // Write header to disk -- the real commit
8010373d:	e8 39 fd ff ff       	call   8010347b <write_head>
    install_trans(); // Now install writes to home locations
80103742:	e8 07 fc ff ff       	call   8010334e <install_trans>
    log.lh.n = 0;
80103747:	c7 05 a8 71 11 80 00 	movl   $0x0,0x801171a8
8010374e:	00 00 00 
    write_head();    // Erase the transaction from the log
80103751:	e8 25 fd ff ff       	call   8010347b <write_head>
  }
}
80103756:	90                   	nop
80103757:	c9                   	leave  
80103758:	c3                   	ret    

80103759 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
80103759:	55                   	push   %ebp
8010375a:	89 e5                	mov    %esp,%ebp
8010375c:	83 ec 18             	sub    $0x18,%esp
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
8010375f:	a1 a8 71 11 80       	mov    0x801171a8,%eax
80103764:	83 f8 1d             	cmp    $0x1d,%eax
80103767:	7f 12                	jg     8010377b <log_write+0x22>
80103769:	a1 a8 71 11 80       	mov    0x801171a8,%eax
8010376e:	8b 15 98 71 11 80    	mov    0x80117198,%edx
80103774:	83 ea 01             	sub    $0x1,%edx
80103777:	39 d0                	cmp    %edx,%eax
80103779:	7c 0d                	jl     80103788 <log_write+0x2f>
    panic("too big a transaction");
8010377b:	83 ec 0c             	sub    $0xc,%esp
8010377e:	68 28 a7 10 80       	push   $0x8010a728
80103783:	e8 21 ce ff ff       	call   801005a9 <panic>
  if (log.outstanding < 1)
80103788:	a1 9c 71 11 80       	mov    0x8011719c,%eax
8010378d:	85 c0                	test   %eax,%eax
8010378f:	7f 0d                	jg     8010379e <log_write+0x45>
    panic("log_write outside of trans");
80103791:	83 ec 0c             	sub    $0xc,%esp
80103794:	68 3e a7 10 80       	push   $0x8010a73e
80103799:	e8 0b ce ff ff       	call   801005a9 <panic>

  acquire(&log.lock);
8010379e:	83 ec 0c             	sub    $0xc,%esp
801037a1:	68 60 71 11 80       	push   $0x80117160
801037a6:	e8 42 14 00 00       	call   80104bed <acquire>
801037ab:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < log.lh.n; i++) {
801037ae:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801037b5:	eb 1d                	jmp    801037d4 <log_write+0x7b>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
801037b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801037ba:	83 c0 10             	add    $0x10,%eax
801037bd:	8b 04 85 6c 71 11 80 	mov    -0x7fee8e94(,%eax,4),%eax
801037c4:	89 c2                	mov    %eax,%edx
801037c6:	8b 45 08             	mov    0x8(%ebp),%eax
801037c9:	8b 40 08             	mov    0x8(%eax),%eax
801037cc:	39 c2                	cmp    %eax,%edx
801037ce:	74 10                	je     801037e0 <log_write+0x87>
  for (i = 0; i < log.lh.n; i++) {
801037d0:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801037d4:	a1 a8 71 11 80       	mov    0x801171a8,%eax
801037d9:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801037dc:	7c d9                	jl     801037b7 <log_write+0x5e>
801037de:	eb 01                	jmp    801037e1 <log_write+0x88>
      break;
801037e0:	90                   	nop
  }
  log.lh.block[i] = b->blockno;
801037e1:	8b 45 08             	mov    0x8(%ebp),%eax
801037e4:	8b 40 08             	mov    0x8(%eax),%eax
801037e7:	89 c2                	mov    %eax,%edx
801037e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801037ec:	83 c0 10             	add    $0x10,%eax
801037ef:	89 14 85 6c 71 11 80 	mov    %edx,-0x7fee8e94(,%eax,4)
  if (i == log.lh.n)
801037f6:	a1 a8 71 11 80       	mov    0x801171a8,%eax
801037fb:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801037fe:	75 0d                	jne    8010380d <log_write+0xb4>
    log.lh.n++;
80103800:	a1 a8 71 11 80       	mov    0x801171a8,%eax
80103805:	83 c0 01             	add    $0x1,%eax
80103808:	a3 a8 71 11 80       	mov    %eax,0x801171a8
  b->flags |= B_DIRTY; // prevent eviction
8010380d:	8b 45 08             	mov    0x8(%ebp),%eax
80103810:	8b 00                	mov    (%eax),%eax
80103812:	83 c8 04             	or     $0x4,%eax
80103815:	89 c2                	mov    %eax,%edx
80103817:	8b 45 08             	mov    0x8(%ebp),%eax
8010381a:	89 10                	mov    %edx,(%eax)
  release(&log.lock);
8010381c:	83 ec 0c             	sub    $0xc,%esp
8010381f:	68 60 71 11 80       	push   $0x80117160
80103824:	e8 32 14 00 00       	call   80104c5b <release>
80103829:	83 c4 10             	add    $0x10,%esp
}
8010382c:	90                   	nop
8010382d:	c9                   	leave  
8010382e:	c3                   	ret    

8010382f <xchg>:
  asm volatile("sti");
}

static inline uint
xchg(volatile uint *addr, uint newval)
{
8010382f:	55                   	push   %ebp
80103830:	89 e5                	mov    %esp,%ebp
80103832:	83 ec 10             	sub    $0x10,%esp
  uint result;

  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80103835:	8b 55 08             	mov    0x8(%ebp),%edx
80103838:	8b 45 0c             	mov    0xc(%ebp),%eax
8010383b:	8b 4d 08             	mov    0x8(%ebp),%ecx
8010383e:	f0 87 02             	lock xchg %eax,(%edx)
80103841:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
80103844:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80103847:	c9                   	leave  
80103848:	c3                   	ret    

80103849 <main>:
// Bootstrap processor starts running C code here.
// Allocate a real stack and switch to it, first
// doing some setup required for memory allocator to work.
int
main(void)
{
80103849:	8d 4c 24 04          	lea    0x4(%esp),%ecx
8010384d:	83 e4 f0             	and    $0xfffffff0,%esp
80103850:	ff 71 fc             	push   -0x4(%ecx)
80103853:	55                   	push   %ebp
80103854:	89 e5                	mov    %esp,%ebp
80103856:	51                   	push   %ecx
80103857:	83 ec 04             	sub    $0x4,%esp
  graphic_init();
8010385a:	e8 c5 4a 00 00       	call   80108324 <graphic_init>
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
8010385f:	83 ec 08             	sub    $0x8,%esp
80103862:	68 00 00 40 80       	push   $0x80400000
80103867:	68 00 c0 11 80       	push   $0x8011c000
8010386c:	e8 de f2 ff ff       	call   80102b4f <kinit1>
80103871:	83 c4 10             	add    $0x10,%esp
  kvmalloc();      // kernel page table
80103874:	e8 c5 40 00 00       	call   8010793e <kvmalloc>
  mpinit_uefi();
80103879:	e8 6c 48 00 00       	call   801080ea <mpinit_uefi>
  lapicinit();     // interrupt controller
8010387e:	e8 3c f6 ff ff       	call   80102ebf <lapicinit>
  seginit();       // segment descriptors
80103883:	e8 4e 3b 00 00       	call   801073d6 <seginit>
  picinit();    // disable pic
80103888:	e8 9d 01 00 00       	call   80103a2a <picinit>
  ioapicinit();    // another interrupt controller
8010388d:	e8 d8 f1 ff ff       	call   80102a6a <ioapicinit>
  consoleinit();   // console hardware
80103892:	e8 68 d2 ff ff       	call   80100aff <consoleinit>
  uartinit();      // serial port
80103897:	e8 d3 2e 00 00       	call   8010676f <uartinit>
  pinit();         // process table
8010389c:	e8 c2 05 00 00       	call   80103e63 <pinit>
  tvinit();        // trap vectors
801038a1:	e8 0f 2a 00 00       	call   801062b5 <tvinit>
  binit();         // buffer cache
801038a6:	e8 bb c7 ff ff       	call   80100066 <binit>
  fileinit();      // file table
801038ab:	e8 0f d7 ff ff       	call   80100fbf <fileinit>
  ideinit();       // disk 
801038b0:	e8 6e ed ff ff       	call   80102623 <ideinit>
  startothers();   // start other processors
801038b5:	e8 8a 00 00 00       	call   80103944 <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
801038ba:	83 ec 08             	sub    $0x8,%esp
801038bd:	68 00 00 00 a0       	push   $0xa0000000
801038c2:	68 00 00 40 80       	push   $0x80400000
801038c7:	e8 bc f2 ff ff       	call   80102b88 <kinit2>
801038cc:	83 c4 10             	add    $0x10,%esp
  pci_init();
801038cf:	e8 a9 4c 00 00       	call   8010857d <pci_init>
  arp_scan();
801038d4:	e8 e0 59 00 00       	call   801092b9 <arp_scan>
  //i8254_recv();
  userinit();      // first user process
801038d9:	e8 66 07 00 00       	call   80104044 <userinit>

  mpmain();        // finish this processor's setup
801038de:	e8 1a 00 00 00       	call   801038fd <mpmain>

801038e3 <mpenter>:
}

// Other CPUs jump here from entryother.S.
static void
mpenter(void)
{
801038e3:	55                   	push   %ebp
801038e4:	89 e5                	mov    %esp,%ebp
801038e6:	83 ec 08             	sub    $0x8,%esp
  switchkvm();
801038e9:	e8 68 40 00 00       	call   80107956 <switchkvm>
  seginit();
801038ee:	e8 e3 3a 00 00       	call   801073d6 <seginit>
  lapicinit();
801038f3:	e8 c7 f5 ff ff       	call   80102ebf <lapicinit>
  mpmain();
801038f8:	e8 00 00 00 00       	call   801038fd <mpmain>

801038fd <mpmain>:
}

// Common CPU setup code.
static void
mpmain(void)
{
801038fd:	55                   	push   %ebp
801038fe:	89 e5                	mov    %esp,%ebp
80103900:	53                   	push   %ebx
80103901:	83 ec 04             	sub    $0x4,%esp
  cprintf("cpu%d: starting %d\n", cpuid(), cpuid());
80103904:	e8 78 05 00 00       	call   80103e81 <cpuid>
80103909:	89 c3                	mov    %eax,%ebx
8010390b:	e8 71 05 00 00       	call   80103e81 <cpuid>
80103910:	83 ec 04             	sub    $0x4,%esp
80103913:	53                   	push   %ebx
80103914:	50                   	push   %eax
80103915:	68 59 a7 10 80       	push   $0x8010a759
8010391a:	e8 d5 ca ff ff       	call   801003f4 <cprintf>
8010391f:	83 c4 10             	add    $0x10,%esp
  idtinit();       // load idt register
80103922:	e8 04 2b 00 00       	call   8010642b <idtinit>
  xchg(&(mycpu()->started), 1); // tell startothers() we're up
80103927:	e8 70 05 00 00       	call   80103e9c <mycpu>
8010392c:	05 a0 00 00 00       	add    $0xa0,%eax
80103931:	83 ec 08             	sub    $0x8,%esp
80103934:	6a 01                	push   $0x1
80103936:	50                   	push   %eax
80103937:	e8 f3 fe ff ff       	call   8010382f <xchg>
8010393c:	83 c4 10             	add    $0x10,%esp
  scheduler();     // start running processes
8010393f:	e8 91 0c 00 00       	call   801045d5 <scheduler>

80103944 <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
80103944:	55                   	push   %ebp
80103945:	89 e5                	mov    %esp,%ebp
80103947:	83 ec 18             	sub    $0x18,%esp
  char *stack;

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = P2V(0x7000);
8010394a:	c7 45 f0 00 70 00 80 	movl   $0x80007000,-0x10(%ebp)
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
80103951:	b8 8a 00 00 00       	mov    $0x8a,%eax
80103956:	83 ec 04             	sub    $0x4,%esp
80103959:	50                   	push   %eax
8010395a:	68 18 f5 10 80       	push   $0x8010f518
8010395f:	ff 75 f0             	push   -0x10(%ebp)
80103962:	e8 bb 15 00 00       	call   80104f22 <memmove>
80103967:	83 c4 10             	add    $0x10,%esp

  for(c = cpus; c < cpus+ncpu; c++){
8010396a:	c7 45 f4 c0 9b 11 80 	movl   $0x80119bc0,-0xc(%ebp)
80103971:	eb 79                	jmp    801039ec <startothers+0xa8>
    if(c == mycpu()){  // We've started already.
80103973:	e8 24 05 00 00       	call   80103e9c <mycpu>
80103978:	39 45 f4             	cmp    %eax,-0xc(%ebp)
8010397b:	74 67                	je     801039e4 <startothers+0xa0>
      continue;
    }
    // Tell entryother.S what stack to use, where to enter, and what
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
8010397d:	e8 02 f3 ff ff       	call   80102c84 <kalloc>
80103982:	89 45 ec             	mov    %eax,-0x14(%ebp)
    *(void**)(code-4) = stack + KSTACKSIZE;
80103985:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103988:	83 e8 04             	sub    $0x4,%eax
8010398b:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010398e:	81 c2 00 10 00 00    	add    $0x1000,%edx
80103994:	89 10                	mov    %edx,(%eax)
    *(void**)(code-8) = mpenter;
80103996:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103999:	83 e8 08             	sub    $0x8,%eax
8010399c:	c7 00 e3 38 10 80    	movl   $0x801038e3,(%eax)
    *(int**)(code-12) = (void *) V2P(entrypgdir);
801039a2:	b8 00 e0 10 80       	mov    $0x8010e000,%eax
801039a7:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
801039ad:	8b 45 f0             	mov    -0x10(%ebp),%eax
801039b0:	83 e8 0c             	sub    $0xc,%eax
801039b3:	89 10                	mov    %edx,(%eax)

    lapicstartap(c->apicid, V2P(code));
801039b5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801039b8:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
801039be:	8b 45 f4             	mov    -0xc(%ebp),%eax
801039c1:	0f b6 00             	movzbl (%eax),%eax
801039c4:	0f b6 c0             	movzbl %al,%eax
801039c7:	83 ec 08             	sub    $0x8,%esp
801039ca:	52                   	push   %edx
801039cb:	50                   	push   %eax
801039cc:	e8 50 f6 ff ff       	call   80103021 <lapicstartap>
801039d1:	83 c4 10             	add    $0x10,%esp

    // wait for cpu to finish mpmain()
    while(c->started == 0)
801039d4:	90                   	nop
801039d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801039d8:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
801039de:	85 c0                	test   %eax,%eax
801039e0:	74 f3                	je     801039d5 <startothers+0x91>
801039e2:	eb 01                	jmp    801039e5 <startothers+0xa1>
      continue;
801039e4:	90                   	nop
  for(c = cpus; c < cpus+ncpu; c++){
801039e5:	81 45 f4 b0 00 00 00 	addl   $0xb0,-0xc(%ebp)
801039ec:	a1 80 9e 11 80       	mov    0x80119e80,%eax
801039f1:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
801039f7:	05 c0 9b 11 80       	add    $0x80119bc0,%eax
801039fc:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801039ff:	0f 82 6e ff ff ff    	jb     80103973 <startothers+0x2f>
      ;
  }
}
80103a05:	90                   	nop
80103a06:	90                   	nop
80103a07:	c9                   	leave  
80103a08:	c3                   	ret    

80103a09 <outb>:
{
80103a09:	55                   	push   %ebp
80103a0a:	89 e5                	mov    %esp,%ebp
80103a0c:	83 ec 08             	sub    $0x8,%esp
80103a0f:	8b 45 08             	mov    0x8(%ebp),%eax
80103a12:	8b 55 0c             	mov    0xc(%ebp),%edx
80103a15:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80103a19:	89 d0                	mov    %edx,%eax
80103a1b:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103a1e:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80103a22:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80103a26:	ee                   	out    %al,(%dx)
}
80103a27:	90                   	nop
80103a28:	c9                   	leave  
80103a29:	c3                   	ret    

80103a2a <picinit>:
#define IO_PIC2         0xA0    // Slave (IRQs 8-15)

// Don't use the 8259A interrupt controllers.  Xv6 assumes SMP hardware.
void
picinit(void)
{
80103a2a:	55                   	push   %ebp
80103a2b:	89 e5                	mov    %esp,%ebp
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
80103a2d:	68 ff 00 00 00       	push   $0xff
80103a32:	6a 21                	push   $0x21
80103a34:	e8 d0 ff ff ff       	call   80103a09 <outb>
80103a39:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, 0xFF);
80103a3c:	68 ff 00 00 00       	push   $0xff
80103a41:	68 a1 00 00 00       	push   $0xa1
80103a46:	e8 be ff ff ff       	call   80103a09 <outb>
80103a4b:	83 c4 08             	add    $0x8,%esp
}
80103a4e:	90                   	nop
80103a4f:	c9                   	leave  
80103a50:	c3                   	ret    

80103a51 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
80103a51:	55                   	push   %ebp
80103a52:	89 e5                	mov    %esp,%ebp
80103a54:	83 ec 18             	sub    $0x18,%esp
  struct pipe *p;

  p = 0;
80103a57:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  *f0 = *f1 = 0;
80103a5e:	8b 45 0c             	mov    0xc(%ebp),%eax
80103a61:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
80103a67:	8b 45 0c             	mov    0xc(%ebp),%eax
80103a6a:	8b 10                	mov    (%eax),%edx
80103a6c:	8b 45 08             	mov    0x8(%ebp),%eax
80103a6f:	89 10                	mov    %edx,(%eax)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
80103a71:	e8 67 d5 ff ff       	call   80100fdd <filealloc>
80103a76:	8b 55 08             	mov    0x8(%ebp),%edx
80103a79:	89 02                	mov    %eax,(%edx)
80103a7b:	8b 45 08             	mov    0x8(%ebp),%eax
80103a7e:	8b 00                	mov    (%eax),%eax
80103a80:	85 c0                	test   %eax,%eax
80103a82:	0f 84 c8 00 00 00    	je     80103b50 <pipealloc+0xff>
80103a88:	e8 50 d5 ff ff       	call   80100fdd <filealloc>
80103a8d:	8b 55 0c             	mov    0xc(%ebp),%edx
80103a90:	89 02                	mov    %eax,(%edx)
80103a92:	8b 45 0c             	mov    0xc(%ebp),%eax
80103a95:	8b 00                	mov    (%eax),%eax
80103a97:	85 c0                	test   %eax,%eax
80103a99:	0f 84 b1 00 00 00    	je     80103b50 <pipealloc+0xff>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
80103a9f:	e8 e0 f1 ff ff       	call   80102c84 <kalloc>
80103aa4:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103aa7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103aab:	0f 84 a2 00 00 00    	je     80103b53 <pipealloc+0x102>
    goto bad;
  p->readopen = 1;
80103ab1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ab4:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
80103abb:	00 00 00 
  p->writeopen = 1;
80103abe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ac1:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
80103ac8:	00 00 00 
  p->nwrite = 0;
80103acb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ace:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
80103ad5:	00 00 00 
  p->nread = 0;
80103ad8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103adb:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
80103ae2:	00 00 00 
  initlock(&p->lock, "pipe");
80103ae5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ae8:	83 ec 08             	sub    $0x8,%esp
80103aeb:	68 6d a7 10 80       	push   $0x8010a76d
80103af0:	50                   	push   %eax
80103af1:	e8 d5 10 00 00       	call   80104bcb <initlock>
80103af6:	83 c4 10             	add    $0x10,%esp
  (*f0)->type = FD_PIPE;
80103af9:	8b 45 08             	mov    0x8(%ebp),%eax
80103afc:	8b 00                	mov    (%eax),%eax
80103afe:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
80103b04:	8b 45 08             	mov    0x8(%ebp),%eax
80103b07:	8b 00                	mov    (%eax),%eax
80103b09:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
80103b0d:	8b 45 08             	mov    0x8(%ebp),%eax
80103b10:	8b 00                	mov    (%eax),%eax
80103b12:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
80103b16:	8b 45 08             	mov    0x8(%ebp),%eax
80103b19:	8b 00                	mov    (%eax),%eax
80103b1b:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103b1e:	89 50 0c             	mov    %edx,0xc(%eax)
  (*f1)->type = FD_PIPE;
80103b21:	8b 45 0c             	mov    0xc(%ebp),%eax
80103b24:	8b 00                	mov    (%eax),%eax
80103b26:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
80103b2c:	8b 45 0c             	mov    0xc(%ebp),%eax
80103b2f:	8b 00                	mov    (%eax),%eax
80103b31:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
80103b35:	8b 45 0c             	mov    0xc(%ebp),%eax
80103b38:	8b 00                	mov    (%eax),%eax
80103b3a:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
80103b3e:	8b 45 0c             	mov    0xc(%ebp),%eax
80103b41:	8b 00                	mov    (%eax),%eax
80103b43:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103b46:	89 50 0c             	mov    %edx,0xc(%eax)
  return 0;
80103b49:	b8 00 00 00 00       	mov    $0x0,%eax
80103b4e:	eb 51                	jmp    80103ba1 <pipealloc+0x150>
    goto bad;
80103b50:	90                   	nop
80103b51:	eb 01                	jmp    80103b54 <pipealloc+0x103>
    goto bad;
80103b53:	90                   	nop

//PAGEBREAK: 20
 bad:
  if(p)
80103b54:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103b58:	74 0e                	je     80103b68 <pipealloc+0x117>
    kfree((char*)p);
80103b5a:	83 ec 0c             	sub    $0xc,%esp
80103b5d:	ff 75 f4             	push   -0xc(%ebp)
80103b60:	e8 85 f0 ff ff       	call   80102bea <kfree>
80103b65:	83 c4 10             	add    $0x10,%esp
  if(*f0)
80103b68:	8b 45 08             	mov    0x8(%ebp),%eax
80103b6b:	8b 00                	mov    (%eax),%eax
80103b6d:	85 c0                	test   %eax,%eax
80103b6f:	74 11                	je     80103b82 <pipealloc+0x131>
    fileclose(*f0);
80103b71:	8b 45 08             	mov    0x8(%ebp),%eax
80103b74:	8b 00                	mov    (%eax),%eax
80103b76:	83 ec 0c             	sub    $0xc,%esp
80103b79:	50                   	push   %eax
80103b7a:	e8 1c d5 ff ff       	call   8010109b <fileclose>
80103b7f:	83 c4 10             	add    $0x10,%esp
  if(*f1)
80103b82:	8b 45 0c             	mov    0xc(%ebp),%eax
80103b85:	8b 00                	mov    (%eax),%eax
80103b87:	85 c0                	test   %eax,%eax
80103b89:	74 11                	je     80103b9c <pipealloc+0x14b>
    fileclose(*f1);
80103b8b:	8b 45 0c             	mov    0xc(%ebp),%eax
80103b8e:	8b 00                	mov    (%eax),%eax
80103b90:	83 ec 0c             	sub    $0xc,%esp
80103b93:	50                   	push   %eax
80103b94:	e8 02 d5 ff ff       	call   8010109b <fileclose>
80103b99:	83 c4 10             	add    $0x10,%esp
  return -1;
80103b9c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80103ba1:	c9                   	leave  
80103ba2:	c3                   	ret    

80103ba3 <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
80103ba3:	55                   	push   %ebp
80103ba4:	89 e5                	mov    %esp,%ebp
80103ba6:	83 ec 08             	sub    $0x8,%esp
  acquire(&p->lock);
80103ba9:	8b 45 08             	mov    0x8(%ebp),%eax
80103bac:	83 ec 0c             	sub    $0xc,%esp
80103baf:	50                   	push   %eax
80103bb0:	e8 38 10 00 00       	call   80104bed <acquire>
80103bb5:	83 c4 10             	add    $0x10,%esp
  if(writable){
80103bb8:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80103bbc:	74 23                	je     80103be1 <pipeclose+0x3e>
    p->writeopen = 0;
80103bbe:	8b 45 08             	mov    0x8(%ebp),%eax
80103bc1:	c7 80 40 02 00 00 00 	movl   $0x0,0x240(%eax)
80103bc8:	00 00 00 
    wakeup(&p->nread);
80103bcb:	8b 45 08             	mov    0x8(%ebp),%eax
80103bce:	05 34 02 00 00       	add    $0x234,%eax
80103bd3:	83 ec 0c             	sub    $0xc,%esp
80103bd6:	50                   	push   %eax
80103bd7:	e8 d7 0c 00 00       	call   801048b3 <wakeup>
80103bdc:	83 c4 10             	add    $0x10,%esp
80103bdf:	eb 21                	jmp    80103c02 <pipeclose+0x5f>
  } else {
    p->readopen = 0;
80103be1:	8b 45 08             	mov    0x8(%ebp),%eax
80103be4:	c7 80 3c 02 00 00 00 	movl   $0x0,0x23c(%eax)
80103beb:	00 00 00 
    wakeup(&p->nwrite);
80103bee:	8b 45 08             	mov    0x8(%ebp),%eax
80103bf1:	05 38 02 00 00       	add    $0x238,%eax
80103bf6:	83 ec 0c             	sub    $0xc,%esp
80103bf9:	50                   	push   %eax
80103bfa:	e8 b4 0c 00 00       	call   801048b3 <wakeup>
80103bff:	83 c4 10             	add    $0x10,%esp
  }
  if(p->readopen == 0 && p->writeopen == 0){
80103c02:	8b 45 08             	mov    0x8(%ebp),%eax
80103c05:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
80103c0b:	85 c0                	test   %eax,%eax
80103c0d:	75 2c                	jne    80103c3b <pipeclose+0x98>
80103c0f:	8b 45 08             	mov    0x8(%ebp),%eax
80103c12:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
80103c18:	85 c0                	test   %eax,%eax
80103c1a:	75 1f                	jne    80103c3b <pipeclose+0x98>
    release(&p->lock);
80103c1c:	8b 45 08             	mov    0x8(%ebp),%eax
80103c1f:	83 ec 0c             	sub    $0xc,%esp
80103c22:	50                   	push   %eax
80103c23:	e8 33 10 00 00       	call   80104c5b <release>
80103c28:	83 c4 10             	add    $0x10,%esp
    kfree((char*)p);
80103c2b:	83 ec 0c             	sub    $0xc,%esp
80103c2e:	ff 75 08             	push   0x8(%ebp)
80103c31:	e8 b4 ef ff ff       	call   80102bea <kfree>
80103c36:	83 c4 10             	add    $0x10,%esp
80103c39:	eb 10                	jmp    80103c4b <pipeclose+0xa8>
  } else
    release(&p->lock);
80103c3b:	8b 45 08             	mov    0x8(%ebp),%eax
80103c3e:	83 ec 0c             	sub    $0xc,%esp
80103c41:	50                   	push   %eax
80103c42:	e8 14 10 00 00       	call   80104c5b <release>
80103c47:	83 c4 10             	add    $0x10,%esp
}
80103c4a:	90                   	nop
80103c4b:	90                   	nop
80103c4c:	c9                   	leave  
80103c4d:	c3                   	ret    

80103c4e <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
80103c4e:	55                   	push   %ebp
80103c4f:	89 e5                	mov    %esp,%ebp
80103c51:	53                   	push   %ebx
80103c52:	83 ec 14             	sub    $0x14,%esp
  int i;

  acquire(&p->lock);
80103c55:	8b 45 08             	mov    0x8(%ebp),%eax
80103c58:	83 ec 0c             	sub    $0xc,%esp
80103c5b:	50                   	push   %eax
80103c5c:	e8 8c 0f 00 00       	call   80104bed <acquire>
80103c61:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++){
80103c64:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103c6b:	e9 ad 00 00 00       	jmp    80103d1d <pipewrite+0xcf>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
      if(p->readopen == 0 || myproc()->killed){
80103c70:	8b 45 08             	mov    0x8(%ebp),%eax
80103c73:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
80103c79:	85 c0                	test   %eax,%eax
80103c7b:	74 0c                	je     80103c89 <pipewrite+0x3b>
80103c7d:	e8 92 02 00 00       	call   80103f14 <myproc>
80103c82:	8b 40 24             	mov    0x24(%eax),%eax
80103c85:	85 c0                	test   %eax,%eax
80103c87:	74 19                	je     80103ca2 <pipewrite+0x54>
        release(&p->lock);
80103c89:	8b 45 08             	mov    0x8(%ebp),%eax
80103c8c:	83 ec 0c             	sub    $0xc,%esp
80103c8f:	50                   	push   %eax
80103c90:	e8 c6 0f 00 00       	call   80104c5b <release>
80103c95:	83 c4 10             	add    $0x10,%esp
        return -1;
80103c98:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103c9d:	e9 a9 00 00 00       	jmp    80103d4b <pipewrite+0xfd>
      }
      wakeup(&p->nread);
80103ca2:	8b 45 08             	mov    0x8(%ebp),%eax
80103ca5:	05 34 02 00 00       	add    $0x234,%eax
80103caa:	83 ec 0c             	sub    $0xc,%esp
80103cad:	50                   	push   %eax
80103cae:	e8 00 0c 00 00       	call   801048b3 <wakeup>
80103cb3:	83 c4 10             	add    $0x10,%esp
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
80103cb6:	8b 45 08             	mov    0x8(%ebp),%eax
80103cb9:	8b 55 08             	mov    0x8(%ebp),%edx
80103cbc:	81 c2 38 02 00 00    	add    $0x238,%edx
80103cc2:	83 ec 08             	sub    $0x8,%esp
80103cc5:	50                   	push   %eax
80103cc6:	52                   	push   %edx
80103cc7:	e8 fd 0a 00 00       	call   801047c9 <sleep>
80103ccc:	83 c4 10             	add    $0x10,%esp
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
80103ccf:	8b 45 08             	mov    0x8(%ebp),%eax
80103cd2:	8b 90 38 02 00 00    	mov    0x238(%eax),%edx
80103cd8:	8b 45 08             	mov    0x8(%ebp),%eax
80103cdb:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
80103ce1:	05 00 02 00 00       	add    $0x200,%eax
80103ce6:	39 c2                	cmp    %eax,%edx
80103ce8:	74 86                	je     80103c70 <pipewrite+0x22>
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
80103cea:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103ced:	8b 45 0c             	mov    0xc(%ebp),%eax
80103cf0:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80103cf3:	8b 45 08             	mov    0x8(%ebp),%eax
80103cf6:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80103cfc:	8d 48 01             	lea    0x1(%eax),%ecx
80103cff:	8b 55 08             	mov    0x8(%ebp),%edx
80103d02:	89 8a 38 02 00 00    	mov    %ecx,0x238(%edx)
80103d08:	25 ff 01 00 00       	and    $0x1ff,%eax
80103d0d:	89 c1                	mov    %eax,%ecx
80103d0f:	0f b6 13             	movzbl (%ebx),%edx
80103d12:	8b 45 08             	mov    0x8(%ebp),%eax
80103d15:	88 54 08 34          	mov    %dl,0x34(%eax,%ecx,1)
  for(i = 0; i < n; i++){
80103d19:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103d1d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d20:	3b 45 10             	cmp    0x10(%ebp),%eax
80103d23:	7c aa                	jl     80103ccf <pipewrite+0x81>
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
80103d25:	8b 45 08             	mov    0x8(%ebp),%eax
80103d28:	05 34 02 00 00       	add    $0x234,%eax
80103d2d:	83 ec 0c             	sub    $0xc,%esp
80103d30:	50                   	push   %eax
80103d31:	e8 7d 0b 00 00       	call   801048b3 <wakeup>
80103d36:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
80103d39:	8b 45 08             	mov    0x8(%ebp),%eax
80103d3c:	83 ec 0c             	sub    $0xc,%esp
80103d3f:	50                   	push   %eax
80103d40:	e8 16 0f 00 00       	call   80104c5b <release>
80103d45:	83 c4 10             	add    $0x10,%esp
  return n;
80103d48:	8b 45 10             	mov    0x10(%ebp),%eax
}
80103d4b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103d4e:	c9                   	leave  
80103d4f:	c3                   	ret    

80103d50 <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
80103d50:	55                   	push   %ebp
80103d51:	89 e5                	mov    %esp,%ebp
80103d53:	83 ec 18             	sub    $0x18,%esp
  int i;

  acquire(&p->lock);
80103d56:	8b 45 08             	mov    0x8(%ebp),%eax
80103d59:	83 ec 0c             	sub    $0xc,%esp
80103d5c:	50                   	push   %eax
80103d5d:	e8 8b 0e 00 00       	call   80104bed <acquire>
80103d62:	83 c4 10             	add    $0x10,%esp
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80103d65:	eb 3e                	jmp    80103da5 <piperead+0x55>
    if(myproc()->killed){
80103d67:	e8 a8 01 00 00       	call   80103f14 <myproc>
80103d6c:	8b 40 24             	mov    0x24(%eax),%eax
80103d6f:	85 c0                	test   %eax,%eax
80103d71:	74 19                	je     80103d8c <piperead+0x3c>
      release(&p->lock);
80103d73:	8b 45 08             	mov    0x8(%ebp),%eax
80103d76:	83 ec 0c             	sub    $0xc,%esp
80103d79:	50                   	push   %eax
80103d7a:	e8 dc 0e 00 00       	call   80104c5b <release>
80103d7f:	83 c4 10             	add    $0x10,%esp
      return -1;
80103d82:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103d87:	e9 be 00 00 00       	jmp    80103e4a <piperead+0xfa>
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
80103d8c:	8b 45 08             	mov    0x8(%ebp),%eax
80103d8f:	8b 55 08             	mov    0x8(%ebp),%edx
80103d92:	81 c2 34 02 00 00    	add    $0x234,%edx
80103d98:	83 ec 08             	sub    $0x8,%esp
80103d9b:	50                   	push   %eax
80103d9c:	52                   	push   %edx
80103d9d:	e8 27 0a 00 00       	call   801047c9 <sleep>
80103da2:	83 c4 10             	add    $0x10,%esp
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80103da5:	8b 45 08             	mov    0x8(%ebp),%eax
80103da8:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
80103dae:	8b 45 08             	mov    0x8(%ebp),%eax
80103db1:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80103db7:	39 c2                	cmp    %eax,%edx
80103db9:	75 0d                	jne    80103dc8 <piperead+0x78>
80103dbb:	8b 45 08             	mov    0x8(%ebp),%eax
80103dbe:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
80103dc4:	85 c0                	test   %eax,%eax
80103dc6:	75 9f                	jne    80103d67 <piperead+0x17>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80103dc8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103dcf:	eb 48                	jmp    80103e19 <piperead+0xc9>
    if(p->nread == p->nwrite)
80103dd1:	8b 45 08             	mov    0x8(%ebp),%eax
80103dd4:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
80103dda:	8b 45 08             	mov    0x8(%ebp),%eax
80103ddd:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80103de3:	39 c2                	cmp    %eax,%edx
80103de5:	74 3c                	je     80103e23 <piperead+0xd3>
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
80103de7:	8b 45 08             	mov    0x8(%ebp),%eax
80103dea:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
80103df0:	8d 48 01             	lea    0x1(%eax),%ecx
80103df3:	8b 55 08             	mov    0x8(%ebp),%edx
80103df6:	89 8a 34 02 00 00    	mov    %ecx,0x234(%edx)
80103dfc:	25 ff 01 00 00       	and    $0x1ff,%eax
80103e01:	89 c1                	mov    %eax,%ecx
80103e03:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103e06:	8b 45 0c             	mov    0xc(%ebp),%eax
80103e09:	01 c2                	add    %eax,%edx
80103e0b:	8b 45 08             	mov    0x8(%ebp),%eax
80103e0e:	0f b6 44 08 34       	movzbl 0x34(%eax,%ecx,1),%eax
80103e13:	88 02                	mov    %al,(%edx)
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80103e15:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103e19:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e1c:	3b 45 10             	cmp    0x10(%ebp),%eax
80103e1f:	7c b0                	jl     80103dd1 <piperead+0x81>
80103e21:	eb 01                	jmp    80103e24 <piperead+0xd4>
      break;
80103e23:	90                   	nop
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
80103e24:	8b 45 08             	mov    0x8(%ebp),%eax
80103e27:	05 38 02 00 00       	add    $0x238,%eax
80103e2c:	83 ec 0c             	sub    $0xc,%esp
80103e2f:	50                   	push   %eax
80103e30:	e8 7e 0a 00 00       	call   801048b3 <wakeup>
80103e35:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
80103e38:	8b 45 08             	mov    0x8(%ebp),%eax
80103e3b:	83 ec 0c             	sub    $0xc,%esp
80103e3e:	50                   	push   %eax
80103e3f:	e8 17 0e 00 00       	call   80104c5b <release>
80103e44:	83 c4 10             	add    $0x10,%esp
  return i;
80103e47:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80103e4a:	c9                   	leave  
80103e4b:	c3                   	ret    

80103e4c <readeflags>:
{
80103e4c:	55                   	push   %ebp
80103e4d:	89 e5                	mov    %esp,%ebp
80103e4f:	83 ec 10             	sub    $0x10,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80103e52:	9c                   	pushf  
80103e53:	58                   	pop    %eax
80103e54:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80103e57:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80103e5a:	c9                   	leave  
80103e5b:	c3                   	ret    

80103e5c <sti>:
{
80103e5c:	55                   	push   %ebp
80103e5d:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80103e5f:	fb                   	sti    
}
80103e60:	90                   	nop
80103e61:	5d                   	pop    %ebp
80103e62:	c3                   	ret    

80103e63 <pinit>:

static void wakeup1(void *chan);

void
pinit(void)
{
80103e63:	55                   	push   %ebp
80103e64:	89 e5                	mov    %esp,%ebp
80103e66:	83 ec 08             	sub    $0x8,%esp
  initlock(&ptable.lock, "ptable");
80103e69:	83 ec 08             	sub    $0x8,%esp
80103e6c:	68 74 a7 10 80       	push   $0x8010a774
80103e71:	68 40 72 11 80       	push   $0x80117240
80103e76:	e8 50 0d 00 00       	call   80104bcb <initlock>
80103e7b:	83 c4 10             	add    $0x10,%esp
}
80103e7e:	90                   	nop
80103e7f:	c9                   	leave  
80103e80:	c3                   	ret    

80103e81 <cpuid>:

// Must be called with interrupts disabled
int
cpuid() {
80103e81:	55                   	push   %ebp
80103e82:	89 e5                	mov    %esp,%ebp
80103e84:	83 ec 08             	sub    $0x8,%esp
  return mycpu()-cpus;
80103e87:	e8 10 00 00 00       	call   80103e9c <mycpu>
80103e8c:	2d c0 9b 11 80       	sub    $0x80119bc0,%eax
80103e91:	c1 f8 04             	sar    $0x4,%eax
80103e94:	69 c0 a3 8b 2e ba    	imul   $0xba2e8ba3,%eax,%eax
}
80103e9a:	c9                   	leave  
80103e9b:	c3                   	ret    

80103e9c <mycpu>:

// Must be called with interrupts disabled to avoid the caller being
// rescheduled between reading lapicid and running through the loop.
struct cpu*
mycpu(void)
{
80103e9c:	55                   	push   %ebp
80103e9d:	89 e5                	mov    %esp,%ebp
80103e9f:	83 ec 18             	sub    $0x18,%esp
  int apicid, i;
  
  if(readeflags()&FL_IF){
80103ea2:	e8 a5 ff ff ff       	call   80103e4c <readeflags>
80103ea7:	25 00 02 00 00       	and    $0x200,%eax
80103eac:	85 c0                	test   %eax,%eax
80103eae:	74 0d                	je     80103ebd <mycpu+0x21>
    panic("mycpu called with interrupts enabled\n");
80103eb0:	83 ec 0c             	sub    $0xc,%esp
80103eb3:	68 7c a7 10 80       	push   $0x8010a77c
80103eb8:	e8 ec c6 ff ff       	call   801005a9 <panic>
  }

  apicid = lapicid();
80103ebd:	e8 1c f1 ff ff       	call   80102fde <lapicid>
80103ec2:	89 45 f0             	mov    %eax,-0x10(%ebp)
  // APIC IDs are not guaranteed to be contiguous. Maybe we should have
  // a reverse map, or reserve a register to store &cpus[i].
  for (i = 0; i < ncpu; ++i) {
80103ec5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103ecc:	eb 2d                	jmp    80103efb <mycpu+0x5f>
    if (cpus[i].apicid == apicid){
80103ece:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ed1:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
80103ed7:	05 c0 9b 11 80       	add    $0x80119bc0,%eax
80103edc:	0f b6 00             	movzbl (%eax),%eax
80103edf:	0f b6 c0             	movzbl %al,%eax
80103ee2:	39 45 f0             	cmp    %eax,-0x10(%ebp)
80103ee5:	75 10                	jne    80103ef7 <mycpu+0x5b>
      return &cpus[i];
80103ee7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103eea:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
80103ef0:	05 c0 9b 11 80       	add    $0x80119bc0,%eax
80103ef5:	eb 1b                	jmp    80103f12 <mycpu+0x76>
  for (i = 0; i < ncpu; ++i) {
80103ef7:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103efb:	a1 80 9e 11 80       	mov    0x80119e80,%eax
80103f00:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103f03:	7c c9                	jl     80103ece <mycpu+0x32>
    }
  }
  panic("unknown apicid\n");
80103f05:	83 ec 0c             	sub    $0xc,%esp
80103f08:	68 a2 a7 10 80       	push   $0x8010a7a2
80103f0d:	e8 97 c6 ff ff       	call   801005a9 <panic>
}
80103f12:	c9                   	leave  
80103f13:	c3                   	ret    

80103f14 <myproc>:

// Disable interrupts so that we are not rescheduled
// while reading proc from the cpu structure
struct proc*
myproc(void) {
80103f14:	55                   	push   %ebp
80103f15:	89 e5                	mov    %esp,%ebp
80103f17:	83 ec 18             	sub    $0x18,%esp
  struct cpu *c;
  struct proc *p;
  pushcli();
80103f1a:	e8 39 0e 00 00       	call   80104d58 <pushcli>
  c = mycpu();
80103f1f:	e8 78 ff ff ff       	call   80103e9c <mycpu>
80103f24:	89 45 f4             	mov    %eax,-0xc(%ebp)
  p = c->proc;
80103f27:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f2a:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80103f30:	89 45 f0             	mov    %eax,-0x10(%ebp)
  popcli();
80103f33:	e8 6d 0e 00 00       	call   80104da5 <popcli>
  return p;
80103f38:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80103f3b:	c9                   	leave  
80103f3c:	c3                   	ret    

80103f3d <allocproc>:
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
80103f3d:	55                   	push   %ebp
80103f3e:	89 e5                	mov    %esp,%ebp
80103f40:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
80103f43:	83 ec 0c             	sub    $0xc,%esp
80103f46:	68 40 72 11 80       	push   $0x80117240
80103f4b:	e8 9d 0c 00 00       	call   80104bed <acquire>
80103f50:	83 c4 10             	add    $0x10,%esp

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80103f53:	c7 45 f4 74 72 11 80 	movl   $0x80117274,-0xc(%ebp)
80103f5a:	eb 11                	jmp    80103f6d <allocproc+0x30>
    if(p->state == UNUSED){
80103f5c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f5f:	8b 40 0c             	mov    0xc(%eax),%eax
80103f62:	85 c0                	test   %eax,%eax
80103f64:	74 2a                	je     80103f90 <allocproc+0x53>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80103f66:	81 45 f4 84 00 00 00 	addl   $0x84,-0xc(%ebp)
80103f6d:	81 7d f4 74 93 11 80 	cmpl   $0x80119374,-0xc(%ebp)
80103f74:	72 e6                	jb     80103f5c <allocproc+0x1f>
      goto found;
    }

  release(&ptable.lock);
80103f76:	83 ec 0c             	sub    $0xc,%esp
80103f79:	68 40 72 11 80       	push   $0x80117240
80103f7e:	e8 d8 0c 00 00       	call   80104c5b <release>
80103f83:	83 c4 10             	add    $0x10,%esp
  return 0;
80103f86:	b8 00 00 00 00       	mov    $0x0,%eax
80103f8b:	e9 b2 00 00 00       	jmp    80104042 <allocproc+0x105>
      goto found;
80103f90:	90                   	nop

found:
  p->state = EMBRYO;
80103f91:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f94:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
  p->pid = nextpid++;
80103f9b:	a1 00 f0 10 80       	mov    0x8010f000,%eax
80103fa0:	8d 50 01             	lea    0x1(%eax),%edx
80103fa3:	89 15 00 f0 10 80    	mov    %edx,0x8010f000
80103fa9:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103fac:	89 42 10             	mov    %eax,0x10(%edx)

  release(&ptable.lock);
80103faf:	83 ec 0c             	sub    $0xc,%esp
80103fb2:	68 40 72 11 80       	push   $0x80117240
80103fb7:	e8 9f 0c 00 00       	call   80104c5b <release>
80103fbc:	83 c4 10             	add    $0x10,%esp


  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
80103fbf:	e8 c0 ec ff ff       	call   80102c84 <kalloc>
80103fc4:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103fc7:	89 42 08             	mov    %eax,0x8(%edx)
80103fca:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103fcd:	8b 40 08             	mov    0x8(%eax),%eax
80103fd0:	85 c0                	test   %eax,%eax
80103fd2:	75 11                	jne    80103fe5 <allocproc+0xa8>
    p->state = UNUSED;
80103fd4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103fd7:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return 0;
80103fde:	b8 00 00 00 00       	mov    $0x0,%eax
80103fe3:	eb 5d                	jmp    80104042 <allocproc+0x105>
  }
  sp = p->kstack + KSTACKSIZE;
80103fe5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103fe8:	8b 40 08             	mov    0x8(%eax),%eax
80103feb:	05 00 10 00 00       	add    $0x1000,%eax
80103ff0:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // Leave room for trap frame.
  sp -= sizeof *p->tf;
80103ff3:	83 6d f0 4c          	subl   $0x4c,-0x10(%ebp)
  p->tf = (struct trapframe*)sp;
80103ff7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ffa:	8b 55 f0             	mov    -0x10(%ebp),%edx
80103ffd:	89 50 18             	mov    %edx,0x18(%eax)

  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
80104000:	83 6d f0 04          	subl   $0x4,-0x10(%ebp)
  *(uint*)sp = (uint)trapret;
80104004:	ba 6f 62 10 80       	mov    $0x8010626f,%edx
80104009:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010400c:	89 10                	mov    %edx,(%eax)

  sp -= sizeof *p->context;
8010400e:	83 6d f0 14          	subl   $0x14,-0x10(%ebp)
  p->context = (struct context*)sp;
80104012:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104015:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104018:	89 50 1c             	mov    %edx,0x1c(%eax)
  memset(p->context, 0, sizeof *p->context);
8010401b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010401e:	8b 40 1c             	mov    0x1c(%eax),%eax
80104021:	83 ec 04             	sub    $0x4,%esp
80104024:	6a 14                	push   $0x14
80104026:	6a 00                	push   $0x0
80104028:	50                   	push   %eax
80104029:	e8 35 0e 00 00       	call   80104e63 <memset>
8010402e:	83 c4 10             	add    $0x10,%esp
  p->context->eip = (uint)forkret;
80104031:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104034:	8b 40 1c             	mov    0x1c(%eax),%eax
80104037:	ba 83 47 10 80       	mov    $0x80104783,%edx
8010403c:	89 50 10             	mov    %edx,0x10(%eax)

  return p;
8010403f:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80104042:	c9                   	leave  
80104043:	c3                   	ret    

80104044 <userinit>:

//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
80104044:	55                   	push   %ebp
80104045:	89 e5                	mov    %esp,%ebp
80104047:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];

  p = allocproc();
8010404a:	e8 ee fe ff ff       	call   80103f3d <allocproc>
8010404f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  initproc = p;
80104052:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104055:	a3 74 93 11 80       	mov    %eax,0x80119374
  if((p->pgdir = setupkvm()) == 0){
8010405a:	e8 f3 37 00 00       	call   80107852 <setupkvm>
8010405f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104062:	89 42 04             	mov    %eax,0x4(%edx)
80104065:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104068:	8b 40 04             	mov    0x4(%eax),%eax
8010406b:	85 c0                	test   %eax,%eax
8010406d:	75 0d                	jne    8010407c <userinit+0x38>
    panic("userinit: out of memory?");
8010406f:	83 ec 0c             	sub    $0xc,%esp
80104072:	68 b2 a7 10 80       	push   $0x8010a7b2
80104077:	e8 2d c5 ff ff       	call   801005a9 <panic>
  }
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
8010407c:	ba 2c 00 00 00       	mov    $0x2c,%edx
80104081:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104084:	8b 40 04             	mov    0x4(%eax),%eax
80104087:	83 ec 04             	sub    $0x4,%esp
8010408a:	52                   	push   %edx
8010408b:	68 ec f4 10 80       	push   $0x8010f4ec
80104090:	50                   	push   %eax
80104091:	e8 78 3a 00 00       	call   80107b0e <inituvm>
80104096:	83 c4 10             	add    $0x10,%esp
  p->sz = PGSIZE;
80104099:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010409c:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  memset(p->tf, 0, sizeof(*p->tf));
801040a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040a5:	8b 40 18             	mov    0x18(%eax),%eax
801040a8:	83 ec 04             	sub    $0x4,%esp
801040ab:	6a 4c                	push   $0x4c
801040ad:	6a 00                	push   $0x0
801040af:	50                   	push   %eax
801040b0:	e8 ae 0d 00 00       	call   80104e63 <memset>
801040b5:	83 c4 10             	add    $0x10,%esp
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
801040b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040bb:	8b 40 18             	mov    0x18(%eax),%eax
801040be:	66 c7 40 3c 1b 00    	movw   $0x1b,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
801040c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040c7:	8b 40 18             	mov    0x18(%eax),%eax
801040ca:	66 c7 40 2c 23 00    	movw   $0x23,0x2c(%eax)
  p->tf->es = p->tf->ds;
801040d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040d3:	8b 50 18             	mov    0x18(%eax),%edx
801040d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040d9:	8b 40 18             	mov    0x18(%eax),%eax
801040dc:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
801040e0:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
801040e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040e7:	8b 50 18             	mov    0x18(%eax),%edx
801040ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040ed:	8b 40 18             	mov    0x18(%eax),%eax
801040f0:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
801040f4:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
801040f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040fb:	8b 40 18             	mov    0x18(%eax),%eax
801040fe:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
80104105:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104108:	8b 40 18             	mov    0x18(%eax),%eax
8010410b:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
80104112:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104115:	8b 40 18             	mov    0x18(%eax),%eax
80104118:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

  safestrcpy(p->name, "initcode", sizeof(p->name));
8010411f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104122:	83 c0 6c             	add    $0x6c,%eax
80104125:	83 ec 04             	sub    $0x4,%esp
80104128:	6a 10                	push   $0x10
8010412a:	68 cb a7 10 80       	push   $0x8010a7cb
8010412f:	50                   	push   %eax
80104130:	e8 31 0f 00 00       	call   80105066 <safestrcpy>
80104135:	83 c4 10             	add    $0x10,%esp
  p->cwd = namei("/");
80104138:	83 ec 0c             	sub    $0xc,%esp
8010413b:	68 d4 a7 10 80       	push   $0x8010a7d4
80104140:	e8 d8 e3 ff ff       	call   8010251d <namei>
80104145:	83 c4 10             	add    $0x10,%esp
80104148:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010414b:	89 42 68             	mov    %eax,0x68(%edx)

  // this assignment to p->state lets other cores
  // run this process. the acquire forces the above
  // writes to be visible, and the lock is also needed
  // because the assignment might not be atomic.
  acquire(&ptable.lock);
8010414e:	83 ec 0c             	sub    $0xc,%esp
80104151:	68 40 72 11 80       	push   $0x80117240
80104156:	e8 92 0a 00 00       	call   80104bed <acquire>
8010415b:	83 c4 10             	add    $0x10,%esp

  p->state = RUNNABLE;
8010415e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104161:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  release(&ptable.lock);
80104168:	83 ec 0c             	sub    $0xc,%esp
8010416b:	68 40 72 11 80       	push   $0x80117240
80104170:	e8 e6 0a 00 00       	call   80104c5b <release>
80104175:	83 c4 10             	add    $0x10,%esp
}
80104178:	90                   	nop
80104179:	c9                   	leave  
8010417a:	c3                   	ret    

8010417b <growproc>:

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
8010417b:	55                   	push   %ebp
8010417c:	89 e5                	mov    %esp,%ebp
8010417e:	83 ec 18             	sub    $0x18,%esp
  uint sz;
  struct proc *curproc = myproc();
80104181:	e8 8e fd ff ff       	call   80103f14 <myproc>
80104186:	89 45 f0             	mov    %eax,-0x10(%ebp)

  sz = curproc->sz;
80104189:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010418c:	8b 00                	mov    (%eax),%eax
8010418e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(n > 0){
80104191:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80104195:	7e 2e                	jle    801041c5 <growproc+0x4a>
    if((sz = allocuvm(curproc->pgdir, sz, sz + n)) == 0)
80104197:	8b 55 08             	mov    0x8(%ebp),%edx
8010419a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010419d:	01 c2                	add    %eax,%edx
8010419f:	8b 45 f0             	mov    -0x10(%ebp),%eax
801041a2:	8b 40 04             	mov    0x4(%eax),%eax
801041a5:	83 ec 04             	sub    $0x4,%esp
801041a8:	52                   	push   %edx
801041a9:	ff 75 f4             	push   -0xc(%ebp)
801041ac:	50                   	push   %eax
801041ad:	e8 99 3a 00 00       	call   80107c4b <allocuvm>
801041b2:	83 c4 10             	add    $0x10,%esp
801041b5:	89 45 f4             	mov    %eax,-0xc(%ebp)
801041b8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801041bc:	75 3b                	jne    801041f9 <growproc+0x7e>
      return -1;
801041be:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801041c3:	eb 4f                	jmp    80104214 <growproc+0x99>
  } else if(n < 0){
801041c5:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801041c9:	79 2e                	jns    801041f9 <growproc+0x7e>
    if((sz = deallocuvm(curproc->pgdir, sz, sz + n)) == 0)
801041cb:	8b 55 08             	mov    0x8(%ebp),%edx
801041ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041d1:	01 c2                	add    %eax,%edx
801041d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801041d6:	8b 40 04             	mov    0x4(%eax),%eax
801041d9:	83 ec 04             	sub    $0x4,%esp
801041dc:	52                   	push   %edx
801041dd:	ff 75 f4             	push   -0xc(%ebp)
801041e0:	50                   	push   %eax
801041e1:	e8 6a 3b 00 00       	call   80107d50 <deallocuvm>
801041e6:	83 c4 10             	add    $0x10,%esp
801041e9:	89 45 f4             	mov    %eax,-0xc(%ebp)
801041ec:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801041f0:	75 07                	jne    801041f9 <growproc+0x7e>
      return -1;
801041f2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801041f7:	eb 1b                	jmp    80104214 <growproc+0x99>
  }
  curproc->sz = sz;
801041f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801041fc:	8b 55 f4             	mov    -0xc(%ebp),%edx
801041ff:	89 10                	mov    %edx,(%eax)
  switchuvm(curproc);
80104201:	83 ec 0c             	sub    $0xc,%esp
80104204:	ff 75 f0             	push   -0x10(%ebp)
80104207:	e8 63 37 00 00       	call   8010796f <switchuvm>
8010420c:	83 c4 10             	add    $0x10,%esp
  return 0;
8010420f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104214:	c9                   	leave  
80104215:	c3                   	ret    

80104216 <fork>:
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
80104216:	55                   	push   %ebp
80104217:	89 e5                	mov    %esp,%ebp
80104219:	57                   	push   %edi
8010421a:	56                   	push   %esi
8010421b:	53                   	push   %ebx
8010421c:	83 ec 1c             	sub    $0x1c,%esp
  int i, pid;
  struct proc *np;
  struct proc *curproc = myproc();
8010421f:	e8 f0 fc ff ff       	call   80103f14 <myproc>
80104224:	89 45 e0             	mov    %eax,-0x20(%ebp)

  // Allocate process.
  if((np = allocproc()) == 0){
80104227:	e8 11 fd ff ff       	call   80103f3d <allocproc>
8010422c:	89 45 dc             	mov    %eax,-0x24(%ebp)
8010422f:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
80104233:	75 0a                	jne    8010423f <fork+0x29>
    return -1;
80104235:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010423a:	e9 48 01 00 00       	jmp    80104387 <fork+0x171>
  }

  // Copy process state from proc.
  if((np->pgdir = copyuvm(curproc->pgdir, curproc->sz)) == 0){
8010423f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104242:	8b 10                	mov    (%eax),%edx
80104244:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104247:	8b 40 04             	mov    0x4(%eax),%eax
8010424a:	83 ec 08             	sub    $0x8,%esp
8010424d:	52                   	push   %edx
8010424e:	50                   	push   %eax
8010424f:	e8 9a 3c 00 00       	call   80107eee <copyuvm>
80104254:	83 c4 10             	add    $0x10,%esp
80104257:	8b 55 dc             	mov    -0x24(%ebp),%edx
8010425a:	89 42 04             	mov    %eax,0x4(%edx)
8010425d:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104260:	8b 40 04             	mov    0x4(%eax),%eax
80104263:	85 c0                	test   %eax,%eax
80104265:	75 30                	jne    80104297 <fork+0x81>
    kfree(np->kstack);
80104267:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010426a:	8b 40 08             	mov    0x8(%eax),%eax
8010426d:	83 ec 0c             	sub    $0xc,%esp
80104270:	50                   	push   %eax
80104271:	e8 74 e9 ff ff       	call   80102bea <kfree>
80104276:	83 c4 10             	add    $0x10,%esp
    np->kstack = 0;
80104279:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010427c:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    np->state = UNUSED;
80104283:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104286:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return -1;
8010428d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104292:	e9 f0 00 00 00       	jmp    80104387 <fork+0x171>
  }
  np->sz = curproc->sz;
80104297:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010429a:	8b 10                	mov    (%eax),%edx
8010429c:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010429f:	89 10                	mov    %edx,(%eax)
  np->parent = curproc;
801042a1:	8b 45 dc             	mov    -0x24(%ebp),%eax
801042a4:	8b 55 e0             	mov    -0x20(%ebp),%edx
801042a7:	89 50 14             	mov    %edx,0x14(%eax)
  *np->tf = *curproc->tf;
801042aa:	8b 45 e0             	mov    -0x20(%ebp),%eax
801042ad:	8b 48 18             	mov    0x18(%eax),%ecx
801042b0:	8b 45 dc             	mov    -0x24(%ebp),%eax
801042b3:	8b 40 18             	mov    0x18(%eax),%eax
801042b6:	89 c2                	mov    %eax,%edx
801042b8:	89 cb                	mov    %ecx,%ebx
801042ba:	b8 13 00 00 00       	mov    $0x13,%eax
801042bf:	89 d7                	mov    %edx,%edi
801042c1:	89 de                	mov    %ebx,%esi
801042c3:	89 c1                	mov    %eax,%ecx
801042c5:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
801042c7:	8b 45 dc             	mov    -0x24(%ebp),%eax
801042ca:	8b 40 18             	mov    0x18(%eax),%eax
801042cd:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  for(i = 0; i < NOFILE; i++)
801042d4:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
801042db:	eb 3b                	jmp    80104318 <fork+0x102>
    if(curproc->ofile[i])
801042dd:	8b 45 e0             	mov    -0x20(%ebp),%eax
801042e0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801042e3:	83 c2 08             	add    $0x8,%edx
801042e6:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801042ea:	85 c0                	test   %eax,%eax
801042ec:	74 26                	je     80104314 <fork+0xfe>
      np->ofile[i] = filedup(curproc->ofile[i]);
801042ee:	8b 45 e0             	mov    -0x20(%ebp),%eax
801042f1:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801042f4:	83 c2 08             	add    $0x8,%edx
801042f7:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801042fb:	83 ec 0c             	sub    $0xc,%esp
801042fe:	50                   	push   %eax
801042ff:	e8 46 cd ff ff       	call   8010104a <filedup>
80104304:	83 c4 10             	add    $0x10,%esp
80104307:	8b 55 dc             	mov    -0x24(%ebp),%edx
8010430a:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
8010430d:	83 c1 08             	add    $0x8,%ecx
80104310:	89 44 8a 08          	mov    %eax,0x8(%edx,%ecx,4)
  for(i = 0; i < NOFILE; i++)
80104314:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80104318:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
8010431c:	7e bf                	jle    801042dd <fork+0xc7>
  np->cwd = idup(curproc->cwd);
8010431e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104321:	8b 40 68             	mov    0x68(%eax),%eax
80104324:	83 ec 0c             	sub    $0xc,%esp
80104327:	50                   	push   %eax
80104328:	e8 83 d6 ff ff       	call   801019b0 <idup>
8010432d:	83 c4 10             	add    $0x10,%esp
80104330:	8b 55 dc             	mov    -0x24(%ebp),%edx
80104333:	89 42 68             	mov    %eax,0x68(%edx)

  safestrcpy(np->name, curproc->name, sizeof(curproc->name));
80104336:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104339:	8d 50 6c             	lea    0x6c(%eax),%edx
8010433c:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010433f:	83 c0 6c             	add    $0x6c,%eax
80104342:	83 ec 04             	sub    $0x4,%esp
80104345:	6a 10                	push   $0x10
80104347:	52                   	push   %edx
80104348:	50                   	push   %eax
80104349:	e8 18 0d 00 00       	call   80105066 <safestrcpy>
8010434e:	83 c4 10             	add    $0x10,%esp

  pid = np->pid;
80104351:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104354:	8b 40 10             	mov    0x10(%eax),%eax
80104357:	89 45 d8             	mov    %eax,-0x28(%ebp)

  acquire(&ptable.lock);
8010435a:	83 ec 0c             	sub    $0xc,%esp
8010435d:	68 40 72 11 80       	push   $0x80117240
80104362:	e8 86 08 00 00       	call   80104bed <acquire>
80104367:	83 c4 10             	add    $0x10,%esp

  np->state = RUNNABLE;
8010436a:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010436d:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  release(&ptable.lock);
80104374:	83 ec 0c             	sub    $0xc,%esp
80104377:	68 40 72 11 80       	push   $0x80117240
8010437c:	e8 da 08 00 00       	call   80104c5b <release>
80104381:	83 c4 10             	add    $0x10,%esp

  return pid;
80104384:	8b 45 d8             	mov    -0x28(%ebp),%eax
}
80104387:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010438a:	5b                   	pop    %ebx
8010438b:	5e                   	pop    %esi
8010438c:	5f                   	pop    %edi
8010438d:	5d                   	pop    %ebp
8010438e:	c3                   	ret    

8010438f <exit>:
// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
8010438f:	55                   	push   %ebp
80104390:	89 e5                	mov    %esp,%ebp
80104392:	83 ec 18             	sub    $0x18,%esp
  struct proc *curproc = myproc();
80104395:	e8 7a fb ff ff       	call   80103f14 <myproc>
8010439a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct proc *p;
  int fd;

  if(curproc == initproc)
8010439d:	a1 74 93 11 80       	mov    0x80119374,%eax
801043a2:	39 45 ec             	cmp    %eax,-0x14(%ebp)
801043a5:	75 0d                	jne    801043b4 <exit+0x25>
    panic("init exiting");
801043a7:	83 ec 0c             	sub    $0xc,%esp
801043aa:	68 d6 a7 10 80       	push   $0x8010a7d6
801043af:	e8 f5 c1 ff ff       	call   801005a9 <panic>

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
801043b4:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801043bb:	eb 3f                	jmp    801043fc <exit+0x6d>
    if(curproc->ofile[fd]){
801043bd:	8b 45 ec             	mov    -0x14(%ebp),%eax
801043c0:	8b 55 f0             	mov    -0x10(%ebp),%edx
801043c3:	83 c2 08             	add    $0x8,%edx
801043c6:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801043ca:	85 c0                	test   %eax,%eax
801043cc:	74 2a                	je     801043f8 <exit+0x69>
      fileclose(curproc->ofile[fd]);
801043ce:	8b 45 ec             	mov    -0x14(%ebp),%eax
801043d1:	8b 55 f0             	mov    -0x10(%ebp),%edx
801043d4:	83 c2 08             	add    $0x8,%edx
801043d7:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801043db:	83 ec 0c             	sub    $0xc,%esp
801043de:	50                   	push   %eax
801043df:	e8 b7 cc ff ff       	call   8010109b <fileclose>
801043e4:	83 c4 10             	add    $0x10,%esp
      curproc->ofile[fd] = 0;
801043e7:	8b 45 ec             	mov    -0x14(%ebp),%eax
801043ea:	8b 55 f0             	mov    -0x10(%ebp),%edx
801043ed:	83 c2 08             	add    $0x8,%edx
801043f0:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
801043f7:	00 
  for(fd = 0; fd < NOFILE; fd++){
801043f8:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
801043fc:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
80104400:	7e bb                	jle    801043bd <exit+0x2e>
    }
  }

  begin_op();
80104402:	e8 19 f1 ff ff       	call   80103520 <begin_op>
  iput(curproc->cwd);
80104407:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010440a:	8b 40 68             	mov    0x68(%eax),%eax
8010440d:	83 ec 0c             	sub    $0xc,%esp
80104410:	50                   	push   %eax
80104411:	e8 35 d7 ff ff       	call   80101b4b <iput>
80104416:	83 c4 10             	add    $0x10,%esp
  end_op();
80104419:	e8 8e f1 ff ff       	call   801035ac <end_op>
  curproc->cwd = 0;
8010441e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104421:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquire(&ptable.lock);
80104428:	83 ec 0c             	sub    $0xc,%esp
8010442b:	68 40 72 11 80       	push   $0x80117240
80104430:	e8 b8 07 00 00       	call   80104bed <acquire>
80104435:	83 c4 10             	add    $0x10,%esp

  // Parent might be sleeping in wait().
  wakeup1(curproc->parent);
80104438:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010443b:	8b 40 14             	mov    0x14(%eax),%eax
8010443e:	83 ec 0c             	sub    $0xc,%esp
80104441:	50                   	push   %eax
80104442:	e8 29 04 00 00       	call   80104870 <wakeup1>
80104447:	83 c4 10             	add    $0x10,%esp

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010444a:	c7 45 f4 74 72 11 80 	movl   $0x80117274,-0xc(%ebp)
80104451:	eb 3a                	jmp    8010448d <exit+0xfe>
    if(p->parent == curproc){
80104453:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104456:	8b 40 14             	mov    0x14(%eax),%eax
80104459:	39 45 ec             	cmp    %eax,-0x14(%ebp)
8010445c:	75 28                	jne    80104486 <exit+0xf7>
      p->parent = initproc;
8010445e:	8b 15 74 93 11 80    	mov    0x80119374,%edx
80104464:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104467:	89 50 14             	mov    %edx,0x14(%eax)
      if(p->state == ZOMBIE)
8010446a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010446d:	8b 40 0c             	mov    0xc(%eax),%eax
80104470:	83 f8 05             	cmp    $0x5,%eax
80104473:	75 11                	jne    80104486 <exit+0xf7>
        wakeup1(initproc);
80104475:	a1 74 93 11 80       	mov    0x80119374,%eax
8010447a:	83 ec 0c             	sub    $0xc,%esp
8010447d:	50                   	push   %eax
8010447e:	e8 ed 03 00 00       	call   80104870 <wakeup1>
80104483:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104486:	81 45 f4 84 00 00 00 	addl   $0x84,-0xc(%ebp)
8010448d:	81 7d f4 74 93 11 80 	cmpl   $0x80119374,-0xc(%ebp)
80104494:	72 bd                	jb     80104453 <exit+0xc4>
    }
  }

  // Jump into the scheduler, never to return.
  curproc->state = ZOMBIE;
80104496:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104499:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  sched();
801044a0:	e8 eb 01 00 00       	call   80104690 <sched>
  panic("zombie exit");
801044a5:	83 ec 0c             	sub    $0xc,%esp
801044a8:	68 e3 a7 10 80       	push   $0x8010a7e3
801044ad:	e8 f7 c0 ff ff       	call   801005a9 <panic>

801044b2 <wait>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
801044b2:	55                   	push   %ebp
801044b3:	89 e5                	mov    %esp,%ebp
801044b5:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int havekids, pid;
  struct proc *curproc = myproc();
801044b8:	e8 57 fa ff ff       	call   80103f14 <myproc>
801044bd:	89 45 ec             	mov    %eax,-0x14(%ebp)
  
  acquire(&ptable.lock);
801044c0:	83 ec 0c             	sub    $0xc,%esp
801044c3:	68 40 72 11 80       	push   $0x80117240
801044c8:	e8 20 07 00 00       	call   80104bed <acquire>
801044cd:	83 c4 10             	add    $0x10,%esp
  for(;;){
    // Scan through table looking for exited children.
    havekids = 0;
801044d0:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801044d7:	c7 45 f4 74 72 11 80 	movl   $0x80117274,-0xc(%ebp)
801044de:	e9 a4 00 00 00       	jmp    80104587 <wait+0xd5>
      if(p->parent != curproc)
801044e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044e6:	8b 40 14             	mov    0x14(%eax),%eax
801044e9:	39 45 ec             	cmp    %eax,-0x14(%ebp)
801044ec:	0f 85 8d 00 00 00    	jne    8010457f <wait+0xcd>
        continue;
      havekids = 1;
801044f2:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
801044f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044fc:	8b 40 0c             	mov    0xc(%eax),%eax
801044ff:	83 f8 05             	cmp    $0x5,%eax
80104502:	75 7c                	jne    80104580 <wait+0xce>
        // Found one.
        pid = p->pid;
80104504:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104507:	8b 40 10             	mov    0x10(%eax),%eax
8010450a:	89 45 e8             	mov    %eax,-0x18(%ebp)
        kfree(p->kstack);
8010450d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104510:	8b 40 08             	mov    0x8(%eax),%eax
80104513:	83 ec 0c             	sub    $0xc,%esp
80104516:	50                   	push   %eax
80104517:	e8 ce e6 ff ff       	call   80102bea <kfree>
8010451c:	83 c4 10             	add    $0x10,%esp
        p->kstack = 0;
8010451f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104522:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
80104529:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010452c:	8b 40 04             	mov    0x4(%eax),%eax
8010452f:	83 ec 0c             	sub    $0xc,%esp
80104532:	50                   	push   %eax
80104533:	e8 dc 38 00 00       	call   80107e14 <freevm>
80104538:	83 c4 10             	add    $0x10,%esp
        p->pid = 0;
8010453b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010453e:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
80104545:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104548:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
8010454f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104552:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
80104556:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104559:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        p->state = UNUSED;
80104560:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104563:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        release(&ptable.lock);
8010456a:	83 ec 0c             	sub    $0xc,%esp
8010456d:	68 40 72 11 80       	push   $0x80117240
80104572:	e8 e4 06 00 00       	call   80104c5b <release>
80104577:	83 c4 10             	add    $0x10,%esp
        return pid;
8010457a:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010457d:	eb 54                	jmp    801045d3 <wait+0x121>
        continue;
8010457f:	90                   	nop
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104580:	81 45 f4 84 00 00 00 	addl   $0x84,-0xc(%ebp)
80104587:	81 7d f4 74 93 11 80 	cmpl   $0x80119374,-0xc(%ebp)
8010458e:	0f 82 4f ff ff ff    	jb     801044e3 <wait+0x31>
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || curproc->killed){
80104594:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104598:	74 0a                	je     801045a4 <wait+0xf2>
8010459a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010459d:	8b 40 24             	mov    0x24(%eax),%eax
801045a0:	85 c0                	test   %eax,%eax
801045a2:	74 17                	je     801045bb <wait+0x109>
      release(&ptable.lock);
801045a4:	83 ec 0c             	sub    $0xc,%esp
801045a7:	68 40 72 11 80       	push   $0x80117240
801045ac:	e8 aa 06 00 00       	call   80104c5b <release>
801045b1:	83 c4 10             	add    $0x10,%esp
      return -1;
801045b4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801045b9:	eb 18                	jmp    801045d3 <wait+0x121>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(curproc, &ptable.lock);  //DOC: wait-sleep
801045bb:	83 ec 08             	sub    $0x8,%esp
801045be:	68 40 72 11 80       	push   $0x80117240
801045c3:	ff 75 ec             	push   -0x14(%ebp)
801045c6:	e8 fe 01 00 00       	call   801047c9 <sleep>
801045cb:	83 c4 10             	add    $0x10,%esp
    havekids = 0;
801045ce:	e9 fd fe ff ff       	jmp    801044d0 <wait+0x1e>
  }
}
801045d3:	c9                   	leave  
801045d4:	c3                   	ret    

801045d5 <scheduler>:
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
801045d5:	55                   	push   %ebp
801045d6:	89 e5                	mov    %esp,%ebp
801045d8:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  struct cpu *c = mycpu();
801045db:	e8 bc f8 ff ff       	call   80103e9c <mycpu>
801045e0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  c->proc = 0;
801045e3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801045e6:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
801045ed:	00 00 00 
  
  for(;;){
    // Enable interrupts on this processor.
    sti();
801045f0:	e8 67 f8 ff ff       	call   80103e5c <sti>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
801045f5:	83 ec 0c             	sub    $0xc,%esp
801045f8:	68 40 72 11 80       	push   $0x80117240
801045fd:	e8 eb 05 00 00       	call   80104bed <acquire>
80104602:	83 c4 10             	add    $0x10,%esp
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104605:	c7 45 f4 74 72 11 80 	movl   $0x80117274,-0xc(%ebp)
8010460c:	eb 64                	jmp    80104672 <scheduler+0x9d>
      if(p->state != RUNNABLE)
8010460e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104611:	8b 40 0c             	mov    0xc(%eax),%eax
80104614:	83 f8 03             	cmp    $0x3,%eax
80104617:	75 51                	jne    8010466a <scheduler+0x95>
        continue;

      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      c->proc = p;
80104619:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010461c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010461f:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
      switchuvm(p);
80104625:	83 ec 0c             	sub    $0xc,%esp
80104628:	ff 75 f4             	push   -0xc(%ebp)
8010462b:	e8 3f 33 00 00       	call   8010796f <switchuvm>
80104630:	83 c4 10             	add    $0x10,%esp
      p->state = RUNNING;
80104633:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104636:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)

      swtch(&(c->scheduler), p->context);
8010463d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104640:	8b 40 1c             	mov    0x1c(%eax),%eax
80104643:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104646:	83 c2 04             	add    $0x4,%edx
80104649:	83 ec 08             	sub    $0x8,%esp
8010464c:	50                   	push   %eax
8010464d:	52                   	push   %edx
8010464e:	e8 85 0a 00 00       	call   801050d8 <swtch>
80104653:	83 c4 10             	add    $0x10,%esp
      switchkvm();
80104656:	e8 fb 32 00 00       	call   80107956 <switchkvm>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      c->proc = 0;
8010465b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010465e:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
80104665:	00 00 00 
80104668:	eb 01                	jmp    8010466b <scheduler+0x96>
        continue;
8010466a:	90                   	nop
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010466b:	81 45 f4 84 00 00 00 	addl   $0x84,-0xc(%ebp)
80104672:	81 7d f4 74 93 11 80 	cmpl   $0x80119374,-0xc(%ebp)
80104679:	72 93                	jb     8010460e <scheduler+0x39>
    }
    release(&ptable.lock);
8010467b:	83 ec 0c             	sub    $0xc,%esp
8010467e:	68 40 72 11 80       	push   $0x80117240
80104683:	e8 d3 05 00 00       	call   80104c5b <release>
80104688:	83 c4 10             	add    $0x10,%esp
    sti();
8010468b:	e9 60 ff ff ff       	jmp    801045f0 <scheduler+0x1b>

80104690 <sched>:
// be proc->intena and proc->ncli, but that would
// break in the few places where a lock is held but
// there's no process.
void
sched(void)
{
80104690:	55                   	push   %ebp
80104691:	89 e5                	mov    %esp,%ebp
80104693:	83 ec 18             	sub    $0x18,%esp
  int intena;
  struct proc *p = myproc();
80104696:	e8 79 f8 ff ff       	call   80103f14 <myproc>
8010469b:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(!holding(&ptable.lock))
8010469e:	83 ec 0c             	sub    $0xc,%esp
801046a1:	68 40 72 11 80       	push   $0x80117240
801046a6:	e8 7d 06 00 00       	call   80104d28 <holding>
801046ab:	83 c4 10             	add    $0x10,%esp
801046ae:	85 c0                	test   %eax,%eax
801046b0:	75 0d                	jne    801046bf <sched+0x2f>
    panic("sched ptable.lock");
801046b2:	83 ec 0c             	sub    $0xc,%esp
801046b5:	68 ef a7 10 80       	push   $0x8010a7ef
801046ba:	e8 ea be ff ff       	call   801005a9 <panic>
  if(mycpu()->ncli != 1)
801046bf:	e8 d8 f7 ff ff       	call   80103e9c <mycpu>
801046c4:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
801046ca:	83 f8 01             	cmp    $0x1,%eax
801046cd:	74 0d                	je     801046dc <sched+0x4c>
    panic("sched locks");
801046cf:	83 ec 0c             	sub    $0xc,%esp
801046d2:	68 01 a8 10 80       	push   $0x8010a801
801046d7:	e8 cd be ff ff       	call   801005a9 <panic>
  if(p->state == RUNNING)
801046dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046df:	8b 40 0c             	mov    0xc(%eax),%eax
801046e2:	83 f8 04             	cmp    $0x4,%eax
801046e5:	75 0d                	jne    801046f4 <sched+0x64>
    panic("sched running");
801046e7:	83 ec 0c             	sub    $0xc,%esp
801046ea:	68 0d a8 10 80       	push   $0x8010a80d
801046ef:	e8 b5 be ff ff       	call   801005a9 <panic>
  if(readeflags()&FL_IF)
801046f4:	e8 53 f7 ff ff       	call   80103e4c <readeflags>
801046f9:	25 00 02 00 00       	and    $0x200,%eax
801046fe:	85 c0                	test   %eax,%eax
80104700:	74 0d                	je     8010470f <sched+0x7f>
    panic("sched interruptible");
80104702:	83 ec 0c             	sub    $0xc,%esp
80104705:	68 1b a8 10 80       	push   $0x8010a81b
8010470a:	e8 9a be ff ff       	call   801005a9 <panic>
  intena = mycpu()->intena;
8010470f:	e8 88 f7 ff ff       	call   80103e9c <mycpu>
80104714:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
8010471a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  swtch(&p->context, mycpu()->scheduler);
8010471d:	e8 7a f7 ff ff       	call   80103e9c <mycpu>
80104722:	8b 40 04             	mov    0x4(%eax),%eax
80104725:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104728:	83 c2 1c             	add    $0x1c,%edx
8010472b:	83 ec 08             	sub    $0x8,%esp
8010472e:	50                   	push   %eax
8010472f:	52                   	push   %edx
80104730:	e8 a3 09 00 00       	call   801050d8 <swtch>
80104735:	83 c4 10             	add    $0x10,%esp
  mycpu()->intena = intena;
80104738:	e8 5f f7 ff ff       	call   80103e9c <mycpu>
8010473d:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104740:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
}
80104746:	90                   	nop
80104747:	c9                   	leave  
80104748:	c3                   	ret    

80104749 <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
80104749:	55                   	push   %ebp
8010474a:	89 e5                	mov    %esp,%ebp
8010474c:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
8010474f:	83 ec 0c             	sub    $0xc,%esp
80104752:	68 40 72 11 80       	push   $0x80117240
80104757:	e8 91 04 00 00       	call   80104bed <acquire>
8010475c:	83 c4 10             	add    $0x10,%esp
  myproc()->state = RUNNABLE;
8010475f:	e8 b0 f7 ff ff       	call   80103f14 <myproc>
80104764:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
8010476b:	e8 20 ff ff ff       	call   80104690 <sched>
  release(&ptable.lock);
80104770:	83 ec 0c             	sub    $0xc,%esp
80104773:	68 40 72 11 80       	push   $0x80117240
80104778:	e8 de 04 00 00       	call   80104c5b <release>
8010477d:	83 c4 10             	add    $0x10,%esp
}
80104780:	90                   	nop
80104781:	c9                   	leave  
80104782:	c3                   	ret    

80104783 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
80104783:	55                   	push   %ebp
80104784:	89 e5                	mov    %esp,%ebp
80104786:	83 ec 08             	sub    $0x8,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
80104789:	83 ec 0c             	sub    $0xc,%esp
8010478c:	68 40 72 11 80       	push   $0x80117240
80104791:	e8 c5 04 00 00       	call   80104c5b <release>
80104796:	83 c4 10             	add    $0x10,%esp

  if (first) {
80104799:	a1 04 f0 10 80       	mov    0x8010f004,%eax
8010479e:	85 c0                	test   %eax,%eax
801047a0:	74 24                	je     801047c6 <forkret+0x43>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot
    // be run from main().
    first = 0;
801047a2:	c7 05 04 f0 10 80 00 	movl   $0x0,0x8010f004
801047a9:	00 00 00 
    iinit(ROOTDEV);
801047ac:	83 ec 0c             	sub    $0xc,%esp
801047af:	6a 01                	push   $0x1
801047b1:	e8 c2 ce ff ff       	call   80101678 <iinit>
801047b6:	83 c4 10             	add    $0x10,%esp
    initlog(ROOTDEV);
801047b9:	83 ec 0c             	sub    $0xc,%esp
801047bc:	6a 01                	push   $0x1
801047be:	e8 3e eb ff ff       	call   80103301 <initlog>
801047c3:	83 c4 10             	add    $0x10,%esp
  }

  // Return to "caller", actually trapret (see allocproc).
}
801047c6:	90                   	nop
801047c7:	c9                   	leave  
801047c8:	c3                   	ret    

801047c9 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
801047c9:	55                   	push   %ebp
801047ca:	89 e5                	mov    %esp,%ebp
801047cc:	83 ec 18             	sub    $0x18,%esp
  struct proc *p = myproc();
801047cf:	e8 40 f7 ff ff       	call   80103f14 <myproc>
801047d4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  if(p == 0)
801047d7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801047db:	75 0d                	jne    801047ea <sleep+0x21>
    panic("sleep");
801047dd:	83 ec 0c             	sub    $0xc,%esp
801047e0:	68 2f a8 10 80       	push   $0x8010a82f
801047e5:	e8 bf bd ff ff       	call   801005a9 <panic>

  if(lk == 0)
801047ea:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801047ee:	75 0d                	jne    801047fd <sleep+0x34>
    panic("sleep without lk");
801047f0:	83 ec 0c             	sub    $0xc,%esp
801047f3:	68 35 a8 10 80       	push   $0x8010a835
801047f8:	e8 ac bd ff ff       	call   801005a9 <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
801047fd:	81 7d 0c 40 72 11 80 	cmpl   $0x80117240,0xc(%ebp)
80104804:	74 1e                	je     80104824 <sleep+0x5b>
    acquire(&ptable.lock);  //DOC: sleeplock1
80104806:	83 ec 0c             	sub    $0xc,%esp
80104809:	68 40 72 11 80       	push   $0x80117240
8010480e:	e8 da 03 00 00       	call   80104bed <acquire>
80104813:	83 c4 10             	add    $0x10,%esp
    release(lk);
80104816:	83 ec 0c             	sub    $0xc,%esp
80104819:	ff 75 0c             	push   0xc(%ebp)
8010481c:	e8 3a 04 00 00       	call   80104c5b <release>
80104821:	83 c4 10             	add    $0x10,%esp
  }
  // Go to sleep.
  p->chan = chan;
80104824:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104827:	8b 55 08             	mov    0x8(%ebp),%edx
8010482a:	89 50 20             	mov    %edx,0x20(%eax)
  p->state = SLEEPING;
8010482d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104830:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)

  sched();
80104837:	e8 54 fe ff ff       	call   80104690 <sched>

  // Tidy up.
  p->chan = 0;
8010483c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010483f:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
80104846:	81 7d 0c 40 72 11 80 	cmpl   $0x80117240,0xc(%ebp)
8010484d:	74 1e                	je     8010486d <sleep+0xa4>
    release(&ptable.lock);
8010484f:	83 ec 0c             	sub    $0xc,%esp
80104852:	68 40 72 11 80       	push   $0x80117240
80104857:	e8 ff 03 00 00       	call   80104c5b <release>
8010485c:	83 c4 10             	add    $0x10,%esp
    acquire(lk);
8010485f:	83 ec 0c             	sub    $0xc,%esp
80104862:	ff 75 0c             	push   0xc(%ebp)
80104865:	e8 83 03 00 00       	call   80104bed <acquire>
8010486a:	83 c4 10             	add    $0x10,%esp
  }
}
8010486d:	90                   	nop
8010486e:	c9                   	leave  
8010486f:	c3                   	ret    

80104870 <wakeup1>:
//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
80104870:	55                   	push   %ebp
80104871:	89 e5                	mov    %esp,%ebp
80104873:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104876:	c7 45 fc 74 72 11 80 	movl   $0x80117274,-0x4(%ebp)
8010487d:	eb 27                	jmp    801048a6 <wakeup1+0x36>
    if(p->state == SLEEPING && p->chan == chan)
8010487f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104882:	8b 40 0c             	mov    0xc(%eax),%eax
80104885:	83 f8 02             	cmp    $0x2,%eax
80104888:	75 15                	jne    8010489f <wakeup1+0x2f>
8010488a:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010488d:	8b 40 20             	mov    0x20(%eax),%eax
80104890:	39 45 08             	cmp    %eax,0x8(%ebp)
80104893:	75 0a                	jne    8010489f <wakeup1+0x2f>
      p->state = RUNNABLE;
80104895:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104898:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
8010489f:	81 45 fc 84 00 00 00 	addl   $0x84,-0x4(%ebp)
801048a6:	81 7d fc 74 93 11 80 	cmpl   $0x80119374,-0x4(%ebp)
801048ad:	72 d0                	jb     8010487f <wakeup1+0xf>
}
801048af:	90                   	nop
801048b0:	90                   	nop
801048b1:	c9                   	leave  
801048b2:	c3                   	ret    

801048b3 <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
801048b3:	55                   	push   %ebp
801048b4:	89 e5                	mov    %esp,%ebp
801048b6:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);
801048b9:	83 ec 0c             	sub    $0xc,%esp
801048bc:	68 40 72 11 80       	push   $0x80117240
801048c1:	e8 27 03 00 00       	call   80104bed <acquire>
801048c6:	83 c4 10             	add    $0x10,%esp
  wakeup1(chan);
801048c9:	83 ec 0c             	sub    $0xc,%esp
801048cc:	ff 75 08             	push   0x8(%ebp)
801048cf:	e8 9c ff ff ff       	call   80104870 <wakeup1>
801048d4:	83 c4 10             	add    $0x10,%esp
  release(&ptable.lock);
801048d7:	83 ec 0c             	sub    $0xc,%esp
801048da:	68 40 72 11 80       	push   $0x80117240
801048df:	e8 77 03 00 00       	call   80104c5b <release>
801048e4:	83 c4 10             	add    $0x10,%esp
}
801048e7:	90                   	nop
801048e8:	c9                   	leave  
801048e9:	c3                   	ret    

801048ea <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
801048ea:	55                   	push   %ebp
801048eb:	89 e5                	mov    %esp,%ebp
801048ed:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;

  acquire(&ptable.lock);
801048f0:	83 ec 0c             	sub    $0xc,%esp
801048f3:	68 40 72 11 80       	push   $0x80117240
801048f8:	e8 f0 02 00 00       	call   80104bed <acquire>
801048fd:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104900:	c7 45 f4 74 72 11 80 	movl   $0x80117274,-0xc(%ebp)
80104907:	eb 48                	jmp    80104951 <kill+0x67>
    if(p->pid == pid){
80104909:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010490c:	8b 40 10             	mov    0x10(%eax),%eax
8010490f:	39 45 08             	cmp    %eax,0x8(%ebp)
80104912:	75 36                	jne    8010494a <kill+0x60>
      p->killed = 1;
80104914:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104917:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
8010491e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104921:	8b 40 0c             	mov    0xc(%eax),%eax
80104924:	83 f8 02             	cmp    $0x2,%eax
80104927:	75 0a                	jne    80104933 <kill+0x49>
        p->state = RUNNABLE;
80104929:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010492c:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      release(&ptable.lock);
80104933:	83 ec 0c             	sub    $0xc,%esp
80104936:	68 40 72 11 80       	push   $0x80117240
8010493b:	e8 1b 03 00 00       	call   80104c5b <release>
80104940:	83 c4 10             	add    $0x10,%esp
      return 0;
80104943:	b8 00 00 00 00       	mov    $0x0,%eax
80104948:	eb 25                	jmp    8010496f <kill+0x85>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010494a:	81 45 f4 84 00 00 00 	addl   $0x84,-0xc(%ebp)
80104951:	81 7d f4 74 93 11 80 	cmpl   $0x80119374,-0xc(%ebp)
80104958:	72 af                	jb     80104909 <kill+0x1f>
    }
  }
  release(&ptable.lock);
8010495a:	83 ec 0c             	sub    $0xc,%esp
8010495d:	68 40 72 11 80       	push   $0x80117240
80104962:	e8 f4 02 00 00       	call   80104c5b <release>
80104967:	83 c4 10             	add    $0x10,%esp
  return -1;
8010496a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010496f:	c9                   	leave  
80104970:	c3                   	ret    

80104971 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
80104971:	55                   	push   %ebp
80104972:	89 e5                	mov    %esp,%ebp
80104974:	83 ec 48             	sub    $0x48,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104977:	c7 45 f0 74 72 11 80 	movl   $0x80117274,-0x10(%ebp)
8010497e:	e9 da 00 00 00       	jmp    80104a5d <procdump+0xec>
    if(p->state == UNUSED)
80104983:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104986:	8b 40 0c             	mov    0xc(%eax),%eax
80104989:	85 c0                	test   %eax,%eax
8010498b:	0f 84 c4 00 00 00    	je     80104a55 <procdump+0xe4>
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
80104991:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104994:	8b 40 0c             	mov    0xc(%eax),%eax
80104997:	83 f8 05             	cmp    $0x5,%eax
8010499a:	77 23                	ja     801049bf <procdump+0x4e>
8010499c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010499f:	8b 40 0c             	mov    0xc(%eax),%eax
801049a2:	8b 04 85 08 f0 10 80 	mov    -0x7fef0ff8(,%eax,4),%eax
801049a9:	85 c0                	test   %eax,%eax
801049ab:	74 12                	je     801049bf <procdump+0x4e>
      state = states[p->state];
801049ad:	8b 45 f0             	mov    -0x10(%ebp),%eax
801049b0:	8b 40 0c             	mov    0xc(%eax),%eax
801049b3:	8b 04 85 08 f0 10 80 	mov    -0x7fef0ff8(,%eax,4),%eax
801049ba:	89 45 ec             	mov    %eax,-0x14(%ebp)
801049bd:	eb 07                	jmp    801049c6 <procdump+0x55>
    else
      state = "???";
801049bf:	c7 45 ec 46 a8 10 80 	movl   $0x8010a846,-0x14(%ebp)
    cprintf("%d %s %s", p->pid, state, p->name);
801049c6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801049c9:	8d 50 6c             	lea    0x6c(%eax),%edx
801049cc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801049cf:	8b 40 10             	mov    0x10(%eax),%eax
801049d2:	52                   	push   %edx
801049d3:	ff 75 ec             	push   -0x14(%ebp)
801049d6:	50                   	push   %eax
801049d7:	68 4a a8 10 80       	push   $0x8010a84a
801049dc:	e8 13 ba ff ff       	call   801003f4 <cprintf>
801049e1:	83 c4 10             	add    $0x10,%esp
    if(p->state == SLEEPING){
801049e4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801049e7:	8b 40 0c             	mov    0xc(%eax),%eax
801049ea:	83 f8 02             	cmp    $0x2,%eax
801049ed:	75 54                	jne    80104a43 <procdump+0xd2>
      getcallerpcs((uint*)p->context->ebp+2, pc);
801049ef:	8b 45 f0             	mov    -0x10(%ebp),%eax
801049f2:	8b 40 1c             	mov    0x1c(%eax),%eax
801049f5:	8b 40 0c             	mov    0xc(%eax),%eax
801049f8:	83 c0 08             	add    $0x8,%eax
801049fb:	89 c2                	mov    %eax,%edx
801049fd:	83 ec 08             	sub    $0x8,%esp
80104a00:	8d 45 c4             	lea    -0x3c(%ebp),%eax
80104a03:	50                   	push   %eax
80104a04:	52                   	push   %edx
80104a05:	e8 a3 02 00 00       	call   80104cad <getcallerpcs>
80104a0a:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
80104a0d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104a14:	eb 1c                	jmp    80104a32 <procdump+0xc1>
        cprintf(" %p", pc[i]);
80104a16:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a19:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80104a1d:	83 ec 08             	sub    $0x8,%esp
80104a20:	50                   	push   %eax
80104a21:	68 53 a8 10 80       	push   $0x8010a853
80104a26:	e8 c9 b9 ff ff       	call   801003f4 <cprintf>
80104a2b:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
80104a2e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104a32:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
80104a36:	7f 0b                	jg     80104a43 <procdump+0xd2>
80104a38:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a3b:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80104a3f:	85 c0                	test   %eax,%eax
80104a41:	75 d3                	jne    80104a16 <procdump+0xa5>
    }
    cprintf("\n");
80104a43:	83 ec 0c             	sub    $0xc,%esp
80104a46:	68 57 a8 10 80       	push   $0x8010a857
80104a4b:	e8 a4 b9 ff ff       	call   801003f4 <cprintf>
80104a50:	83 c4 10             	add    $0x10,%esp
80104a53:	eb 01                	jmp    80104a56 <procdump+0xe5>
      continue;
80104a55:	90                   	nop
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104a56:	81 45 f0 84 00 00 00 	addl   $0x84,-0x10(%ebp)
80104a5d:	81 7d f0 74 93 11 80 	cmpl   $0x80119374,-0x10(%ebp)
80104a64:	0f 82 19 ff ff ff    	jb     80104983 <procdump+0x12>
  }
}
80104a6a:	90                   	nop
80104a6b:	90                   	nop
80104a6c:	c9                   	leave  
80104a6d:	c3                   	ret    

80104a6e <initsleeplock>:
#include "spinlock.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
80104a6e:	55                   	push   %ebp
80104a6f:	89 e5                	mov    %esp,%ebp
80104a71:	83 ec 08             	sub    $0x8,%esp
  initlock(&lk->lk, "sleep lock");
80104a74:	8b 45 08             	mov    0x8(%ebp),%eax
80104a77:	83 c0 04             	add    $0x4,%eax
80104a7a:	83 ec 08             	sub    $0x8,%esp
80104a7d:	68 83 a8 10 80       	push   $0x8010a883
80104a82:	50                   	push   %eax
80104a83:	e8 43 01 00 00       	call   80104bcb <initlock>
80104a88:	83 c4 10             	add    $0x10,%esp
  lk->name = name;
80104a8b:	8b 45 08             	mov    0x8(%ebp),%eax
80104a8e:	8b 55 0c             	mov    0xc(%ebp),%edx
80104a91:	89 50 38             	mov    %edx,0x38(%eax)
  lk->locked = 0;
80104a94:	8b 45 08             	mov    0x8(%ebp),%eax
80104a97:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
80104a9d:	8b 45 08             	mov    0x8(%ebp),%eax
80104aa0:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
}
80104aa7:	90                   	nop
80104aa8:	c9                   	leave  
80104aa9:	c3                   	ret    

80104aaa <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
80104aaa:	55                   	push   %ebp
80104aab:	89 e5                	mov    %esp,%ebp
80104aad:	83 ec 08             	sub    $0x8,%esp
  acquire(&lk->lk);
80104ab0:	8b 45 08             	mov    0x8(%ebp),%eax
80104ab3:	83 c0 04             	add    $0x4,%eax
80104ab6:	83 ec 0c             	sub    $0xc,%esp
80104ab9:	50                   	push   %eax
80104aba:	e8 2e 01 00 00       	call   80104bed <acquire>
80104abf:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
80104ac2:	eb 15                	jmp    80104ad9 <acquiresleep+0x2f>
    sleep(lk, &lk->lk);
80104ac4:	8b 45 08             	mov    0x8(%ebp),%eax
80104ac7:	83 c0 04             	add    $0x4,%eax
80104aca:	83 ec 08             	sub    $0x8,%esp
80104acd:	50                   	push   %eax
80104ace:	ff 75 08             	push   0x8(%ebp)
80104ad1:	e8 f3 fc ff ff       	call   801047c9 <sleep>
80104ad6:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
80104ad9:	8b 45 08             	mov    0x8(%ebp),%eax
80104adc:	8b 00                	mov    (%eax),%eax
80104ade:	85 c0                	test   %eax,%eax
80104ae0:	75 e2                	jne    80104ac4 <acquiresleep+0x1a>
  }
  lk->locked = 1;
80104ae2:	8b 45 08             	mov    0x8(%ebp),%eax
80104ae5:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  lk->pid = myproc()->pid;
80104aeb:	e8 24 f4 ff ff       	call   80103f14 <myproc>
80104af0:	8b 50 10             	mov    0x10(%eax),%edx
80104af3:	8b 45 08             	mov    0x8(%ebp),%eax
80104af6:	89 50 3c             	mov    %edx,0x3c(%eax)
  release(&lk->lk);
80104af9:	8b 45 08             	mov    0x8(%ebp),%eax
80104afc:	83 c0 04             	add    $0x4,%eax
80104aff:	83 ec 0c             	sub    $0xc,%esp
80104b02:	50                   	push   %eax
80104b03:	e8 53 01 00 00       	call   80104c5b <release>
80104b08:	83 c4 10             	add    $0x10,%esp
}
80104b0b:	90                   	nop
80104b0c:	c9                   	leave  
80104b0d:	c3                   	ret    

80104b0e <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
80104b0e:	55                   	push   %ebp
80104b0f:	89 e5                	mov    %esp,%ebp
80104b11:	83 ec 08             	sub    $0x8,%esp
  acquire(&lk->lk);
80104b14:	8b 45 08             	mov    0x8(%ebp),%eax
80104b17:	83 c0 04             	add    $0x4,%eax
80104b1a:	83 ec 0c             	sub    $0xc,%esp
80104b1d:	50                   	push   %eax
80104b1e:	e8 ca 00 00 00       	call   80104bed <acquire>
80104b23:	83 c4 10             	add    $0x10,%esp
  lk->locked = 0;
80104b26:	8b 45 08             	mov    0x8(%ebp),%eax
80104b29:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
80104b2f:	8b 45 08             	mov    0x8(%ebp),%eax
80104b32:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
  wakeup(lk);
80104b39:	83 ec 0c             	sub    $0xc,%esp
80104b3c:	ff 75 08             	push   0x8(%ebp)
80104b3f:	e8 6f fd ff ff       	call   801048b3 <wakeup>
80104b44:	83 c4 10             	add    $0x10,%esp
  release(&lk->lk);
80104b47:	8b 45 08             	mov    0x8(%ebp),%eax
80104b4a:	83 c0 04             	add    $0x4,%eax
80104b4d:	83 ec 0c             	sub    $0xc,%esp
80104b50:	50                   	push   %eax
80104b51:	e8 05 01 00 00       	call   80104c5b <release>
80104b56:	83 c4 10             	add    $0x10,%esp
}
80104b59:	90                   	nop
80104b5a:	c9                   	leave  
80104b5b:	c3                   	ret    

80104b5c <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
80104b5c:	55                   	push   %ebp
80104b5d:	89 e5                	mov    %esp,%ebp
80104b5f:	83 ec 18             	sub    $0x18,%esp
  int r;
  
  acquire(&lk->lk);
80104b62:	8b 45 08             	mov    0x8(%ebp),%eax
80104b65:	83 c0 04             	add    $0x4,%eax
80104b68:	83 ec 0c             	sub    $0xc,%esp
80104b6b:	50                   	push   %eax
80104b6c:	e8 7c 00 00 00       	call   80104bed <acquire>
80104b71:	83 c4 10             	add    $0x10,%esp
  r = lk->locked;
80104b74:	8b 45 08             	mov    0x8(%ebp),%eax
80104b77:	8b 00                	mov    (%eax),%eax
80104b79:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&lk->lk);
80104b7c:	8b 45 08             	mov    0x8(%ebp),%eax
80104b7f:	83 c0 04             	add    $0x4,%eax
80104b82:	83 ec 0c             	sub    $0xc,%esp
80104b85:	50                   	push   %eax
80104b86:	e8 d0 00 00 00       	call   80104c5b <release>
80104b8b:	83 c4 10             	add    $0x10,%esp
  return r;
80104b8e:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80104b91:	c9                   	leave  
80104b92:	c3                   	ret    

80104b93 <readeflags>:
{
80104b93:	55                   	push   %ebp
80104b94:	89 e5                	mov    %esp,%ebp
80104b96:	83 ec 10             	sub    $0x10,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80104b99:	9c                   	pushf  
80104b9a:	58                   	pop    %eax
80104b9b:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80104b9e:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104ba1:	c9                   	leave  
80104ba2:	c3                   	ret    

80104ba3 <cli>:
{
80104ba3:	55                   	push   %ebp
80104ba4:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80104ba6:	fa                   	cli    
}
80104ba7:	90                   	nop
80104ba8:	5d                   	pop    %ebp
80104ba9:	c3                   	ret    

80104baa <sti>:
{
80104baa:	55                   	push   %ebp
80104bab:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80104bad:	fb                   	sti    
}
80104bae:	90                   	nop
80104baf:	5d                   	pop    %ebp
80104bb0:	c3                   	ret    

80104bb1 <xchg>:
{
80104bb1:	55                   	push   %ebp
80104bb2:	89 e5                	mov    %esp,%ebp
80104bb4:	83 ec 10             	sub    $0x10,%esp
  asm volatile("lock; xchgl %0, %1" :
80104bb7:	8b 55 08             	mov    0x8(%ebp),%edx
80104bba:	8b 45 0c             	mov    0xc(%ebp),%eax
80104bbd:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104bc0:	f0 87 02             	lock xchg %eax,(%edx)
80104bc3:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return result;
80104bc6:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104bc9:	c9                   	leave  
80104bca:	c3                   	ret    

80104bcb <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
80104bcb:	55                   	push   %ebp
80104bcc:	89 e5                	mov    %esp,%ebp
  lk->name = name;
80104bce:	8b 45 08             	mov    0x8(%ebp),%eax
80104bd1:	8b 55 0c             	mov    0xc(%ebp),%edx
80104bd4:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
80104bd7:	8b 45 08             	mov    0x8(%ebp),%eax
80104bda:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
80104be0:	8b 45 08             	mov    0x8(%ebp),%eax
80104be3:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
80104bea:	90                   	nop
80104beb:	5d                   	pop    %ebp
80104bec:	c3                   	ret    

80104bed <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
80104bed:	55                   	push   %ebp
80104bee:	89 e5                	mov    %esp,%ebp
80104bf0:	53                   	push   %ebx
80104bf1:	83 ec 04             	sub    $0x4,%esp
  pushcli(); // disable interrupts to avoid deadlock.
80104bf4:	e8 5f 01 00 00       	call   80104d58 <pushcli>
  if(holding(lk)){
80104bf9:	8b 45 08             	mov    0x8(%ebp),%eax
80104bfc:	83 ec 0c             	sub    $0xc,%esp
80104bff:	50                   	push   %eax
80104c00:	e8 23 01 00 00       	call   80104d28 <holding>
80104c05:	83 c4 10             	add    $0x10,%esp
80104c08:	85 c0                	test   %eax,%eax
80104c0a:	74 0d                	je     80104c19 <acquire+0x2c>
    panic("acquire");
80104c0c:	83 ec 0c             	sub    $0xc,%esp
80104c0f:	68 8e a8 10 80       	push   $0x8010a88e
80104c14:	e8 90 b9 ff ff       	call   801005a9 <panic>
  }

  // The xchg is atomic.
  while(xchg(&lk->locked, 1) != 0)
80104c19:	90                   	nop
80104c1a:	8b 45 08             	mov    0x8(%ebp),%eax
80104c1d:	83 ec 08             	sub    $0x8,%esp
80104c20:	6a 01                	push   $0x1
80104c22:	50                   	push   %eax
80104c23:	e8 89 ff ff ff       	call   80104bb1 <xchg>
80104c28:	83 c4 10             	add    $0x10,%esp
80104c2b:	85 c0                	test   %eax,%eax
80104c2d:	75 eb                	jne    80104c1a <acquire+0x2d>
    ;

  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that the critical section's memory
  // references happen after the lock is acquired.
  __sync_synchronize();
80104c2f:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Record info about lock acquisition for debugging.
  lk->cpu = mycpu();
80104c34:	8b 5d 08             	mov    0x8(%ebp),%ebx
80104c37:	e8 60 f2 ff ff       	call   80103e9c <mycpu>
80104c3c:	89 43 08             	mov    %eax,0x8(%ebx)
  getcallerpcs(&lk, lk->pcs);
80104c3f:	8b 45 08             	mov    0x8(%ebp),%eax
80104c42:	83 c0 0c             	add    $0xc,%eax
80104c45:	83 ec 08             	sub    $0x8,%esp
80104c48:	50                   	push   %eax
80104c49:	8d 45 08             	lea    0x8(%ebp),%eax
80104c4c:	50                   	push   %eax
80104c4d:	e8 5b 00 00 00       	call   80104cad <getcallerpcs>
80104c52:	83 c4 10             	add    $0x10,%esp
}
80104c55:	90                   	nop
80104c56:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104c59:	c9                   	leave  
80104c5a:	c3                   	ret    

80104c5b <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
80104c5b:	55                   	push   %ebp
80104c5c:	89 e5                	mov    %esp,%ebp
80104c5e:	83 ec 08             	sub    $0x8,%esp
  if(!holding(lk))
80104c61:	83 ec 0c             	sub    $0xc,%esp
80104c64:	ff 75 08             	push   0x8(%ebp)
80104c67:	e8 bc 00 00 00       	call   80104d28 <holding>
80104c6c:	83 c4 10             	add    $0x10,%esp
80104c6f:	85 c0                	test   %eax,%eax
80104c71:	75 0d                	jne    80104c80 <release+0x25>
    panic("release");
80104c73:	83 ec 0c             	sub    $0xc,%esp
80104c76:	68 96 a8 10 80       	push   $0x8010a896
80104c7b:	e8 29 b9 ff ff       	call   801005a9 <panic>

  lk->pcs[0] = 0;
80104c80:	8b 45 08             	mov    0x8(%ebp),%eax
80104c83:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
80104c8a:	8b 45 08             	mov    0x8(%ebp),%eax
80104c8d:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that all the stores in the critical
  // section are visible to other cores before the lock is released.
  // Both the C compiler and the hardware may re-order loads and
  // stores; __sync_synchronize() tells them both not to.
  __sync_synchronize();
80104c94:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Release the lock, equivalent to lk->locked = 0.
  // This code can't use a C assignment, since it might
  // not be atomic. A real OS would use C atomics here.
  asm volatile("movl $0, %0" : "+m" (lk->locked) : );
80104c99:	8b 45 08             	mov    0x8(%ebp),%eax
80104c9c:	8b 55 08             	mov    0x8(%ebp),%edx
80104c9f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  popcli();
80104ca5:	e8 fb 00 00 00       	call   80104da5 <popcli>
}
80104caa:	90                   	nop
80104cab:	c9                   	leave  
80104cac:	c3                   	ret    

80104cad <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
80104cad:	55                   	push   %ebp
80104cae:	89 e5                	mov    %esp,%ebp
80104cb0:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
80104cb3:	8b 45 08             	mov    0x8(%ebp),%eax
80104cb6:	83 e8 08             	sub    $0x8,%eax
80104cb9:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
80104cbc:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80104cc3:	eb 38                	jmp    80104cfd <getcallerpcs+0x50>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
80104cc5:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
80104cc9:	74 53                	je     80104d1e <getcallerpcs+0x71>
80104ccb:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
80104cd2:	76 4a                	jbe    80104d1e <getcallerpcs+0x71>
80104cd4:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
80104cd8:	74 44                	je     80104d1e <getcallerpcs+0x71>
      break;
    pcs[i] = ebp[1];     // saved %eip
80104cda:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104cdd:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80104ce4:	8b 45 0c             	mov    0xc(%ebp),%eax
80104ce7:	01 c2                	add    %eax,%edx
80104ce9:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104cec:	8b 40 04             	mov    0x4(%eax),%eax
80104cef:	89 02                	mov    %eax,(%edx)
    ebp = (uint*)ebp[0]; // saved %ebp
80104cf1:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104cf4:	8b 00                	mov    (%eax),%eax
80104cf6:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
80104cf9:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80104cfd:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80104d01:	7e c2                	jle    80104cc5 <getcallerpcs+0x18>
  }
  for(; i < 10; i++)
80104d03:	eb 19                	jmp    80104d1e <getcallerpcs+0x71>
    pcs[i] = 0;
80104d05:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104d08:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80104d0f:	8b 45 0c             	mov    0xc(%ebp),%eax
80104d12:	01 d0                	add    %edx,%eax
80104d14:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; i < 10; i++)
80104d1a:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80104d1e:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80104d22:	7e e1                	jle    80104d05 <getcallerpcs+0x58>
}
80104d24:	90                   	nop
80104d25:	90                   	nop
80104d26:	c9                   	leave  
80104d27:	c3                   	ret    

80104d28 <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
80104d28:	55                   	push   %ebp
80104d29:	89 e5                	mov    %esp,%ebp
80104d2b:	53                   	push   %ebx
80104d2c:	83 ec 04             	sub    $0x4,%esp
  return lock->locked && lock->cpu == mycpu();
80104d2f:	8b 45 08             	mov    0x8(%ebp),%eax
80104d32:	8b 00                	mov    (%eax),%eax
80104d34:	85 c0                	test   %eax,%eax
80104d36:	74 16                	je     80104d4e <holding+0x26>
80104d38:	8b 45 08             	mov    0x8(%ebp),%eax
80104d3b:	8b 58 08             	mov    0x8(%eax),%ebx
80104d3e:	e8 59 f1 ff ff       	call   80103e9c <mycpu>
80104d43:	39 c3                	cmp    %eax,%ebx
80104d45:	75 07                	jne    80104d4e <holding+0x26>
80104d47:	b8 01 00 00 00       	mov    $0x1,%eax
80104d4c:	eb 05                	jmp    80104d53 <holding+0x2b>
80104d4e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104d53:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104d56:	c9                   	leave  
80104d57:	c3                   	ret    

80104d58 <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
80104d58:	55                   	push   %ebp
80104d59:	89 e5                	mov    %esp,%ebp
80104d5b:	83 ec 18             	sub    $0x18,%esp
  int eflags;

  eflags = readeflags();
80104d5e:	e8 30 fe ff ff       	call   80104b93 <readeflags>
80104d63:	89 45 f4             	mov    %eax,-0xc(%ebp)
  cli();
80104d66:	e8 38 fe ff ff       	call   80104ba3 <cli>
  if(mycpu()->ncli == 0)
80104d6b:	e8 2c f1 ff ff       	call   80103e9c <mycpu>
80104d70:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104d76:	85 c0                	test   %eax,%eax
80104d78:	75 14                	jne    80104d8e <pushcli+0x36>
    mycpu()->intena = eflags & FL_IF;
80104d7a:	e8 1d f1 ff ff       	call   80103e9c <mycpu>
80104d7f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104d82:	81 e2 00 02 00 00    	and    $0x200,%edx
80104d88:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
  mycpu()->ncli += 1;
80104d8e:	e8 09 f1 ff ff       	call   80103e9c <mycpu>
80104d93:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
80104d99:	83 c2 01             	add    $0x1,%edx
80104d9c:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
}
80104da2:	90                   	nop
80104da3:	c9                   	leave  
80104da4:	c3                   	ret    

80104da5 <popcli>:

void
popcli(void)
{
80104da5:	55                   	push   %ebp
80104da6:	89 e5                	mov    %esp,%ebp
80104da8:	83 ec 08             	sub    $0x8,%esp
  if(readeflags()&FL_IF)
80104dab:	e8 e3 fd ff ff       	call   80104b93 <readeflags>
80104db0:	25 00 02 00 00       	and    $0x200,%eax
80104db5:	85 c0                	test   %eax,%eax
80104db7:	74 0d                	je     80104dc6 <popcli+0x21>
    panic("popcli - interruptible");
80104db9:	83 ec 0c             	sub    $0xc,%esp
80104dbc:	68 9e a8 10 80       	push   $0x8010a89e
80104dc1:	e8 e3 b7 ff ff       	call   801005a9 <panic>
  if(--mycpu()->ncli < 0)
80104dc6:	e8 d1 f0 ff ff       	call   80103e9c <mycpu>
80104dcb:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
80104dd1:	83 ea 01             	sub    $0x1,%edx
80104dd4:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
80104dda:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104de0:	85 c0                	test   %eax,%eax
80104de2:	79 0d                	jns    80104df1 <popcli+0x4c>
    panic("popcli");
80104de4:	83 ec 0c             	sub    $0xc,%esp
80104de7:	68 b5 a8 10 80       	push   $0x8010a8b5
80104dec:	e8 b8 b7 ff ff       	call   801005a9 <panic>
  if(mycpu()->ncli == 0 && mycpu()->intena)
80104df1:	e8 a6 f0 ff ff       	call   80103e9c <mycpu>
80104df6:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104dfc:	85 c0                	test   %eax,%eax
80104dfe:	75 14                	jne    80104e14 <popcli+0x6f>
80104e00:	e8 97 f0 ff ff       	call   80103e9c <mycpu>
80104e05:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
80104e0b:	85 c0                	test   %eax,%eax
80104e0d:	74 05                	je     80104e14 <popcli+0x6f>
    sti();
80104e0f:	e8 96 fd ff ff       	call   80104baa <sti>
}
80104e14:	90                   	nop
80104e15:	c9                   	leave  
80104e16:	c3                   	ret    

80104e17 <stosb>:
{
80104e17:	55                   	push   %ebp
80104e18:	89 e5                	mov    %esp,%ebp
80104e1a:	57                   	push   %edi
80104e1b:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
80104e1c:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104e1f:	8b 55 10             	mov    0x10(%ebp),%edx
80104e22:	8b 45 0c             	mov    0xc(%ebp),%eax
80104e25:	89 cb                	mov    %ecx,%ebx
80104e27:	89 df                	mov    %ebx,%edi
80104e29:	89 d1                	mov    %edx,%ecx
80104e2b:	fc                   	cld    
80104e2c:	f3 aa                	rep stos %al,%es:(%edi)
80104e2e:	89 ca                	mov    %ecx,%edx
80104e30:	89 fb                	mov    %edi,%ebx
80104e32:	89 5d 08             	mov    %ebx,0x8(%ebp)
80104e35:	89 55 10             	mov    %edx,0x10(%ebp)
}
80104e38:	90                   	nop
80104e39:	5b                   	pop    %ebx
80104e3a:	5f                   	pop    %edi
80104e3b:	5d                   	pop    %ebp
80104e3c:	c3                   	ret    

80104e3d <stosl>:
{
80104e3d:	55                   	push   %ebp
80104e3e:	89 e5                	mov    %esp,%ebp
80104e40:	57                   	push   %edi
80104e41:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
80104e42:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104e45:	8b 55 10             	mov    0x10(%ebp),%edx
80104e48:	8b 45 0c             	mov    0xc(%ebp),%eax
80104e4b:	89 cb                	mov    %ecx,%ebx
80104e4d:	89 df                	mov    %ebx,%edi
80104e4f:	89 d1                	mov    %edx,%ecx
80104e51:	fc                   	cld    
80104e52:	f3 ab                	rep stos %eax,%es:(%edi)
80104e54:	89 ca                	mov    %ecx,%edx
80104e56:	89 fb                	mov    %edi,%ebx
80104e58:	89 5d 08             	mov    %ebx,0x8(%ebp)
80104e5b:	89 55 10             	mov    %edx,0x10(%ebp)
}
80104e5e:	90                   	nop
80104e5f:	5b                   	pop    %ebx
80104e60:	5f                   	pop    %edi
80104e61:	5d                   	pop    %ebp
80104e62:	c3                   	ret    

80104e63 <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
80104e63:	55                   	push   %ebp
80104e64:	89 e5                	mov    %esp,%ebp
  if ((int)dst%4 == 0 && n%4 == 0){
80104e66:	8b 45 08             	mov    0x8(%ebp),%eax
80104e69:	83 e0 03             	and    $0x3,%eax
80104e6c:	85 c0                	test   %eax,%eax
80104e6e:	75 43                	jne    80104eb3 <memset+0x50>
80104e70:	8b 45 10             	mov    0x10(%ebp),%eax
80104e73:	83 e0 03             	and    $0x3,%eax
80104e76:	85 c0                	test   %eax,%eax
80104e78:	75 39                	jne    80104eb3 <memset+0x50>
    c &= 0xFF;
80104e7a:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
80104e81:	8b 45 10             	mov    0x10(%ebp),%eax
80104e84:	c1 e8 02             	shr    $0x2,%eax
80104e87:	89 c2                	mov    %eax,%edx
80104e89:	8b 45 0c             	mov    0xc(%ebp),%eax
80104e8c:	c1 e0 18             	shl    $0x18,%eax
80104e8f:	89 c1                	mov    %eax,%ecx
80104e91:	8b 45 0c             	mov    0xc(%ebp),%eax
80104e94:	c1 e0 10             	shl    $0x10,%eax
80104e97:	09 c1                	or     %eax,%ecx
80104e99:	8b 45 0c             	mov    0xc(%ebp),%eax
80104e9c:	c1 e0 08             	shl    $0x8,%eax
80104e9f:	09 c8                	or     %ecx,%eax
80104ea1:	0b 45 0c             	or     0xc(%ebp),%eax
80104ea4:	52                   	push   %edx
80104ea5:	50                   	push   %eax
80104ea6:	ff 75 08             	push   0x8(%ebp)
80104ea9:	e8 8f ff ff ff       	call   80104e3d <stosl>
80104eae:	83 c4 0c             	add    $0xc,%esp
80104eb1:	eb 12                	jmp    80104ec5 <memset+0x62>
  } else
    stosb(dst, c, n);
80104eb3:	8b 45 10             	mov    0x10(%ebp),%eax
80104eb6:	50                   	push   %eax
80104eb7:	ff 75 0c             	push   0xc(%ebp)
80104eba:	ff 75 08             	push   0x8(%ebp)
80104ebd:	e8 55 ff ff ff       	call   80104e17 <stosb>
80104ec2:	83 c4 0c             	add    $0xc,%esp
  return dst;
80104ec5:	8b 45 08             	mov    0x8(%ebp),%eax
}
80104ec8:	c9                   	leave  
80104ec9:	c3                   	ret    

80104eca <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
80104eca:	55                   	push   %ebp
80104ecb:	89 e5                	mov    %esp,%ebp
80104ecd:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;

  s1 = v1;
80104ed0:	8b 45 08             	mov    0x8(%ebp),%eax
80104ed3:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
80104ed6:	8b 45 0c             	mov    0xc(%ebp),%eax
80104ed9:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
80104edc:	eb 30                	jmp    80104f0e <memcmp+0x44>
    if(*s1 != *s2)
80104ede:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104ee1:	0f b6 10             	movzbl (%eax),%edx
80104ee4:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104ee7:	0f b6 00             	movzbl (%eax),%eax
80104eea:	38 c2                	cmp    %al,%dl
80104eec:	74 18                	je     80104f06 <memcmp+0x3c>
      return *s1 - *s2;
80104eee:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104ef1:	0f b6 00             	movzbl (%eax),%eax
80104ef4:	0f b6 d0             	movzbl %al,%edx
80104ef7:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104efa:	0f b6 00             	movzbl (%eax),%eax
80104efd:	0f b6 c8             	movzbl %al,%ecx
80104f00:	89 d0                	mov    %edx,%eax
80104f02:	29 c8                	sub    %ecx,%eax
80104f04:	eb 1a                	jmp    80104f20 <memcmp+0x56>
    s1++, s2++;
80104f06:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80104f0a:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
  while(n-- > 0){
80104f0e:	8b 45 10             	mov    0x10(%ebp),%eax
80104f11:	8d 50 ff             	lea    -0x1(%eax),%edx
80104f14:	89 55 10             	mov    %edx,0x10(%ebp)
80104f17:	85 c0                	test   %eax,%eax
80104f19:	75 c3                	jne    80104ede <memcmp+0x14>
  }

  return 0;
80104f1b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104f20:	c9                   	leave  
80104f21:	c3                   	ret    

80104f22 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
80104f22:	55                   	push   %ebp
80104f23:	89 e5                	mov    %esp,%ebp
80104f25:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
80104f28:	8b 45 0c             	mov    0xc(%ebp),%eax
80104f2b:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
80104f2e:	8b 45 08             	mov    0x8(%ebp),%eax
80104f31:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
80104f34:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104f37:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80104f3a:	73 54                	jae    80104f90 <memmove+0x6e>
80104f3c:	8b 55 fc             	mov    -0x4(%ebp),%edx
80104f3f:	8b 45 10             	mov    0x10(%ebp),%eax
80104f42:	01 d0                	add    %edx,%eax
80104f44:	39 45 f8             	cmp    %eax,-0x8(%ebp)
80104f47:	73 47                	jae    80104f90 <memmove+0x6e>
    s += n;
80104f49:	8b 45 10             	mov    0x10(%ebp),%eax
80104f4c:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
80104f4f:	8b 45 10             	mov    0x10(%ebp),%eax
80104f52:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
80104f55:	eb 13                	jmp    80104f6a <memmove+0x48>
      *--d = *--s;
80104f57:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
80104f5b:	83 6d f8 01          	subl   $0x1,-0x8(%ebp)
80104f5f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104f62:	0f b6 10             	movzbl (%eax),%edx
80104f65:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104f68:	88 10                	mov    %dl,(%eax)
    while(n-- > 0)
80104f6a:	8b 45 10             	mov    0x10(%ebp),%eax
80104f6d:	8d 50 ff             	lea    -0x1(%eax),%edx
80104f70:	89 55 10             	mov    %edx,0x10(%ebp)
80104f73:	85 c0                	test   %eax,%eax
80104f75:	75 e0                	jne    80104f57 <memmove+0x35>
  if(s < d && s + n > d){
80104f77:	eb 24                	jmp    80104f9d <memmove+0x7b>
  } else
    while(n-- > 0)
      *d++ = *s++;
80104f79:	8b 55 fc             	mov    -0x4(%ebp),%edx
80104f7c:	8d 42 01             	lea    0x1(%edx),%eax
80104f7f:	89 45 fc             	mov    %eax,-0x4(%ebp)
80104f82:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104f85:	8d 48 01             	lea    0x1(%eax),%ecx
80104f88:	89 4d f8             	mov    %ecx,-0x8(%ebp)
80104f8b:	0f b6 12             	movzbl (%edx),%edx
80104f8e:	88 10                	mov    %dl,(%eax)
    while(n-- > 0)
80104f90:	8b 45 10             	mov    0x10(%ebp),%eax
80104f93:	8d 50 ff             	lea    -0x1(%eax),%edx
80104f96:	89 55 10             	mov    %edx,0x10(%ebp)
80104f99:	85 c0                	test   %eax,%eax
80104f9b:	75 dc                	jne    80104f79 <memmove+0x57>

  return dst;
80104f9d:	8b 45 08             	mov    0x8(%ebp),%eax
}
80104fa0:	c9                   	leave  
80104fa1:	c3                   	ret    

80104fa2 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
80104fa2:	55                   	push   %ebp
80104fa3:	89 e5                	mov    %esp,%ebp
  return memmove(dst, src, n);
80104fa5:	ff 75 10             	push   0x10(%ebp)
80104fa8:	ff 75 0c             	push   0xc(%ebp)
80104fab:	ff 75 08             	push   0x8(%ebp)
80104fae:	e8 6f ff ff ff       	call   80104f22 <memmove>
80104fb3:	83 c4 0c             	add    $0xc,%esp
}
80104fb6:	c9                   	leave  
80104fb7:	c3                   	ret    

80104fb8 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
80104fb8:	55                   	push   %ebp
80104fb9:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
80104fbb:	eb 0c                	jmp    80104fc9 <strncmp+0x11>
    n--, p++, q++;
80104fbd:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80104fc1:	83 45 08 01          	addl   $0x1,0x8(%ebp)
80104fc5:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(n > 0 && *p && *p == *q)
80104fc9:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104fcd:	74 1a                	je     80104fe9 <strncmp+0x31>
80104fcf:	8b 45 08             	mov    0x8(%ebp),%eax
80104fd2:	0f b6 00             	movzbl (%eax),%eax
80104fd5:	84 c0                	test   %al,%al
80104fd7:	74 10                	je     80104fe9 <strncmp+0x31>
80104fd9:	8b 45 08             	mov    0x8(%ebp),%eax
80104fdc:	0f b6 10             	movzbl (%eax),%edx
80104fdf:	8b 45 0c             	mov    0xc(%ebp),%eax
80104fe2:	0f b6 00             	movzbl (%eax),%eax
80104fe5:	38 c2                	cmp    %al,%dl
80104fe7:	74 d4                	je     80104fbd <strncmp+0x5>
  if(n == 0)
80104fe9:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104fed:	75 07                	jne    80104ff6 <strncmp+0x3e>
    return 0;
80104fef:	b8 00 00 00 00       	mov    $0x0,%eax
80104ff4:	eb 16                	jmp    8010500c <strncmp+0x54>
  return (uchar)*p - (uchar)*q;
80104ff6:	8b 45 08             	mov    0x8(%ebp),%eax
80104ff9:	0f b6 00             	movzbl (%eax),%eax
80104ffc:	0f b6 d0             	movzbl %al,%edx
80104fff:	8b 45 0c             	mov    0xc(%ebp),%eax
80105002:	0f b6 00             	movzbl (%eax),%eax
80105005:	0f b6 c8             	movzbl %al,%ecx
80105008:	89 d0                	mov    %edx,%eax
8010500a:	29 c8                	sub    %ecx,%eax
}
8010500c:	5d                   	pop    %ebp
8010500d:	c3                   	ret    

8010500e <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
8010500e:	55                   	push   %ebp
8010500f:	89 e5                	mov    %esp,%ebp
80105011:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
80105014:	8b 45 08             	mov    0x8(%ebp),%eax
80105017:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
8010501a:	90                   	nop
8010501b:	8b 45 10             	mov    0x10(%ebp),%eax
8010501e:	8d 50 ff             	lea    -0x1(%eax),%edx
80105021:	89 55 10             	mov    %edx,0x10(%ebp)
80105024:	85 c0                	test   %eax,%eax
80105026:	7e 2c                	jle    80105054 <strncpy+0x46>
80105028:	8b 55 0c             	mov    0xc(%ebp),%edx
8010502b:	8d 42 01             	lea    0x1(%edx),%eax
8010502e:	89 45 0c             	mov    %eax,0xc(%ebp)
80105031:	8b 45 08             	mov    0x8(%ebp),%eax
80105034:	8d 48 01             	lea    0x1(%eax),%ecx
80105037:	89 4d 08             	mov    %ecx,0x8(%ebp)
8010503a:	0f b6 12             	movzbl (%edx),%edx
8010503d:	88 10                	mov    %dl,(%eax)
8010503f:	0f b6 00             	movzbl (%eax),%eax
80105042:	84 c0                	test   %al,%al
80105044:	75 d5                	jne    8010501b <strncpy+0xd>
    ;
  while(n-- > 0)
80105046:	eb 0c                	jmp    80105054 <strncpy+0x46>
    *s++ = 0;
80105048:	8b 45 08             	mov    0x8(%ebp),%eax
8010504b:	8d 50 01             	lea    0x1(%eax),%edx
8010504e:	89 55 08             	mov    %edx,0x8(%ebp)
80105051:	c6 00 00             	movb   $0x0,(%eax)
  while(n-- > 0)
80105054:	8b 45 10             	mov    0x10(%ebp),%eax
80105057:	8d 50 ff             	lea    -0x1(%eax),%edx
8010505a:	89 55 10             	mov    %edx,0x10(%ebp)
8010505d:	85 c0                	test   %eax,%eax
8010505f:	7f e7                	jg     80105048 <strncpy+0x3a>
  return os;
80105061:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105064:	c9                   	leave  
80105065:	c3                   	ret    

80105066 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
80105066:	55                   	push   %ebp
80105067:	89 e5                	mov    %esp,%ebp
80105069:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
8010506c:	8b 45 08             	mov    0x8(%ebp),%eax
8010506f:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
80105072:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105076:	7f 05                	jg     8010507d <safestrcpy+0x17>
    return os;
80105078:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010507b:	eb 32                	jmp    801050af <safestrcpy+0x49>
  while(--n > 0 && (*s++ = *t++) != 0)
8010507d:	90                   	nop
8010507e:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80105082:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105086:	7e 1e                	jle    801050a6 <safestrcpy+0x40>
80105088:	8b 55 0c             	mov    0xc(%ebp),%edx
8010508b:	8d 42 01             	lea    0x1(%edx),%eax
8010508e:	89 45 0c             	mov    %eax,0xc(%ebp)
80105091:	8b 45 08             	mov    0x8(%ebp),%eax
80105094:	8d 48 01             	lea    0x1(%eax),%ecx
80105097:	89 4d 08             	mov    %ecx,0x8(%ebp)
8010509a:	0f b6 12             	movzbl (%edx),%edx
8010509d:	88 10                	mov    %dl,(%eax)
8010509f:	0f b6 00             	movzbl (%eax),%eax
801050a2:	84 c0                	test   %al,%al
801050a4:	75 d8                	jne    8010507e <safestrcpy+0x18>
    ;
  *s = 0;
801050a6:	8b 45 08             	mov    0x8(%ebp),%eax
801050a9:	c6 00 00             	movb   $0x0,(%eax)
  return os;
801050ac:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801050af:	c9                   	leave  
801050b0:	c3                   	ret    

801050b1 <strlen>:

int
strlen(const char *s)
{
801050b1:	55                   	push   %ebp
801050b2:	89 e5                	mov    %esp,%ebp
801050b4:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
801050b7:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801050be:	eb 04                	jmp    801050c4 <strlen+0x13>
801050c0:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801050c4:	8b 55 fc             	mov    -0x4(%ebp),%edx
801050c7:	8b 45 08             	mov    0x8(%ebp),%eax
801050ca:	01 d0                	add    %edx,%eax
801050cc:	0f b6 00             	movzbl (%eax),%eax
801050cf:	84 c0                	test   %al,%al
801050d1:	75 ed                	jne    801050c0 <strlen+0xf>
    ;
  return n;
801050d3:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801050d6:	c9                   	leave  
801050d7:	c3                   	ret    

801050d8 <swtch>:
# a struct context, and save its address in *old.
# Switch stacks to new and pop previously-saved registers.

.globl swtch
swtch:
  movl 4(%esp), %eax
801050d8:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
801050dc:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
801050e0:	55                   	push   %ebp
  pushl %ebx
801050e1:	53                   	push   %ebx
  pushl %esi
801050e2:	56                   	push   %esi
  pushl %edi
801050e3:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
801050e4:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
801050e6:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
801050e8:	5f                   	pop    %edi
  popl %esi
801050e9:	5e                   	pop    %esi
  popl %ebx
801050ea:	5b                   	pop    %ebx
  popl %ebp
801050eb:	5d                   	pop    %ebp
  ret
801050ec:	c3                   	ret    

801050ed <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
801050ed:	55                   	push   %ebp
801050ee:	89 e5                	mov    %esp,%ebp
801050f0:	83 ec 18             	sub    $0x18,%esp
  struct proc *curproc = myproc();
801050f3:	e8 1c ee ff ff       	call   80103f14 <myproc>
801050f8:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(addr >= curproc->sz || addr+4 > curproc->sz)
801050fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801050fe:	8b 00                	mov    (%eax),%eax
80105100:	39 45 08             	cmp    %eax,0x8(%ebp)
80105103:	73 0f                	jae    80105114 <fetchint+0x27>
80105105:	8b 45 08             	mov    0x8(%ebp),%eax
80105108:	8d 50 04             	lea    0x4(%eax),%edx
8010510b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010510e:	8b 00                	mov    (%eax),%eax
80105110:	39 c2                	cmp    %eax,%edx
80105112:	76 07                	jbe    8010511b <fetchint+0x2e>
    return -1;
80105114:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105119:	eb 0f                	jmp    8010512a <fetchint+0x3d>
  *ip = *(int*)(addr);
8010511b:	8b 45 08             	mov    0x8(%ebp),%eax
8010511e:	8b 10                	mov    (%eax),%edx
80105120:	8b 45 0c             	mov    0xc(%ebp),%eax
80105123:	89 10                	mov    %edx,(%eax)
  return 0;
80105125:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010512a:	c9                   	leave  
8010512b:	c3                   	ret    

8010512c <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
8010512c:	55                   	push   %ebp
8010512d:	89 e5                	mov    %esp,%ebp
8010512f:	83 ec 18             	sub    $0x18,%esp
  char *s, *ep;
  struct proc *curproc = myproc();
80105132:	e8 dd ed ff ff       	call   80103f14 <myproc>
80105137:	89 45 f0             	mov    %eax,-0x10(%ebp)

  if(addr >= curproc->sz)
8010513a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010513d:	8b 00                	mov    (%eax),%eax
8010513f:	39 45 08             	cmp    %eax,0x8(%ebp)
80105142:	72 07                	jb     8010514b <fetchstr+0x1f>
    return -1;
80105144:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105149:	eb 41                	jmp    8010518c <fetchstr+0x60>
  *pp = (char*)addr;
8010514b:	8b 55 08             	mov    0x8(%ebp),%edx
8010514e:	8b 45 0c             	mov    0xc(%ebp),%eax
80105151:	89 10                	mov    %edx,(%eax)
  ep = (char*)curproc->sz;
80105153:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105156:	8b 00                	mov    (%eax),%eax
80105158:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(s = *pp; s < ep; s++){
8010515b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010515e:	8b 00                	mov    (%eax),%eax
80105160:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105163:	eb 1a                	jmp    8010517f <fetchstr+0x53>
    if(*s == 0)
80105165:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105168:	0f b6 00             	movzbl (%eax),%eax
8010516b:	84 c0                	test   %al,%al
8010516d:	75 0c                	jne    8010517b <fetchstr+0x4f>
      return s - *pp;
8010516f:	8b 45 0c             	mov    0xc(%ebp),%eax
80105172:	8b 10                	mov    (%eax),%edx
80105174:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105177:	29 d0                	sub    %edx,%eax
80105179:	eb 11                	jmp    8010518c <fetchstr+0x60>
  for(s = *pp; s < ep; s++){
8010517b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010517f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105182:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80105185:	72 de                	jb     80105165 <fetchstr+0x39>
  }
  return -1;
80105187:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010518c:	c9                   	leave  
8010518d:	c3                   	ret    

8010518e <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
8010518e:	55                   	push   %ebp
8010518f:	89 e5                	mov    %esp,%ebp
80105191:	83 ec 08             	sub    $0x8,%esp
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
80105194:	e8 7b ed ff ff       	call   80103f14 <myproc>
80105199:	8b 40 18             	mov    0x18(%eax),%eax
8010519c:	8b 50 44             	mov    0x44(%eax),%edx
8010519f:	8b 45 08             	mov    0x8(%ebp),%eax
801051a2:	c1 e0 02             	shl    $0x2,%eax
801051a5:	01 d0                	add    %edx,%eax
801051a7:	83 c0 04             	add    $0x4,%eax
801051aa:	83 ec 08             	sub    $0x8,%esp
801051ad:	ff 75 0c             	push   0xc(%ebp)
801051b0:	50                   	push   %eax
801051b1:	e8 37 ff ff ff       	call   801050ed <fetchint>
801051b6:	83 c4 10             	add    $0x10,%esp
}
801051b9:	c9                   	leave  
801051ba:	c3                   	ret    

801051bb <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
801051bb:	55                   	push   %ebp
801051bc:	89 e5                	mov    %esp,%ebp
801051be:	83 ec 18             	sub    $0x18,%esp
  int i;
  struct proc *curproc = myproc();
801051c1:	e8 4e ed ff ff       	call   80103f14 <myproc>
801051c6:	89 45 f4             	mov    %eax,-0xc(%ebp)
 
  if(argint(n, &i) < 0)
801051c9:	83 ec 08             	sub    $0x8,%esp
801051cc:	8d 45 f0             	lea    -0x10(%ebp),%eax
801051cf:	50                   	push   %eax
801051d0:	ff 75 08             	push   0x8(%ebp)
801051d3:	e8 b6 ff ff ff       	call   8010518e <argint>
801051d8:	83 c4 10             	add    $0x10,%esp
801051db:	85 c0                	test   %eax,%eax
801051dd:	79 07                	jns    801051e6 <argptr+0x2b>
    return -1;
801051df:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801051e4:	eb 3b                	jmp    80105221 <argptr+0x66>
  if(size < 0 || (uint)i >= curproc->sz || (uint)i+size > curproc->sz)
801051e6:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801051ea:	78 1f                	js     8010520b <argptr+0x50>
801051ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
801051ef:	8b 00                	mov    (%eax),%eax
801051f1:	8b 55 f0             	mov    -0x10(%ebp),%edx
801051f4:	39 d0                	cmp    %edx,%eax
801051f6:	76 13                	jbe    8010520b <argptr+0x50>
801051f8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801051fb:	89 c2                	mov    %eax,%edx
801051fd:	8b 45 10             	mov    0x10(%ebp),%eax
80105200:	01 c2                	add    %eax,%edx
80105202:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105205:	8b 00                	mov    (%eax),%eax
80105207:	39 c2                	cmp    %eax,%edx
80105209:	76 07                	jbe    80105212 <argptr+0x57>
    return -1;
8010520b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105210:	eb 0f                	jmp    80105221 <argptr+0x66>
  *pp = (char*)i;
80105212:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105215:	89 c2                	mov    %eax,%edx
80105217:	8b 45 0c             	mov    0xc(%ebp),%eax
8010521a:	89 10                	mov    %edx,(%eax)
  return 0;
8010521c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105221:	c9                   	leave  
80105222:	c3                   	ret    

80105223 <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
80105223:	55                   	push   %ebp
80105224:	89 e5                	mov    %esp,%ebp
80105226:	83 ec 18             	sub    $0x18,%esp
  int addr;
  if(argint(n, &addr) < 0)
80105229:	83 ec 08             	sub    $0x8,%esp
8010522c:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010522f:	50                   	push   %eax
80105230:	ff 75 08             	push   0x8(%ebp)
80105233:	e8 56 ff ff ff       	call   8010518e <argint>
80105238:	83 c4 10             	add    $0x10,%esp
8010523b:	85 c0                	test   %eax,%eax
8010523d:	79 07                	jns    80105246 <argstr+0x23>
    return -1;
8010523f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105244:	eb 12                	jmp    80105258 <argstr+0x35>
  return fetchstr(addr, pp);
80105246:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105249:	83 ec 08             	sub    $0x8,%esp
8010524c:	ff 75 0c             	push   0xc(%ebp)
8010524f:	50                   	push   %eax
80105250:	e8 d7 fe ff ff       	call   8010512c <fetchstr>
80105255:	83 c4 10             	add    $0x10,%esp
}
80105258:	c9                   	leave  
80105259:	c3                   	ret    

8010525a <syscall>:
    [SYS_thread_num] sys_thread_num,
};

void
syscall(void)
{
8010525a:	55                   	push   %ebp
8010525b:	89 e5                	mov    %esp,%ebp
8010525d:	83 ec 18             	sub    $0x18,%esp
  int num;
  struct proc *curproc = myproc();
80105260:	e8 af ec ff ff       	call   80103f14 <myproc>
80105265:	89 45 f4             	mov    %eax,-0xc(%ebp)

  num = curproc->tf->eax;
80105268:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010526b:	8b 40 18             	mov    0x18(%eax),%eax
8010526e:	8b 40 1c             	mov    0x1c(%eax),%eax
80105271:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
80105274:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105278:	7e 2f                	jle    801052a9 <syscall+0x4f>
8010527a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010527d:	83 f8 17             	cmp    $0x17,%eax
80105280:	77 27                	ja     801052a9 <syscall+0x4f>
80105282:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105285:	8b 04 85 20 f0 10 80 	mov    -0x7fef0fe0(,%eax,4),%eax
8010528c:	85 c0                	test   %eax,%eax
8010528e:	74 19                	je     801052a9 <syscall+0x4f>
    curproc->tf->eax = syscalls[num]();
80105290:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105293:	8b 04 85 20 f0 10 80 	mov    -0x7fef0fe0(,%eax,4),%eax
8010529a:	ff d0                	call   *%eax
8010529c:	89 c2                	mov    %eax,%edx
8010529e:	8b 45 f4             	mov    -0xc(%ebp),%eax
801052a1:	8b 40 18             	mov    0x18(%eax),%eax
801052a4:	89 50 1c             	mov    %edx,0x1c(%eax)
801052a7:	eb 2c                	jmp    801052d5 <syscall+0x7b>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            curproc->pid, curproc->name, num);
801052a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801052ac:	8d 50 6c             	lea    0x6c(%eax),%edx
    cprintf("%d %s: unknown sys call %d\n",
801052af:	8b 45 f4             	mov    -0xc(%ebp),%eax
801052b2:	8b 40 10             	mov    0x10(%eax),%eax
801052b5:	ff 75 f0             	push   -0x10(%ebp)
801052b8:	52                   	push   %edx
801052b9:	50                   	push   %eax
801052ba:	68 bc a8 10 80       	push   $0x8010a8bc
801052bf:	e8 30 b1 ff ff       	call   801003f4 <cprintf>
801052c4:	83 c4 10             	add    $0x10,%esp
    curproc->tf->eax = -1;
801052c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801052ca:	8b 40 18             	mov    0x18(%eax),%eax
801052cd:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
801052d4:	90                   	nop
801052d5:	90                   	nop
801052d6:	c9                   	leave  
801052d7:	c3                   	ret    

801052d8 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
801052d8:	55                   	push   %ebp
801052d9:	89 e5                	mov    %esp,%ebp
801052db:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
801052de:	83 ec 08             	sub    $0x8,%esp
801052e1:	8d 45 f0             	lea    -0x10(%ebp),%eax
801052e4:	50                   	push   %eax
801052e5:	ff 75 08             	push   0x8(%ebp)
801052e8:	e8 a1 fe ff ff       	call   8010518e <argint>
801052ed:	83 c4 10             	add    $0x10,%esp
801052f0:	85 c0                	test   %eax,%eax
801052f2:	79 07                	jns    801052fb <argfd+0x23>
    return -1;
801052f4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801052f9:	eb 4f                	jmp    8010534a <argfd+0x72>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
801052fb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801052fe:	85 c0                	test   %eax,%eax
80105300:	78 20                	js     80105322 <argfd+0x4a>
80105302:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105305:	83 f8 0f             	cmp    $0xf,%eax
80105308:	7f 18                	jg     80105322 <argfd+0x4a>
8010530a:	e8 05 ec ff ff       	call   80103f14 <myproc>
8010530f:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105312:	83 c2 08             	add    $0x8,%edx
80105315:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105319:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010531c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105320:	75 07                	jne    80105329 <argfd+0x51>
    return -1;
80105322:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105327:	eb 21                	jmp    8010534a <argfd+0x72>
  if(pfd)
80105329:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
8010532d:	74 08                	je     80105337 <argfd+0x5f>
    *pfd = fd;
8010532f:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105332:	8b 45 0c             	mov    0xc(%ebp),%eax
80105335:	89 10                	mov    %edx,(%eax)
  if(pf)
80105337:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010533b:	74 08                	je     80105345 <argfd+0x6d>
    *pf = f;
8010533d:	8b 45 10             	mov    0x10(%ebp),%eax
80105340:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105343:	89 10                	mov    %edx,(%eax)
  return 0;
80105345:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010534a:	c9                   	leave  
8010534b:	c3                   	ret    

8010534c <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
8010534c:	55                   	push   %ebp
8010534d:	89 e5                	mov    %esp,%ebp
8010534f:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct proc *curproc = myproc();
80105352:	e8 bd eb ff ff       	call   80103f14 <myproc>
80105357:	89 45 f0             	mov    %eax,-0x10(%ebp)

  for(fd = 0; fd < NOFILE; fd++){
8010535a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80105361:	eb 2a                	jmp    8010538d <fdalloc+0x41>
    if(curproc->ofile[fd] == 0){
80105363:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105366:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105369:	83 c2 08             	add    $0x8,%edx
8010536c:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105370:	85 c0                	test   %eax,%eax
80105372:	75 15                	jne    80105389 <fdalloc+0x3d>
      curproc->ofile[fd] = f;
80105374:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105377:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010537a:	8d 4a 08             	lea    0x8(%edx),%ecx
8010537d:	8b 55 08             	mov    0x8(%ebp),%edx
80105380:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
      return fd;
80105384:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105387:	eb 0f                	jmp    80105398 <fdalloc+0x4c>
  for(fd = 0; fd < NOFILE; fd++){
80105389:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010538d:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
80105391:	7e d0                	jle    80105363 <fdalloc+0x17>
    }
  }
  return -1;
80105393:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105398:	c9                   	leave  
80105399:	c3                   	ret    

8010539a <sys_dup>:

int
sys_dup(void)
{
8010539a:	55                   	push   %ebp
8010539b:	89 e5                	mov    %esp,%ebp
8010539d:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int fd;

  if(argfd(0, 0, &f) < 0)
801053a0:	83 ec 04             	sub    $0x4,%esp
801053a3:	8d 45 f0             	lea    -0x10(%ebp),%eax
801053a6:	50                   	push   %eax
801053a7:	6a 00                	push   $0x0
801053a9:	6a 00                	push   $0x0
801053ab:	e8 28 ff ff ff       	call   801052d8 <argfd>
801053b0:	83 c4 10             	add    $0x10,%esp
801053b3:	85 c0                	test   %eax,%eax
801053b5:	79 07                	jns    801053be <sys_dup+0x24>
    return -1;
801053b7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801053bc:	eb 31                	jmp    801053ef <sys_dup+0x55>
  if((fd=fdalloc(f)) < 0)
801053be:	8b 45 f0             	mov    -0x10(%ebp),%eax
801053c1:	83 ec 0c             	sub    $0xc,%esp
801053c4:	50                   	push   %eax
801053c5:	e8 82 ff ff ff       	call   8010534c <fdalloc>
801053ca:	83 c4 10             	add    $0x10,%esp
801053cd:	89 45 f4             	mov    %eax,-0xc(%ebp)
801053d0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801053d4:	79 07                	jns    801053dd <sys_dup+0x43>
    return -1;
801053d6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801053db:	eb 12                	jmp    801053ef <sys_dup+0x55>
  filedup(f);
801053dd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801053e0:	83 ec 0c             	sub    $0xc,%esp
801053e3:	50                   	push   %eax
801053e4:	e8 61 bc ff ff       	call   8010104a <filedup>
801053e9:	83 c4 10             	add    $0x10,%esp
  return fd;
801053ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801053ef:	c9                   	leave  
801053f0:	c3                   	ret    

801053f1 <sys_read>:

int
sys_read(void)
{
801053f1:	55                   	push   %ebp
801053f2:	89 e5                	mov    %esp,%ebp
801053f4:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
801053f7:	83 ec 04             	sub    $0x4,%esp
801053fa:	8d 45 f4             	lea    -0xc(%ebp),%eax
801053fd:	50                   	push   %eax
801053fe:	6a 00                	push   $0x0
80105400:	6a 00                	push   $0x0
80105402:	e8 d1 fe ff ff       	call   801052d8 <argfd>
80105407:	83 c4 10             	add    $0x10,%esp
8010540a:	85 c0                	test   %eax,%eax
8010540c:	78 2e                	js     8010543c <sys_read+0x4b>
8010540e:	83 ec 08             	sub    $0x8,%esp
80105411:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105414:	50                   	push   %eax
80105415:	6a 02                	push   $0x2
80105417:	e8 72 fd ff ff       	call   8010518e <argint>
8010541c:	83 c4 10             	add    $0x10,%esp
8010541f:	85 c0                	test   %eax,%eax
80105421:	78 19                	js     8010543c <sys_read+0x4b>
80105423:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105426:	83 ec 04             	sub    $0x4,%esp
80105429:	50                   	push   %eax
8010542a:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010542d:	50                   	push   %eax
8010542e:	6a 01                	push   $0x1
80105430:	e8 86 fd ff ff       	call   801051bb <argptr>
80105435:	83 c4 10             	add    $0x10,%esp
80105438:	85 c0                	test   %eax,%eax
8010543a:	79 07                	jns    80105443 <sys_read+0x52>
    return -1;
8010543c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105441:	eb 17                	jmp    8010545a <sys_read+0x69>
  return fileread(f, p, n);
80105443:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105446:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105449:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010544c:	83 ec 04             	sub    $0x4,%esp
8010544f:	51                   	push   %ecx
80105450:	52                   	push   %edx
80105451:	50                   	push   %eax
80105452:	e8 83 bd ff ff       	call   801011da <fileread>
80105457:	83 c4 10             	add    $0x10,%esp
}
8010545a:	c9                   	leave  
8010545b:	c3                   	ret    

8010545c <sys_write>:

int
sys_write(void)
{
8010545c:	55                   	push   %ebp
8010545d:	89 e5                	mov    %esp,%ebp
8010545f:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105462:	83 ec 04             	sub    $0x4,%esp
80105465:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105468:	50                   	push   %eax
80105469:	6a 00                	push   $0x0
8010546b:	6a 00                	push   $0x0
8010546d:	e8 66 fe ff ff       	call   801052d8 <argfd>
80105472:	83 c4 10             	add    $0x10,%esp
80105475:	85 c0                	test   %eax,%eax
80105477:	78 2e                	js     801054a7 <sys_write+0x4b>
80105479:	83 ec 08             	sub    $0x8,%esp
8010547c:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010547f:	50                   	push   %eax
80105480:	6a 02                	push   $0x2
80105482:	e8 07 fd ff ff       	call   8010518e <argint>
80105487:	83 c4 10             	add    $0x10,%esp
8010548a:	85 c0                	test   %eax,%eax
8010548c:	78 19                	js     801054a7 <sys_write+0x4b>
8010548e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105491:	83 ec 04             	sub    $0x4,%esp
80105494:	50                   	push   %eax
80105495:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105498:	50                   	push   %eax
80105499:	6a 01                	push   $0x1
8010549b:	e8 1b fd ff ff       	call   801051bb <argptr>
801054a0:	83 c4 10             	add    $0x10,%esp
801054a3:	85 c0                	test   %eax,%eax
801054a5:	79 07                	jns    801054ae <sys_write+0x52>
    return -1;
801054a7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801054ac:	eb 17                	jmp    801054c5 <sys_write+0x69>
  return filewrite(f, p, n);
801054ae:	8b 4d f0             	mov    -0x10(%ebp),%ecx
801054b1:	8b 55 ec             	mov    -0x14(%ebp),%edx
801054b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801054b7:	83 ec 04             	sub    $0x4,%esp
801054ba:	51                   	push   %ecx
801054bb:	52                   	push   %edx
801054bc:	50                   	push   %eax
801054bd:	e8 d0 bd ff ff       	call   80101292 <filewrite>
801054c2:	83 c4 10             	add    $0x10,%esp
}
801054c5:	c9                   	leave  
801054c6:	c3                   	ret    

801054c7 <sys_close>:

int
sys_close(void)
{
801054c7:	55                   	push   %ebp
801054c8:	89 e5                	mov    %esp,%ebp
801054ca:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argfd(0, &fd, &f) < 0)
801054cd:	83 ec 04             	sub    $0x4,%esp
801054d0:	8d 45 f0             	lea    -0x10(%ebp),%eax
801054d3:	50                   	push   %eax
801054d4:	8d 45 f4             	lea    -0xc(%ebp),%eax
801054d7:	50                   	push   %eax
801054d8:	6a 00                	push   $0x0
801054da:	e8 f9 fd ff ff       	call   801052d8 <argfd>
801054df:	83 c4 10             	add    $0x10,%esp
801054e2:	85 c0                	test   %eax,%eax
801054e4:	79 07                	jns    801054ed <sys_close+0x26>
    return -1;
801054e6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801054eb:	eb 27                	jmp    80105514 <sys_close+0x4d>
  myproc()->ofile[fd] = 0;
801054ed:	e8 22 ea ff ff       	call   80103f14 <myproc>
801054f2:	8b 55 f4             	mov    -0xc(%ebp),%edx
801054f5:	83 c2 08             	add    $0x8,%edx
801054f8:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
801054ff:	00 
  fileclose(f);
80105500:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105503:	83 ec 0c             	sub    $0xc,%esp
80105506:	50                   	push   %eax
80105507:	e8 8f bb ff ff       	call   8010109b <fileclose>
8010550c:	83 c4 10             	add    $0x10,%esp
  return 0;
8010550f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105514:	c9                   	leave  
80105515:	c3                   	ret    

80105516 <sys_fstat>:

int
sys_fstat(void)
{
80105516:	55                   	push   %ebp
80105517:	89 e5                	mov    %esp,%ebp
80105519:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  struct stat *st;

  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
8010551c:	83 ec 04             	sub    $0x4,%esp
8010551f:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105522:	50                   	push   %eax
80105523:	6a 00                	push   $0x0
80105525:	6a 00                	push   $0x0
80105527:	e8 ac fd ff ff       	call   801052d8 <argfd>
8010552c:	83 c4 10             	add    $0x10,%esp
8010552f:	85 c0                	test   %eax,%eax
80105531:	78 17                	js     8010554a <sys_fstat+0x34>
80105533:	83 ec 04             	sub    $0x4,%esp
80105536:	6a 14                	push   $0x14
80105538:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010553b:	50                   	push   %eax
8010553c:	6a 01                	push   $0x1
8010553e:	e8 78 fc ff ff       	call   801051bb <argptr>
80105543:	83 c4 10             	add    $0x10,%esp
80105546:	85 c0                	test   %eax,%eax
80105548:	79 07                	jns    80105551 <sys_fstat+0x3b>
    return -1;
8010554a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010554f:	eb 13                	jmp    80105564 <sys_fstat+0x4e>
  return filestat(f, st);
80105551:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105554:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105557:	83 ec 08             	sub    $0x8,%esp
8010555a:	52                   	push   %edx
8010555b:	50                   	push   %eax
8010555c:	e8 22 bc ff ff       	call   80101183 <filestat>
80105561:	83 c4 10             	add    $0x10,%esp
}
80105564:	c9                   	leave  
80105565:	c3                   	ret    

80105566 <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
80105566:	55                   	push   %ebp
80105567:	89 e5                	mov    %esp,%ebp
80105569:	83 ec 28             	sub    $0x28,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
8010556c:	83 ec 08             	sub    $0x8,%esp
8010556f:	8d 45 d8             	lea    -0x28(%ebp),%eax
80105572:	50                   	push   %eax
80105573:	6a 00                	push   $0x0
80105575:	e8 a9 fc ff ff       	call   80105223 <argstr>
8010557a:	83 c4 10             	add    $0x10,%esp
8010557d:	85 c0                	test   %eax,%eax
8010557f:	78 15                	js     80105596 <sys_link+0x30>
80105581:	83 ec 08             	sub    $0x8,%esp
80105584:	8d 45 dc             	lea    -0x24(%ebp),%eax
80105587:	50                   	push   %eax
80105588:	6a 01                	push   $0x1
8010558a:	e8 94 fc ff ff       	call   80105223 <argstr>
8010558f:	83 c4 10             	add    $0x10,%esp
80105592:	85 c0                	test   %eax,%eax
80105594:	79 0a                	jns    801055a0 <sys_link+0x3a>
    return -1;
80105596:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010559b:	e9 68 01 00 00       	jmp    80105708 <sys_link+0x1a2>

  begin_op();
801055a0:	e8 7b df ff ff       	call   80103520 <begin_op>
  if((ip = namei(old)) == 0){
801055a5:	8b 45 d8             	mov    -0x28(%ebp),%eax
801055a8:	83 ec 0c             	sub    $0xc,%esp
801055ab:	50                   	push   %eax
801055ac:	e8 6c cf ff ff       	call   8010251d <namei>
801055b1:	83 c4 10             	add    $0x10,%esp
801055b4:	89 45 f4             	mov    %eax,-0xc(%ebp)
801055b7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801055bb:	75 0f                	jne    801055cc <sys_link+0x66>
    end_op();
801055bd:	e8 ea df ff ff       	call   801035ac <end_op>
    return -1;
801055c2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801055c7:	e9 3c 01 00 00       	jmp    80105708 <sys_link+0x1a2>
  }

  ilock(ip);
801055cc:	83 ec 0c             	sub    $0xc,%esp
801055cf:	ff 75 f4             	push   -0xc(%ebp)
801055d2:	e8 13 c4 ff ff       	call   801019ea <ilock>
801055d7:	83 c4 10             	add    $0x10,%esp
  if(ip->type == T_DIR){
801055da:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055dd:	0f b7 40 50          	movzwl 0x50(%eax),%eax
801055e1:	66 83 f8 01          	cmp    $0x1,%ax
801055e5:	75 1d                	jne    80105604 <sys_link+0x9e>
    iunlockput(ip);
801055e7:	83 ec 0c             	sub    $0xc,%esp
801055ea:	ff 75 f4             	push   -0xc(%ebp)
801055ed:	e8 29 c6 ff ff       	call   80101c1b <iunlockput>
801055f2:	83 c4 10             	add    $0x10,%esp
    end_op();
801055f5:	e8 b2 df ff ff       	call   801035ac <end_op>
    return -1;
801055fa:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801055ff:	e9 04 01 00 00       	jmp    80105708 <sys_link+0x1a2>
  }

  ip->nlink++;
80105604:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105607:	0f b7 40 56          	movzwl 0x56(%eax),%eax
8010560b:	83 c0 01             	add    $0x1,%eax
8010560e:	89 c2                	mov    %eax,%edx
80105610:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105613:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
80105617:	83 ec 0c             	sub    $0xc,%esp
8010561a:	ff 75 f4             	push   -0xc(%ebp)
8010561d:	e8 eb c1 ff ff       	call   8010180d <iupdate>
80105622:	83 c4 10             	add    $0x10,%esp
  iunlock(ip);
80105625:	83 ec 0c             	sub    $0xc,%esp
80105628:	ff 75 f4             	push   -0xc(%ebp)
8010562b:	e8 cd c4 ff ff       	call   80101afd <iunlock>
80105630:	83 c4 10             	add    $0x10,%esp

  if((dp = nameiparent(new, name)) == 0)
80105633:	8b 45 dc             	mov    -0x24(%ebp),%eax
80105636:	83 ec 08             	sub    $0x8,%esp
80105639:	8d 55 e2             	lea    -0x1e(%ebp),%edx
8010563c:	52                   	push   %edx
8010563d:	50                   	push   %eax
8010563e:	e8 f6 ce ff ff       	call   80102539 <nameiparent>
80105643:	83 c4 10             	add    $0x10,%esp
80105646:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105649:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010564d:	74 71                	je     801056c0 <sys_link+0x15a>
    goto bad;
  ilock(dp);
8010564f:	83 ec 0c             	sub    $0xc,%esp
80105652:	ff 75 f0             	push   -0x10(%ebp)
80105655:	e8 90 c3 ff ff       	call   801019ea <ilock>
8010565a:	83 c4 10             	add    $0x10,%esp
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
8010565d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105660:	8b 10                	mov    (%eax),%edx
80105662:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105665:	8b 00                	mov    (%eax),%eax
80105667:	39 c2                	cmp    %eax,%edx
80105669:	75 1d                	jne    80105688 <sys_link+0x122>
8010566b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010566e:	8b 40 04             	mov    0x4(%eax),%eax
80105671:	83 ec 04             	sub    $0x4,%esp
80105674:	50                   	push   %eax
80105675:	8d 45 e2             	lea    -0x1e(%ebp),%eax
80105678:	50                   	push   %eax
80105679:	ff 75 f0             	push   -0x10(%ebp)
8010567c:	e8 05 cc ff ff       	call   80102286 <dirlink>
80105681:	83 c4 10             	add    $0x10,%esp
80105684:	85 c0                	test   %eax,%eax
80105686:	79 10                	jns    80105698 <sys_link+0x132>
    iunlockput(dp);
80105688:	83 ec 0c             	sub    $0xc,%esp
8010568b:	ff 75 f0             	push   -0x10(%ebp)
8010568e:	e8 88 c5 ff ff       	call   80101c1b <iunlockput>
80105693:	83 c4 10             	add    $0x10,%esp
    goto bad;
80105696:	eb 29                	jmp    801056c1 <sys_link+0x15b>
  }
  iunlockput(dp);
80105698:	83 ec 0c             	sub    $0xc,%esp
8010569b:	ff 75 f0             	push   -0x10(%ebp)
8010569e:	e8 78 c5 ff ff       	call   80101c1b <iunlockput>
801056a3:	83 c4 10             	add    $0x10,%esp
  iput(ip);
801056a6:	83 ec 0c             	sub    $0xc,%esp
801056a9:	ff 75 f4             	push   -0xc(%ebp)
801056ac:	e8 9a c4 ff ff       	call   80101b4b <iput>
801056b1:	83 c4 10             	add    $0x10,%esp

  end_op();
801056b4:	e8 f3 de ff ff       	call   801035ac <end_op>

  return 0;
801056b9:	b8 00 00 00 00       	mov    $0x0,%eax
801056be:	eb 48                	jmp    80105708 <sys_link+0x1a2>
    goto bad;
801056c0:	90                   	nop

bad:
  ilock(ip);
801056c1:	83 ec 0c             	sub    $0xc,%esp
801056c4:	ff 75 f4             	push   -0xc(%ebp)
801056c7:	e8 1e c3 ff ff       	call   801019ea <ilock>
801056cc:	83 c4 10             	add    $0x10,%esp
  ip->nlink--;
801056cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801056d2:	0f b7 40 56          	movzwl 0x56(%eax),%eax
801056d6:	83 e8 01             	sub    $0x1,%eax
801056d9:	89 c2                	mov    %eax,%edx
801056db:	8b 45 f4             	mov    -0xc(%ebp),%eax
801056de:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
801056e2:	83 ec 0c             	sub    $0xc,%esp
801056e5:	ff 75 f4             	push   -0xc(%ebp)
801056e8:	e8 20 c1 ff ff       	call   8010180d <iupdate>
801056ed:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
801056f0:	83 ec 0c             	sub    $0xc,%esp
801056f3:	ff 75 f4             	push   -0xc(%ebp)
801056f6:	e8 20 c5 ff ff       	call   80101c1b <iunlockput>
801056fb:	83 c4 10             	add    $0x10,%esp
  end_op();
801056fe:	e8 a9 de ff ff       	call   801035ac <end_op>
  return -1;
80105703:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105708:	c9                   	leave  
80105709:	c3                   	ret    

8010570a <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
8010570a:	55                   	push   %ebp
8010570b:	89 e5                	mov    %esp,%ebp
8010570d:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105710:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
80105717:	eb 40                	jmp    80105759 <isdirempty+0x4f>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105719:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010571c:	6a 10                	push   $0x10
8010571e:	50                   	push   %eax
8010571f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105722:	50                   	push   %eax
80105723:	ff 75 08             	push   0x8(%ebp)
80105726:	e8 ab c7 ff ff       	call   80101ed6 <readi>
8010572b:	83 c4 10             	add    $0x10,%esp
8010572e:	83 f8 10             	cmp    $0x10,%eax
80105731:	74 0d                	je     80105740 <isdirempty+0x36>
      panic("isdirempty: readi");
80105733:	83 ec 0c             	sub    $0xc,%esp
80105736:	68 d8 a8 10 80       	push   $0x8010a8d8
8010573b:	e8 69 ae ff ff       	call   801005a9 <panic>
    if(de.inum != 0)
80105740:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
80105744:	66 85 c0             	test   %ax,%ax
80105747:	74 07                	je     80105750 <isdirempty+0x46>
      return 0;
80105749:	b8 00 00 00 00       	mov    $0x0,%eax
8010574e:	eb 1b                	jmp    8010576b <isdirempty+0x61>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105750:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105753:	83 c0 10             	add    $0x10,%eax
80105756:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105759:	8b 45 08             	mov    0x8(%ebp),%eax
8010575c:	8b 50 58             	mov    0x58(%eax),%edx
8010575f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105762:	39 c2                	cmp    %eax,%edx
80105764:	77 b3                	ja     80105719 <isdirempty+0xf>
  }
  return 1;
80105766:	b8 01 00 00 00       	mov    $0x1,%eax
}
8010576b:	c9                   	leave  
8010576c:	c3                   	ret    

8010576d <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
8010576d:	55                   	push   %ebp
8010576e:	89 e5                	mov    %esp,%ebp
80105770:	83 ec 38             	sub    $0x38,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
80105773:	83 ec 08             	sub    $0x8,%esp
80105776:	8d 45 cc             	lea    -0x34(%ebp),%eax
80105779:	50                   	push   %eax
8010577a:	6a 00                	push   $0x0
8010577c:	e8 a2 fa ff ff       	call   80105223 <argstr>
80105781:	83 c4 10             	add    $0x10,%esp
80105784:	85 c0                	test   %eax,%eax
80105786:	79 0a                	jns    80105792 <sys_unlink+0x25>
    return -1;
80105788:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010578d:	e9 bf 01 00 00       	jmp    80105951 <sys_unlink+0x1e4>

  begin_op();
80105792:	e8 89 dd ff ff       	call   80103520 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
80105797:	8b 45 cc             	mov    -0x34(%ebp),%eax
8010579a:	83 ec 08             	sub    $0x8,%esp
8010579d:	8d 55 d2             	lea    -0x2e(%ebp),%edx
801057a0:	52                   	push   %edx
801057a1:	50                   	push   %eax
801057a2:	e8 92 cd ff ff       	call   80102539 <nameiparent>
801057a7:	83 c4 10             	add    $0x10,%esp
801057aa:	89 45 f4             	mov    %eax,-0xc(%ebp)
801057ad:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801057b1:	75 0f                	jne    801057c2 <sys_unlink+0x55>
    end_op();
801057b3:	e8 f4 dd ff ff       	call   801035ac <end_op>
    return -1;
801057b8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801057bd:	e9 8f 01 00 00       	jmp    80105951 <sys_unlink+0x1e4>
  }

  ilock(dp);
801057c2:	83 ec 0c             	sub    $0xc,%esp
801057c5:	ff 75 f4             	push   -0xc(%ebp)
801057c8:	e8 1d c2 ff ff       	call   801019ea <ilock>
801057cd:	83 c4 10             	add    $0x10,%esp

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
801057d0:	83 ec 08             	sub    $0x8,%esp
801057d3:	68 ea a8 10 80       	push   $0x8010a8ea
801057d8:	8d 45 d2             	lea    -0x2e(%ebp),%eax
801057db:	50                   	push   %eax
801057dc:	e8 d0 c9 ff ff       	call   801021b1 <namecmp>
801057e1:	83 c4 10             	add    $0x10,%esp
801057e4:	85 c0                	test   %eax,%eax
801057e6:	0f 84 49 01 00 00    	je     80105935 <sys_unlink+0x1c8>
801057ec:	83 ec 08             	sub    $0x8,%esp
801057ef:	68 ec a8 10 80       	push   $0x8010a8ec
801057f4:	8d 45 d2             	lea    -0x2e(%ebp),%eax
801057f7:	50                   	push   %eax
801057f8:	e8 b4 c9 ff ff       	call   801021b1 <namecmp>
801057fd:	83 c4 10             	add    $0x10,%esp
80105800:	85 c0                	test   %eax,%eax
80105802:	0f 84 2d 01 00 00    	je     80105935 <sys_unlink+0x1c8>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
80105808:	83 ec 04             	sub    $0x4,%esp
8010580b:	8d 45 c8             	lea    -0x38(%ebp),%eax
8010580e:	50                   	push   %eax
8010580f:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105812:	50                   	push   %eax
80105813:	ff 75 f4             	push   -0xc(%ebp)
80105816:	e8 b1 c9 ff ff       	call   801021cc <dirlookup>
8010581b:	83 c4 10             	add    $0x10,%esp
8010581e:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105821:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105825:	0f 84 0d 01 00 00    	je     80105938 <sys_unlink+0x1cb>
    goto bad;
  ilock(ip);
8010582b:	83 ec 0c             	sub    $0xc,%esp
8010582e:	ff 75 f0             	push   -0x10(%ebp)
80105831:	e8 b4 c1 ff ff       	call   801019ea <ilock>
80105836:	83 c4 10             	add    $0x10,%esp

  if(ip->nlink < 1)
80105839:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010583c:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105840:	66 85 c0             	test   %ax,%ax
80105843:	7f 0d                	jg     80105852 <sys_unlink+0xe5>
    panic("unlink: nlink < 1");
80105845:	83 ec 0c             	sub    $0xc,%esp
80105848:	68 ef a8 10 80       	push   $0x8010a8ef
8010584d:	e8 57 ad ff ff       	call   801005a9 <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
80105852:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105855:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105859:	66 83 f8 01          	cmp    $0x1,%ax
8010585d:	75 25                	jne    80105884 <sys_unlink+0x117>
8010585f:	83 ec 0c             	sub    $0xc,%esp
80105862:	ff 75 f0             	push   -0x10(%ebp)
80105865:	e8 a0 fe ff ff       	call   8010570a <isdirempty>
8010586a:	83 c4 10             	add    $0x10,%esp
8010586d:	85 c0                	test   %eax,%eax
8010586f:	75 13                	jne    80105884 <sys_unlink+0x117>
    iunlockput(ip);
80105871:	83 ec 0c             	sub    $0xc,%esp
80105874:	ff 75 f0             	push   -0x10(%ebp)
80105877:	e8 9f c3 ff ff       	call   80101c1b <iunlockput>
8010587c:	83 c4 10             	add    $0x10,%esp
    goto bad;
8010587f:	e9 b5 00 00 00       	jmp    80105939 <sys_unlink+0x1cc>
  }

  memset(&de, 0, sizeof(de));
80105884:	83 ec 04             	sub    $0x4,%esp
80105887:	6a 10                	push   $0x10
80105889:	6a 00                	push   $0x0
8010588b:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010588e:	50                   	push   %eax
8010588f:	e8 cf f5 ff ff       	call   80104e63 <memset>
80105894:	83 c4 10             	add    $0x10,%esp
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105897:	8b 45 c8             	mov    -0x38(%ebp),%eax
8010589a:	6a 10                	push   $0x10
8010589c:	50                   	push   %eax
8010589d:	8d 45 e0             	lea    -0x20(%ebp),%eax
801058a0:	50                   	push   %eax
801058a1:	ff 75 f4             	push   -0xc(%ebp)
801058a4:	e8 82 c7 ff ff       	call   8010202b <writei>
801058a9:	83 c4 10             	add    $0x10,%esp
801058ac:	83 f8 10             	cmp    $0x10,%eax
801058af:	74 0d                	je     801058be <sys_unlink+0x151>
    panic("unlink: writei");
801058b1:	83 ec 0c             	sub    $0xc,%esp
801058b4:	68 01 a9 10 80       	push   $0x8010a901
801058b9:	e8 eb ac ff ff       	call   801005a9 <panic>
  if(ip->type == T_DIR){
801058be:	8b 45 f0             	mov    -0x10(%ebp),%eax
801058c1:	0f b7 40 50          	movzwl 0x50(%eax),%eax
801058c5:	66 83 f8 01          	cmp    $0x1,%ax
801058c9:	75 21                	jne    801058ec <sys_unlink+0x17f>
    dp->nlink--;
801058cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801058ce:	0f b7 40 56          	movzwl 0x56(%eax),%eax
801058d2:	83 e8 01             	sub    $0x1,%eax
801058d5:	89 c2                	mov    %eax,%edx
801058d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801058da:	66 89 50 56          	mov    %dx,0x56(%eax)
    iupdate(dp);
801058de:	83 ec 0c             	sub    $0xc,%esp
801058e1:	ff 75 f4             	push   -0xc(%ebp)
801058e4:	e8 24 bf ff ff       	call   8010180d <iupdate>
801058e9:	83 c4 10             	add    $0x10,%esp
  }
  iunlockput(dp);
801058ec:	83 ec 0c             	sub    $0xc,%esp
801058ef:	ff 75 f4             	push   -0xc(%ebp)
801058f2:	e8 24 c3 ff ff       	call   80101c1b <iunlockput>
801058f7:	83 c4 10             	add    $0x10,%esp

  ip->nlink--;
801058fa:	8b 45 f0             	mov    -0x10(%ebp),%eax
801058fd:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105901:	83 e8 01             	sub    $0x1,%eax
80105904:	89 c2                	mov    %eax,%edx
80105906:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105909:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
8010590d:	83 ec 0c             	sub    $0xc,%esp
80105910:	ff 75 f0             	push   -0x10(%ebp)
80105913:	e8 f5 be ff ff       	call   8010180d <iupdate>
80105918:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
8010591b:	83 ec 0c             	sub    $0xc,%esp
8010591e:	ff 75 f0             	push   -0x10(%ebp)
80105921:	e8 f5 c2 ff ff       	call   80101c1b <iunlockput>
80105926:	83 c4 10             	add    $0x10,%esp

  end_op();
80105929:	e8 7e dc ff ff       	call   801035ac <end_op>

  return 0;
8010592e:	b8 00 00 00 00       	mov    $0x0,%eax
80105933:	eb 1c                	jmp    80105951 <sys_unlink+0x1e4>
    goto bad;
80105935:	90                   	nop
80105936:	eb 01                	jmp    80105939 <sys_unlink+0x1cc>
    goto bad;
80105938:	90                   	nop

bad:
  iunlockput(dp);
80105939:	83 ec 0c             	sub    $0xc,%esp
8010593c:	ff 75 f4             	push   -0xc(%ebp)
8010593f:	e8 d7 c2 ff ff       	call   80101c1b <iunlockput>
80105944:	83 c4 10             	add    $0x10,%esp
  end_op();
80105947:	e8 60 dc ff ff       	call   801035ac <end_op>
  return -1;
8010594c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105951:	c9                   	leave  
80105952:	c3                   	ret    

80105953 <create>:

static struct inode*
create(char *path, short type, short major, short minor)
{
80105953:	55                   	push   %ebp
80105954:	89 e5                	mov    %esp,%ebp
80105956:	83 ec 38             	sub    $0x38,%esp
80105959:	8b 4d 0c             	mov    0xc(%ebp),%ecx
8010595c:	8b 55 10             	mov    0x10(%ebp),%edx
8010595f:	8b 45 14             	mov    0x14(%ebp),%eax
80105962:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
80105966:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
8010596a:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
8010596e:	83 ec 08             	sub    $0x8,%esp
80105971:	8d 45 de             	lea    -0x22(%ebp),%eax
80105974:	50                   	push   %eax
80105975:	ff 75 08             	push   0x8(%ebp)
80105978:	e8 bc cb ff ff       	call   80102539 <nameiparent>
8010597d:	83 c4 10             	add    $0x10,%esp
80105980:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105983:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105987:	75 0a                	jne    80105993 <create+0x40>
    return 0;
80105989:	b8 00 00 00 00       	mov    $0x0,%eax
8010598e:	e9 90 01 00 00       	jmp    80105b23 <create+0x1d0>
  ilock(dp);
80105993:	83 ec 0c             	sub    $0xc,%esp
80105996:	ff 75 f4             	push   -0xc(%ebp)
80105999:	e8 4c c0 ff ff       	call   801019ea <ilock>
8010599e:	83 c4 10             	add    $0x10,%esp

  if((ip = dirlookup(dp, name, &off)) != 0){
801059a1:	83 ec 04             	sub    $0x4,%esp
801059a4:	8d 45 ec             	lea    -0x14(%ebp),%eax
801059a7:	50                   	push   %eax
801059a8:	8d 45 de             	lea    -0x22(%ebp),%eax
801059ab:	50                   	push   %eax
801059ac:	ff 75 f4             	push   -0xc(%ebp)
801059af:	e8 18 c8 ff ff       	call   801021cc <dirlookup>
801059b4:	83 c4 10             	add    $0x10,%esp
801059b7:	89 45 f0             	mov    %eax,-0x10(%ebp)
801059ba:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801059be:	74 50                	je     80105a10 <create+0xbd>
    iunlockput(dp);
801059c0:	83 ec 0c             	sub    $0xc,%esp
801059c3:	ff 75 f4             	push   -0xc(%ebp)
801059c6:	e8 50 c2 ff ff       	call   80101c1b <iunlockput>
801059cb:	83 c4 10             	add    $0x10,%esp
    ilock(ip);
801059ce:	83 ec 0c             	sub    $0xc,%esp
801059d1:	ff 75 f0             	push   -0x10(%ebp)
801059d4:	e8 11 c0 ff ff       	call   801019ea <ilock>
801059d9:	83 c4 10             	add    $0x10,%esp
    if(type == T_FILE && ip->type == T_FILE)
801059dc:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
801059e1:	75 15                	jne    801059f8 <create+0xa5>
801059e3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801059e6:	0f b7 40 50          	movzwl 0x50(%eax),%eax
801059ea:	66 83 f8 02          	cmp    $0x2,%ax
801059ee:	75 08                	jne    801059f8 <create+0xa5>
      return ip;
801059f0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801059f3:	e9 2b 01 00 00       	jmp    80105b23 <create+0x1d0>
    iunlockput(ip);
801059f8:	83 ec 0c             	sub    $0xc,%esp
801059fb:	ff 75 f0             	push   -0x10(%ebp)
801059fe:	e8 18 c2 ff ff       	call   80101c1b <iunlockput>
80105a03:	83 c4 10             	add    $0x10,%esp
    return 0;
80105a06:	b8 00 00 00 00       	mov    $0x0,%eax
80105a0b:	e9 13 01 00 00       	jmp    80105b23 <create+0x1d0>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
80105a10:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
80105a14:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a17:	8b 00                	mov    (%eax),%eax
80105a19:	83 ec 08             	sub    $0x8,%esp
80105a1c:	52                   	push   %edx
80105a1d:	50                   	push   %eax
80105a1e:	e8 13 bd ff ff       	call   80101736 <ialloc>
80105a23:	83 c4 10             	add    $0x10,%esp
80105a26:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105a29:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105a2d:	75 0d                	jne    80105a3c <create+0xe9>
    panic("create: ialloc");
80105a2f:	83 ec 0c             	sub    $0xc,%esp
80105a32:	68 10 a9 10 80       	push   $0x8010a910
80105a37:	e8 6d ab ff ff       	call   801005a9 <panic>

  ilock(ip);
80105a3c:	83 ec 0c             	sub    $0xc,%esp
80105a3f:	ff 75 f0             	push   -0x10(%ebp)
80105a42:	e8 a3 bf ff ff       	call   801019ea <ilock>
80105a47:	83 c4 10             	add    $0x10,%esp
  ip->major = major;
80105a4a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a4d:	0f b7 55 d0          	movzwl -0x30(%ebp),%edx
80105a51:	66 89 50 52          	mov    %dx,0x52(%eax)
  ip->minor = minor;
80105a55:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a58:	0f b7 55 cc          	movzwl -0x34(%ebp),%edx
80105a5c:	66 89 50 54          	mov    %dx,0x54(%eax)
  ip->nlink = 1;
80105a60:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a63:	66 c7 40 56 01 00    	movw   $0x1,0x56(%eax)
  iupdate(ip);
80105a69:	83 ec 0c             	sub    $0xc,%esp
80105a6c:	ff 75 f0             	push   -0x10(%ebp)
80105a6f:	e8 99 bd ff ff       	call   8010180d <iupdate>
80105a74:	83 c4 10             	add    $0x10,%esp

  if(type == T_DIR){  // Create . and .. entries.
80105a77:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
80105a7c:	75 6a                	jne    80105ae8 <create+0x195>
    dp->nlink++;  // for ".."
80105a7e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a81:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105a85:	83 c0 01             	add    $0x1,%eax
80105a88:	89 c2                	mov    %eax,%edx
80105a8a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a8d:	66 89 50 56          	mov    %dx,0x56(%eax)
    iupdate(dp);
80105a91:	83 ec 0c             	sub    $0xc,%esp
80105a94:	ff 75 f4             	push   -0xc(%ebp)
80105a97:	e8 71 bd ff ff       	call   8010180d <iupdate>
80105a9c:	83 c4 10             	add    $0x10,%esp
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
80105a9f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105aa2:	8b 40 04             	mov    0x4(%eax),%eax
80105aa5:	83 ec 04             	sub    $0x4,%esp
80105aa8:	50                   	push   %eax
80105aa9:	68 ea a8 10 80       	push   $0x8010a8ea
80105aae:	ff 75 f0             	push   -0x10(%ebp)
80105ab1:	e8 d0 c7 ff ff       	call   80102286 <dirlink>
80105ab6:	83 c4 10             	add    $0x10,%esp
80105ab9:	85 c0                	test   %eax,%eax
80105abb:	78 1e                	js     80105adb <create+0x188>
80105abd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ac0:	8b 40 04             	mov    0x4(%eax),%eax
80105ac3:	83 ec 04             	sub    $0x4,%esp
80105ac6:	50                   	push   %eax
80105ac7:	68 ec a8 10 80       	push   $0x8010a8ec
80105acc:	ff 75 f0             	push   -0x10(%ebp)
80105acf:	e8 b2 c7 ff ff       	call   80102286 <dirlink>
80105ad4:	83 c4 10             	add    $0x10,%esp
80105ad7:	85 c0                	test   %eax,%eax
80105ad9:	79 0d                	jns    80105ae8 <create+0x195>
      panic("create dots");
80105adb:	83 ec 0c             	sub    $0xc,%esp
80105ade:	68 1f a9 10 80       	push   $0x8010a91f
80105ae3:	e8 c1 aa ff ff       	call   801005a9 <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
80105ae8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105aeb:	8b 40 04             	mov    0x4(%eax),%eax
80105aee:	83 ec 04             	sub    $0x4,%esp
80105af1:	50                   	push   %eax
80105af2:	8d 45 de             	lea    -0x22(%ebp),%eax
80105af5:	50                   	push   %eax
80105af6:	ff 75 f4             	push   -0xc(%ebp)
80105af9:	e8 88 c7 ff ff       	call   80102286 <dirlink>
80105afe:	83 c4 10             	add    $0x10,%esp
80105b01:	85 c0                	test   %eax,%eax
80105b03:	79 0d                	jns    80105b12 <create+0x1bf>
    panic("create: dirlink");
80105b05:	83 ec 0c             	sub    $0xc,%esp
80105b08:	68 2b a9 10 80       	push   $0x8010a92b
80105b0d:	e8 97 aa ff ff       	call   801005a9 <panic>

  iunlockput(dp);
80105b12:	83 ec 0c             	sub    $0xc,%esp
80105b15:	ff 75 f4             	push   -0xc(%ebp)
80105b18:	e8 fe c0 ff ff       	call   80101c1b <iunlockput>
80105b1d:	83 c4 10             	add    $0x10,%esp

  return ip;
80105b20:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80105b23:	c9                   	leave  
80105b24:	c3                   	ret    

80105b25 <sys_open>:

int
sys_open(void)
{
80105b25:	55                   	push   %ebp
80105b26:	89 e5                	mov    %esp,%ebp
80105b28:	83 ec 28             	sub    $0x28,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
80105b2b:	83 ec 08             	sub    $0x8,%esp
80105b2e:	8d 45 e8             	lea    -0x18(%ebp),%eax
80105b31:	50                   	push   %eax
80105b32:	6a 00                	push   $0x0
80105b34:	e8 ea f6 ff ff       	call   80105223 <argstr>
80105b39:	83 c4 10             	add    $0x10,%esp
80105b3c:	85 c0                	test   %eax,%eax
80105b3e:	78 15                	js     80105b55 <sys_open+0x30>
80105b40:	83 ec 08             	sub    $0x8,%esp
80105b43:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105b46:	50                   	push   %eax
80105b47:	6a 01                	push   $0x1
80105b49:	e8 40 f6 ff ff       	call   8010518e <argint>
80105b4e:	83 c4 10             	add    $0x10,%esp
80105b51:	85 c0                	test   %eax,%eax
80105b53:	79 0a                	jns    80105b5f <sys_open+0x3a>
    return -1;
80105b55:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b5a:	e9 61 01 00 00       	jmp    80105cc0 <sys_open+0x19b>

  begin_op();
80105b5f:	e8 bc d9 ff ff       	call   80103520 <begin_op>

  if(omode & O_CREATE){
80105b64:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105b67:	25 00 02 00 00       	and    $0x200,%eax
80105b6c:	85 c0                	test   %eax,%eax
80105b6e:	74 2a                	je     80105b9a <sys_open+0x75>
    ip = create(path, T_FILE, 0, 0);
80105b70:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105b73:	6a 00                	push   $0x0
80105b75:	6a 00                	push   $0x0
80105b77:	6a 02                	push   $0x2
80105b79:	50                   	push   %eax
80105b7a:	e8 d4 fd ff ff       	call   80105953 <create>
80105b7f:	83 c4 10             	add    $0x10,%esp
80105b82:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ip == 0){
80105b85:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105b89:	75 75                	jne    80105c00 <sys_open+0xdb>
      end_op();
80105b8b:	e8 1c da ff ff       	call   801035ac <end_op>
      return -1;
80105b90:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b95:	e9 26 01 00 00       	jmp    80105cc0 <sys_open+0x19b>
    }
  } else {
    if((ip = namei(path)) == 0){
80105b9a:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105b9d:	83 ec 0c             	sub    $0xc,%esp
80105ba0:	50                   	push   %eax
80105ba1:	e8 77 c9 ff ff       	call   8010251d <namei>
80105ba6:	83 c4 10             	add    $0x10,%esp
80105ba9:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105bac:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105bb0:	75 0f                	jne    80105bc1 <sys_open+0x9c>
      end_op();
80105bb2:	e8 f5 d9 ff ff       	call   801035ac <end_op>
      return -1;
80105bb7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105bbc:	e9 ff 00 00 00       	jmp    80105cc0 <sys_open+0x19b>
    }
    ilock(ip);
80105bc1:	83 ec 0c             	sub    $0xc,%esp
80105bc4:	ff 75 f4             	push   -0xc(%ebp)
80105bc7:	e8 1e be ff ff       	call   801019ea <ilock>
80105bcc:	83 c4 10             	add    $0x10,%esp
    if(ip->type == T_DIR && omode != O_RDONLY){
80105bcf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105bd2:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105bd6:	66 83 f8 01          	cmp    $0x1,%ax
80105bda:	75 24                	jne    80105c00 <sys_open+0xdb>
80105bdc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105bdf:	85 c0                	test   %eax,%eax
80105be1:	74 1d                	je     80105c00 <sys_open+0xdb>
      iunlockput(ip);
80105be3:	83 ec 0c             	sub    $0xc,%esp
80105be6:	ff 75 f4             	push   -0xc(%ebp)
80105be9:	e8 2d c0 ff ff       	call   80101c1b <iunlockput>
80105bee:	83 c4 10             	add    $0x10,%esp
      end_op();
80105bf1:	e8 b6 d9 ff ff       	call   801035ac <end_op>
      return -1;
80105bf6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105bfb:	e9 c0 00 00 00       	jmp    80105cc0 <sys_open+0x19b>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
80105c00:	e8 d8 b3 ff ff       	call   80100fdd <filealloc>
80105c05:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105c08:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105c0c:	74 17                	je     80105c25 <sys_open+0x100>
80105c0e:	83 ec 0c             	sub    $0xc,%esp
80105c11:	ff 75 f0             	push   -0x10(%ebp)
80105c14:	e8 33 f7 ff ff       	call   8010534c <fdalloc>
80105c19:	83 c4 10             	add    $0x10,%esp
80105c1c:	89 45 ec             	mov    %eax,-0x14(%ebp)
80105c1f:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80105c23:	79 2e                	jns    80105c53 <sys_open+0x12e>
    if(f)
80105c25:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105c29:	74 0e                	je     80105c39 <sys_open+0x114>
      fileclose(f);
80105c2b:	83 ec 0c             	sub    $0xc,%esp
80105c2e:	ff 75 f0             	push   -0x10(%ebp)
80105c31:	e8 65 b4 ff ff       	call   8010109b <fileclose>
80105c36:	83 c4 10             	add    $0x10,%esp
    iunlockput(ip);
80105c39:	83 ec 0c             	sub    $0xc,%esp
80105c3c:	ff 75 f4             	push   -0xc(%ebp)
80105c3f:	e8 d7 bf ff ff       	call   80101c1b <iunlockput>
80105c44:	83 c4 10             	add    $0x10,%esp
    end_op();
80105c47:	e8 60 d9 ff ff       	call   801035ac <end_op>
    return -1;
80105c4c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c51:	eb 6d                	jmp    80105cc0 <sys_open+0x19b>
  }
  iunlock(ip);
80105c53:	83 ec 0c             	sub    $0xc,%esp
80105c56:	ff 75 f4             	push   -0xc(%ebp)
80105c59:	e8 9f be ff ff       	call   80101afd <iunlock>
80105c5e:	83 c4 10             	add    $0x10,%esp
  end_op();
80105c61:	e8 46 d9 ff ff       	call   801035ac <end_op>

  f->type = FD_INODE;
80105c66:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c69:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
80105c6f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c72:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105c75:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
80105c78:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c7b:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
80105c82:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105c85:	83 e0 01             	and    $0x1,%eax
80105c88:	85 c0                	test   %eax,%eax
80105c8a:	0f 94 c0             	sete   %al
80105c8d:	89 c2                	mov    %eax,%edx
80105c8f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c92:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
80105c95:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105c98:	83 e0 01             	and    $0x1,%eax
80105c9b:	85 c0                	test   %eax,%eax
80105c9d:	75 0a                	jne    80105ca9 <sys_open+0x184>
80105c9f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105ca2:	83 e0 02             	and    $0x2,%eax
80105ca5:	85 c0                	test   %eax,%eax
80105ca7:	74 07                	je     80105cb0 <sys_open+0x18b>
80105ca9:	b8 01 00 00 00       	mov    $0x1,%eax
80105cae:	eb 05                	jmp    80105cb5 <sys_open+0x190>
80105cb0:	b8 00 00 00 00       	mov    $0x0,%eax
80105cb5:	89 c2                	mov    %eax,%edx
80105cb7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105cba:	88 50 09             	mov    %dl,0x9(%eax)
  return fd;
80105cbd:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
80105cc0:	c9                   	leave  
80105cc1:	c3                   	ret    

80105cc2 <sys_mkdir>:

int
sys_mkdir(void)
{
80105cc2:	55                   	push   %ebp
80105cc3:	89 e5                	mov    %esp,%ebp
80105cc5:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
80105cc8:	e8 53 d8 ff ff       	call   80103520 <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
80105ccd:	83 ec 08             	sub    $0x8,%esp
80105cd0:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105cd3:	50                   	push   %eax
80105cd4:	6a 00                	push   $0x0
80105cd6:	e8 48 f5 ff ff       	call   80105223 <argstr>
80105cdb:	83 c4 10             	add    $0x10,%esp
80105cde:	85 c0                	test   %eax,%eax
80105ce0:	78 1b                	js     80105cfd <sys_mkdir+0x3b>
80105ce2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ce5:	6a 00                	push   $0x0
80105ce7:	6a 00                	push   $0x0
80105ce9:	6a 01                	push   $0x1
80105ceb:	50                   	push   %eax
80105cec:	e8 62 fc ff ff       	call   80105953 <create>
80105cf1:	83 c4 10             	add    $0x10,%esp
80105cf4:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105cf7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105cfb:	75 0c                	jne    80105d09 <sys_mkdir+0x47>
    end_op();
80105cfd:	e8 aa d8 ff ff       	call   801035ac <end_op>
    return -1;
80105d02:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d07:	eb 18                	jmp    80105d21 <sys_mkdir+0x5f>
  }
  iunlockput(ip);
80105d09:	83 ec 0c             	sub    $0xc,%esp
80105d0c:	ff 75 f4             	push   -0xc(%ebp)
80105d0f:	e8 07 bf ff ff       	call   80101c1b <iunlockput>
80105d14:	83 c4 10             	add    $0x10,%esp
  end_op();
80105d17:	e8 90 d8 ff ff       	call   801035ac <end_op>
  return 0;
80105d1c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105d21:	c9                   	leave  
80105d22:	c3                   	ret    

80105d23 <sys_mknod>:

int
sys_mknod(void)
{
80105d23:	55                   	push   %ebp
80105d24:	89 e5                	mov    %esp,%ebp
80105d26:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
80105d29:	e8 f2 d7 ff ff       	call   80103520 <begin_op>
  if((argstr(0, &path)) < 0 ||
80105d2e:	83 ec 08             	sub    $0x8,%esp
80105d31:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105d34:	50                   	push   %eax
80105d35:	6a 00                	push   $0x0
80105d37:	e8 e7 f4 ff ff       	call   80105223 <argstr>
80105d3c:	83 c4 10             	add    $0x10,%esp
80105d3f:	85 c0                	test   %eax,%eax
80105d41:	78 4f                	js     80105d92 <sys_mknod+0x6f>
     argint(1, &major) < 0 ||
80105d43:	83 ec 08             	sub    $0x8,%esp
80105d46:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105d49:	50                   	push   %eax
80105d4a:	6a 01                	push   $0x1
80105d4c:	e8 3d f4 ff ff       	call   8010518e <argint>
80105d51:	83 c4 10             	add    $0x10,%esp
  if((argstr(0, &path)) < 0 ||
80105d54:	85 c0                	test   %eax,%eax
80105d56:	78 3a                	js     80105d92 <sys_mknod+0x6f>
     argint(2, &minor) < 0 ||
80105d58:	83 ec 08             	sub    $0x8,%esp
80105d5b:	8d 45 e8             	lea    -0x18(%ebp),%eax
80105d5e:	50                   	push   %eax
80105d5f:	6a 02                	push   $0x2
80105d61:	e8 28 f4 ff ff       	call   8010518e <argint>
80105d66:	83 c4 10             	add    $0x10,%esp
     argint(1, &major) < 0 ||
80105d69:	85 c0                	test   %eax,%eax
80105d6b:	78 25                	js     80105d92 <sys_mknod+0x6f>
     (ip = create(path, T_DEV, major, minor)) == 0){
80105d6d:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105d70:	0f bf c8             	movswl %ax,%ecx
80105d73:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105d76:	0f bf d0             	movswl %ax,%edx
80105d79:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d7c:	51                   	push   %ecx
80105d7d:	52                   	push   %edx
80105d7e:	6a 03                	push   $0x3
80105d80:	50                   	push   %eax
80105d81:	e8 cd fb ff ff       	call   80105953 <create>
80105d86:	83 c4 10             	add    $0x10,%esp
80105d89:	89 45 f4             	mov    %eax,-0xc(%ebp)
     argint(2, &minor) < 0 ||
80105d8c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105d90:	75 0c                	jne    80105d9e <sys_mknod+0x7b>
    end_op();
80105d92:	e8 15 d8 ff ff       	call   801035ac <end_op>
    return -1;
80105d97:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d9c:	eb 18                	jmp    80105db6 <sys_mknod+0x93>
  }
  iunlockput(ip);
80105d9e:	83 ec 0c             	sub    $0xc,%esp
80105da1:	ff 75 f4             	push   -0xc(%ebp)
80105da4:	e8 72 be ff ff       	call   80101c1b <iunlockput>
80105da9:	83 c4 10             	add    $0x10,%esp
  end_op();
80105dac:	e8 fb d7 ff ff       	call   801035ac <end_op>
  return 0;
80105db1:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105db6:	c9                   	leave  
80105db7:	c3                   	ret    

80105db8 <sys_chdir>:

int
sys_chdir(void)
{
80105db8:	55                   	push   %ebp
80105db9:	89 e5                	mov    %esp,%ebp
80105dbb:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;
  struct proc *curproc = myproc();
80105dbe:	e8 51 e1 ff ff       	call   80103f14 <myproc>
80105dc3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  begin_op();
80105dc6:	e8 55 d7 ff ff       	call   80103520 <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
80105dcb:	83 ec 08             	sub    $0x8,%esp
80105dce:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105dd1:	50                   	push   %eax
80105dd2:	6a 00                	push   $0x0
80105dd4:	e8 4a f4 ff ff       	call   80105223 <argstr>
80105dd9:	83 c4 10             	add    $0x10,%esp
80105ddc:	85 c0                	test   %eax,%eax
80105dde:	78 18                	js     80105df8 <sys_chdir+0x40>
80105de0:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105de3:	83 ec 0c             	sub    $0xc,%esp
80105de6:	50                   	push   %eax
80105de7:	e8 31 c7 ff ff       	call   8010251d <namei>
80105dec:	83 c4 10             	add    $0x10,%esp
80105def:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105df2:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105df6:	75 0c                	jne    80105e04 <sys_chdir+0x4c>
    end_op();
80105df8:	e8 af d7 ff ff       	call   801035ac <end_op>
    return -1;
80105dfd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105e02:	eb 68                	jmp    80105e6c <sys_chdir+0xb4>
  }
  ilock(ip);
80105e04:	83 ec 0c             	sub    $0xc,%esp
80105e07:	ff 75 f0             	push   -0x10(%ebp)
80105e0a:	e8 db bb ff ff       	call   801019ea <ilock>
80105e0f:	83 c4 10             	add    $0x10,%esp
  if(ip->type != T_DIR){
80105e12:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e15:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105e19:	66 83 f8 01          	cmp    $0x1,%ax
80105e1d:	74 1a                	je     80105e39 <sys_chdir+0x81>
    iunlockput(ip);
80105e1f:	83 ec 0c             	sub    $0xc,%esp
80105e22:	ff 75 f0             	push   -0x10(%ebp)
80105e25:	e8 f1 bd ff ff       	call   80101c1b <iunlockput>
80105e2a:	83 c4 10             	add    $0x10,%esp
    end_op();
80105e2d:	e8 7a d7 ff ff       	call   801035ac <end_op>
    return -1;
80105e32:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105e37:	eb 33                	jmp    80105e6c <sys_chdir+0xb4>
  }
  iunlock(ip);
80105e39:	83 ec 0c             	sub    $0xc,%esp
80105e3c:	ff 75 f0             	push   -0x10(%ebp)
80105e3f:	e8 b9 bc ff ff       	call   80101afd <iunlock>
80105e44:	83 c4 10             	add    $0x10,%esp
  iput(curproc->cwd);
80105e47:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e4a:	8b 40 68             	mov    0x68(%eax),%eax
80105e4d:	83 ec 0c             	sub    $0xc,%esp
80105e50:	50                   	push   %eax
80105e51:	e8 f5 bc ff ff       	call   80101b4b <iput>
80105e56:	83 c4 10             	add    $0x10,%esp
  end_op();
80105e59:	e8 4e d7 ff ff       	call   801035ac <end_op>
  curproc->cwd = ip;
80105e5e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e61:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105e64:	89 50 68             	mov    %edx,0x68(%eax)
  return 0;
80105e67:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105e6c:	c9                   	leave  
80105e6d:	c3                   	ret    

80105e6e <sys_exec>:

int
sys_exec(void)
{
80105e6e:	55                   	push   %ebp
80105e6f:	89 e5                	mov    %esp,%ebp
80105e71:	81 ec 98 00 00 00    	sub    $0x98,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
80105e77:	83 ec 08             	sub    $0x8,%esp
80105e7a:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105e7d:	50                   	push   %eax
80105e7e:	6a 00                	push   $0x0
80105e80:	e8 9e f3 ff ff       	call   80105223 <argstr>
80105e85:	83 c4 10             	add    $0x10,%esp
80105e88:	85 c0                	test   %eax,%eax
80105e8a:	78 18                	js     80105ea4 <sys_exec+0x36>
80105e8c:	83 ec 08             	sub    $0x8,%esp
80105e8f:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
80105e95:	50                   	push   %eax
80105e96:	6a 01                	push   $0x1
80105e98:	e8 f1 f2 ff ff       	call   8010518e <argint>
80105e9d:	83 c4 10             	add    $0x10,%esp
80105ea0:	85 c0                	test   %eax,%eax
80105ea2:	79 0a                	jns    80105eae <sys_exec+0x40>
    return -1;
80105ea4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ea9:	e9 c6 00 00 00       	jmp    80105f74 <sys_exec+0x106>
  }
  memset(argv, 0, sizeof(argv));
80105eae:	83 ec 04             	sub    $0x4,%esp
80105eb1:	68 80 00 00 00       	push   $0x80
80105eb6:	6a 00                	push   $0x0
80105eb8:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80105ebe:	50                   	push   %eax
80105ebf:	e8 9f ef ff ff       	call   80104e63 <memset>
80105ec4:	83 c4 10             	add    $0x10,%esp
  for(i=0;; i++){
80105ec7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
80105ece:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ed1:	83 f8 1f             	cmp    $0x1f,%eax
80105ed4:	76 0a                	jbe    80105ee0 <sys_exec+0x72>
      return -1;
80105ed6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105edb:	e9 94 00 00 00       	jmp    80105f74 <sys_exec+0x106>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
80105ee0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ee3:	c1 e0 02             	shl    $0x2,%eax
80105ee6:	89 c2                	mov    %eax,%edx
80105ee8:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
80105eee:	01 c2                	add    %eax,%edx
80105ef0:	83 ec 08             	sub    $0x8,%esp
80105ef3:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
80105ef9:	50                   	push   %eax
80105efa:	52                   	push   %edx
80105efb:	e8 ed f1 ff ff       	call   801050ed <fetchint>
80105f00:	83 c4 10             	add    $0x10,%esp
80105f03:	85 c0                	test   %eax,%eax
80105f05:	79 07                	jns    80105f0e <sys_exec+0xa0>
      return -1;
80105f07:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f0c:	eb 66                	jmp    80105f74 <sys_exec+0x106>
    if(uarg == 0){
80105f0e:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80105f14:	85 c0                	test   %eax,%eax
80105f16:	75 27                	jne    80105f3f <sys_exec+0xd1>
      argv[i] = 0;
80105f18:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f1b:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
80105f22:	00 00 00 00 
      break;
80105f26:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
80105f27:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f2a:	83 ec 08             	sub    $0x8,%esp
80105f2d:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
80105f33:	52                   	push   %edx
80105f34:	50                   	push   %eax
80105f35:	e8 46 ac ff ff       	call   80100b80 <exec>
80105f3a:	83 c4 10             	add    $0x10,%esp
80105f3d:	eb 35                	jmp    80105f74 <sys_exec+0x106>
    if(fetchstr(uarg, &argv[i]) < 0)
80105f3f:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
80105f45:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f48:	c1 e0 02             	shl    $0x2,%eax
80105f4b:	01 c2                	add    %eax,%edx
80105f4d:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80105f53:	83 ec 08             	sub    $0x8,%esp
80105f56:	52                   	push   %edx
80105f57:	50                   	push   %eax
80105f58:	e8 cf f1 ff ff       	call   8010512c <fetchstr>
80105f5d:	83 c4 10             	add    $0x10,%esp
80105f60:	85 c0                	test   %eax,%eax
80105f62:	79 07                	jns    80105f6b <sys_exec+0xfd>
      return -1;
80105f64:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f69:	eb 09                	jmp    80105f74 <sys_exec+0x106>
  for(i=0;; i++){
80105f6b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(i >= NELEM(argv))
80105f6f:	e9 5a ff ff ff       	jmp    80105ece <sys_exec+0x60>
}
80105f74:	c9                   	leave  
80105f75:	c3                   	ret    

80105f76 <sys_pipe>:

int
sys_pipe(void)
{
80105f76:	55                   	push   %ebp
80105f77:	89 e5                	mov    %esp,%ebp
80105f79:	83 ec 28             	sub    $0x28,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
80105f7c:	83 ec 04             	sub    $0x4,%esp
80105f7f:	6a 08                	push   $0x8
80105f81:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105f84:	50                   	push   %eax
80105f85:	6a 00                	push   $0x0
80105f87:	e8 2f f2 ff ff       	call   801051bb <argptr>
80105f8c:	83 c4 10             	add    $0x10,%esp
80105f8f:	85 c0                	test   %eax,%eax
80105f91:	79 0a                	jns    80105f9d <sys_pipe+0x27>
    return -1;
80105f93:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f98:	e9 ae 00 00 00       	jmp    8010604b <sys_pipe+0xd5>
  if(pipealloc(&rf, &wf) < 0)
80105f9d:	83 ec 08             	sub    $0x8,%esp
80105fa0:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105fa3:	50                   	push   %eax
80105fa4:	8d 45 e8             	lea    -0x18(%ebp),%eax
80105fa7:	50                   	push   %eax
80105fa8:	e8 a4 da ff ff       	call   80103a51 <pipealloc>
80105fad:	83 c4 10             	add    $0x10,%esp
80105fb0:	85 c0                	test   %eax,%eax
80105fb2:	79 0a                	jns    80105fbe <sys_pipe+0x48>
    return -1;
80105fb4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105fb9:	e9 8d 00 00 00       	jmp    8010604b <sys_pipe+0xd5>
  fd0 = -1;
80105fbe:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
80105fc5:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105fc8:	83 ec 0c             	sub    $0xc,%esp
80105fcb:	50                   	push   %eax
80105fcc:	e8 7b f3 ff ff       	call   8010534c <fdalloc>
80105fd1:	83 c4 10             	add    $0x10,%esp
80105fd4:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105fd7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105fdb:	78 18                	js     80105ff5 <sys_pipe+0x7f>
80105fdd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105fe0:	83 ec 0c             	sub    $0xc,%esp
80105fe3:	50                   	push   %eax
80105fe4:	e8 63 f3 ff ff       	call   8010534c <fdalloc>
80105fe9:	83 c4 10             	add    $0x10,%esp
80105fec:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105fef:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105ff3:	79 3e                	jns    80106033 <sys_pipe+0xbd>
    if(fd0 >= 0)
80105ff5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105ff9:	78 13                	js     8010600e <sys_pipe+0x98>
      myproc()->ofile[fd0] = 0;
80105ffb:	e8 14 df ff ff       	call   80103f14 <myproc>
80106000:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106003:	83 c2 08             	add    $0x8,%edx
80106006:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
8010600d:	00 
    fileclose(rf);
8010600e:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106011:	83 ec 0c             	sub    $0xc,%esp
80106014:	50                   	push   %eax
80106015:	e8 81 b0 ff ff       	call   8010109b <fileclose>
8010601a:	83 c4 10             	add    $0x10,%esp
    fileclose(wf);
8010601d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106020:	83 ec 0c             	sub    $0xc,%esp
80106023:	50                   	push   %eax
80106024:	e8 72 b0 ff ff       	call   8010109b <fileclose>
80106029:	83 c4 10             	add    $0x10,%esp
    return -1;
8010602c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106031:	eb 18                	jmp    8010604b <sys_pipe+0xd5>
  }
  fd[0] = fd0;
80106033:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106036:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106039:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
8010603b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010603e:	8d 50 04             	lea    0x4(%eax),%edx
80106041:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106044:	89 02                	mov    %eax,(%edx)
  return 0;
80106046:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010604b:	c9                   	leave  
8010604c:	c3                   	ret    

8010604d <sys_fork>:
#include "mmu.h"
#include "proc.h"

int
sys_fork(void)
{
8010604d:	55                   	push   %ebp
8010604e:	89 e5                	mov    %esp,%ebp
80106050:	83 ec 08             	sub    $0x8,%esp
  return fork();
80106053:	e8 be e1 ff ff       	call   80104216 <fork>
}
80106058:	c9                   	leave  
80106059:	c3                   	ret    

8010605a <sys_exit>:

int
sys_exit(void)
{
8010605a:	55                   	push   %ebp
8010605b:	89 e5                	mov    %esp,%ebp
8010605d:	83 ec 08             	sub    $0x8,%esp
  exit();
80106060:	e8 2a e3 ff ff       	call   8010438f <exit>
  return 0;  // not reached
80106065:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010606a:	c9                   	leave  
8010606b:	c3                   	ret    

8010606c <sys_wait>:

int
sys_wait(void)
{
8010606c:	55                   	push   %ebp
8010606d:	89 e5                	mov    %esp,%ebp
8010606f:	83 ec 08             	sub    $0x8,%esp
  return wait();
80106072:	e8 3b e4 ff ff       	call   801044b2 <wait>
}
80106077:	c9                   	leave  
80106078:	c3                   	ret    

80106079 <sys_kill>:

int
sys_kill(void)
{
80106079:	55                   	push   %ebp
8010607a:	89 e5                	mov    %esp,%ebp
8010607c:	83 ec 18             	sub    $0x18,%esp
  int pid;

  if(argint(0, &pid) < 0)
8010607f:	83 ec 08             	sub    $0x8,%esp
80106082:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106085:	50                   	push   %eax
80106086:	6a 00                	push   $0x0
80106088:	e8 01 f1 ff ff       	call   8010518e <argint>
8010608d:	83 c4 10             	add    $0x10,%esp
80106090:	85 c0                	test   %eax,%eax
80106092:	79 07                	jns    8010609b <sys_kill+0x22>
    return -1;
80106094:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106099:	eb 0f                	jmp    801060aa <sys_kill+0x31>
  return kill(pid);
8010609b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010609e:	83 ec 0c             	sub    $0xc,%esp
801060a1:	50                   	push   %eax
801060a2:	e8 43 e8 ff ff       	call   801048ea <kill>
801060a7:	83 c4 10             	add    $0x10,%esp
}
801060aa:	c9                   	leave  
801060ab:	c3                   	ret    

801060ac <sys_getpid>:

int
sys_getpid(void)
{
801060ac:	55                   	push   %ebp
801060ad:	89 e5                	mov    %esp,%ebp
801060af:	83 ec 08             	sub    $0x8,%esp
  return myproc()->pid;
801060b2:	e8 5d de ff ff       	call   80103f14 <myproc>
801060b7:	8b 40 10             	mov    0x10(%eax),%eax
}
801060ba:	c9                   	leave  
801060bb:	c3                   	ret    

801060bc <sys_sbrk>:

int
sys_sbrk(void)
{
801060bc:	55                   	push   %ebp
801060bd:	89 e5                	mov    %esp,%ebp
801060bf:	83 ec 18             	sub    $0x18,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
801060c2:	83 ec 08             	sub    $0x8,%esp
801060c5:	8d 45 f0             	lea    -0x10(%ebp),%eax
801060c8:	50                   	push   %eax
801060c9:	6a 00                	push   $0x0
801060cb:	e8 be f0 ff ff       	call   8010518e <argint>
801060d0:	83 c4 10             	add    $0x10,%esp
801060d3:	85 c0                	test   %eax,%eax
801060d5:	79 07                	jns    801060de <sys_sbrk+0x22>
    return -1;
801060d7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801060dc:	eb 27                	jmp    80106105 <sys_sbrk+0x49>
  addr = myproc()->sz;
801060de:	e8 31 de ff ff       	call   80103f14 <myproc>
801060e3:	8b 00                	mov    (%eax),%eax
801060e5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
801060e8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060eb:	83 ec 0c             	sub    $0xc,%esp
801060ee:	50                   	push   %eax
801060ef:	e8 87 e0 ff ff       	call   8010417b <growproc>
801060f4:	83 c4 10             	add    $0x10,%esp
801060f7:	85 c0                	test   %eax,%eax
801060f9:	79 07                	jns    80106102 <sys_sbrk+0x46>
    return -1;
801060fb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106100:	eb 03                	jmp    80106105 <sys_sbrk+0x49>
  return addr;
80106102:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80106105:	c9                   	leave  
80106106:	c3                   	ret    

80106107 <sys_sleep>:

int
sys_sleep(void)
{
80106107:	55                   	push   %ebp
80106108:	89 e5                	mov    %esp,%ebp
8010610a:	83 ec 18             	sub    $0x18,%esp
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
8010610d:	83 ec 08             	sub    $0x8,%esp
80106110:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106113:	50                   	push   %eax
80106114:	6a 00                	push   $0x0
80106116:	e8 73 f0 ff ff       	call   8010518e <argint>
8010611b:	83 c4 10             	add    $0x10,%esp
8010611e:	85 c0                	test   %eax,%eax
80106120:	79 07                	jns    80106129 <sys_sleep+0x22>
    return -1;
80106122:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106127:	eb 76                	jmp    8010619f <sys_sleep+0x98>
  acquire(&tickslock);
80106129:	83 ec 0c             	sub    $0xc,%esp
8010612c:	68 80 9b 11 80       	push   $0x80119b80
80106131:	e8 b7 ea ff ff       	call   80104bed <acquire>
80106136:	83 c4 10             	add    $0x10,%esp
  ticks0 = ticks;
80106139:	a1 b4 9b 11 80       	mov    0x80119bb4,%eax
8010613e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
80106141:	eb 38                	jmp    8010617b <sys_sleep+0x74>
    if(myproc()->killed){
80106143:	e8 cc dd ff ff       	call   80103f14 <myproc>
80106148:	8b 40 24             	mov    0x24(%eax),%eax
8010614b:	85 c0                	test   %eax,%eax
8010614d:	74 17                	je     80106166 <sys_sleep+0x5f>
      release(&tickslock);
8010614f:	83 ec 0c             	sub    $0xc,%esp
80106152:	68 80 9b 11 80       	push   $0x80119b80
80106157:	e8 ff ea ff ff       	call   80104c5b <release>
8010615c:	83 c4 10             	add    $0x10,%esp
      return -1;
8010615f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106164:	eb 39                	jmp    8010619f <sys_sleep+0x98>
    }
    sleep(&ticks, &tickslock);
80106166:	83 ec 08             	sub    $0x8,%esp
80106169:	68 80 9b 11 80       	push   $0x80119b80
8010616e:	68 b4 9b 11 80       	push   $0x80119bb4
80106173:	e8 51 e6 ff ff       	call   801047c9 <sleep>
80106178:	83 c4 10             	add    $0x10,%esp
  while(ticks - ticks0 < n){
8010617b:	a1 b4 9b 11 80       	mov    0x80119bb4,%eax
80106180:	2b 45 f4             	sub    -0xc(%ebp),%eax
80106183:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106186:	39 d0                	cmp    %edx,%eax
80106188:	72 b9                	jb     80106143 <sys_sleep+0x3c>
  }
  release(&tickslock);
8010618a:	83 ec 0c             	sub    $0xc,%esp
8010618d:	68 80 9b 11 80       	push   $0x80119b80
80106192:	e8 c4 ea ff ff       	call   80104c5b <release>
80106197:	83 c4 10             	add    $0x10,%esp
  return 0;
8010619a:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010619f:	c9                   	leave  
801061a0:	c3                   	ret    

801061a1 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
801061a1:	55                   	push   %ebp
801061a2:	89 e5                	mov    %esp,%ebp
801061a4:	83 ec 18             	sub    $0x18,%esp
  uint xticks;

  acquire(&tickslock);
801061a7:	83 ec 0c             	sub    $0xc,%esp
801061aa:	68 80 9b 11 80       	push   $0x80119b80
801061af:	e8 39 ea ff ff       	call   80104bed <acquire>
801061b4:	83 c4 10             	add    $0x10,%esp
  xticks = ticks;
801061b7:	a1 b4 9b 11 80       	mov    0x80119bb4,%eax
801061bc:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
801061bf:	83 ec 0c             	sub    $0xc,%esp
801061c2:	68 80 9b 11 80       	push   $0x80119b80
801061c7:	e8 8f ea ff ff       	call   80104c5b <release>
801061cc:	83 c4 10             	add    $0x10,%esp
  return xticks;
801061cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801061d2:	c9                   	leave  
801061d3:	c3                   	ret    

801061d4 <sys_uthread_init>:

int
sys_uthread_init(void) // syscall 실행은 됨
{
801061d4:	55                   	push   %ebp
801061d5:	89 e5                	mov    %esp,%ebp
801061d7:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int func;

  if(argint(0, &func) < 0)
801061da:	83 ec 08             	sub    $0x8,%esp
801061dd:	8d 45 f0             	lea    -0x10(%ebp),%eax
801061e0:	50                   	push   %eax
801061e1:	6a 00                	push   $0x0
801061e3:	e8 a6 ef ff ff       	call   8010518e <argint>
801061e8:	83 c4 10             	add    $0x10,%esp
801061eb:	85 c0                	test   %eax,%eax
801061ed:	79 07                	jns    801061f6 <sys_uthread_init+0x22>
    return -1;
801061ef:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801061f4:	eb 22                	jmp    80106218 <sys_uthread_init+0x44>
  p = myproc();
801061f6:	e8 19 dd ff ff       	call   80103f14 <myproc>
801061fb:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p->scheduler == 0)
801061fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106201:	8b 40 7c             	mov    0x7c(%eax),%eax
80106204:	85 c0                	test   %eax,%eax
80106206:	75 0b                	jne    80106213 <sys_uthread_init+0x3f>
    p->scheduler = (uint)func;
80106208:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010620b:	89 c2                	mov    %eax,%edx
8010620d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106210:	89 50 7c             	mov    %edx,0x7c(%eax)
  
  return 0;
80106213:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106218:	c9                   	leave  
80106219:	c3                   	ret    

8010621a <sys_thread_num>:

int
sys_thread_num(void)
{
8010621a:	55                   	push   %ebp
8010621b:	89 e5                	mov    %esp,%ebp
8010621d:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int thread;

  if (argint(0, &thread) < 0)
80106220:	83 ec 08             	sub    $0x8,%esp
80106223:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106226:	50                   	push   %eax
80106227:	6a 00                	push   $0x0
80106229:	e8 60 ef ff ff       	call   8010518e <argint>
8010622e:	83 c4 10             	add    $0x10,%esp
80106231:	85 c0                	test   %eax,%eax
80106233:	79 07                	jns    8010623c <sys_thread_num+0x22>
    return -1;
80106235:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010623a:	eb 19                	jmp    80106255 <sys_thread_num+0x3b>
  p = myproc();
8010623c:	e8 d3 dc ff ff       	call   80103f14 <myproc>
80106241:	89 45 f4             	mov    %eax,-0xc(%ebp)
    p->thread = thread;
80106244:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106247:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010624a:	89 90 80 00 00 00    	mov    %edx,0x80(%eax)

  return 0;
80106250:	b8 00 00 00 00       	mov    $0x0,%eax
80106255:	c9                   	leave  
80106256:	c3                   	ret    

80106257 <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
80106257:	1e                   	push   %ds
  pushl %es
80106258:	06                   	push   %es
  pushl %fs
80106259:	0f a0                	push   %fs
  pushl %gs
8010625b:	0f a8                	push   %gs
  pushal
8010625d:	60                   	pusha  
  
  # Set up data segments.
  movw $(SEG_KDATA<<3), %ax
8010625e:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
80106262:	8e d8                	mov    %eax,%ds
  movw %ax, %es
80106264:	8e c0                	mov    %eax,%es

  # Call trap(tf), where tf=%esp
  pushl %esp
80106266:	54                   	push   %esp
  call trap
80106267:	e8 d7 01 00 00       	call   80106443 <trap>
  addl $4, %esp
8010626c:	83 c4 04             	add    $0x4,%esp

8010626f <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
8010626f:	61                   	popa   
  popl %gs
80106270:	0f a9                	pop    %gs
  popl %fs
80106272:	0f a1                	pop    %fs
  popl %es
80106274:	07                   	pop    %es
  popl %ds
80106275:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
80106276:	83 c4 08             	add    $0x8,%esp
  iret
80106279:	cf                   	iret   

8010627a <lidt>:
{
8010627a:	55                   	push   %ebp
8010627b:	89 e5                	mov    %esp,%ebp
8010627d:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
80106280:	8b 45 0c             	mov    0xc(%ebp),%eax
80106283:	83 e8 01             	sub    $0x1,%eax
80106286:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
8010628a:	8b 45 08             	mov    0x8(%ebp),%eax
8010628d:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80106291:	8b 45 08             	mov    0x8(%ebp),%eax
80106294:	c1 e8 10             	shr    $0x10,%eax
80106297:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lidt (%0)" : : "r" (pd));
8010629b:	8d 45 fa             	lea    -0x6(%ebp),%eax
8010629e:	0f 01 18             	lidtl  (%eax)
}
801062a1:	90                   	nop
801062a2:	c9                   	leave  
801062a3:	c3                   	ret    

801062a4 <rcr2>:

static inline uint
rcr2(void)
{
801062a4:	55                   	push   %ebp
801062a5:	89 e5                	mov    %esp,%ebp
801062a7:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
801062aa:	0f 20 d0             	mov    %cr2,%eax
801062ad:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return val;
801062b0:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801062b3:	c9                   	leave  
801062b4:	c3                   	ret    

801062b5 <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
801062b5:	55                   	push   %ebp
801062b6:	89 e5                	mov    %esp,%ebp
801062b8:	83 ec 18             	sub    $0x18,%esp
  int i;

  for(i = 0; i < 256; i++)
801062bb:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801062c2:	e9 c3 00 00 00       	jmp    8010638a <tvinit+0xd5>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
801062c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062ca:	8b 04 85 80 f0 10 80 	mov    -0x7fef0f80(,%eax,4),%eax
801062d1:	89 c2                	mov    %eax,%edx
801062d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062d6:	66 89 14 c5 80 93 11 	mov    %dx,-0x7fee6c80(,%eax,8)
801062dd:	80 
801062de:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062e1:	66 c7 04 c5 82 93 11 	movw   $0x8,-0x7fee6c7e(,%eax,8)
801062e8:	80 08 00 
801062eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062ee:	0f b6 14 c5 84 93 11 	movzbl -0x7fee6c7c(,%eax,8),%edx
801062f5:	80 
801062f6:	83 e2 e0             	and    $0xffffffe0,%edx
801062f9:	88 14 c5 84 93 11 80 	mov    %dl,-0x7fee6c7c(,%eax,8)
80106300:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106303:	0f b6 14 c5 84 93 11 	movzbl -0x7fee6c7c(,%eax,8),%edx
8010630a:	80 
8010630b:	83 e2 1f             	and    $0x1f,%edx
8010630e:	88 14 c5 84 93 11 80 	mov    %dl,-0x7fee6c7c(,%eax,8)
80106315:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106318:	0f b6 14 c5 85 93 11 	movzbl -0x7fee6c7b(,%eax,8),%edx
8010631f:	80 
80106320:	83 e2 f0             	and    $0xfffffff0,%edx
80106323:	83 ca 0e             	or     $0xe,%edx
80106326:	88 14 c5 85 93 11 80 	mov    %dl,-0x7fee6c7b(,%eax,8)
8010632d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106330:	0f b6 14 c5 85 93 11 	movzbl -0x7fee6c7b(,%eax,8),%edx
80106337:	80 
80106338:	83 e2 ef             	and    $0xffffffef,%edx
8010633b:	88 14 c5 85 93 11 80 	mov    %dl,-0x7fee6c7b(,%eax,8)
80106342:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106345:	0f b6 14 c5 85 93 11 	movzbl -0x7fee6c7b(,%eax,8),%edx
8010634c:	80 
8010634d:	83 e2 9f             	and    $0xffffff9f,%edx
80106350:	88 14 c5 85 93 11 80 	mov    %dl,-0x7fee6c7b(,%eax,8)
80106357:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010635a:	0f b6 14 c5 85 93 11 	movzbl -0x7fee6c7b(,%eax,8),%edx
80106361:	80 
80106362:	83 ca 80             	or     $0xffffff80,%edx
80106365:	88 14 c5 85 93 11 80 	mov    %dl,-0x7fee6c7b(,%eax,8)
8010636c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010636f:	8b 04 85 80 f0 10 80 	mov    -0x7fef0f80(,%eax,4),%eax
80106376:	c1 e8 10             	shr    $0x10,%eax
80106379:	89 c2                	mov    %eax,%edx
8010637b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010637e:	66 89 14 c5 86 93 11 	mov    %dx,-0x7fee6c7a(,%eax,8)
80106385:	80 
  for(i = 0; i < 256; i++)
80106386:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010638a:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80106391:	0f 8e 30 ff ff ff    	jle    801062c7 <tvinit+0x12>
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
80106397:	a1 80 f1 10 80       	mov    0x8010f180,%eax
8010639c:	66 a3 80 95 11 80    	mov    %ax,0x80119580
801063a2:	66 c7 05 82 95 11 80 	movw   $0x8,0x80119582
801063a9:	08 00 
801063ab:	0f b6 05 84 95 11 80 	movzbl 0x80119584,%eax
801063b2:	83 e0 e0             	and    $0xffffffe0,%eax
801063b5:	a2 84 95 11 80       	mov    %al,0x80119584
801063ba:	0f b6 05 84 95 11 80 	movzbl 0x80119584,%eax
801063c1:	83 e0 1f             	and    $0x1f,%eax
801063c4:	a2 84 95 11 80       	mov    %al,0x80119584
801063c9:	0f b6 05 85 95 11 80 	movzbl 0x80119585,%eax
801063d0:	83 c8 0f             	or     $0xf,%eax
801063d3:	a2 85 95 11 80       	mov    %al,0x80119585
801063d8:	0f b6 05 85 95 11 80 	movzbl 0x80119585,%eax
801063df:	83 e0 ef             	and    $0xffffffef,%eax
801063e2:	a2 85 95 11 80       	mov    %al,0x80119585
801063e7:	0f b6 05 85 95 11 80 	movzbl 0x80119585,%eax
801063ee:	83 c8 60             	or     $0x60,%eax
801063f1:	a2 85 95 11 80       	mov    %al,0x80119585
801063f6:	0f b6 05 85 95 11 80 	movzbl 0x80119585,%eax
801063fd:	83 c8 80             	or     $0xffffff80,%eax
80106400:	a2 85 95 11 80       	mov    %al,0x80119585
80106405:	a1 80 f1 10 80       	mov    0x8010f180,%eax
8010640a:	c1 e8 10             	shr    $0x10,%eax
8010640d:	66 a3 86 95 11 80    	mov    %ax,0x80119586

  initlock(&tickslock, "time");
80106413:	83 ec 08             	sub    $0x8,%esp
80106416:	68 3c a9 10 80       	push   $0x8010a93c
8010641b:	68 80 9b 11 80       	push   $0x80119b80
80106420:	e8 a6 e7 ff ff       	call   80104bcb <initlock>
80106425:	83 c4 10             	add    $0x10,%esp
}
80106428:	90                   	nop
80106429:	c9                   	leave  
8010642a:	c3                   	ret    

8010642b <idtinit>:

void
idtinit(void)
{
8010642b:	55                   	push   %ebp
8010642c:	89 e5                	mov    %esp,%ebp
  lidt(idt, sizeof(idt));
8010642e:	68 00 08 00 00       	push   $0x800
80106433:	68 80 93 11 80       	push   $0x80119380
80106438:	e8 3d fe ff ff       	call   8010627a <lidt>
8010643d:	83 c4 08             	add    $0x8,%esp
}
80106440:	90                   	nop
80106441:	c9                   	leave  
80106442:	c3                   	ret    

80106443 <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
80106443:	55                   	push   %ebp
80106444:	89 e5                	mov    %esp,%ebp
80106446:	57                   	push   %edi
80106447:	56                   	push   %esi
80106448:	53                   	push   %ebx
80106449:	83 ec 1c             	sub    $0x1c,%esp
  if(tf->trapno == T_SYSCALL){
8010644c:	8b 45 08             	mov    0x8(%ebp),%eax
8010644f:	8b 40 30             	mov    0x30(%eax),%eax
80106452:	83 f8 40             	cmp    $0x40,%eax
80106455:	75 3b                	jne    80106492 <trap+0x4f>
    if(myproc()->killed)
80106457:	e8 b8 da ff ff       	call   80103f14 <myproc>
8010645c:	8b 40 24             	mov    0x24(%eax),%eax
8010645f:	85 c0                	test   %eax,%eax
80106461:	74 05                	je     80106468 <trap+0x25>
      exit();
80106463:	e8 27 df ff ff       	call   8010438f <exit>
    myproc()->tf = tf;
80106468:	e8 a7 da ff ff       	call   80103f14 <myproc>
8010646d:	8b 55 08             	mov    0x8(%ebp),%edx
80106470:	89 50 18             	mov    %edx,0x18(%eax)
    syscall();
80106473:	e8 e2 ed ff ff       	call   8010525a <syscall>
    if(myproc()->killed)
80106478:	e8 97 da ff ff       	call   80103f14 <myproc>
8010647d:	8b 40 24             	mov    0x24(%eax),%eax
80106480:	85 c0                	test   %eax,%eax
80106482:	0f 84 a0 02 00 00    	je     80106728 <trap+0x2e5>
      exit();
80106488:	e8 02 df ff ff       	call   8010438f <exit>
    return;
8010648d:	e9 96 02 00 00       	jmp    80106728 <trap+0x2e5>
  }

  switch(tf->trapno){
80106492:	8b 45 08             	mov    0x8(%ebp),%eax
80106495:	8b 40 30             	mov    0x30(%eax),%eax
80106498:	83 e8 20             	sub    $0x20,%eax
8010649b:	83 f8 1f             	cmp    $0x1f,%eax
8010649e:	0f 87 4c 01 00 00    	ja     801065f0 <trap+0x1ad>
801064a4:	8b 04 85 f0 a9 10 80 	mov    -0x7fef5610(,%eax,4),%eax
801064ab:	ff e0                	jmp    *%eax
  case T_IRQ0 + IRQ_TIMER:
    if(cpuid() == 0){
801064ad:	e8 cf d9 ff ff       	call   80103e81 <cpuid>
801064b2:	85 c0                	test   %eax,%eax
801064b4:	75 3d                	jne    801064f3 <trap+0xb0>
      acquire(&tickslock);
801064b6:	83 ec 0c             	sub    $0xc,%esp
801064b9:	68 80 9b 11 80       	push   $0x80119b80
801064be:	e8 2a e7 ff ff       	call   80104bed <acquire>
801064c3:	83 c4 10             	add    $0x10,%esp
      ticks++;
801064c6:	a1 b4 9b 11 80       	mov    0x80119bb4,%eax
801064cb:	83 c0 01             	add    $0x1,%eax
801064ce:	a3 b4 9b 11 80       	mov    %eax,0x80119bb4
      wakeup(&ticks);
801064d3:	83 ec 0c             	sub    $0xc,%esp
801064d6:	68 b4 9b 11 80       	push   $0x80119bb4
801064db:	e8 d3 e3 ff ff       	call   801048b3 <wakeup>
801064e0:	83 c4 10             	add    $0x10,%esp
      release(&tickslock);
801064e3:	83 ec 0c             	sub    $0xc,%esp
801064e6:	68 80 9b 11 80       	push   $0x80119b80
801064eb:	e8 6b e7 ff ff       	call   80104c5b <release>
801064f0:	83 c4 10             	add    $0x10,%esp
    }
    lapiceoi();
801064f3:	e8 08 cb ff ff       	call   80103000 <lapiceoi>
    if(myproc())
801064f8:	e8 17 da ff ff       	call   80103f14 <myproc>
801064fd:	85 c0                	test   %eax,%eax
801064ff:	0f 84 a2 01 00 00    	je     801066a7 <trap+0x264>
    {
      if (ticks % 10 == 0 && myproc()->scheduler != 0 && myproc()->thread >= 1)
80106505:	8b 0d b4 9b 11 80    	mov    0x80119bb4,%ecx
8010650b:	ba cd cc cc cc       	mov    $0xcccccccd,%edx
80106510:	89 c8                	mov    %ecx,%eax
80106512:	f7 e2                	mul    %edx
80106514:	c1 ea 03             	shr    $0x3,%edx
80106517:	89 d0                	mov    %edx,%eax
80106519:	c1 e0 02             	shl    $0x2,%eax
8010651c:	01 d0                	add    %edx,%eax
8010651e:	01 c0                	add    %eax,%eax
80106520:	29 c1                	sub    %eax,%ecx
80106522:	89 ca                	mov    %ecx,%edx
80106524:	85 d2                	test   %edx,%edx
80106526:	0f 85 7b 01 00 00    	jne    801066a7 <trap+0x264>
8010652c:	e8 e3 d9 ff ff       	call   80103f14 <myproc>
80106531:	8b 40 7c             	mov    0x7c(%eax),%eax
80106534:	85 c0                	test   %eax,%eax
80106536:	0f 84 6b 01 00 00    	je     801066a7 <trap+0x264>
8010653c:	e8 d3 d9 ff ff       	call   80103f14 <myproc>
80106541:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80106547:	85 c0                	test   %eax,%eax
80106549:	0f 8e 58 01 00 00    	jle    801066a7 <trap+0x264>
      {
        cprintf("thread : %d\n", myproc()->thread);
8010654f:	e8 c0 d9 ff ff       	call   80103f14 <myproc>
80106554:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
8010655a:	83 ec 08             	sub    $0x8,%esp
8010655d:	50                   	push   %eax
8010655e:	68 41 a9 10 80       	push   $0x8010a941
80106563:	e8 8c 9e ff ff       	call   801003f4 <cprintf>
80106568:	83 c4 10             	add    $0x10,%esp
        myproc()->tf->eip = myproc()->scheduler;
8010656b:	e8 a4 d9 ff ff       	call   80103f14 <myproc>
80106570:	89 c3                	mov    %eax,%ebx
80106572:	e8 9d d9 ff ff       	call   80103f14 <myproc>
80106577:	8b 40 18             	mov    0x18(%eax),%eax
8010657a:	8b 53 7c             	mov    0x7c(%ebx),%edx
8010657d:	89 50 38             	mov    %edx,0x38(%eax)
      }
    }
    break;
80106580:	e9 22 01 00 00       	jmp    801066a7 <trap+0x264>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
80106585:	e8 cc c2 ff ff       	call   80102856 <ideintr>
    lapiceoi();
8010658a:	e8 71 ca ff ff       	call   80103000 <lapiceoi>
    break;
8010658f:	e9 14 01 00 00       	jmp    801066a8 <trap+0x265>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
80106594:	e8 ac c8 ff ff       	call   80102e45 <kbdintr>
    lapiceoi();
80106599:	e8 62 ca ff ff       	call   80103000 <lapiceoi>
    break;
8010659e:	e9 05 01 00 00       	jmp    801066a8 <trap+0x265>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
801065a3:	e8 56 03 00 00       	call   801068fe <uartintr>
    lapiceoi();
801065a8:	e8 53 ca ff ff       	call   80103000 <lapiceoi>
    break;
801065ad:	e9 f6 00 00 00       	jmp    801066a8 <trap+0x265>
  case T_IRQ0 + 0xB:
    i8254_intr();
801065b2:	e8 7e 2b 00 00       	call   80109135 <i8254_intr>
    lapiceoi();
801065b7:	e8 44 ca ff ff       	call   80103000 <lapiceoi>
    break;
801065bc:	e9 e7 00 00 00       	jmp    801066a8 <trap+0x265>
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
801065c1:	8b 45 08             	mov    0x8(%ebp),%eax
801065c4:	8b 70 38             	mov    0x38(%eax),%esi
            cpuid(), tf->cs, tf->eip);
801065c7:	8b 45 08             	mov    0x8(%ebp),%eax
801065ca:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
801065ce:	0f b7 d8             	movzwl %ax,%ebx
801065d1:	e8 ab d8 ff ff       	call   80103e81 <cpuid>
801065d6:	56                   	push   %esi
801065d7:	53                   	push   %ebx
801065d8:	50                   	push   %eax
801065d9:	68 50 a9 10 80       	push   $0x8010a950
801065de:	e8 11 9e ff ff       	call   801003f4 <cprintf>
801065e3:	83 c4 10             	add    $0x10,%esp
    lapiceoi();
801065e6:	e8 15 ca ff ff       	call   80103000 <lapiceoi>
    break;
801065eb:	e9 b8 00 00 00       	jmp    801066a8 <trap+0x265>

  //PAGEBREAK: 13
  default:
    if(myproc() == 0 || (tf->cs&3) == 0){
801065f0:	e8 1f d9 ff ff       	call   80103f14 <myproc>
801065f5:	85 c0                	test   %eax,%eax
801065f7:	74 11                	je     8010660a <trap+0x1c7>
801065f9:	8b 45 08             	mov    0x8(%ebp),%eax
801065fc:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106600:	0f b7 c0             	movzwl %ax,%eax
80106603:	83 e0 03             	and    $0x3,%eax
80106606:	85 c0                	test   %eax,%eax
80106608:	75 39                	jne    80106643 <trap+0x200>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
8010660a:	e8 95 fc ff ff       	call   801062a4 <rcr2>
8010660f:	89 c3                	mov    %eax,%ebx
80106611:	8b 45 08             	mov    0x8(%ebp),%eax
80106614:	8b 70 38             	mov    0x38(%eax),%esi
80106617:	e8 65 d8 ff ff       	call   80103e81 <cpuid>
8010661c:	8b 55 08             	mov    0x8(%ebp),%edx
8010661f:	8b 52 30             	mov    0x30(%edx),%edx
80106622:	83 ec 0c             	sub    $0xc,%esp
80106625:	53                   	push   %ebx
80106626:	56                   	push   %esi
80106627:	50                   	push   %eax
80106628:	52                   	push   %edx
80106629:	68 74 a9 10 80       	push   $0x8010a974
8010662e:	e8 c1 9d ff ff       	call   801003f4 <cprintf>
80106633:	83 c4 20             	add    $0x20,%esp
              tf->trapno, cpuid(), tf->eip, rcr2());
      panic("trap");
80106636:	83 ec 0c             	sub    $0xc,%esp
80106639:	68 a6 a9 10 80       	push   $0x8010a9a6
8010663e:	e8 66 9f ff ff       	call   801005a9 <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106643:	e8 5c fc ff ff       	call   801062a4 <rcr2>
80106648:	89 c6                	mov    %eax,%esi
8010664a:	8b 45 08             	mov    0x8(%ebp),%eax
8010664d:	8b 40 38             	mov    0x38(%eax),%eax
80106650:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80106653:	e8 29 d8 ff ff       	call   80103e81 <cpuid>
80106658:	89 c3                	mov    %eax,%ebx
8010665a:	8b 45 08             	mov    0x8(%ebp),%eax
8010665d:	8b 78 34             	mov    0x34(%eax),%edi
80106660:	89 7d e0             	mov    %edi,-0x20(%ebp)
80106663:	8b 45 08             	mov    0x8(%ebp),%eax
80106666:	8b 78 30             	mov    0x30(%eax),%edi
            "eip 0x%x addr 0x%x--kill proc\n",
            myproc()->pid, myproc()->name, tf->trapno,
80106669:	e8 a6 d8 ff ff       	call   80103f14 <myproc>
8010666e:	8d 48 6c             	lea    0x6c(%eax),%ecx
80106671:	89 4d dc             	mov    %ecx,-0x24(%ebp)
80106674:	e8 9b d8 ff ff       	call   80103f14 <myproc>
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106679:	8b 40 10             	mov    0x10(%eax),%eax
8010667c:	56                   	push   %esi
8010667d:	ff 75 e4             	push   -0x1c(%ebp)
80106680:	53                   	push   %ebx
80106681:	ff 75 e0             	push   -0x20(%ebp)
80106684:	57                   	push   %edi
80106685:	ff 75 dc             	push   -0x24(%ebp)
80106688:	50                   	push   %eax
80106689:	68 ac a9 10 80       	push   $0x8010a9ac
8010668e:	e8 61 9d ff ff       	call   801003f4 <cprintf>
80106693:	83 c4 20             	add    $0x20,%esp
            tf->err, cpuid(), tf->eip, rcr2());
    myproc()->killed = 1;
80106696:	e8 79 d8 ff ff       	call   80103f14 <myproc>
8010669b:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
801066a2:	eb 04                	jmp    801066a8 <trap+0x265>
    break;
801066a4:	90                   	nop
801066a5:	eb 01                	jmp    801066a8 <trap+0x265>
    break;
801066a7:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running
  // until it gets to the regular system call return.)
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
801066a8:	e8 67 d8 ff ff       	call   80103f14 <myproc>
801066ad:	85 c0                	test   %eax,%eax
801066af:	74 23                	je     801066d4 <trap+0x291>
801066b1:	e8 5e d8 ff ff       	call   80103f14 <myproc>
801066b6:	8b 40 24             	mov    0x24(%eax),%eax
801066b9:	85 c0                	test   %eax,%eax
801066bb:	74 17                	je     801066d4 <trap+0x291>
801066bd:	8b 45 08             	mov    0x8(%ebp),%eax
801066c0:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
801066c4:	0f b7 c0             	movzwl %ax,%eax
801066c7:	83 e0 03             	and    $0x3,%eax
801066ca:	83 f8 03             	cmp    $0x3,%eax
801066cd:	75 05                	jne    801066d4 <trap+0x291>
    exit();
801066cf:	e8 bb dc ff ff       	call   8010438f <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(myproc() && myproc()->state == RUNNING &&
801066d4:	e8 3b d8 ff ff       	call   80103f14 <myproc>
801066d9:	85 c0                	test   %eax,%eax
801066db:	74 1d                	je     801066fa <trap+0x2b7>
801066dd:	e8 32 d8 ff ff       	call   80103f14 <myproc>
801066e2:	8b 40 0c             	mov    0xc(%eax),%eax
801066e5:	83 f8 04             	cmp    $0x4,%eax
801066e8:	75 10                	jne    801066fa <trap+0x2b7>
     tf->trapno == T_IRQ0+IRQ_TIMER)
801066ea:	8b 45 08             	mov    0x8(%ebp),%eax
801066ed:	8b 40 30             	mov    0x30(%eax),%eax
  if(myproc() && myproc()->state == RUNNING &&
801066f0:	83 f8 20             	cmp    $0x20,%eax
801066f3:	75 05                	jne    801066fa <trap+0x2b7>
    yield();
801066f5:	e8 4f e0 ff ff       	call   80104749 <yield>

  // Check if the process has been killed since we yielded
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
801066fa:	e8 15 d8 ff ff       	call   80103f14 <myproc>
801066ff:	85 c0                	test   %eax,%eax
80106701:	74 26                	je     80106729 <trap+0x2e6>
80106703:	e8 0c d8 ff ff       	call   80103f14 <myproc>
80106708:	8b 40 24             	mov    0x24(%eax),%eax
8010670b:	85 c0                	test   %eax,%eax
8010670d:	74 1a                	je     80106729 <trap+0x2e6>
8010670f:	8b 45 08             	mov    0x8(%ebp),%eax
80106712:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106716:	0f b7 c0             	movzwl %ax,%eax
80106719:	83 e0 03             	and    $0x3,%eax
8010671c:	83 f8 03             	cmp    $0x3,%eax
8010671f:	75 08                	jne    80106729 <trap+0x2e6>
    exit();
80106721:	e8 69 dc ff ff       	call   8010438f <exit>
80106726:	eb 01                	jmp    80106729 <trap+0x2e6>
    return;
80106728:	90                   	nop
}
80106729:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010672c:	5b                   	pop    %ebx
8010672d:	5e                   	pop    %esi
8010672e:	5f                   	pop    %edi
8010672f:	5d                   	pop    %ebp
80106730:	c3                   	ret    

80106731 <inb>:
{
80106731:	55                   	push   %ebp
80106732:	89 e5                	mov    %esp,%ebp
80106734:	83 ec 14             	sub    $0x14,%esp
80106737:	8b 45 08             	mov    0x8(%ebp),%eax
8010673a:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010673e:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80106742:	89 c2                	mov    %eax,%edx
80106744:	ec                   	in     (%dx),%al
80106745:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80106748:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
8010674c:	c9                   	leave  
8010674d:	c3                   	ret    

8010674e <outb>:
{
8010674e:	55                   	push   %ebp
8010674f:	89 e5                	mov    %esp,%ebp
80106751:	83 ec 08             	sub    $0x8,%esp
80106754:	8b 45 08             	mov    0x8(%ebp),%eax
80106757:	8b 55 0c             	mov    0xc(%ebp),%edx
8010675a:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
8010675e:	89 d0                	mov    %edx,%eax
80106760:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80106763:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80106767:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
8010676b:	ee                   	out    %al,(%dx)
}
8010676c:	90                   	nop
8010676d:	c9                   	leave  
8010676e:	c3                   	ret    

8010676f <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
8010676f:	55                   	push   %ebp
80106770:	89 e5                	mov    %esp,%ebp
80106772:	83 ec 18             	sub    $0x18,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
80106775:	6a 00                	push   $0x0
80106777:	68 fa 03 00 00       	push   $0x3fa
8010677c:	e8 cd ff ff ff       	call   8010674e <outb>
80106781:	83 c4 08             	add    $0x8,%esp

  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
80106784:	68 80 00 00 00       	push   $0x80
80106789:	68 fb 03 00 00       	push   $0x3fb
8010678e:	e8 bb ff ff ff       	call   8010674e <outb>
80106793:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
80106796:	6a 0c                	push   $0xc
80106798:	68 f8 03 00 00       	push   $0x3f8
8010679d:	e8 ac ff ff ff       	call   8010674e <outb>
801067a2:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
801067a5:	6a 00                	push   $0x0
801067a7:	68 f9 03 00 00       	push   $0x3f9
801067ac:	e8 9d ff ff ff       	call   8010674e <outb>
801067b1:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
801067b4:	6a 03                	push   $0x3
801067b6:	68 fb 03 00 00       	push   $0x3fb
801067bb:	e8 8e ff ff ff       	call   8010674e <outb>
801067c0:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
801067c3:	6a 00                	push   $0x0
801067c5:	68 fc 03 00 00       	push   $0x3fc
801067ca:	e8 7f ff ff ff       	call   8010674e <outb>
801067cf:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0x01);    // Enable receive interrupts.
801067d2:	6a 01                	push   $0x1
801067d4:	68 f9 03 00 00       	push   $0x3f9
801067d9:	e8 70 ff ff ff       	call   8010674e <outb>
801067de:	83 c4 08             	add    $0x8,%esp

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
801067e1:	68 fd 03 00 00       	push   $0x3fd
801067e6:	e8 46 ff ff ff       	call   80106731 <inb>
801067eb:	83 c4 04             	add    $0x4,%esp
801067ee:	3c ff                	cmp    $0xff,%al
801067f0:	74 61                	je     80106853 <uartinit+0xe4>
    return;
  uart = 1;
801067f2:	c7 05 b8 9b 11 80 01 	movl   $0x1,0x80119bb8
801067f9:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
801067fc:	68 fa 03 00 00       	push   $0x3fa
80106801:	e8 2b ff ff ff       	call   80106731 <inb>
80106806:	83 c4 04             	add    $0x4,%esp
  inb(COM1+0);
80106809:	68 f8 03 00 00       	push   $0x3f8
8010680e:	e8 1e ff ff ff       	call   80106731 <inb>
80106813:	83 c4 04             	add    $0x4,%esp
  ioapicenable(IRQ_COM1, 0);
80106816:	83 ec 08             	sub    $0x8,%esp
80106819:	6a 00                	push   $0x0
8010681b:	6a 04                	push   $0x4
8010681d:	e8 f0 c2 ff ff       	call   80102b12 <ioapicenable>
80106822:	83 c4 10             	add    $0x10,%esp

  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80106825:	c7 45 f4 70 aa 10 80 	movl   $0x8010aa70,-0xc(%ebp)
8010682c:	eb 19                	jmp    80106847 <uartinit+0xd8>
    uartputc(*p);
8010682e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106831:	0f b6 00             	movzbl (%eax),%eax
80106834:	0f be c0             	movsbl %al,%eax
80106837:	83 ec 0c             	sub    $0xc,%esp
8010683a:	50                   	push   %eax
8010683b:	e8 16 00 00 00       	call   80106856 <uartputc>
80106840:	83 c4 10             	add    $0x10,%esp
  for(p="xv6...\n"; *p; p++)
80106843:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106847:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010684a:	0f b6 00             	movzbl (%eax),%eax
8010684d:	84 c0                	test   %al,%al
8010684f:	75 dd                	jne    8010682e <uartinit+0xbf>
80106851:	eb 01                	jmp    80106854 <uartinit+0xe5>
    return;
80106853:	90                   	nop
}
80106854:	c9                   	leave  
80106855:	c3                   	ret    

80106856 <uartputc>:

void
uartputc(int c)
{
80106856:	55                   	push   %ebp
80106857:	89 e5                	mov    %esp,%ebp
80106859:	83 ec 18             	sub    $0x18,%esp
  int i;

  if(!uart)
8010685c:	a1 b8 9b 11 80       	mov    0x80119bb8,%eax
80106861:	85 c0                	test   %eax,%eax
80106863:	74 53                	je     801068b8 <uartputc+0x62>
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106865:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010686c:	eb 11                	jmp    8010687f <uartputc+0x29>
    microdelay(10);
8010686e:	83 ec 0c             	sub    $0xc,%esp
80106871:	6a 0a                	push   $0xa
80106873:	e8 a3 c7 ff ff       	call   8010301b <microdelay>
80106878:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
8010687b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010687f:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
80106883:	7f 1a                	jg     8010689f <uartputc+0x49>
80106885:	83 ec 0c             	sub    $0xc,%esp
80106888:	68 fd 03 00 00       	push   $0x3fd
8010688d:	e8 9f fe ff ff       	call   80106731 <inb>
80106892:	83 c4 10             	add    $0x10,%esp
80106895:	0f b6 c0             	movzbl %al,%eax
80106898:	83 e0 20             	and    $0x20,%eax
8010689b:	85 c0                	test   %eax,%eax
8010689d:	74 cf                	je     8010686e <uartputc+0x18>
  outb(COM1+0, c);
8010689f:	8b 45 08             	mov    0x8(%ebp),%eax
801068a2:	0f b6 c0             	movzbl %al,%eax
801068a5:	83 ec 08             	sub    $0x8,%esp
801068a8:	50                   	push   %eax
801068a9:	68 f8 03 00 00       	push   $0x3f8
801068ae:	e8 9b fe ff ff       	call   8010674e <outb>
801068b3:	83 c4 10             	add    $0x10,%esp
801068b6:	eb 01                	jmp    801068b9 <uartputc+0x63>
    return;
801068b8:	90                   	nop
}
801068b9:	c9                   	leave  
801068ba:	c3                   	ret    

801068bb <uartgetc>:

static int
uartgetc(void)
{
801068bb:	55                   	push   %ebp
801068bc:	89 e5                	mov    %esp,%ebp
  if(!uart)
801068be:	a1 b8 9b 11 80       	mov    0x80119bb8,%eax
801068c3:	85 c0                	test   %eax,%eax
801068c5:	75 07                	jne    801068ce <uartgetc+0x13>
    return -1;
801068c7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801068cc:	eb 2e                	jmp    801068fc <uartgetc+0x41>
  if(!(inb(COM1+5) & 0x01))
801068ce:	68 fd 03 00 00       	push   $0x3fd
801068d3:	e8 59 fe ff ff       	call   80106731 <inb>
801068d8:	83 c4 04             	add    $0x4,%esp
801068db:	0f b6 c0             	movzbl %al,%eax
801068de:	83 e0 01             	and    $0x1,%eax
801068e1:	85 c0                	test   %eax,%eax
801068e3:	75 07                	jne    801068ec <uartgetc+0x31>
    return -1;
801068e5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801068ea:	eb 10                	jmp    801068fc <uartgetc+0x41>
  return inb(COM1+0);
801068ec:	68 f8 03 00 00       	push   $0x3f8
801068f1:	e8 3b fe ff ff       	call   80106731 <inb>
801068f6:	83 c4 04             	add    $0x4,%esp
801068f9:	0f b6 c0             	movzbl %al,%eax
}
801068fc:	c9                   	leave  
801068fd:	c3                   	ret    

801068fe <uartintr>:

void
uartintr(void)
{
801068fe:	55                   	push   %ebp
801068ff:	89 e5                	mov    %esp,%ebp
80106901:	83 ec 08             	sub    $0x8,%esp
  consoleintr(uartgetc);
80106904:	83 ec 0c             	sub    $0xc,%esp
80106907:	68 bb 68 10 80       	push   $0x801068bb
8010690c:	e8 c5 9e ff ff       	call   801007d6 <consoleintr>
80106911:	83 c4 10             	add    $0x10,%esp
}
80106914:	90                   	nop
80106915:	c9                   	leave  
80106916:	c3                   	ret    

80106917 <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
80106917:	6a 00                	push   $0x0
  pushl $0
80106919:	6a 00                	push   $0x0
  jmp alltraps
8010691b:	e9 37 f9 ff ff       	jmp    80106257 <alltraps>

80106920 <vector1>:
.globl vector1
vector1:
  pushl $0
80106920:	6a 00                	push   $0x0
  pushl $1
80106922:	6a 01                	push   $0x1
  jmp alltraps
80106924:	e9 2e f9 ff ff       	jmp    80106257 <alltraps>

80106929 <vector2>:
.globl vector2
vector2:
  pushl $0
80106929:	6a 00                	push   $0x0
  pushl $2
8010692b:	6a 02                	push   $0x2
  jmp alltraps
8010692d:	e9 25 f9 ff ff       	jmp    80106257 <alltraps>

80106932 <vector3>:
.globl vector3
vector3:
  pushl $0
80106932:	6a 00                	push   $0x0
  pushl $3
80106934:	6a 03                	push   $0x3
  jmp alltraps
80106936:	e9 1c f9 ff ff       	jmp    80106257 <alltraps>

8010693b <vector4>:
.globl vector4
vector4:
  pushl $0
8010693b:	6a 00                	push   $0x0
  pushl $4
8010693d:	6a 04                	push   $0x4
  jmp alltraps
8010693f:	e9 13 f9 ff ff       	jmp    80106257 <alltraps>

80106944 <vector5>:
.globl vector5
vector5:
  pushl $0
80106944:	6a 00                	push   $0x0
  pushl $5
80106946:	6a 05                	push   $0x5
  jmp alltraps
80106948:	e9 0a f9 ff ff       	jmp    80106257 <alltraps>

8010694d <vector6>:
.globl vector6
vector6:
  pushl $0
8010694d:	6a 00                	push   $0x0
  pushl $6
8010694f:	6a 06                	push   $0x6
  jmp alltraps
80106951:	e9 01 f9 ff ff       	jmp    80106257 <alltraps>

80106956 <vector7>:
.globl vector7
vector7:
  pushl $0
80106956:	6a 00                	push   $0x0
  pushl $7
80106958:	6a 07                	push   $0x7
  jmp alltraps
8010695a:	e9 f8 f8 ff ff       	jmp    80106257 <alltraps>

8010695f <vector8>:
.globl vector8
vector8:
  pushl $8
8010695f:	6a 08                	push   $0x8
  jmp alltraps
80106961:	e9 f1 f8 ff ff       	jmp    80106257 <alltraps>

80106966 <vector9>:
.globl vector9
vector9:
  pushl $0
80106966:	6a 00                	push   $0x0
  pushl $9
80106968:	6a 09                	push   $0x9
  jmp alltraps
8010696a:	e9 e8 f8 ff ff       	jmp    80106257 <alltraps>

8010696f <vector10>:
.globl vector10
vector10:
  pushl $10
8010696f:	6a 0a                	push   $0xa
  jmp alltraps
80106971:	e9 e1 f8 ff ff       	jmp    80106257 <alltraps>

80106976 <vector11>:
.globl vector11
vector11:
  pushl $11
80106976:	6a 0b                	push   $0xb
  jmp alltraps
80106978:	e9 da f8 ff ff       	jmp    80106257 <alltraps>

8010697d <vector12>:
.globl vector12
vector12:
  pushl $12
8010697d:	6a 0c                	push   $0xc
  jmp alltraps
8010697f:	e9 d3 f8 ff ff       	jmp    80106257 <alltraps>

80106984 <vector13>:
.globl vector13
vector13:
  pushl $13
80106984:	6a 0d                	push   $0xd
  jmp alltraps
80106986:	e9 cc f8 ff ff       	jmp    80106257 <alltraps>

8010698b <vector14>:
.globl vector14
vector14:
  pushl $14
8010698b:	6a 0e                	push   $0xe
  jmp alltraps
8010698d:	e9 c5 f8 ff ff       	jmp    80106257 <alltraps>

80106992 <vector15>:
.globl vector15
vector15:
  pushl $0
80106992:	6a 00                	push   $0x0
  pushl $15
80106994:	6a 0f                	push   $0xf
  jmp alltraps
80106996:	e9 bc f8 ff ff       	jmp    80106257 <alltraps>

8010699b <vector16>:
.globl vector16
vector16:
  pushl $0
8010699b:	6a 00                	push   $0x0
  pushl $16
8010699d:	6a 10                	push   $0x10
  jmp alltraps
8010699f:	e9 b3 f8 ff ff       	jmp    80106257 <alltraps>

801069a4 <vector17>:
.globl vector17
vector17:
  pushl $17
801069a4:	6a 11                	push   $0x11
  jmp alltraps
801069a6:	e9 ac f8 ff ff       	jmp    80106257 <alltraps>

801069ab <vector18>:
.globl vector18
vector18:
  pushl $0
801069ab:	6a 00                	push   $0x0
  pushl $18
801069ad:	6a 12                	push   $0x12
  jmp alltraps
801069af:	e9 a3 f8 ff ff       	jmp    80106257 <alltraps>

801069b4 <vector19>:
.globl vector19
vector19:
  pushl $0
801069b4:	6a 00                	push   $0x0
  pushl $19
801069b6:	6a 13                	push   $0x13
  jmp alltraps
801069b8:	e9 9a f8 ff ff       	jmp    80106257 <alltraps>

801069bd <vector20>:
.globl vector20
vector20:
  pushl $0
801069bd:	6a 00                	push   $0x0
  pushl $20
801069bf:	6a 14                	push   $0x14
  jmp alltraps
801069c1:	e9 91 f8 ff ff       	jmp    80106257 <alltraps>

801069c6 <vector21>:
.globl vector21
vector21:
  pushl $0
801069c6:	6a 00                	push   $0x0
  pushl $21
801069c8:	6a 15                	push   $0x15
  jmp alltraps
801069ca:	e9 88 f8 ff ff       	jmp    80106257 <alltraps>

801069cf <vector22>:
.globl vector22
vector22:
  pushl $0
801069cf:	6a 00                	push   $0x0
  pushl $22
801069d1:	6a 16                	push   $0x16
  jmp alltraps
801069d3:	e9 7f f8 ff ff       	jmp    80106257 <alltraps>

801069d8 <vector23>:
.globl vector23
vector23:
  pushl $0
801069d8:	6a 00                	push   $0x0
  pushl $23
801069da:	6a 17                	push   $0x17
  jmp alltraps
801069dc:	e9 76 f8 ff ff       	jmp    80106257 <alltraps>

801069e1 <vector24>:
.globl vector24
vector24:
  pushl $0
801069e1:	6a 00                	push   $0x0
  pushl $24
801069e3:	6a 18                	push   $0x18
  jmp alltraps
801069e5:	e9 6d f8 ff ff       	jmp    80106257 <alltraps>

801069ea <vector25>:
.globl vector25
vector25:
  pushl $0
801069ea:	6a 00                	push   $0x0
  pushl $25
801069ec:	6a 19                	push   $0x19
  jmp alltraps
801069ee:	e9 64 f8 ff ff       	jmp    80106257 <alltraps>

801069f3 <vector26>:
.globl vector26
vector26:
  pushl $0
801069f3:	6a 00                	push   $0x0
  pushl $26
801069f5:	6a 1a                	push   $0x1a
  jmp alltraps
801069f7:	e9 5b f8 ff ff       	jmp    80106257 <alltraps>

801069fc <vector27>:
.globl vector27
vector27:
  pushl $0
801069fc:	6a 00                	push   $0x0
  pushl $27
801069fe:	6a 1b                	push   $0x1b
  jmp alltraps
80106a00:	e9 52 f8 ff ff       	jmp    80106257 <alltraps>

80106a05 <vector28>:
.globl vector28
vector28:
  pushl $0
80106a05:	6a 00                	push   $0x0
  pushl $28
80106a07:	6a 1c                	push   $0x1c
  jmp alltraps
80106a09:	e9 49 f8 ff ff       	jmp    80106257 <alltraps>

80106a0e <vector29>:
.globl vector29
vector29:
  pushl $0
80106a0e:	6a 00                	push   $0x0
  pushl $29
80106a10:	6a 1d                	push   $0x1d
  jmp alltraps
80106a12:	e9 40 f8 ff ff       	jmp    80106257 <alltraps>

80106a17 <vector30>:
.globl vector30
vector30:
  pushl $0
80106a17:	6a 00                	push   $0x0
  pushl $30
80106a19:	6a 1e                	push   $0x1e
  jmp alltraps
80106a1b:	e9 37 f8 ff ff       	jmp    80106257 <alltraps>

80106a20 <vector31>:
.globl vector31
vector31:
  pushl $0
80106a20:	6a 00                	push   $0x0
  pushl $31
80106a22:	6a 1f                	push   $0x1f
  jmp alltraps
80106a24:	e9 2e f8 ff ff       	jmp    80106257 <alltraps>

80106a29 <vector32>:
.globl vector32
vector32:
  pushl $0
80106a29:	6a 00                	push   $0x0
  pushl $32
80106a2b:	6a 20                	push   $0x20
  jmp alltraps
80106a2d:	e9 25 f8 ff ff       	jmp    80106257 <alltraps>

80106a32 <vector33>:
.globl vector33
vector33:
  pushl $0
80106a32:	6a 00                	push   $0x0
  pushl $33
80106a34:	6a 21                	push   $0x21
  jmp alltraps
80106a36:	e9 1c f8 ff ff       	jmp    80106257 <alltraps>

80106a3b <vector34>:
.globl vector34
vector34:
  pushl $0
80106a3b:	6a 00                	push   $0x0
  pushl $34
80106a3d:	6a 22                	push   $0x22
  jmp alltraps
80106a3f:	e9 13 f8 ff ff       	jmp    80106257 <alltraps>

80106a44 <vector35>:
.globl vector35
vector35:
  pushl $0
80106a44:	6a 00                	push   $0x0
  pushl $35
80106a46:	6a 23                	push   $0x23
  jmp alltraps
80106a48:	e9 0a f8 ff ff       	jmp    80106257 <alltraps>

80106a4d <vector36>:
.globl vector36
vector36:
  pushl $0
80106a4d:	6a 00                	push   $0x0
  pushl $36
80106a4f:	6a 24                	push   $0x24
  jmp alltraps
80106a51:	e9 01 f8 ff ff       	jmp    80106257 <alltraps>

80106a56 <vector37>:
.globl vector37
vector37:
  pushl $0
80106a56:	6a 00                	push   $0x0
  pushl $37
80106a58:	6a 25                	push   $0x25
  jmp alltraps
80106a5a:	e9 f8 f7 ff ff       	jmp    80106257 <alltraps>

80106a5f <vector38>:
.globl vector38
vector38:
  pushl $0
80106a5f:	6a 00                	push   $0x0
  pushl $38
80106a61:	6a 26                	push   $0x26
  jmp alltraps
80106a63:	e9 ef f7 ff ff       	jmp    80106257 <alltraps>

80106a68 <vector39>:
.globl vector39
vector39:
  pushl $0
80106a68:	6a 00                	push   $0x0
  pushl $39
80106a6a:	6a 27                	push   $0x27
  jmp alltraps
80106a6c:	e9 e6 f7 ff ff       	jmp    80106257 <alltraps>

80106a71 <vector40>:
.globl vector40
vector40:
  pushl $0
80106a71:	6a 00                	push   $0x0
  pushl $40
80106a73:	6a 28                	push   $0x28
  jmp alltraps
80106a75:	e9 dd f7 ff ff       	jmp    80106257 <alltraps>

80106a7a <vector41>:
.globl vector41
vector41:
  pushl $0
80106a7a:	6a 00                	push   $0x0
  pushl $41
80106a7c:	6a 29                	push   $0x29
  jmp alltraps
80106a7e:	e9 d4 f7 ff ff       	jmp    80106257 <alltraps>

80106a83 <vector42>:
.globl vector42
vector42:
  pushl $0
80106a83:	6a 00                	push   $0x0
  pushl $42
80106a85:	6a 2a                	push   $0x2a
  jmp alltraps
80106a87:	e9 cb f7 ff ff       	jmp    80106257 <alltraps>

80106a8c <vector43>:
.globl vector43
vector43:
  pushl $0
80106a8c:	6a 00                	push   $0x0
  pushl $43
80106a8e:	6a 2b                	push   $0x2b
  jmp alltraps
80106a90:	e9 c2 f7 ff ff       	jmp    80106257 <alltraps>

80106a95 <vector44>:
.globl vector44
vector44:
  pushl $0
80106a95:	6a 00                	push   $0x0
  pushl $44
80106a97:	6a 2c                	push   $0x2c
  jmp alltraps
80106a99:	e9 b9 f7 ff ff       	jmp    80106257 <alltraps>

80106a9e <vector45>:
.globl vector45
vector45:
  pushl $0
80106a9e:	6a 00                	push   $0x0
  pushl $45
80106aa0:	6a 2d                	push   $0x2d
  jmp alltraps
80106aa2:	e9 b0 f7 ff ff       	jmp    80106257 <alltraps>

80106aa7 <vector46>:
.globl vector46
vector46:
  pushl $0
80106aa7:	6a 00                	push   $0x0
  pushl $46
80106aa9:	6a 2e                	push   $0x2e
  jmp alltraps
80106aab:	e9 a7 f7 ff ff       	jmp    80106257 <alltraps>

80106ab0 <vector47>:
.globl vector47
vector47:
  pushl $0
80106ab0:	6a 00                	push   $0x0
  pushl $47
80106ab2:	6a 2f                	push   $0x2f
  jmp alltraps
80106ab4:	e9 9e f7 ff ff       	jmp    80106257 <alltraps>

80106ab9 <vector48>:
.globl vector48
vector48:
  pushl $0
80106ab9:	6a 00                	push   $0x0
  pushl $48
80106abb:	6a 30                	push   $0x30
  jmp alltraps
80106abd:	e9 95 f7 ff ff       	jmp    80106257 <alltraps>

80106ac2 <vector49>:
.globl vector49
vector49:
  pushl $0
80106ac2:	6a 00                	push   $0x0
  pushl $49
80106ac4:	6a 31                	push   $0x31
  jmp alltraps
80106ac6:	e9 8c f7 ff ff       	jmp    80106257 <alltraps>

80106acb <vector50>:
.globl vector50
vector50:
  pushl $0
80106acb:	6a 00                	push   $0x0
  pushl $50
80106acd:	6a 32                	push   $0x32
  jmp alltraps
80106acf:	e9 83 f7 ff ff       	jmp    80106257 <alltraps>

80106ad4 <vector51>:
.globl vector51
vector51:
  pushl $0
80106ad4:	6a 00                	push   $0x0
  pushl $51
80106ad6:	6a 33                	push   $0x33
  jmp alltraps
80106ad8:	e9 7a f7 ff ff       	jmp    80106257 <alltraps>

80106add <vector52>:
.globl vector52
vector52:
  pushl $0
80106add:	6a 00                	push   $0x0
  pushl $52
80106adf:	6a 34                	push   $0x34
  jmp alltraps
80106ae1:	e9 71 f7 ff ff       	jmp    80106257 <alltraps>

80106ae6 <vector53>:
.globl vector53
vector53:
  pushl $0
80106ae6:	6a 00                	push   $0x0
  pushl $53
80106ae8:	6a 35                	push   $0x35
  jmp alltraps
80106aea:	e9 68 f7 ff ff       	jmp    80106257 <alltraps>

80106aef <vector54>:
.globl vector54
vector54:
  pushl $0
80106aef:	6a 00                	push   $0x0
  pushl $54
80106af1:	6a 36                	push   $0x36
  jmp alltraps
80106af3:	e9 5f f7 ff ff       	jmp    80106257 <alltraps>

80106af8 <vector55>:
.globl vector55
vector55:
  pushl $0
80106af8:	6a 00                	push   $0x0
  pushl $55
80106afa:	6a 37                	push   $0x37
  jmp alltraps
80106afc:	e9 56 f7 ff ff       	jmp    80106257 <alltraps>

80106b01 <vector56>:
.globl vector56
vector56:
  pushl $0
80106b01:	6a 00                	push   $0x0
  pushl $56
80106b03:	6a 38                	push   $0x38
  jmp alltraps
80106b05:	e9 4d f7 ff ff       	jmp    80106257 <alltraps>

80106b0a <vector57>:
.globl vector57
vector57:
  pushl $0
80106b0a:	6a 00                	push   $0x0
  pushl $57
80106b0c:	6a 39                	push   $0x39
  jmp alltraps
80106b0e:	e9 44 f7 ff ff       	jmp    80106257 <alltraps>

80106b13 <vector58>:
.globl vector58
vector58:
  pushl $0
80106b13:	6a 00                	push   $0x0
  pushl $58
80106b15:	6a 3a                	push   $0x3a
  jmp alltraps
80106b17:	e9 3b f7 ff ff       	jmp    80106257 <alltraps>

80106b1c <vector59>:
.globl vector59
vector59:
  pushl $0
80106b1c:	6a 00                	push   $0x0
  pushl $59
80106b1e:	6a 3b                	push   $0x3b
  jmp alltraps
80106b20:	e9 32 f7 ff ff       	jmp    80106257 <alltraps>

80106b25 <vector60>:
.globl vector60
vector60:
  pushl $0
80106b25:	6a 00                	push   $0x0
  pushl $60
80106b27:	6a 3c                	push   $0x3c
  jmp alltraps
80106b29:	e9 29 f7 ff ff       	jmp    80106257 <alltraps>

80106b2e <vector61>:
.globl vector61
vector61:
  pushl $0
80106b2e:	6a 00                	push   $0x0
  pushl $61
80106b30:	6a 3d                	push   $0x3d
  jmp alltraps
80106b32:	e9 20 f7 ff ff       	jmp    80106257 <alltraps>

80106b37 <vector62>:
.globl vector62
vector62:
  pushl $0
80106b37:	6a 00                	push   $0x0
  pushl $62
80106b39:	6a 3e                	push   $0x3e
  jmp alltraps
80106b3b:	e9 17 f7 ff ff       	jmp    80106257 <alltraps>

80106b40 <vector63>:
.globl vector63
vector63:
  pushl $0
80106b40:	6a 00                	push   $0x0
  pushl $63
80106b42:	6a 3f                	push   $0x3f
  jmp alltraps
80106b44:	e9 0e f7 ff ff       	jmp    80106257 <alltraps>

80106b49 <vector64>:
.globl vector64
vector64:
  pushl $0
80106b49:	6a 00                	push   $0x0
  pushl $64
80106b4b:	6a 40                	push   $0x40
  jmp alltraps
80106b4d:	e9 05 f7 ff ff       	jmp    80106257 <alltraps>

80106b52 <vector65>:
.globl vector65
vector65:
  pushl $0
80106b52:	6a 00                	push   $0x0
  pushl $65
80106b54:	6a 41                	push   $0x41
  jmp alltraps
80106b56:	e9 fc f6 ff ff       	jmp    80106257 <alltraps>

80106b5b <vector66>:
.globl vector66
vector66:
  pushl $0
80106b5b:	6a 00                	push   $0x0
  pushl $66
80106b5d:	6a 42                	push   $0x42
  jmp alltraps
80106b5f:	e9 f3 f6 ff ff       	jmp    80106257 <alltraps>

80106b64 <vector67>:
.globl vector67
vector67:
  pushl $0
80106b64:	6a 00                	push   $0x0
  pushl $67
80106b66:	6a 43                	push   $0x43
  jmp alltraps
80106b68:	e9 ea f6 ff ff       	jmp    80106257 <alltraps>

80106b6d <vector68>:
.globl vector68
vector68:
  pushl $0
80106b6d:	6a 00                	push   $0x0
  pushl $68
80106b6f:	6a 44                	push   $0x44
  jmp alltraps
80106b71:	e9 e1 f6 ff ff       	jmp    80106257 <alltraps>

80106b76 <vector69>:
.globl vector69
vector69:
  pushl $0
80106b76:	6a 00                	push   $0x0
  pushl $69
80106b78:	6a 45                	push   $0x45
  jmp alltraps
80106b7a:	e9 d8 f6 ff ff       	jmp    80106257 <alltraps>

80106b7f <vector70>:
.globl vector70
vector70:
  pushl $0
80106b7f:	6a 00                	push   $0x0
  pushl $70
80106b81:	6a 46                	push   $0x46
  jmp alltraps
80106b83:	e9 cf f6 ff ff       	jmp    80106257 <alltraps>

80106b88 <vector71>:
.globl vector71
vector71:
  pushl $0
80106b88:	6a 00                	push   $0x0
  pushl $71
80106b8a:	6a 47                	push   $0x47
  jmp alltraps
80106b8c:	e9 c6 f6 ff ff       	jmp    80106257 <alltraps>

80106b91 <vector72>:
.globl vector72
vector72:
  pushl $0
80106b91:	6a 00                	push   $0x0
  pushl $72
80106b93:	6a 48                	push   $0x48
  jmp alltraps
80106b95:	e9 bd f6 ff ff       	jmp    80106257 <alltraps>

80106b9a <vector73>:
.globl vector73
vector73:
  pushl $0
80106b9a:	6a 00                	push   $0x0
  pushl $73
80106b9c:	6a 49                	push   $0x49
  jmp alltraps
80106b9e:	e9 b4 f6 ff ff       	jmp    80106257 <alltraps>

80106ba3 <vector74>:
.globl vector74
vector74:
  pushl $0
80106ba3:	6a 00                	push   $0x0
  pushl $74
80106ba5:	6a 4a                	push   $0x4a
  jmp alltraps
80106ba7:	e9 ab f6 ff ff       	jmp    80106257 <alltraps>

80106bac <vector75>:
.globl vector75
vector75:
  pushl $0
80106bac:	6a 00                	push   $0x0
  pushl $75
80106bae:	6a 4b                	push   $0x4b
  jmp alltraps
80106bb0:	e9 a2 f6 ff ff       	jmp    80106257 <alltraps>

80106bb5 <vector76>:
.globl vector76
vector76:
  pushl $0
80106bb5:	6a 00                	push   $0x0
  pushl $76
80106bb7:	6a 4c                	push   $0x4c
  jmp alltraps
80106bb9:	e9 99 f6 ff ff       	jmp    80106257 <alltraps>

80106bbe <vector77>:
.globl vector77
vector77:
  pushl $0
80106bbe:	6a 00                	push   $0x0
  pushl $77
80106bc0:	6a 4d                	push   $0x4d
  jmp alltraps
80106bc2:	e9 90 f6 ff ff       	jmp    80106257 <alltraps>

80106bc7 <vector78>:
.globl vector78
vector78:
  pushl $0
80106bc7:	6a 00                	push   $0x0
  pushl $78
80106bc9:	6a 4e                	push   $0x4e
  jmp alltraps
80106bcb:	e9 87 f6 ff ff       	jmp    80106257 <alltraps>

80106bd0 <vector79>:
.globl vector79
vector79:
  pushl $0
80106bd0:	6a 00                	push   $0x0
  pushl $79
80106bd2:	6a 4f                	push   $0x4f
  jmp alltraps
80106bd4:	e9 7e f6 ff ff       	jmp    80106257 <alltraps>

80106bd9 <vector80>:
.globl vector80
vector80:
  pushl $0
80106bd9:	6a 00                	push   $0x0
  pushl $80
80106bdb:	6a 50                	push   $0x50
  jmp alltraps
80106bdd:	e9 75 f6 ff ff       	jmp    80106257 <alltraps>

80106be2 <vector81>:
.globl vector81
vector81:
  pushl $0
80106be2:	6a 00                	push   $0x0
  pushl $81
80106be4:	6a 51                	push   $0x51
  jmp alltraps
80106be6:	e9 6c f6 ff ff       	jmp    80106257 <alltraps>

80106beb <vector82>:
.globl vector82
vector82:
  pushl $0
80106beb:	6a 00                	push   $0x0
  pushl $82
80106bed:	6a 52                	push   $0x52
  jmp alltraps
80106bef:	e9 63 f6 ff ff       	jmp    80106257 <alltraps>

80106bf4 <vector83>:
.globl vector83
vector83:
  pushl $0
80106bf4:	6a 00                	push   $0x0
  pushl $83
80106bf6:	6a 53                	push   $0x53
  jmp alltraps
80106bf8:	e9 5a f6 ff ff       	jmp    80106257 <alltraps>

80106bfd <vector84>:
.globl vector84
vector84:
  pushl $0
80106bfd:	6a 00                	push   $0x0
  pushl $84
80106bff:	6a 54                	push   $0x54
  jmp alltraps
80106c01:	e9 51 f6 ff ff       	jmp    80106257 <alltraps>

80106c06 <vector85>:
.globl vector85
vector85:
  pushl $0
80106c06:	6a 00                	push   $0x0
  pushl $85
80106c08:	6a 55                	push   $0x55
  jmp alltraps
80106c0a:	e9 48 f6 ff ff       	jmp    80106257 <alltraps>

80106c0f <vector86>:
.globl vector86
vector86:
  pushl $0
80106c0f:	6a 00                	push   $0x0
  pushl $86
80106c11:	6a 56                	push   $0x56
  jmp alltraps
80106c13:	e9 3f f6 ff ff       	jmp    80106257 <alltraps>

80106c18 <vector87>:
.globl vector87
vector87:
  pushl $0
80106c18:	6a 00                	push   $0x0
  pushl $87
80106c1a:	6a 57                	push   $0x57
  jmp alltraps
80106c1c:	e9 36 f6 ff ff       	jmp    80106257 <alltraps>

80106c21 <vector88>:
.globl vector88
vector88:
  pushl $0
80106c21:	6a 00                	push   $0x0
  pushl $88
80106c23:	6a 58                	push   $0x58
  jmp alltraps
80106c25:	e9 2d f6 ff ff       	jmp    80106257 <alltraps>

80106c2a <vector89>:
.globl vector89
vector89:
  pushl $0
80106c2a:	6a 00                	push   $0x0
  pushl $89
80106c2c:	6a 59                	push   $0x59
  jmp alltraps
80106c2e:	e9 24 f6 ff ff       	jmp    80106257 <alltraps>

80106c33 <vector90>:
.globl vector90
vector90:
  pushl $0
80106c33:	6a 00                	push   $0x0
  pushl $90
80106c35:	6a 5a                	push   $0x5a
  jmp alltraps
80106c37:	e9 1b f6 ff ff       	jmp    80106257 <alltraps>

80106c3c <vector91>:
.globl vector91
vector91:
  pushl $0
80106c3c:	6a 00                	push   $0x0
  pushl $91
80106c3e:	6a 5b                	push   $0x5b
  jmp alltraps
80106c40:	e9 12 f6 ff ff       	jmp    80106257 <alltraps>

80106c45 <vector92>:
.globl vector92
vector92:
  pushl $0
80106c45:	6a 00                	push   $0x0
  pushl $92
80106c47:	6a 5c                	push   $0x5c
  jmp alltraps
80106c49:	e9 09 f6 ff ff       	jmp    80106257 <alltraps>

80106c4e <vector93>:
.globl vector93
vector93:
  pushl $0
80106c4e:	6a 00                	push   $0x0
  pushl $93
80106c50:	6a 5d                	push   $0x5d
  jmp alltraps
80106c52:	e9 00 f6 ff ff       	jmp    80106257 <alltraps>

80106c57 <vector94>:
.globl vector94
vector94:
  pushl $0
80106c57:	6a 00                	push   $0x0
  pushl $94
80106c59:	6a 5e                	push   $0x5e
  jmp alltraps
80106c5b:	e9 f7 f5 ff ff       	jmp    80106257 <alltraps>

80106c60 <vector95>:
.globl vector95
vector95:
  pushl $0
80106c60:	6a 00                	push   $0x0
  pushl $95
80106c62:	6a 5f                	push   $0x5f
  jmp alltraps
80106c64:	e9 ee f5 ff ff       	jmp    80106257 <alltraps>

80106c69 <vector96>:
.globl vector96
vector96:
  pushl $0
80106c69:	6a 00                	push   $0x0
  pushl $96
80106c6b:	6a 60                	push   $0x60
  jmp alltraps
80106c6d:	e9 e5 f5 ff ff       	jmp    80106257 <alltraps>

80106c72 <vector97>:
.globl vector97
vector97:
  pushl $0
80106c72:	6a 00                	push   $0x0
  pushl $97
80106c74:	6a 61                	push   $0x61
  jmp alltraps
80106c76:	e9 dc f5 ff ff       	jmp    80106257 <alltraps>

80106c7b <vector98>:
.globl vector98
vector98:
  pushl $0
80106c7b:	6a 00                	push   $0x0
  pushl $98
80106c7d:	6a 62                	push   $0x62
  jmp alltraps
80106c7f:	e9 d3 f5 ff ff       	jmp    80106257 <alltraps>

80106c84 <vector99>:
.globl vector99
vector99:
  pushl $0
80106c84:	6a 00                	push   $0x0
  pushl $99
80106c86:	6a 63                	push   $0x63
  jmp alltraps
80106c88:	e9 ca f5 ff ff       	jmp    80106257 <alltraps>

80106c8d <vector100>:
.globl vector100
vector100:
  pushl $0
80106c8d:	6a 00                	push   $0x0
  pushl $100
80106c8f:	6a 64                	push   $0x64
  jmp alltraps
80106c91:	e9 c1 f5 ff ff       	jmp    80106257 <alltraps>

80106c96 <vector101>:
.globl vector101
vector101:
  pushl $0
80106c96:	6a 00                	push   $0x0
  pushl $101
80106c98:	6a 65                	push   $0x65
  jmp alltraps
80106c9a:	e9 b8 f5 ff ff       	jmp    80106257 <alltraps>

80106c9f <vector102>:
.globl vector102
vector102:
  pushl $0
80106c9f:	6a 00                	push   $0x0
  pushl $102
80106ca1:	6a 66                	push   $0x66
  jmp alltraps
80106ca3:	e9 af f5 ff ff       	jmp    80106257 <alltraps>

80106ca8 <vector103>:
.globl vector103
vector103:
  pushl $0
80106ca8:	6a 00                	push   $0x0
  pushl $103
80106caa:	6a 67                	push   $0x67
  jmp alltraps
80106cac:	e9 a6 f5 ff ff       	jmp    80106257 <alltraps>

80106cb1 <vector104>:
.globl vector104
vector104:
  pushl $0
80106cb1:	6a 00                	push   $0x0
  pushl $104
80106cb3:	6a 68                	push   $0x68
  jmp alltraps
80106cb5:	e9 9d f5 ff ff       	jmp    80106257 <alltraps>

80106cba <vector105>:
.globl vector105
vector105:
  pushl $0
80106cba:	6a 00                	push   $0x0
  pushl $105
80106cbc:	6a 69                	push   $0x69
  jmp alltraps
80106cbe:	e9 94 f5 ff ff       	jmp    80106257 <alltraps>

80106cc3 <vector106>:
.globl vector106
vector106:
  pushl $0
80106cc3:	6a 00                	push   $0x0
  pushl $106
80106cc5:	6a 6a                	push   $0x6a
  jmp alltraps
80106cc7:	e9 8b f5 ff ff       	jmp    80106257 <alltraps>

80106ccc <vector107>:
.globl vector107
vector107:
  pushl $0
80106ccc:	6a 00                	push   $0x0
  pushl $107
80106cce:	6a 6b                	push   $0x6b
  jmp alltraps
80106cd0:	e9 82 f5 ff ff       	jmp    80106257 <alltraps>

80106cd5 <vector108>:
.globl vector108
vector108:
  pushl $0
80106cd5:	6a 00                	push   $0x0
  pushl $108
80106cd7:	6a 6c                	push   $0x6c
  jmp alltraps
80106cd9:	e9 79 f5 ff ff       	jmp    80106257 <alltraps>

80106cde <vector109>:
.globl vector109
vector109:
  pushl $0
80106cde:	6a 00                	push   $0x0
  pushl $109
80106ce0:	6a 6d                	push   $0x6d
  jmp alltraps
80106ce2:	e9 70 f5 ff ff       	jmp    80106257 <alltraps>

80106ce7 <vector110>:
.globl vector110
vector110:
  pushl $0
80106ce7:	6a 00                	push   $0x0
  pushl $110
80106ce9:	6a 6e                	push   $0x6e
  jmp alltraps
80106ceb:	e9 67 f5 ff ff       	jmp    80106257 <alltraps>

80106cf0 <vector111>:
.globl vector111
vector111:
  pushl $0
80106cf0:	6a 00                	push   $0x0
  pushl $111
80106cf2:	6a 6f                	push   $0x6f
  jmp alltraps
80106cf4:	e9 5e f5 ff ff       	jmp    80106257 <alltraps>

80106cf9 <vector112>:
.globl vector112
vector112:
  pushl $0
80106cf9:	6a 00                	push   $0x0
  pushl $112
80106cfb:	6a 70                	push   $0x70
  jmp alltraps
80106cfd:	e9 55 f5 ff ff       	jmp    80106257 <alltraps>

80106d02 <vector113>:
.globl vector113
vector113:
  pushl $0
80106d02:	6a 00                	push   $0x0
  pushl $113
80106d04:	6a 71                	push   $0x71
  jmp alltraps
80106d06:	e9 4c f5 ff ff       	jmp    80106257 <alltraps>

80106d0b <vector114>:
.globl vector114
vector114:
  pushl $0
80106d0b:	6a 00                	push   $0x0
  pushl $114
80106d0d:	6a 72                	push   $0x72
  jmp alltraps
80106d0f:	e9 43 f5 ff ff       	jmp    80106257 <alltraps>

80106d14 <vector115>:
.globl vector115
vector115:
  pushl $0
80106d14:	6a 00                	push   $0x0
  pushl $115
80106d16:	6a 73                	push   $0x73
  jmp alltraps
80106d18:	e9 3a f5 ff ff       	jmp    80106257 <alltraps>

80106d1d <vector116>:
.globl vector116
vector116:
  pushl $0
80106d1d:	6a 00                	push   $0x0
  pushl $116
80106d1f:	6a 74                	push   $0x74
  jmp alltraps
80106d21:	e9 31 f5 ff ff       	jmp    80106257 <alltraps>

80106d26 <vector117>:
.globl vector117
vector117:
  pushl $0
80106d26:	6a 00                	push   $0x0
  pushl $117
80106d28:	6a 75                	push   $0x75
  jmp alltraps
80106d2a:	e9 28 f5 ff ff       	jmp    80106257 <alltraps>

80106d2f <vector118>:
.globl vector118
vector118:
  pushl $0
80106d2f:	6a 00                	push   $0x0
  pushl $118
80106d31:	6a 76                	push   $0x76
  jmp alltraps
80106d33:	e9 1f f5 ff ff       	jmp    80106257 <alltraps>

80106d38 <vector119>:
.globl vector119
vector119:
  pushl $0
80106d38:	6a 00                	push   $0x0
  pushl $119
80106d3a:	6a 77                	push   $0x77
  jmp alltraps
80106d3c:	e9 16 f5 ff ff       	jmp    80106257 <alltraps>

80106d41 <vector120>:
.globl vector120
vector120:
  pushl $0
80106d41:	6a 00                	push   $0x0
  pushl $120
80106d43:	6a 78                	push   $0x78
  jmp alltraps
80106d45:	e9 0d f5 ff ff       	jmp    80106257 <alltraps>

80106d4a <vector121>:
.globl vector121
vector121:
  pushl $0
80106d4a:	6a 00                	push   $0x0
  pushl $121
80106d4c:	6a 79                	push   $0x79
  jmp alltraps
80106d4e:	e9 04 f5 ff ff       	jmp    80106257 <alltraps>

80106d53 <vector122>:
.globl vector122
vector122:
  pushl $0
80106d53:	6a 00                	push   $0x0
  pushl $122
80106d55:	6a 7a                	push   $0x7a
  jmp alltraps
80106d57:	e9 fb f4 ff ff       	jmp    80106257 <alltraps>

80106d5c <vector123>:
.globl vector123
vector123:
  pushl $0
80106d5c:	6a 00                	push   $0x0
  pushl $123
80106d5e:	6a 7b                	push   $0x7b
  jmp alltraps
80106d60:	e9 f2 f4 ff ff       	jmp    80106257 <alltraps>

80106d65 <vector124>:
.globl vector124
vector124:
  pushl $0
80106d65:	6a 00                	push   $0x0
  pushl $124
80106d67:	6a 7c                	push   $0x7c
  jmp alltraps
80106d69:	e9 e9 f4 ff ff       	jmp    80106257 <alltraps>

80106d6e <vector125>:
.globl vector125
vector125:
  pushl $0
80106d6e:	6a 00                	push   $0x0
  pushl $125
80106d70:	6a 7d                	push   $0x7d
  jmp alltraps
80106d72:	e9 e0 f4 ff ff       	jmp    80106257 <alltraps>

80106d77 <vector126>:
.globl vector126
vector126:
  pushl $0
80106d77:	6a 00                	push   $0x0
  pushl $126
80106d79:	6a 7e                	push   $0x7e
  jmp alltraps
80106d7b:	e9 d7 f4 ff ff       	jmp    80106257 <alltraps>

80106d80 <vector127>:
.globl vector127
vector127:
  pushl $0
80106d80:	6a 00                	push   $0x0
  pushl $127
80106d82:	6a 7f                	push   $0x7f
  jmp alltraps
80106d84:	e9 ce f4 ff ff       	jmp    80106257 <alltraps>

80106d89 <vector128>:
.globl vector128
vector128:
  pushl $0
80106d89:	6a 00                	push   $0x0
  pushl $128
80106d8b:	68 80 00 00 00       	push   $0x80
  jmp alltraps
80106d90:	e9 c2 f4 ff ff       	jmp    80106257 <alltraps>

80106d95 <vector129>:
.globl vector129
vector129:
  pushl $0
80106d95:	6a 00                	push   $0x0
  pushl $129
80106d97:	68 81 00 00 00       	push   $0x81
  jmp alltraps
80106d9c:	e9 b6 f4 ff ff       	jmp    80106257 <alltraps>

80106da1 <vector130>:
.globl vector130
vector130:
  pushl $0
80106da1:	6a 00                	push   $0x0
  pushl $130
80106da3:	68 82 00 00 00       	push   $0x82
  jmp alltraps
80106da8:	e9 aa f4 ff ff       	jmp    80106257 <alltraps>

80106dad <vector131>:
.globl vector131
vector131:
  pushl $0
80106dad:	6a 00                	push   $0x0
  pushl $131
80106daf:	68 83 00 00 00       	push   $0x83
  jmp alltraps
80106db4:	e9 9e f4 ff ff       	jmp    80106257 <alltraps>

80106db9 <vector132>:
.globl vector132
vector132:
  pushl $0
80106db9:	6a 00                	push   $0x0
  pushl $132
80106dbb:	68 84 00 00 00       	push   $0x84
  jmp alltraps
80106dc0:	e9 92 f4 ff ff       	jmp    80106257 <alltraps>

80106dc5 <vector133>:
.globl vector133
vector133:
  pushl $0
80106dc5:	6a 00                	push   $0x0
  pushl $133
80106dc7:	68 85 00 00 00       	push   $0x85
  jmp alltraps
80106dcc:	e9 86 f4 ff ff       	jmp    80106257 <alltraps>

80106dd1 <vector134>:
.globl vector134
vector134:
  pushl $0
80106dd1:	6a 00                	push   $0x0
  pushl $134
80106dd3:	68 86 00 00 00       	push   $0x86
  jmp alltraps
80106dd8:	e9 7a f4 ff ff       	jmp    80106257 <alltraps>

80106ddd <vector135>:
.globl vector135
vector135:
  pushl $0
80106ddd:	6a 00                	push   $0x0
  pushl $135
80106ddf:	68 87 00 00 00       	push   $0x87
  jmp alltraps
80106de4:	e9 6e f4 ff ff       	jmp    80106257 <alltraps>

80106de9 <vector136>:
.globl vector136
vector136:
  pushl $0
80106de9:	6a 00                	push   $0x0
  pushl $136
80106deb:	68 88 00 00 00       	push   $0x88
  jmp alltraps
80106df0:	e9 62 f4 ff ff       	jmp    80106257 <alltraps>

80106df5 <vector137>:
.globl vector137
vector137:
  pushl $0
80106df5:	6a 00                	push   $0x0
  pushl $137
80106df7:	68 89 00 00 00       	push   $0x89
  jmp alltraps
80106dfc:	e9 56 f4 ff ff       	jmp    80106257 <alltraps>

80106e01 <vector138>:
.globl vector138
vector138:
  pushl $0
80106e01:	6a 00                	push   $0x0
  pushl $138
80106e03:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
80106e08:	e9 4a f4 ff ff       	jmp    80106257 <alltraps>

80106e0d <vector139>:
.globl vector139
vector139:
  pushl $0
80106e0d:	6a 00                	push   $0x0
  pushl $139
80106e0f:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
80106e14:	e9 3e f4 ff ff       	jmp    80106257 <alltraps>

80106e19 <vector140>:
.globl vector140
vector140:
  pushl $0
80106e19:	6a 00                	push   $0x0
  pushl $140
80106e1b:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
80106e20:	e9 32 f4 ff ff       	jmp    80106257 <alltraps>

80106e25 <vector141>:
.globl vector141
vector141:
  pushl $0
80106e25:	6a 00                	push   $0x0
  pushl $141
80106e27:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
80106e2c:	e9 26 f4 ff ff       	jmp    80106257 <alltraps>

80106e31 <vector142>:
.globl vector142
vector142:
  pushl $0
80106e31:	6a 00                	push   $0x0
  pushl $142
80106e33:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
80106e38:	e9 1a f4 ff ff       	jmp    80106257 <alltraps>

80106e3d <vector143>:
.globl vector143
vector143:
  pushl $0
80106e3d:	6a 00                	push   $0x0
  pushl $143
80106e3f:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
80106e44:	e9 0e f4 ff ff       	jmp    80106257 <alltraps>

80106e49 <vector144>:
.globl vector144
vector144:
  pushl $0
80106e49:	6a 00                	push   $0x0
  pushl $144
80106e4b:	68 90 00 00 00       	push   $0x90
  jmp alltraps
80106e50:	e9 02 f4 ff ff       	jmp    80106257 <alltraps>

80106e55 <vector145>:
.globl vector145
vector145:
  pushl $0
80106e55:	6a 00                	push   $0x0
  pushl $145
80106e57:	68 91 00 00 00       	push   $0x91
  jmp alltraps
80106e5c:	e9 f6 f3 ff ff       	jmp    80106257 <alltraps>

80106e61 <vector146>:
.globl vector146
vector146:
  pushl $0
80106e61:	6a 00                	push   $0x0
  pushl $146
80106e63:	68 92 00 00 00       	push   $0x92
  jmp alltraps
80106e68:	e9 ea f3 ff ff       	jmp    80106257 <alltraps>

80106e6d <vector147>:
.globl vector147
vector147:
  pushl $0
80106e6d:	6a 00                	push   $0x0
  pushl $147
80106e6f:	68 93 00 00 00       	push   $0x93
  jmp alltraps
80106e74:	e9 de f3 ff ff       	jmp    80106257 <alltraps>

80106e79 <vector148>:
.globl vector148
vector148:
  pushl $0
80106e79:	6a 00                	push   $0x0
  pushl $148
80106e7b:	68 94 00 00 00       	push   $0x94
  jmp alltraps
80106e80:	e9 d2 f3 ff ff       	jmp    80106257 <alltraps>

80106e85 <vector149>:
.globl vector149
vector149:
  pushl $0
80106e85:	6a 00                	push   $0x0
  pushl $149
80106e87:	68 95 00 00 00       	push   $0x95
  jmp alltraps
80106e8c:	e9 c6 f3 ff ff       	jmp    80106257 <alltraps>

80106e91 <vector150>:
.globl vector150
vector150:
  pushl $0
80106e91:	6a 00                	push   $0x0
  pushl $150
80106e93:	68 96 00 00 00       	push   $0x96
  jmp alltraps
80106e98:	e9 ba f3 ff ff       	jmp    80106257 <alltraps>

80106e9d <vector151>:
.globl vector151
vector151:
  pushl $0
80106e9d:	6a 00                	push   $0x0
  pushl $151
80106e9f:	68 97 00 00 00       	push   $0x97
  jmp alltraps
80106ea4:	e9 ae f3 ff ff       	jmp    80106257 <alltraps>

80106ea9 <vector152>:
.globl vector152
vector152:
  pushl $0
80106ea9:	6a 00                	push   $0x0
  pushl $152
80106eab:	68 98 00 00 00       	push   $0x98
  jmp alltraps
80106eb0:	e9 a2 f3 ff ff       	jmp    80106257 <alltraps>

80106eb5 <vector153>:
.globl vector153
vector153:
  pushl $0
80106eb5:	6a 00                	push   $0x0
  pushl $153
80106eb7:	68 99 00 00 00       	push   $0x99
  jmp alltraps
80106ebc:	e9 96 f3 ff ff       	jmp    80106257 <alltraps>

80106ec1 <vector154>:
.globl vector154
vector154:
  pushl $0
80106ec1:	6a 00                	push   $0x0
  pushl $154
80106ec3:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
80106ec8:	e9 8a f3 ff ff       	jmp    80106257 <alltraps>

80106ecd <vector155>:
.globl vector155
vector155:
  pushl $0
80106ecd:	6a 00                	push   $0x0
  pushl $155
80106ecf:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
80106ed4:	e9 7e f3 ff ff       	jmp    80106257 <alltraps>

80106ed9 <vector156>:
.globl vector156
vector156:
  pushl $0
80106ed9:	6a 00                	push   $0x0
  pushl $156
80106edb:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
80106ee0:	e9 72 f3 ff ff       	jmp    80106257 <alltraps>

80106ee5 <vector157>:
.globl vector157
vector157:
  pushl $0
80106ee5:	6a 00                	push   $0x0
  pushl $157
80106ee7:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
80106eec:	e9 66 f3 ff ff       	jmp    80106257 <alltraps>

80106ef1 <vector158>:
.globl vector158
vector158:
  pushl $0
80106ef1:	6a 00                	push   $0x0
  pushl $158
80106ef3:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
80106ef8:	e9 5a f3 ff ff       	jmp    80106257 <alltraps>

80106efd <vector159>:
.globl vector159
vector159:
  pushl $0
80106efd:	6a 00                	push   $0x0
  pushl $159
80106eff:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
80106f04:	e9 4e f3 ff ff       	jmp    80106257 <alltraps>

80106f09 <vector160>:
.globl vector160
vector160:
  pushl $0
80106f09:	6a 00                	push   $0x0
  pushl $160
80106f0b:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
80106f10:	e9 42 f3 ff ff       	jmp    80106257 <alltraps>

80106f15 <vector161>:
.globl vector161
vector161:
  pushl $0
80106f15:	6a 00                	push   $0x0
  pushl $161
80106f17:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
80106f1c:	e9 36 f3 ff ff       	jmp    80106257 <alltraps>

80106f21 <vector162>:
.globl vector162
vector162:
  pushl $0
80106f21:	6a 00                	push   $0x0
  pushl $162
80106f23:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
80106f28:	e9 2a f3 ff ff       	jmp    80106257 <alltraps>

80106f2d <vector163>:
.globl vector163
vector163:
  pushl $0
80106f2d:	6a 00                	push   $0x0
  pushl $163
80106f2f:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
80106f34:	e9 1e f3 ff ff       	jmp    80106257 <alltraps>

80106f39 <vector164>:
.globl vector164
vector164:
  pushl $0
80106f39:	6a 00                	push   $0x0
  pushl $164
80106f3b:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
80106f40:	e9 12 f3 ff ff       	jmp    80106257 <alltraps>

80106f45 <vector165>:
.globl vector165
vector165:
  pushl $0
80106f45:	6a 00                	push   $0x0
  pushl $165
80106f47:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
80106f4c:	e9 06 f3 ff ff       	jmp    80106257 <alltraps>

80106f51 <vector166>:
.globl vector166
vector166:
  pushl $0
80106f51:	6a 00                	push   $0x0
  pushl $166
80106f53:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
80106f58:	e9 fa f2 ff ff       	jmp    80106257 <alltraps>

80106f5d <vector167>:
.globl vector167
vector167:
  pushl $0
80106f5d:	6a 00                	push   $0x0
  pushl $167
80106f5f:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
80106f64:	e9 ee f2 ff ff       	jmp    80106257 <alltraps>

80106f69 <vector168>:
.globl vector168
vector168:
  pushl $0
80106f69:	6a 00                	push   $0x0
  pushl $168
80106f6b:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
80106f70:	e9 e2 f2 ff ff       	jmp    80106257 <alltraps>

80106f75 <vector169>:
.globl vector169
vector169:
  pushl $0
80106f75:	6a 00                	push   $0x0
  pushl $169
80106f77:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
80106f7c:	e9 d6 f2 ff ff       	jmp    80106257 <alltraps>

80106f81 <vector170>:
.globl vector170
vector170:
  pushl $0
80106f81:	6a 00                	push   $0x0
  pushl $170
80106f83:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
80106f88:	e9 ca f2 ff ff       	jmp    80106257 <alltraps>

80106f8d <vector171>:
.globl vector171
vector171:
  pushl $0
80106f8d:	6a 00                	push   $0x0
  pushl $171
80106f8f:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
80106f94:	e9 be f2 ff ff       	jmp    80106257 <alltraps>

80106f99 <vector172>:
.globl vector172
vector172:
  pushl $0
80106f99:	6a 00                	push   $0x0
  pushl $172
80106f9b:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
80106fa0:	e9 b2 f2 ff ff       	jmp    80106257 <alltraps>

80106fa5 <vector173>:
.globl vector173
vector173:
  pushl $0
80106fa5:	6a 00                	push   $0x0
  pushl $173
80106fa7:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
80106fac:	e9 a6 f2 ff ff       	jmp    80106257 <alltraps>

80106fb1 <vector174>:
.globl vector174
vector174:
  pushl $0
80106fb1:	6a 00                	push   $0x0
  pushl $174
80106fb3:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
80106fb8:	e9 9a f2 ff ff       	jmp    80106257 <alltraps>

80106fbd <vector175>:
.globl vector175
vector175:
  pushl $0
80106fbd:	6a 00                	push   $0x0
  pushl $175
80106fbf:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
80106fc4:	e9 8e f2 ff ff       	jmp    80106257 <alltraps>

80106fc9 <vector176>:
.globl vector176
vector176:
  pushl $0
80106fc9:	6a 00                	push   $0x0
  pushl $176
80106fcb:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
80106fd0:	e9 82 f2 ff ff       	jmp    80106257 <alltraps>

80106fd5 <vector177>:
.globl vector177
vector177:
  pushl $0
80106fd5:	6a 00                	push   $0x0
  pushl $177
80106fd7:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
80106fdc:	e9 76 f2 ff ff       	jmp    80106257 <alltraps>

80106fe1 <vector178>:
.globl vector178
vector178:
  pushl $0
80106fe1:	6a 00                	push   $0x0
  pushl $178
80106fe3:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
80106fe8:	e9 6a f2 ff ff       	jmp    80106257 <alltraps>

80106fed <vector179>:
.globl vector179
vector179:
  pushl $0
80106fed:	6a 00                	push   $0x0
  pushl $179
80106fef:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
80106ff4:	e9 5e f2 ff ff       	jmp    80106257 <alltraps>

80106ff9 <vector180>:
.globl vector180
vector180:
  pushl $0
80106ff9:	6a 00                	push   $0x0
  pushl $180
80106ffb:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
80107000:	e9 52 f2 ff ff       	jmp    80106257 <alltraps>

80107005 <vector181>:
.globl vector181
vector181:
  pushl $0
80107005:	6a 00                	push   $0x0
  pushl $181
80107007:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
8010700c:	e9 46 f2 ff ff       	jmp    80106257 <alltraps>

80107011 <vector182>:
.globl vector182
vector182:
  pushl $0
80107011:	6a 00                	push   $0x0
  pushl $182
80107013:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
80107018:	e9 3a f2 ff ff       	jmp    80106257 <alltraps>

8010701d <vector183>:
.globl vector183
vector183:
  pushl $0
8010701d:	6a 00                	push   $0x0
  pushl $183
8010701f:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
80107024:	e9 2e f2 ff ff       	jmp    80106257 <alltraps>

80107029 <vector184>:
.globl vector184
vector184:
  pushl $0
80107029:	6a 00                	push   $0x0
  pushl $184
8010702b:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
80107030:	e9 22 f2 ff ff       	jmp    80106257 <alltraps>

80107035 <vector185>:
.globl vector185
vector185:
  pushl $0
80107035:	6a 00                	push   $0x0
  pushl $185
80107037:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
8010703c:	e9 16 f2 ff ff       	jmp    80106257 <alltraps>

80107041 <vector186>:
.globl vector186
vector186:
  pushl $0
80107041:	6a 00                	push   $0x0
  pushl $186
80107043:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
80107048:	e9 0a f2 ff ff       	jmp    80106257 <alltraps>

8010704d <vector187>:
.globl vector187
vector187:
  pushl $0
8010704d:	6a 00                	push   $0x0
  pushl $187
8010704f:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
80107054:	e9 fe f1 ff ff       	jmp    80106257 <alltraps>

80107059 <vector188>:
.globl vector188
vector188:
  pushl $0
80107059:	6a 00                	push   $0x0
  pushl $188
8010705b:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
80107060:	e9 f2 f1 ff ff       	jmp    80106257 <alltraps>

80107065 <vector189>:
.globl vector189
vector189:
  pushl $0
80107065:	6a 00                	push   $0x0
  pushl $189
80107067:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
8010706c:	e9 e6 f1 ff ff       	jmp    80106257 <alltraps>

80107071 <vector190>:
.globl vector190
vector190:
  pushl $0
80107071:	6a 00                	push   $0x0
  pushl $190
80107073:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
80107078:	e9 da f1 ff ff       	jmp    80106257 <alltraps>

8010707d <vector191>:
.globl vector191
vector191:
  pushl $0
8010707d:	6a 00                	push   $0x0
  pushl $191
8010707f:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
80107084:	e9 ce f1 ff ff       	jmp    80106257 <alltraps>

80107089 <vector192>:
.globl vector192
vector192:
  pushl $0
80107089:	6a 00                	push   $0x0
  pushl $192
8010708b:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
80107090:	e9 c2 f1 ff ff       	jmp    80106257 <alltraps>

80107095 <vector193>:
.globl vector193
vector193:
  pushl $0
80107095:	6a 00                	push   $0x0
  pushl $193
80107097:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
8010709c:	e9 b6 f1 ff ff       	jmp    80106257 <alltraps>

801070a1 <vector194>:
.globl vector194
vector194:
  pushl $0
801070a1:	6a 00                	push   $0x0
  pushl $194
801070a3:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
801070a8:	e9 aa f1 ff ff       	jmp    80106257 <alltraps>

801070ad <vector195>:
.globl vector195
vector195:
  pushl $0
801070ad:	6a 00                	push   $0x0
  pushl $195
801070af:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
801070b4:	e9 9e f1 ff ff       	jmp    80106257 <alltraps>

801070b9 <vector196>:
.globl vector196
vector196:
  pushl $0
801070b9:	6a 00                	push   $0x0
  pushl $196
801070bb:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
801070c0:	e9 92 f1 ff ff       	jmp    80106257 <alltraps>

801070c5 <vector197>:
.globl vector197
vector197:
  pushl $0
801070c5:	6a 00                	push   $0x0
  pushl $197
801070c7:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
801070cc:	e9 86 f1 ff ff       	jmp    80106257 <alltraps>

801070d1 <vector198>:
.globl vector198
vector198:
  pushl $0
801070d1:	6a 00                	push   $0x0
  pushl $198
801070d3:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
801070d8:	e9 7a f1 ff ff       	jmp    80106257 <alltraps>

801070dd <vector199>:
.globl vector199
vector199:
  pushl $0
801070dd:	6a 00                	push   $0x0
  pushl $199
801070df:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
801070e4:	e9 6e f1 ff ff       	jmp    80106257 <alltraps>

801070e9 <vector200>:
.globl vector200
vector200:
  pushl $0
801070e9:	6a 00                	push   $0x0
  pushl $200
801070eb:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
801070f0:	e9 62 f1 ff ff       	jmp    80106257 <alltraps>

801070f5 <vector201>:
.globl vector201
vector201:
  pushl $0
801070f5:	6a 00                	push   $0x0
  pushl $201
801070f7:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
801070fc:	e9 56 f1 ff ff       	jmp    80106257 <alltraps>

80107101 <vector202>:
.globl vector202
vector202:
  pushl $0
80107101:	6a 00                	push   $0x0
  pushl $202
80107103:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
80107108:	e9 4a f1 ff ff       	jmp    80106257 <alltraps>

8010710d <vector203>:
.globl vector203
vector203:
  pushl $0
8010710d:	6a 00                	push   $0x0
  pushl $203
8010710f:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
80107114:	e9 3e f1 ff ff       	jmp    80106257 <alltraps>

80107119 <vector204>:
.globl vector204
vector204:
  pushl $0
80107119:	6a 00                	push   $0x0
  pushl $204
8010711b:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
80107120:	e9 32 f1 ff ff       	jmp    80106257 <alltraps>

80107125 <vector205>:
.globl vector205
vector205:
  pushl $0
80107125:	6a 00                	push   $0x0
  pushl $205
80107127:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
8010712c:	e9 26 f1 ff ff       	jmp    80106257 <alltraps>

80107131 <vector206>:
.globl vector206
vector206:
  pushl $0
80107131:	6a 00                	push   $0x0
  pushl $206
80107133:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
80107138:	e9 1a f1 ff ff       	jmp    80106257 <alltraps>

8010713d <vector207>:
.globl vector207
vector207:
  pushl $0
8010713d:	6a 00                	push   $0x0
  pushl $207
8010713f:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
80107144:	e9 0e f1 ff ff       	jmp    80106257 <alltraps>

80107149 <vector208>:
.globl vector208
vector208:
  pushl $0
80107149:	6a 00                	push   $0x0
  pushl $208
8010714b:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
80107150:	e9 02 f1 ff ff       	jmp    80106257 <alltraps>

80107155 <vector209>:
.globl vector209
vector209:
  pushl $0
80107155:	6a 00                	push   $0x0
  pushl $209
80107157:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
8010715c:	e9 f6 f0 ff ff       	jmp    80106257 <alltraps>

80107161 <vector210>:
.globl vector210
vector210:
  pushl $0
80107161:	6a 00                	push   $0x0
  pushl $210
80107163:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
80107168:	e9 ea f0 ff ff       	jmp    80106257 <alltraps>

8010716d <vector211>:
.globl vector211
vector211:
  pushl $0
8010716d:	6a 00                	push   $0x0
  pushl $211
8010716f:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
80107174:	e9 de f0 ff ff       	jmp    80106257 <alltraps>

80107179 <vector212>:
.globl vector212
vector212:
  pushl $0
80107179:	6a 00                	push   $0x0
  pushl $212
8010717b:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
80107180:	e9 d2 f0 ff ff       	jmp    80106257 <alltraps>

80107185 <vector213>:
.globl vector213
vector213:
  pushl $0
80107185:	6a 00                	push   $0x0
  pushl $213
80107187:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
8010718c:	e9 c6 f0 ff ff       	jmp    80106257 <alltraps>

80107191 <vector214>:
.globl vector214
vector214:
  pushl $0
80107191:	6a 00                	push   $0x0
  pushl $214
80107193:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
80107198:	e9 ba f0 ff ff       	jmp    80106257 <alltraps>

8010719d <vector215>:
.globl vector215
vector215:
  pushl $0
8010719d:	6a 00                	push   $0x0
  pushl $215
8010719f:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
801071a4:	e9 ae f0 ff ff       	jmp    80106257 <alltraps>

801071a9 <vector216>:
.globl vector216
vector216:
  pushl $0
801071a9:	6a 00                	push   $0x0
  pushl $216
801071ab:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
801071b0:	e9 a2 f0 ff ff       	jmp    80106257 <alltraps>

801071b5 <vector217>:
.globl vector217
vector217:
  pushl $0
801071b5:	6a 00                	push   $0x0
  pushl $217
801071b7:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
801071bc:	e9 96 f0 ff ff       	jmp    80106257 <alltraps>

801071c1 <vector218>:
.globl vector218
vector218:
  pushl $0
801071c1:	6a 00                	push   $0x0
  pushl $218
801071c3:	68 da 00 00 00       	push   $0xda
  jmp alltraps
801071c8:	e9 8a f0 ff ff       	jmp    80106257 <alltraps>

801071cd <vector219>:
.globl vector219
vector219:
  pushl $0
801071cd:	6a 00                	push   $0x0
  pushl $219
801071cf:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
801071d4:	e9 7e f0 ff ff       	jmp    80106257 <alltraps>

801071d9 <vector220>:
.globl vector220
vector220:
  pushl $0
801071d9:	6a 00                	push   $0x0
  pushl $220
801071db:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
801071e0:	e9 72 f0 ff ff       	jmp    80106257 <alltraps>

801071e5 <vector221>:
.globl vector221
vector221:
  pushl $0
801071e5:	6a 00                	push   $0x0
  pushl $221
801071e7:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
801071ec:	e9 66 f0 ff ff       	jmp    80106257 <alltraps>

801071f1 <vector222>:
.globl vector222
vector222:
  pushl $0
801071f1:	6a 00                	push   $0x0
  pushl $222
801071f3:	68 de 00 00 00       	push   $0xde
  jmp alltraps
801071f8:	e9 5a f0 ff ff       	jmp    80106257 <alltraps>

801071fd <vector223>:
.globl vector223
vector223:
  pushl $0
801071fd:	6a 00                	push   $0x0
  pushl $223
801071ff:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
80107204:	e9 4e f0 ff ff       	jmp    80106257 <alltraps>

80107209 <vector224>:
.globl vector224
vector224:
  pushl $0
80107209:	6a 00                	push   $0x0
  pushl $224
8010720b:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
80107210:	e9 42 f0 ff ff       	jmp    80106257 <alltraps>

80107215 <vector225>:
.globl vector225
vector225:
  pushl $0
80107215:	6a 00                	push   $0x0
  pushl $225
80107217:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
8010721c:	e9 36 f0 ff ff       	jmp    80106257 <alltraps>

80107221 <vector226>:
.globl vector226
vector226:
  pushl $0
80107221:	6a 00                	push   $0x0
  pushl $226
80107223:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
80107228:	e9 2a f0 ff ff       	jmp    80106257 <alltraps>

8010722d <vector227>:
.globl vector227
vector227:
  pushl $0
8010722d:	6a 00                	push   $0x0
  pushl $227
8010722f:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
80107234:	e9 1e f0 ff ff       	jmp    80106257 <alltraps>

80107239 <vector228>:
.globl vector228
vector228:
  pushl $0
80107239:	6a 00                	push   $0x0
  pushl $228
8010723b:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
80107240:	e9 12 f0 ff ff       	jmp    80106257 <alltraps>

80107245 <vector229>:
.globl vector229
vector229:
  pushl $0
80107245:	6a 00                	push   $0x0
  pushl $229
80107247:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
8010724c:	e9 06 f0 ff ff       	jmp    80106257 <alltraps>

80107251 <vector230>:
.globl vector230
vector230:
  pushl $0
80107251:	6a 00                	push   $0x0
  pushl $230
80107253:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
80107258:	e9 fa ef ff ff       	jmp    80106257 <alltraps>

8010725d <vector231>:
.globl vector231
vector231:
  pushl $0
8010725d:	6a 00                	push   $0x0
  pushl $231
8010725f:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
80107264:	e9 ee ef ff ff       	jmp    80106257 <alltraps>

80107269 <vector232>:
.globl vector232
vector232:
  pushl $0
80107269:	6a 00                	push   $0x0
  pushl $232
8010726b:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
80107270:	e9 e2 ef ff ff       	jmp    80106257 <alltraps>

80107275 <vector233>:
.globl vector233
vector233:
  pushl $0
80107275:	6a 00                	push   $0x0
  pushl $233
80107277:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
8010727c:	e9 d6 ef ff ff       	jmp    80106257 <alltraps>

80107281 <vector234>:
.globl vector234
vector234:
  pushl $0
80107281:	6a 00                	push   $0x0
  pushl $234
80107283:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
80107288:	e9 ca ef ff ff       	jmp    80106257 <alltraps>

8010728d <vector235>:
.globl vector235
vector235:
  pushl $0
8010728d:	6a 00                	push   $0x0
  pushl $235
8010728f:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
80107294:	e9 be ef ff ff       	jmp    80106257 <alltraps>

80107299 <vector236>:
.globl vector236
vector236:
  pushl $0
80107299:	6a 00                	push   $0x0
  pushl $236
8010729b:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
801072a0:	e9 b2 ef ff ff       	jmp    80106257 <alltraps>

801072a5 <vector237>:
.globl vector237
vector237:
  pushl $0
801072a5:	6a 00                	push   $0x0
  pushl $237
801072a7:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
801072ac:	e9 a6 ef ff ff       	jmp    80106257 <alltraps>

801072b1 <vector238>:
.globl vector238
vector238:
  pushl $0
801072b1:	6a 00                	push   $0x0
  pushl $238
801072b3:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
801072b8:	e9 9a ef ff ff       	jmp    80106257 <alltraps>

801072bd <vector239>:
.globl vector239
vector239:
  pushl $0
801072bd:	6a 00                	push   $0x0
  pushl $239
801072bf:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
801072c4:	e9 8e ef ff ff       	jmp    80106257 <alltraps>

801072c9 <vector240>:
.globl vector240
vector240:
  pushl $0
801072c9:	6a 00                	push   $0x0
  pushl $240
801072cb:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
801072d0:	e9 82 ef ff ff       	jmp    80106257 <alltraps>

801072d5 <vector241>:
.globl vector241
vector241:
  pushl $0
801072d5:	6a 00                	push   $0x0
  pushl $241
801072d7:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
801072dc:	e9 76 ef ff ff       	jmp    80106257 <alltraps>

801072e1 <vector242>:
.globl vector242
vector242:
  pushl $0
801072e1:	6a 00                	push   $0x0
  pushl $242
801072e3:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
801072e8:	e9 6a ef ff ff       	jmp    80106257 <alltraps>

801072ed <vector243>:
.globl vector243
vector243:
  pushl $0
801072ed:	6a 00                	push   $0x0
  pushl $243
801072ef:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
801072f4:	e9 5e ef ff ff       	jmp    80106257 <alltraps>

801072f9 <vector244>:
.globl vector244
vector244:
  pushl $0
801072f9:	6a 00                	push   $0x0
  pushl $244
801072fb:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
80107300:	e9 52 ef ff ff       	jmp    80106257 <alltraps>

80107305 <vector245>:
.globl vector245
vector245:
  pushl $0
80107305:	6a 00                	push   $0x0
  pushl $245
80107307:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
8010730c:	e9 46 ef ff ff       	jmp    80106257 <alltraps>

80107311 <vector246>:
.globl vector246
vector246:
  pushl $0
80107311:	6a 00                	push   $0x0
  pushl $246
80107313:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
80107318:	e9 3a ef ff ff       	jmp    80106257 <alltraps>

8010731d <vector247>:
.globl vector247
vector247:
  pushl $0
8010731d:	6a 00                	push   $0x0
  pushl $247
8010731f:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
80107324:	e9 2e ef ff ff       	jmp    80106257 <alltraps>

80107329 <vector248>:
.globl vector248
vector248:
  pushl $0
80107329:	6a 00                	push   $0x0
  pushl $248
8010732b:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
80107330:	e9 22 ef ff ff       	jmp    80106257 <alltraps>

80107335 <vector249>:
.globl vector249
vector249:
  pushl $0
80107335:	6a 00                	push   $0x0
  pushl $249
80107337:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
8010733c:	e9 16 ef ff ff       	jmp    80106257 <alltraps>

80107341 <vector250>:
.globl vector250
vector250:
  pushl $0
80107341:	6a 00                	push   $0x0
  pushl $250
80107343:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
80107348:	e9 0a ef ff ff       	jmp    80106257 <alltraps>

8010734d <vector251>:
.globl vector251
vector251:
  pushl $0
8010734d:	6a 00                	push   $0x0
  pushl $251
8010734f:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
80107354:	e9 fe ee ff ff       	jmp    80106257 <alltraps>

80107359 <vector252>:
.globl vector252
vector252:
  pushl $0
80107359:	6a 00                	push   $0x0
  pushl $252
8010735b:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
80107360:	e9 f2 ee ff ff       	jmp    80106257 <alltraps>

80107365 <vector253>:
.globl vector253
vector253:
  pushl $0
80107365:	6a 00                	push   $0x0
  pushl $253
80107367:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
8010736c:	e9 e6 ee ff ff       	jmp    80106257 <alltraps>

80107371 <vector254>:
.globl vector254
vector254:
  pushl $0
80107371:	6a 00                	push   $0x0
  pushl $254
80107373:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
80107378:	e9 da ee ff ff       	jmp    80106257 <alltraps>

8010737d <vector255>:
.globl vector255
vector255:
  pushl $0
8010737d:	6a 00                	push   $0x0
  pushl $255
8010737f:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
80107384:	e9 ce ee ff ff       	jmp    80106257 <alltraps>

80107389 <lgdt>:
{
80107389:	55                   	push   %ebp
8010738a:	89 e5                	mov    %esp,%ebp
8010738c:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
8010738f:	8b 45 0c             	mov    0xc(%ebp),%eax
80107392:	83 e8 01             	sub    $0x1,%eax
80107395:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80107399:	8b 45 08             	mov    0x8(%ebp),%eax
8010739c:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
801073a0:	8b 45 08             	mov    0x8(%ebp),%eax
801073a3:	c1 e8 10             	shr    $0x10,%eax
801073a6:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lgdt (%0)" : : "r" (pd));
801073aa:	8d 45 fa             	lea    -0x6(%ebp),%eax
801073ad:	0f 01 10             	lgdtl  (%eax)
}
801073b0:	90                   	nop
801073b1:	c9                   	leave  
801073b2:	c3                   	ret    

801073b3 <ltr>:
{
801073b3:	55                   	push   %ebp
801073b4:	89 e5                	mov    %esp,%ebp
801073b6:	83 ec 04             	sub    $0x4,%esp
801073b9:	8b 45 08             	mov    0x8(%ebp),%eax
801073bc:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
801073c0:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
801073c4:	0f 00 d8             	ltr    %ax
}
801073c7:	90                   	nop
801073c8:	c9                   	leave  
801073c9:	c3                   	ret    

801073ca <lcr3>:

static inline void
lcr3(uint val)
{
801073ca:	55                   	push   %ebp
801073cb:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
801073cd:	8b 45 08             	mov    0x8(%ebp),%eax
801073d0:	0f 22 d8             	mov    %eax,%cr3
}
801073d3:	90                   	nop
801073d4:	5d                   	pop    %ebp
801073d5:	c3                   	ret    

801073d6 <seginit>:
extern struct gpu gpu;
// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
801073d6:	55                   	push   %ebp
801073d7:	89 e5                	mov    %esp,%ebp
801073d9:	83 ec 18             	sub    $0x18,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpuid()];
801073dc:	e8 a0 ca ff ff       	call   80103e81 <cpuid>
801073e1:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
801073e7:	05 c0 9b 11 80       	add    $0x80119bc0,%eax
801073ec:	89 45 f4             	mov    %eax,-0xc(%ebp)

  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
801073ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073f2:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
801073f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073fb:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
80107401:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107404:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
80107408:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010740b:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
8010740f:	83 e2 f0             	and    $0xfffffff0,%edx
80107412:	83 ca 0a             	or     $0xa,%edx
80107415:	88 50 7d             	mov    %dl,0x7d(%eax)
80107418:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010741b:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
8010741f:	83 ca 10             	or     $0x10,%edx
80107422:	88 50 7d             	mov    %dl,0x7d(%eax)
80107425:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107428:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
8010742c:	83 e2 9f             	and    $0xffffff9f,%edx
8010742f:	88 50 7d             	mov    %dl,0x7d(%eax)
80107432:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107435:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107439:	83 ca 80             	or     $0xffffff80,%edx
8010743c:	88 50 7d             	mov    %dl,0x7d(%eax)
8010743f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107442:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107446:	83 ca 0f             	or     $0xf,%edx
80107449:	88 50 7e             	mov    %dl,0x7e(%eax)
8010744c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010744f:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107453:	83 e2 ef             	and    $0xffffffef,%edx
80107456:	88 50 7e             	mov    %dl,0x7e(%eax)
80107459:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010745c:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107460:	83 e2 df             	and    $0xffffffdf,%edx
80107463:	88 50 7e             	mov    %dl,0x7e(%eax)
80107466:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107469:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
8010746d:	83 ca 40             	or     $0x40,%edx
80107470:	88 50 7e             	mov    %dl,0x7e(%eax)
80107473:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107476:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
8010747a:	83 ca 80             	or     $0xffffff80,%edx
8010747d:	88 50 7e             	mov    %dl,0x7e(%eax)
80107480:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107483:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
80107487:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010748a:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
80107491:	ff ff 
80107493:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107496:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
8010749d:	00 00 
8010749f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074a2:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
801074a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074ac:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
801074b3:	83 e2 f0             	and    $0xfffffff0,%edx
801074b6:	83 ca 02             	or     $0x2,%edx
801074b9:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801074bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074c2:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
801074c9:	83 ca 10             	or     $0x10,%edx
801074cc:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801074d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074d5:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
801074dc:	83 e2 9f             	and    $0xffffff9f,%edx
801074df:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801074e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074e8:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
801074ef:	83 ca 80             	or     $0xffffff80,%edx
801074f2:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801074f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074fb:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107502:	83 ca 0f             	or     $0xf,%edx
80107505:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
8010750b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010750e:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107515:	83 e2 ef             	and    $0xffffffef,%edx
80107518:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
8010751e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107521:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107528:	83 e2 df             	and    $0xffffffdf,%edx
8010752b:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107531:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107534:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
8010753b:	83 ca 40             	or     $0x40,%edx
8010753e:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107544:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107547:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
8010754e:	83 ca 80             	or     $0xffffff80,%edx
80107551:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107557:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010755a:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
80107561:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107564:	66 c7 80 88 00 00 00 	movw   $0xffff,0x88(%eax)
8010756b:	ff ff 
8010756d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107570:	66 c7 80 8a 00 00 00 	movw   $0x0,0x8a(%eax)
80107577:	00 00 
80107579:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010757c:	c6 80 8c 00 00 00 00 	movb   $0x0,0x8c(%eax)
80107583:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107586:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
8010758d:	83 e2 f0             	and    $0xfffffff0,%edx
80107590:	83 ca 0a             	or     $0xa,%edx
80107593:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107599:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010759c:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
801075a3:	83 ca 10             	or     $0x10,%edx
801075a6:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
801075ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075af:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
801075b6:	83 ca 60             	or     $0x60,%edx
801075b9:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
801075bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075c2:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
801075c9:	83 ca 80             	or     $0xffffff80,%edx
801075cc:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
801075d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075d5:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
801075dc:	83 ca 0f             	or     $0xf,%edx
801075df:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
801075e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075e8:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
801075ef:	83 e2 ef             	and    $0xffffffef,%edx
801075f2:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
801075f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075fb:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107602:	83 e2 df             	and    $0xffffffdf,%edx
80107605:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
8010760b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010760e:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107615:	83 ca 40             	or     $0x40,%edx
80107618:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
8010761e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107621:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107628:	83 ca 80             	or     $0xffffff80,%edx
8010762b:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107631:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107634:	c6 80 8f 00 00 00 00 	movb   $0x0,0x8f(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
8010763b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010763e:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
80107645:	ff ff 
80107647:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010764a:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
80107651:	00 00 
80107653:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107656:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
8010765d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107660:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107667:	83 e2 f0             	and    $0xfffffff0,%edx
8010766a:	83 ca 02             	or     $0x2,%edx
8010766d:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107673:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107676:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
8010767d:	83 ca 10             	or     $0x10,%edx
80107680:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107686:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107689:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107690:	83 ca 60             	or     $0x60,%edx
80107693:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107699:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010769c:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
801076a3:	83 ca 80             	or     $0xffffff80,%edx
801076a6:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801076ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076af:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801076b6:	83 ca 0f             	or     $0xf,%edx
801076b9:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801076bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076c2:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801076c9:	83 e2 ef             	and    $0xffffffef,%edx
801076cc:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801076d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076d5:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801076dc:	83 e2 df             	and    $0xffffffdf,%edx
801076df:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801076e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076e8:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801076ef:	83 ca 40             	or     $0x40,%edx
801076f2:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801076f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076fb:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107702:	83 ca 80             	or     $0xffffff80,%edx
80107705:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
8010770b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010770e:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  lgdt(c->gdt, sizeof(c->gdt));
80107715:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107718:	83 c0 70             	add    $0x70,%eax
8010771b:	83 ec 08             	sub    $0x8,%esp
8010771e:	6a 30                	push   $0x30
80107720:	50                   	push   %eax
80107721:	e8 63 fc ff ff       	call   80107389 <lgdt>
80107726:	83 c4 10             	add    $0x10,%esp
}
80107729:	90                   	nop
8010772a:	c9                   	leave  
8010772b:	c3                   	ret    

8010772c <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
8010772c:	55                   	push   %ebp
8010772d:	89 e5                	mov    %esp,%ebp
8010772f:	83 ec 18             	sub    $0x18,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
80107732:	8b 45 0c             	mov    0xc(%ebp),%eax
80107735:	c1 e8 16             	shr    $0x16,%eax
80107738:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010773f:	8b 45 08             	mov    0x8(%ebp),%eax
80107742:	01 d0                	add    %edx,%eax
80107744:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
80107747:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010774a:	8b 00                	mov    (%eax),%eax
8010774c:	83 e0 01             	and    $0x1,%eax
8010774f:	85 c0                	test   %eax,%eax
80107751:	74 14                	je     80107767 <walkpgdir+0x3b>
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
80107753:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107756:	8b 00                	mov    (%eax),%eax
80107758:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010775d:	05 00 00 00 80       	add    $0x80000000,%eax
80107762:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107765:	eb 42                	jmp    801077a9 <walkpgdir+0x7d>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
80107767:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010776b:	74 0e                	je     8010777b <walkpgdir+0x4f>
8010776d:	e8 12 b5 ff ff       	call   80102c84 <kalloc>
80107772:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107775:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107779:	75 07                	jne    80107782 <walkpgdir+0x56>
      return 0;
8010777b:	b8 00 00 00 00       	mov    $0x0,%eax
80107780:	eb 3e                	jmp    801077c0 <walkpgdir+0x94>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
80107782:	83 ec 04             	sub    $0x4,%esp
80107785:	68 00 10 00 00       	push   $0x1000
8010778a:	6a 00                	push   $0x0
8010778c:	ff 75 f4             	push   -0xc(%ebp)
8010778f:	e8 cf d6 ff ff       	call   80104e63 <memset>
80107794:	83 c4 10             	add    $0x10,%esp
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table
    // entries, if necessary.
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
80107797:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010779a:	05 00 00 00 80       	add    $0x80000000,%eax
8010779f:	83 c8 07             	or     $0x7,%eax
801077a2:	89 c2                	mov    %eax,%edx
801077a4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801077a7:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
801077a9:	8b 45 0c             	mov    0xc(%ebp),%eax
801077ac:	c1 e8 0c             	shr    $0xc,%eax
801077af:	25 ff 03 00 00       	and    $0x3ff,%eax
801077b4:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801077bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077be:	01 d0                	add    %edx,%eax
}
801077c0:	c9                   	leave  
801077c1:	c3                   	ret    

801077c2 <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
801077c2:	55                   	push   %ebp
801077c3:	89 e5                	mov    %esp,%ebp
801077c5:	83 ec 18             	sub    $0x18,%esp
  char *a, *last;
  pte_t *pte;

  a = (char*)PGROUNDDOWN((uint)va);
801077c8:	8b 45 0c             	mov    0xc(%ebp),%eax
801077cb:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801077d0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
801077d3:	8b 55 0c             	mov    0xc(%ebp),%edx
801077d6:	8b 45 10             	mov    0x10(%ebp),%eax
801077d9:	01 d0                	add    %edx,%eax
801077db:	83 e8 01             	sub    $0x1,%eax
801077de:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801077e3:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
801077e6:	83 ec 04             	sub    $0x4,%esp
801077e9:	6a 01                	push   $0x1
801077eb:	ff 75 f4             	push   -0xc(%ebp)
801077ee:	ff 75 08             	push   0x8(%ebp)
801077f1:	e8 36 ff ff ff       	call   8010772c <walkpgdir>
801077f6:	83 c4 10             	add    $0x10,%esp
801077f9:	89 45 ec             	mov    %eax,-0x14(%ebp)
801077fc:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107800:	75 07                	jne    80107809 <mappages+0x47>
      return -1;
80107802:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107807:	eb 47                	jmp    80107850 <mappages+0x8e>
    if(*pte & PTE_P)
80107809:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010780c:	8b 00                	mov    (%eax),%eax
8010780e:	83 e0 01             	and    $0x1,%eax
80107811:	85 c0                	test   %eax,%eax
80107813:	74 0d                	je     80107822 <mappages+0x60>
      panic("remap");
80107815:	83 ec 0c             	sub    $0xc,%esp
80107818:	68 78 aa 10 80       	push   $0x8010aa78
8010781d:	e8 87 8d ff ff       	call   801005a9 <panic>
    *pte = pa | perm | PTE_P;
80107822:	8b 45 18             	mov    0x18(%ebp),%eax
80107825:	0b 45 14             	or     0x14(%ebp),%eax
80107828:	83 c8 01             	or     $0x1,%eax
8010782b:	89 c2                	mov    %eax,%edx
8010782d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107830:	89 10                	mov    %edx,(%eax)
    if(a == last)
80107832:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107835:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80107838:	74 10                	je     8010784a <mappages+0x88>
      break;
    a += PGSIZE;
8010783a:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
80107841:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80107848:	eb 9c                	jmp    801077e6 <mappages+0x24>
      break;
8010784a:	90                   	nop
  }
  return 0;
8010784b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107850:	c9                   	leave  
80107851:	c3                   	ret    

80107852 <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
80107852:	55                   	push   %ebp
80107853:	89 e5                	mov    %esp,%ebp
80107855:	53                   	push   %ebx
80107856:	83 ec 24             	sub    $0x24,%esp
  pde_t *pgdir;
  struct kmap *k;
  k = kmap;
80107859:	c7 45 f4 80 f4 10 80 	movl   $0x8010f480,-0xc(%ebp)
  struct kmap vram = { (void*)(DEVSPACE - gpu.vram_size),gpu.pvram_addr,gpu.pvram_addr+gpu.vram_size, PTE_W};
80107860:	8b 15 90 9e 11 80    	mov    0x80119e90,%edx
80107866:	b8 00 00 00 fe       	mov    $0xfe000000,%eax
8010786b:	29 d0                	sub    %edx,%eax
8010786d:	89 45 e0             	mov    %eax,-0x20(%ebp)
80107870:	a1 88 9e 11 80       	mov    0x80119e88,%eax
80107875:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80107878:	8b 15 88 9e 11 80    	mov    0x80119e88,%edx
8010787e:	a1 90 9e 11 80       	mov    0x80119e90,%eax
80107883:	01 d0                	add    %edx,%eax
80107885:	89 45 e8             	mov    %eax,-0x18(%ebp)
80107888:	c7 45 ec 02 00 00 00 	movl   $0x2,-0x14(%ebp)
  k[3] = vram;
8010788f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107892:	83 c0 30             	add    $0x30,%eax
80107895:	8b 55 e0             	mov    -0x20(%ebp),%edx
80107898:	89 10                	mov    %edx,(%eax)
8010789a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010789d:	89 50 04             	mov    %edx,0x4(%eax)
801078a0:	8b 55 e8             	mov    -0x18(%ebp),%edx
801078a3:	89 50 08             	mov    %edx,0x8(%eax)
801078a6:	8b 55 ec             	mov    -0x14(%ebp),%edx
801078a9:	89 50 0c             	mov    %edx,0xc(%eax)
  if((pgdir = (pde_t*)kalloc()) == 0){
801078ac:	e8 d3 b3 ff ff       	call   80102c84 <kalloc>
801078b1:	89 45 f0             	mov    %eax,-0x10(%ebp)
801078b4:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801078b8:	75 07                	jne    801078c1 <setupkvm+0x6f>
    return 0;
801078ba:	b8 00 00 00 00       	mov    $0x0,%eax
801078bf:	eb 78                	jmp    80107939 <setupkvm+0xe7>
  }
  memset(pgdir, 0, PGSIZE);
801078c1:	83 ec 04             	sub    $0x4,%esp
801078c4:	68 00 10 00 00       	push   $0x1000
801078c9:	6a 00                	push   $0x0
801078cb:	ff 75 f0             	push   -0x10(%ebp)
801078ce:	e8 90 d5 ff ff       	call   80104e63 <memset>
801078d3:	83 c4 10             	add    $0x10,%esp
  if (P2V(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
801078d6:	c7 45 f4 80 f4 10 80 	movl   $0x8010f480,-0xc(%ebp)
801078dd:	eb 4e                	jmp    8010792d <setupkvm+0xdb>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
801078df:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078e2:	8b 48 0c             	mov    0xc(%eax),%ecx
                (uint)k->phys_start, k->perm) < 0) {
801078e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078e8:	8b 50 04             	mov    0x4(%eax),%edx
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
801078eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078ee:	8b 58 08             	mov    0x8(%eax),%ebx
801078f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078f4:	8b 40 04             	mov    0x4(%eax),%eax
801078f7:	29 c3                	sub    %eax,%ebx
801078f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078fc:	8b 00                	mov    (%eax),%eax
801078fe:	83 ec 0c             	sub    $0xc,%esp
80107901:	51                   	push   %ecx
80107902:	52                   	push   %edx
80107903:	53                   	push   %ebx
80107904:	50                   	push   %eax
80107905:	ff 75 f0             	push   -0x10(%ebp)
80107908:	e8 b5 fe ff ff       	call   801077c2 <mappages>
8010790d:	83 c4 20             	add    $0x20,%esp
80107910:	85 c0                	test   %eax,%eax
80107912:	79 15                	jns    80107929 <setupkvm+0xd7>
      freevm(pgdir);
80107914:	83 ec 0c             	sub    $0xc,%esp
80107917:	ff 75 f0             	push   -0x10(%ebp)
8010791a:	e8 f5 04 00 00       	call   80107e14 <freevm>
8010791f:	83 c4 10             	add    $0x10,%esp
      return 0;
80107922:	b8 00 00 00 00       	mov    $0x0,%eax
80107927:	eb 10                	jmp    80107939 <setupkvm+0xe7>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80107929:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
8010792d:	81 7d f4 e0 f4 10 80 	cmpl   $0x8010f4e0,-0xc(%ebp)
80107934:	72 a9                	jb     801078df <setupkvm+0x8d>
    }
  return pgdir;
80107936:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80107939:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010793c:	c9                   	leave  
8010793d:	c3                   	ret    

8010793e <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
8010793e:	55                   	push   %ebp
8010793f:	89 e5                	mov    %esp,%ebp
80107941:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
80107944:	e8 09 ff ff ff       	call   80107852 <setupkvm>
80107949:	a3 bc 9b 11 80       	mov    %eax,0x80119bbc
  switchkvm();
8010794e:	e8 03 00 00 00       	call   80107956 <switchkvm>
}
80107953:	90                   	nop
80107954:	c9                   	leave  
80107955:	c3                   	ret    

80107956 <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
80107956:	55                   	push   %ebp
80107957:	89 e5                	mov    %esp,%ebp
  lcr3(V2P(kpgdir));   // switch to the kernel page table
80107959:	a1 bc 9b 11 80       	mov    0x80119bbc,%eax
8010795e:	05 00 00 00 80       	add    $0x80000000,%eax
80107963:	50                   	push   %eax
80107964:	e8 61 fa ff ff       	call   801073ca <lcr3>
80107969:	83 c4 04             	add    $0x4,%esp
}
8010796c:	90                   	nop
8010796d:	c9                   	leave  
8010796e:	c3                   	ret    

8010796f <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
8010796f:	55                   	push   %ebp
80107970:	89 e5                	mov    %esp,%ebp
80107972:	56                   	push   %esi
80107973:	53                   	push   %ebx
80107974:	83 ec 10             	sub    $0x10,%esp
  if(p == 0)
80107977:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010797b:	75 0d                	jne    8010798a <switchuvm+0x1b>
    panic("switchuvm: no process");
8010797d:	83 ec 0c             	sub    $0xc,%esp
80107980:	68 7e aa 10 80       	push   $0x8010aa7e
80107985:	e8 1f 8c ff ff       	call   801005a9 <panic>
  if(p->kstack == 0)
8010798a:	8b 45 08             	mov    0x8(%ebp),%eax
8010798d:	8b 40 08             	mov    0x8(%eax),%eax
80107990:	85 c0                	test   %eax,%eax
80107992:	75 0d                	jne    801079a1 <switchuvm+0x32>
    panic("switchuvm: no kstack");
80107994:	83 ec 0c             	sub    $0xc,%esp
80107997:	68 94 aa 10 80       	push   $0x8010aa94
8010799c:	e8 08 8c ff ff       	call   801005a9 <panic>
  if(p->pgdir == 0)
801079a1:	8b 45 08             	mov    0x8(%ebp),%eax
801079a4:	8b 40 04             	mov    0x4(%eax),%eax
801079a7:	85 c0                	test   %eax,%eax
801079a9:	75 0d                	jne    801079b8 <switchuvm+0x49>
    panic("switchuvm: no pgdir");
801079ab:	83 ec 0c             	sub    $0xc,%esp
801079ae:	68 a9 aa 10 80       	push   $0x8010aaa9
801079b3:	e8 f1 8b ff ff       	call   801005a9 <panic>

  pushcli();
801079b8:	e8 9b d3 ff ff       	call   80104d58 <pushcli>
  mycpu()->gdt[SEG_TSS] = SEG16(STS_T32A, &mycpu()->ts,
801079bd:	e8 da c4 ff ff       	call   80103e9c <mycpu>
801079c2:	89 c3                	mov    %eax,%ebx
801079c4:	e8 d3 c4 ff ff       	call   80103e9c <mycpu>
801079c9:	83 c0 08             	add    $0x8,%eax
801079cc:	89 c6                	mov    %eax,%esi
801079ce:	e8 c9 c4 ff ff       	call   80103e9c <mycpu>
801079d3:	83 c0 08             	add    $0x8,%eax
801079d6:	c1 e8 10             	shr    $0x10,%eax
801079d9:	88 45 f7             	mov    %al,-0x9(%ebp)
801079dc:	e8 bb c4 ff ff       	call   80103e9c <mycpu>
801079e1:	83 c0 08             	add    $0x8,%eax
801079e4:	c1 e8 18             	shr    $0x18,%eax
801079e7:	89 c2                	mov    %eax,%edx
801079e9:	66 c7 83 98 00 00 00 	movw   $0x67,0x98(%ebx)
801079f0:	67 00 
801079f2:	66 89 b3 9a 00 00 00 	mov    %si,0x9a(%ebx)
801079f9:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
801079fd:	88 83 9c 00 00 00    	mov    %al,0x9c(%ebx)
80107a03:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80107a0a:	83 e0 f0             	and    $0xfffffff0,%eax
80107a0d:	83 c8 09             	or     $0x9,%eax
80107a10:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80107a16:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80107a1d:	83 c8 10             	or     $0x10,%eax
80107a20:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80107a26:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80107a2d:	83 e0 9f             	and    $0xffffff9f,%eax
80107a30:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80107a36:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80107a3d:	83 c8 80             	or     $0xffffff80,%eax
80107a40:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80107a46:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107a4d:	83 e0 f0             	and    $0xfffffff0,%eax
80107a50:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107a56:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107a5d:	83 e0 ef             	and    $0xffffffef,%eax
80107a60:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107a66:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107a6d:	83 e0 df             	and    $0xffffffdf,%eax
80107a70:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107a76:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107a7d:	83 c8 40             	or     $0x40,%eax
80107a80:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107a86:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107a8d:	83 e0 7f             	and    $0x7f,%eax
80107a90:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107a96:	88 93 9f 00 00 00    	mov    %dl,0x9f(%ebx)
                                sizeof(mycpu()->ts)-1, 0);
  mycpu()->gdt[SEG_TSS].s = 0;
80107a9c:	e8 fb c3 ff ff       	call   80103e9c <mycpu>
80107aa1:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107aa8:	83 e2 ef             	and    $0xffffffef,%edx
80107aab:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
  mycpu()->ts.ss0 = SEG_KDATA << 3;
80107ab1:	e8 e6 c3 ff ff       	call   80103e9c <mycpu>
80107ab6:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  mycpu()->ts.esp0 = (uint)p->kstack + KSTACKSIZE;
80107abc:	8b 45 08             	mov    0x8(%ebp),%eax
80107abf:	8b 40 08             	mov    0x8(%eax),%eax
80107ac2:	89 c3                	mov    %eax,%ebx
80107ac4:	e8 d3 c3 ff ff       	call   80103e9c <mycpu>
80107ac9:	8d 93 00 10 00 00    	lea    0x1000(%ebx),%edx
80107acf:	89 50 0c             	mov    %edx,0xc(%eax)
  // setting IOPL=0 in eflags *and* iomb beyond the tss segment limit
  // forbids I/O instructions (e.g., inb and outb) from user space
  mycpu()->ts.iomb = (ushort) 0xFFFF;
80107ad2:	e8 c5 c3 ff ff       	call   80103e9c <mycpu>
80107ad7:	66 c7 40 6e ff ff    	movw   $0xffff,0x6e(%eax)
  ltr(SEG_TSS << 3);
80107add:	83 ec 0c             	sub    $0xc,%esp
80107ae0:	6a 28                	push   $0x28
80107ae2:	e8 cc f8 ff ff       	call   801073b3 <ltr>
80107ae7:	83 c4 10             	add    $0x10,%esp
  lcr3(V2P(p->pgdir));  // switch to process's address space
80107aea:	8b 45 08             	mov    0x8(%ebp),%eax
80107aed:	8b 40 04             	mov    0x4(%eax),%eax
80107af0:	05 00 00 00 80       	add    $0x80000000,%eax
80107af5:	83 ec 0c             	sub    $0xc,%esp
80107af8:	50                   	push   %eax
80107af9:	e8 cc f8 ff ff       	call   801073ca <lcr3>
80107afe:	83 c4 10             	add    $0x10,%esp
  popcli();
80107b01:	e8 9f d2 ff ff       	call   80104da5 <popcli>
}
80107b06:	90                   	nop
80107b07:	8d 65 f8             	lea    -0x8(%ebp),%esp
80107b0a:	5b                   	pop    %ebx
80107b0b:	5e                   	pop    %esi
80107b0c:	5d                   	pop    %ebp
80107b0d:	c3                   	ret    

80107b0e <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
80107b0e:	55                   	push   %ebp
80107b0f:	89 e5                	mov    %esp,%ebp
80107b11:	83 ec 18             	sub    $0x18,%esp
  char *mem;

  if(sz >= PGSIZE)
80107b14:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
80107b1b:	76 0d                	jbe    80107b2a <inituvm+0x1c>
    panic("inituvm: more than a page");
80107b1d:	83 ec 0c             	sub    $0xc,%esp
80107b20:	68 bd aa 10 80       	push   $0x8010aabd
80107b25:	e8 7f 8a ff ff       	call   801005a9 <panic>
  mem = kalloc();
80107b2a:	e8 55 b1 ff ff       	call   80102c84 <kalloc>
80107b2f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
80107b32:	83 ec 04             	sub    $0x4,%esp
80107b35:	68 00 10 00 00       	push   $0x1000
80107b3a:	6a 00                	push   $0x0
80107b3c:	ff 75 f4             	push   -0xc(%ebp)
80107b3f:	e8 1f d3 ff ff       	call   80104e63 <memset>
80107b44:	83 c4 10             	add    $0x10,%esp
  mappages(pgdir, 0, PGSIZE, V2P(mem), PTE_W|PTE_U);
80107b47:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b4a:	05 00 00 00 80       	add    $0x80000000,%eax
80107b4f:	83 ec 0c             	sub    $0xc,%esp
80107b52:	6a 06                	push   $0x6
80107b54:	50                   	push   %eax
80107b55:	68 00 10 00 00       	push   $0x1000
80107b5a:	6a 00                	push   $0x0
80107b5c:	ff 75 08             	push   0x8(%ebp)
80107b5f:	e8 5e fc ff ff       	call   801077c2 <mappages>
80107b64:	83 c4 20             	add    $0x20,%esp
  memmove(mem, init, sz);
80107b67:	83 ec 04             	sub    $0x4,%esp
80107b6a:	ff 75 10             	push   0x10(%ebp)
80107b6d:	ff 75 0c             	push   0xc(%ebp)
80107b70:	ff 75 f4             	push   -0xc(%ebp)
80107b73:	e8 aa d3 ff ff       	call   80104f22 <memmove>
80107b78:	83 c4 10             	add    $0x10,%esp
}
80107b7b:	90                   	nop
80107b7c:	c9                   	leave  
80107b7d:	c3                   	ret    

80107b7e <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
80107b7e:	55                   	push   %ebp
80107b7f:	89 e5                	mov    %esp,%ebp
80107b81:	83 ec 18             	sub    $0x18,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
80107b84:	8b 45 0c             	mov    0xc(%ebp),%eax
80107b87:	25 ff 0f 00 00       	and    $0xfff,%eax
80107b8c:	85 c0                	test   %eax,%eax
80107b8e:	74 0d                	je     80107b9d <loaduvm+0x1f>
    panic("loaduvm: addr must be page aligned");
80107b90:	83 ec 0c             	sub    $0xc,%esp
80107b93:	68 d8 aa 10 80       	push   $0x8010aad8
80107b98:	e8 0c 8a ff ff       	call   801005a9 <panic>
  for(i = 0; i < sz; i += PGSIZE){
80107b9d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107ba4:	e9 8f 00 00 00       	jmp    80107c38 <loaduvm+0xba>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
80107ba9:	8b 55 0c             	mov    0xc(%ebp),%edx
80107bac:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107baf:	01 d0                	add    %edx,%eax
80107bb1:	83 ec 04             	sub    $0x4,%esp
80107bb4:	6a 00                	push   $0x0
80107bb6:	50                   	push   %eax
80107bb7:	ff 75 08             	push   0x8(%ebp)
80107bba:	e8 6d fb ff ff       	call   8010772c <walkpgdir>
80107bbf:	83 c4 10             	add    $0x10,%esp
80107bc2:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107bc5:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107bc9:	75 0d                	jne    80107bd8 <loaduvm+0x5a>
      panic("loaduvm: address should exist");
80107bcb:	83 ec 0c             	sub    $0xc,%esp
80107bce:	68 fb aa 10 80       	push   $0x8010aafb
80107bd3:	e8 d1 89 ff ff       	call   801005a9 <panic>
    pa = PTE_ADDR(*pte);
80107bd8:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107bdb:	8b 00                	mov    (%eax),%eax
80107bdd:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107be2:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
80107be5:	8b 45 18             	mov    0x18(%ebp),%eax
80107be8:	2b 45 f4             	sub    -0xc(%ebp),%eax
80107beb:	3d ff 0f 00 00       	cmp    $0xfff,%eax
80107bf0:	77 0b                	ja     80107bfd <loaduvm+0x7f>
      n = sz - i;
80107bf2:	8b 45 18             	mov    0x18(%ebp),%eax
80107bf5:	2b 45 f4             	sub    -0xc(%ebp),%eax
80107bf8:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107bfb:	eb 07                	jmp    80107c04 <loaduvm+0x86>
    else
      n = PGSIZE;
80107bfd:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, P2V(pa), offset+i, n) != n)
80107c04:	8b 55 14             	mov    0x14(%ebp),%edx
80107c07:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c0a:	01 d0                	add    %edx,%eax
80107c0c:	8b 55 e8             	mov    -0x18(%ebp),%edx
80107c0f:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80107c15:	ff 75 f0             	push   -0x10(%ebp)
80107c18:	50                   	push   %eax
80107c19:	52                   	push   %edx
80107c1a:	ff 75 10             	push   0x10(%ebp)
80107c1d:	e8 b4 a2 ff ff       	call   80101ed6 <readi>
80107c22:	83 c4 10             	add    $0x10,%esp
80107c25:	39 45 f0             	cmp    %eax,-0x10(%ebp)
80107c28:	74 07                	je     80107c31 <loaduvm+0xb3>
      return -1;
80107c2a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107c2f:	eb 18                	jmp    80107c49 <loaduvm+0xcb>
  for(i = 0; i < sz; i += PGSIZE){
80107c31:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80107c38:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c3b:	3b 45 18             	cmp    0x18(%ebp),%eax
80107c3e:	0f 82 65 ff ff ff    	jb     80107ba9 <loaduvm+0x2b>
  }
  return 0;
80107c44:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107c49:	c9                   	leave  
80107c4a:	c3                   	ret    

80107c4b <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80107c4b:	55                   	push   %ebp
80107c4c:	89 e5                	mov    %esp,%ebp
80107c4e:	83 ec 18             	sub    $0x18,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
80107c51:	8b 45 10             	mov    0x10(%ebp),%eax
80107c54:	85 c0                	test   %eax,%eax
80107c56:	79 0a                	jns    80107c62 <allocuvm+0x17>
    return 0;
80107c58:	b8 00 00 00 00       	mov    $0x0,%eax
80107c5d:	e9 ec 00 00 00       	jmp    80107d4e <allocuvm+0x103>
  if(newsz < oldsz)
80107c62:	8b 45 10             	mov    0x10(%ebp),%eax
80107c65:	3b 45 0c             	cmp    0xc(%ebp),%eax
80107c68:	73 08                	jae    80107c72 <allocuvm+0x27>
    return oldsz;
80107c6a:	8b 45 0c             	mov    0xc(%ebp),%eax
80107c6d:	e9 dc 00 00 00       	jmp    80107d4e <allocuvm+0x103>

  a = PGROUNDUP(oldsz);
80107c72:	8b 45 0c             	mov    0xc(%ebp),%eax
80107c75:	05 ff 0f 00 00       	add    $0xfff,%eax
80107c7a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107c7f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
80107c82:	e9 b8 00 00 00       	jmp    80107d3f <allocuvm+0xf4>
    mem = kalloc();
80107c87:	e8 f8 af ff ff       	call   80102c84 <kalloc>
80107c8c:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
80107c8f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107c93:	75 2e                	jne    80107cc3 <allocuvm+0x78>
      cprintf("allocuvm out of memory\n");
80107c95:	83 ec 0c             	sub    $0xc,%esp
80107c98:	68 19 ab 10 80       	push   $0x8010ab19
80107c9d:	e8 52 87 ff ff       	call   801003f4 <cprintf>
80107ca2:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
80107ca5:	83 ec 04             	sub    $0x4,%esp
80107ca8:	ff 75 0c             	push   0xc(%ebp)
80107cab:	ff 75 10             	push   0x10(%ebp)
80107cae:	ff 75 08             	push   0x8(%ebp)
80107cb1:	e8 9a 00 00 00       	call   80107d50 <deallocuvm>
80107cb6:	83 c4 10             	add    $0x10,%esp
      return 0;
80107cb9:	b8 00 00 00 00       	mov    $0x0,%eax
80107cbe:	e9 8b 00 00 00       	jmp    80107d4e <allocuvm+0x103>
    }
    memset(mem, 0, PGSIZE);
80107cc3:	83 ec 04             	sub    $0x4,%esp
80107cc6:	68 00 10 00 00       	push   $0x1000
80107ccb:	6a 00                	push   $0x0
80107ccd:	ff 75 f0             	push   -0x10(%ebp)
80107cd0:	e8 8e d1 ff ff       	call   80104e63 <memset>
80107cd5:	83 c4 10             	add    $0x10,%esp
    if(mappages(pgdir, (char*)a, PGSIZE, V2P(mem), PTE_W|PTE_U) < 0){
80107cd8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107cdb:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80107ce1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ce4:	83 ec 0c             	sub    $0xc,%esp
80107ce7:	6a 06                	push   $0x6
80107ce9:	52                   	push   %edx
80107cea:	68 00 10 00 00       	push   $0x1000
80107cef:	50                   	push   %eax
80107cf0:	ff 75 08             	push   0x8(%ebp)
80107cf3:	e8 ca fa ff ff       	call   801077c2 <mappages>
80107cf8:	83 c4 20             	add    $0x20,%esp
80107cfb:	85 c0                	test   %eax,%eax
80107cfd:	79 39                	jns    80107d38 <allocuvm+0xed>
      cprintf("allocuvm out of memory (2)\n");
80107cff:	83 ec 0c             	sub    $0xc,%esp
80107d02:	68 31 ab 10 80       	push   $0x8010ab31
80107d07:	e8 e8 86 ff ff       	call   801003f4 <cprintf>
80107d0c:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
80107d0f:	83 ec 04             	sub    $0x4,%esp
80107d12:	ff 75 0c             	push   0xc(%ebp)
80107d15:	ff 75 10             	push   0x10(%ebp)
80107d18:	ff 75 08             	push   0x8(%ebp)
80107d1b:	e8 30 00 00 00       	call   80107d50 <deallocuvm>
80107d20:	83 c4 10             	add    $0x10,%esp
      kfree(mem);
80107d23:	83 ec 0c             	sub    $0xc,%esp
80107d26:	ff 75 f0             	push   -0x10(%ebp)
80107d29:	e8 bc ae ff ff       	call   80102bea <kfree>
80107d2e:	83 c4 10             	add    $0x10,%esp
      return 0;
80107d31:	b8 00 00 00 00       	mov    $0x0,%eax
80107d36:	eb 16                	jmp    80107d4e <allocuvm+0x103>
  for(; a < newsz; a += PGSIZE){
80107d38:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80107d3f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d42:	3b 45 10             	cmp    0x10(%ebp),%eax
80107d45:	0f 82 3c ff ff ff    	jb     80107c87 <allocuvm+0x3c>
    }
  }
  return newsz;
80107d4b:	8b 45 10             	mov    0x10(%ebp),%eax
}
80107d4e:	c9                   	leave  
80107d4f:	c3                   	ret    

80107d50 <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80107d50:	55                   	push   %ebp
80107d51:	89 e5                	mov    %esp,%ebp
80107d53:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
80107d56:	8b 45 10             	mov    0x10(%ebp),%eax
80107d59:	3b 45 0c             	cmp    0xc(%ebp),%eax
80107d5c:	72 08                	jb     80107d66 <deallocuvm+0x16>
    return oldsz;
80107d5e:	8b 45 0c             	mov    0xc(%ebp),%eax
80107d61:	e9 ac 00 00 00       	jmp    80107e12 <deallocuvm+0xc2>

  a = PGROUNDUP(newsz);
80107d66:	8b 45 10             	mov    0x10(%ebp),%eax
80107d69:	05 ff 0f 00 00       	add    $0xfff,%eax
80107d6e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107d73:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
80107d76:	e9 88 00 00 00       	jmp    80107e03 <deallocuvm+0xb3>
    pte = walkpgdir(pgdir, (char*)a, 0);
80107d7b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d7e:	83 ec 04             	sub    $0x4,%esp
80107d81:	6a 00                	push   $0x0
80107d83:	50                   	push   %eax
80107d84:	ff 75 08             	push   0x8(%ebp)
80107d87:	e8 a0 f9 ff ff       	call   8010772c <walkpgdir>
80107d8c:	83 c4 10             	add    $0x10,%esp
80107d8f:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
80107d92:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107d96:	75 16                	jne    80107dae <deallocuvm+0x5e>
      a = PGADDR(PDX(a) + 1, 0, 0) - PGSIZE;
80107d98:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d9b:	c1 e8 16             	shr    $0x16,%eax
80107d9e:	83 c0 01             	add    $0x1,%eax
80107da1:	c1 e0 16             	shl    $0x16,%eax
80107da4:	2d 00 10 00 00       	sub    $0x1000,%eax
80107da9:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107dac:	eb 4e                	jmp    80107dfc <deallocuvm+0xac>
    else if((*pte & PTE_P) != 0){
80107dae:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107db1:	8b 00                	mov    (%eax),%eax
80107db3:	83 e0 01             	and    $0x1,%eax
80107db6:	85 c0                	test   %eax,%eax
80107db8:	74 42                	je     80107dfc <deallocuvm+0xac>
      pa = PTE_ADDR(*pte);
80107dba:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107dbd:	8b 00                	mov    (%eax),%eax
80107dbf:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107dc4:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
80107dc7:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107dcb:	75 0d                	jne    80107dda <deallocuvm+0x8a>
        panic("kfree");
80107dcd:	83 ec 0c             	sub    $0xc,%esp
80107dd0:	68 4d ab 10 80       	push   $0x8010ab4d
80107dd5:	e8 cf 87 ff ff       	call   801005a9 <panic>
      char *v = P2V(pa);
80107dda:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107ddd:	05 00 00 00 80       	add    $0x80000000,%eax
80107de2:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
80107de5:	83 ec 0c             	sub    $0xc,%esp
80107de8:	ff 75 e8             	push   -0x18(%ebp)
80107deb:	e8 fa ad ff ff       	call   80102bea <kfree>
80107df0:	83 c4 10             	add    $0x10,%esp
      *pte = 0;
80107df3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107df6:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; a  < oldsz; a += PGSIZE){
80107dfc:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80107e03:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e06:	3b 45 0c             	cmp    0xc(%ebp),%eax
80107e09:	0f 82 6c ff ff ff    	jb     80107d7b <deallocuvm+0x2b>
    }
  }
  return newsz;
80107e0f:	8b 45 10             	mov    0x10(%ebp),%eax
}
80107e12:	c9                   	leave  
80107e13:	c3                   	ret    

80107e14 <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
80107e14:	55                   	push   %ebp
80107e15:	89 e5                	mov    %esp,%ebp
80107e17:	83 ec 18             	sub    $0x18,%esp
  uint i;

  if(pgdir == 0)
80107e1a:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80107e1e:	75 0d                	jne    80107e2d <freevm+0x19>
    panic("freevm: no pgdir");
80107e20:	83 ec 0c             	sub    $0xc,%esp
80107e23:	68 53 ab 10 80       	push   $0x8010ab53
80107e28:	e8 7c 87 ff ff       	call   801005a9 <panic>
  deallocuvm(pgdir, KERNBASE, 0);
80107e2d:	83 ec 04             	sub    $0x4,%esp
80107e30:	6a 00                	push   $0x0
80107e32:	68 00 00 00 80       	push   $0x80000000
80107e37:	ff 75 08             	push   0x8(%ebp)
80107e3a:	e8 11 ff ff ff       	call   80107d50 <deallocuvm>
80107e3f:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
80107e42:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107e49:	eb 48                	jmp    80107e93 <freevm+0x7f>
    if(pgdir[i] & PTE_P){
80107e4b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e4e:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107e55:	8b 45 08             	mov    0x8(%ebp),%eax
80107e58:	01 d0                	add    %edx,%eax
80107e5a:	8b 00                	mov    (%eax),%eax
80107e5c:	83 e0 01             	and    $0x1,%eax
80107e5f:	85 c0                	test   %eax,%eax
80107e61:	74 2c                	je     80107e8f <freevm+0x7b>
      char * v = P2V(PTE_ADDR(pgdir[i]));
80107e63:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e66:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107e6d:	8b 45 08             	mov    0x8(%ebp),%eax
80107e70:	01 d0                	add    %edx,%eax
80107e72:	8b 00                	mov    (%eax),%eax
80107e74:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107e79:	05 00 00 00 80       	add    $0x80000000,%eax
80107e7e:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
80107e81:	83 ec 0c             	sub    $0xc,%esp
80107e84:	ff 75 f0             	push   -0x10(%ebp)
80107e87:	e8 5e ad ff ff       	call   80102bea <kfree>
80107e8c:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
80107e8f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80107e93:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
80107e9a:	76 af                	jbe    80107e4b <freevm+0x37>
    }
  }
  kfree((char*)pgdir);
80107e9c:	83 ec 0c             	sub    $0xc,%esp
80107e9f:	ff 75 08             	push   0x8(%ebp)
80107ea2:	e8 43 ad ff ff       	call   80102bea <kfree>
80107ea7:	83 c4 10             	add    $0x10,%esp
}
80107eaa:	90                   	nop
80107eab:	c9                   	leave  
80107eac:	c3                   	ret    

80107ead <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
80107ead:	55                   	push   %ebp
80107eae:	89 e5                	mov    %esp,%ebp
80107eb0:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80107eb3:	83 ec 04             	sub    $0x4,%esp
80107eb6:	6a 00                	push   $0x0
80107eb8:	ff 75 0c             	push   0xc(%ebp)
80107ebb:	ff 75 08             	push   0x8(%ebp)
80107ebe:	e8 69 f8 ff ff       	call   8010772c <walkpgdir>
80107ec3:	83 c4 10             	add    $0x10,%esp
80107ec6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
80107ec9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107ecd:	75 0d                	jne    80107edc <clearpteu+0x2f>
    panic("clearpteu");
80107ecf:	83 ec 0c             	sub    $0xc,%esp
80107ed2:	68 64 ab 10 80       	push   $0x8010ab64
80107ed7:	e8 cd 86 ff ff       	call   801005a9 <panic>
  *pte &= ~PTE_U;
80107edc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107edf:	8b 00                	mov    (%eax),%eax
80107ee1:	83 e0 fb             	and    $0xfffffffb,%eax
80107ee4:	89 c2                	mov    %eax,%edx
80107ee6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ee9:	89 10                	mov    %edx,(%eax)
}
80107eeb:	90                   	nop
80107eec:	c9                   	leave  
80107eed:	c3                   	ret    

80107eee <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
80107eee:	55                   	push   %ebp
80107eef:	89 e5                	mov    %esp,%ebp
80107ef1:	83 ec 28             	sub    $0x28,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
80107ef4:	e8 59 f9 ff ff       	call   80107852 <setupkvm>
80107ef9:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107efc:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107f00:	75 0a                	jne    80107f0c <copyuvm+0x1e>
    return 0;
80107f02:	b8 00 00 00 00       	mov    $0x0,%eax
80107f07:	e9 eb 00 00 00       	jmp    80107ff7 <copyuvm+0x109>
  for(i = 0; i < sz; i += PGSIZE){
80107f0c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107f13:	e9 b7 00 00 00       	jmp    80107fcf <copyuvm+0xe1>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
80107f18:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f1b:	83 ec 04             	sub    $0x4,%esp
80107f1e:	6a 00                	push   $0x0
80107f20:	50                   	push   %eax
80107f21:	ff 75 08             	push   0x8(%ebp)
80107f24:	e8 03 f8 ff ff       	call   8010772c <walkpgdir>
80107f29:	83 c4 10             	add    $0x10,%esp
80107f2c:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107f2f:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107f33:	75 0d                	jne    80107f42 <copyuvm+0x54>
      panic("copyuvm: pte should exist");
80107f35:	83 ec 0c             	sub    $0xc,%esp
80107f38:	68 6e ab 10 80       	push   $0x8010ab6e
80107f3d:	e8 67 86 ff ff       	call   801005a9 <panic>
    if(!(*pte & PTE_P))
80107f42:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107f45:	8b 00                	mov    (%eax),%eax
80107f47:	83 e0 01             	and    $0x1,%eax
80107f4a:	85 c0                	test   %eax,%eax
80107f4c:	75 0d                	jne    80107f5b <copyuvm+0x6d>
      panic("copyuvm: page not present");
80107f4e:	83 ec 0c             	sub    $0xc,%esp
80107f51:	68 88 ab 10 80       	push   $0x8010ab88
80107f56:	e8 4e 86 ff ff       	call   801005a9 <panic>
    pa = PTE_ADDR(*pte);
80107f5b:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107f5e:	8b 00                	mov    (%eax),%eax
80107f60:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107f65:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
80107f68:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107f6b:	8b 00                	mov    (%eax),%eax
80107f6d:	25 ff 0f 00 00       	and    $0xfff,%eax
80107f72:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if((mem = kalloc()) == 0)
80107f75:	e8 0a ad ff ff       	call   80102c84 <kalloc>
80107f7a:	89 45 e0             	mov    %eax,-0x20(%ebp)
80107f7d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80107f81:	74 5d                	je     80107fe0 <copyuvm+0xf2>
      goto bad;
    memmove(mem, (char*)P2V(pa), PGSIZE);
80107f83:	8b 45 e8             	mov    -0x18(%ebp),%eax
80107f86:	05 00 00 00 80       	add    $0x80000000,%eax
80107f8b:	83 ec 04             	sub    $0x4,%esp
80107f8e:	68 00 10 00 00       	push   $0x1000
80107f93:	50                   	push   %eax
80107f94:	ff 75 e0             	push   -0x20(%ebp)
80107f97:	e8 86 cf ff ff       	call   80104f22 <memmove>
80107f9c:	83 c4 10             	add    $0x10,%esp
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0)
80107f9f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80107fa2:	8b 45 e0             	mov    -0x20(%ebp),%eax
80107fa5:	8d 88 00 00 00 80    	lea    -0x80000000(%eax),%ecx
80107fab:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fae:	83 ec 0c             	sub    $0xc,%esp
80107fb1:	52                   	push   %edx
80107fb2:	51                   	push   %ecx
80107fb3:	68 00 10 00 00       	push   $0x1000
80107fb8:	50                   	push   %eax
80107fb9:	ff 75 f0             	push   -0x10(%ebp)
80107fbc:	e8 01 f8 ff ff       	call   801077c2 <mappages>
80107fc1:	83 c4 20             	add    $0x20,%esp
80107fc4:	85 c0                	test   %eax,%eax
80107fc6:	78 1b                	js     80107fe3 <copyuvm+0xf5>
  for(i = 0; i < sz; i += PGSIZE){
80107fc8:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80107fcf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fd2:	3b 45 0c             	cmp    0xc(%ebp),%eax
80107fd5:	0f 82 3d ff ff ff    	jb     80107f18 <copyuvm+0x2a>
      goto bad;
  }
  return d;
80107fdb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107fde:	eb 17                	jmp    80107ff7 <copyuvm+0x109>
      goto bad;
80107fe0:	90                   	nop
80107fe1:	eb 01                	jmp    80107fe4 <copyuvm+0xf6>
      goto bad;
80107fe3:	90                   	nop

bad:
  freevm(d);
80107fe4:	83 ec 0c             	sub    $0xc,%esp
80107fe7:	ff 75 f0             	push   -0x10(%ebp)
80107fea:	e8 25 fe ff ff       	call   80107e14 <freevm>
80107fef:	83 c4 10             	add    $0x10,%esp
  return 0;
80107ff2:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107ff7:	c9                   	leave  
80107ff8:	c3                   	ret    

80107ff9 <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
80107ff9:	55                   	push   %ebp
80107ffa:	89 e5                	mov    %esp,%ebp
80107ffc:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80107fff:	83 ec 04             	sub    $0x4,%esp
80108002:	6a 00                	push   $0x0
80108004:	ff 75 0c             	push   0xc(%ebp)
80108007:	ff 75 08             	push   0x8(%ebp)
8010800a:	e8 1d f7 ff ff       	call   8010772c <walkpgdir>
8010800f:	83 c4 10             	add    $0x10,%esp
80108012:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
80108015:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108018:	8b 00                	mov    (%eax),%eax
8010801a:	83 e0 01             	and    $0x1,%eax
8010801d:	85 c0                	test   %eax,%eax
8010801f:	75 07                	jne    80108028 <uva2ka+0x2f>
    return 0;
80108021:	b8 00 00 00 00       	mov    $0x0,%eax
80108026:	eb 22                	jmp    8010804a <uva2ka+0x51>
  if((*pte & PTE_U) == 0)
80108028:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010802b:	8b 00                	mov    (%eax),%eax
8010802d:	83 e0 04             	and    $0x4,%eax
80108030:	85 c0                	test   %eax,%eax
80108032:	75 07                	jne    8010803b <uva2ka+0x42>
    return 0;
80108034:	b8 00 00 00 00       	mov    $0x0,%eax
80108039:	eb 0f                	jmp    8010804a <uva2ka+0x51>
  return (char*)P2V(PTE_ADDR(*pte));
8010803b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010803e:	8b 00                	mov    (%eax),%eax
80108040:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108045:	05 00 00 00 80       	add    $0x80000000,%eax
}
8010804a:	c9                   	leave  
8010804b:	c3                   	ret    

8010804c <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
8010804c:	55                   	push   %ebp
8010804d:	89 e5                	mov    %esp,%ebp
8010804f:	83 ec 18             	sub    $0x18,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
80108052:	8b 45 10             	mov    0x10(%ebp),%eax
80108055:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
80108058:	eb 7f                	jmp    801080d9 <copyout+0x8d>
    va0 = (uint)PGROUNDDOWN(va);
8010805a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010805d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108062:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
80108065:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108068:	83 ec 08             	sub    $0x8,%esp
8010806b:	50                   	push   %eax
8010806c:	ff 75 08             	push   0x8(%ebp)
8010806f:	e8 85 ff ff ff       	call   80107ff9 <uva2ka>
80108074:	83 c4 10             	add    $0x10,%esp
80108077:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
8010807a:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
8010807e:	75 07                	jne    80108087 <copyout+0x3b>
      return -1;
80108080:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108085:	eb 61                	jmp    801080e8 <copyout+0x9c>
    n = PGSIZE - (va - va0);
80108087:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010808a:	2b 45 0c             	sub    0xc(%ebp),%eax
8010808d:	05 00 10 00 00       	add    $0x1000,%eax
80108092:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
80108095:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108098:	3b 45 14             	cmp    0x14(%ebp),%eax
8010809b:	76 06                	jbe    801080a3 <copyout+0x57>
      n = len;
8010809d:	8b 45 14             	mov    0x14(%ebp),%eax
801080a0:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
801080a3:	8b 45 0c             	mov    0xc(%ebp),%eax
801080a6:	2b 45 ec             	sub    -0x14(%ebp),%eax
801080a9:	89 c2                	mov    %eax,%edx
801080ab:	8b 45 e8             	mov    -0x18(%ebp),%eax
801080ae:	01 d0                	add    %edx,%eax
801080b0:	83 ec 04             	sub    $0x4,%esp
801080b3:	ff 75 f0             	push   -0x10(%ebp)
801080b6:	ff 75 f4             	push   -0xc(%ebp)
801080b9:	50                   	push   %eax
801080ba:	e8 63 ce ff ff       	call   80104f22 <memmove>
801080bf:	83 c4 10             	add    $0x10,%esp
    len -= n;
801080c2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801080c5:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
801080c8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801080cb:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
801080ce:	8b 45 ec             	mov    -0x14(%ebp),%eax
801080d1:	05 00 10 00 00       	add    $0x1000,%eax
801080d6:	89 45 0c             	mov    %eax,0xc(%ebp)
  while(len > 0){
801080d9:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
801080dd:	0f 85 77 ff ff ff    	jne    8010805a <copyout+0xe>
  }
  return 0;
801080e3:	b8 00 00 00 00       	mov    $0x0,%eax
}
801080e8:	c9                   	leave  
801080e9:	c3                   	ret    

801080ea <mpinit_uefi>:

struct cpu cpus[NCPU];
int ncpu;
uchar ioapicid;
void mpinit_uefi(void)
{
801080ea:	55                   	push   %ebp
801080eb:	89 e5                	mov    %esp,%ebp
801080ed:	83 ec 20             	sub    $0x20,%esp
  struct boot_param *boot_param = (struct boot_param *)P2V_WO(BOOTPARAM);
801080f0:	c7 45 f8 00 00 05 80 	movl   $0x80050000,-0x8(%ebp)
  struct uefi_madt *madt = (struct uefi_madt*)(P2V_WO(boot_param->madt_addr));
801080f7:	8b 45 f8             	mov    -0x8(%ebp),%eax
801080fa:	8b 40 08             	mov    0x8(%eax),%eax
801080fd:	05 00 00 00 80       	add    $0x80000000,%eax
80108102:	89 45 f4             	mov    %eax,-0xc(%ebp)

  uint i=sizeof(struct uefi_madt);
80108105:	c7 45 fc 2c 00 00 00 	movl   $0x2c,-0x4(%ebp)
  struct uefi_lapic *lapic_entry;
  struct uefi_ioapic *ioapic;
  struct uefi_iso *iso;
  struct uefi_non_maskable_intr *non_mask_intr; 
  
  lapic = (uint *)(madt->lapic_addr);
8010810c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010810f:	8b 40 24             	mov    0x24(%eax),%eax
80108112:	a3 40 71 11 80       	mov    %eax,0x80117140
  ncpu = 0;
80108117:	c7 05 80 9e 11 80 00 	movl   $0x0,0x80119e80
8010811e:	00 00 00 

  while(i<madt->len){
80108121:	90                   	nop
80108122:	e9 bd 00 00 00       	jmp    801081e4 <mpinit_uefi+0xfa>
    uchar *entry_type = ((uchar *)madt)+i;
80108127:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010812a:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010812d:	01 d0                	add    %edx,%eax
8010812f:	89 45 f0             	mov    %eax,-0x10(%ebp)
    switch(*entry_type){
80108132:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108135:	0f b6 00             	movzbl (%eax),%eax
80108138:	0f b6 c0             	movzbl %al,%eax
8010813b:	83 f8 05             	cmp    $0x5,%eax
8010813e:	0f 87 a0 00 00 00    	ja     801081e4 <mpinit_uefi+0xfa>
80108144:	8b 04 85 a4 ab 10 80 	mov    -0x7fef545c(,%eax,4),%eax
8010814b:	ff e0                	jmp    *%eax
      case 0:
        lapic_entry = (struct uefi_lapic *)entry_type;
8010814d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108150:	89 45 e0             	mov    %eax,-0x20(%ebp)
        if(ncpu < NCPU) {
80108153:	a1 80 9e 11 80       	mov    0x80119e80,%eax
80108158:	83 f8 03             	cmp    $0x3,%eax
8010815b:	7f 28                	jg     80108185 <mpinit_uefi+0x9b>
          cpus[ncpu].apicid = lapic_entry->lapic_id;
8010815d:	8b 15 80 9e 11 80    	mov    0x80119e80,%edx
80108163:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108166:	0f b6 40 03          	movzbl 0x3(%eax),%eax
8010816a:	69 d2 b0 00 00 00    	imul   $0xb0,%edx,%edx
80108170:	81 c2 c0 9b 11 80    	add    $0x80119bc0,%edx
80108176:	88 02                	mov    %al,(%edx)
          ncpu++;
80108178:	a1 80 9e 11 80       	mov    0x80119e80,%eax
8010817d:	83 c0 01             	add    $0x1,%eax
80108180:	a3 80 9e 11 80       	mov    %eax,0x80119e80
        }
        i += lapic_entry->record_len;
80108185:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108188:	0f b6 40 01          	movzbl 0x1(%eax),%eax
8010818c:	0f b6 c0             	movzbl %al,%eax
8010818f:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
80108192:	eb 50                	jmp    801081e4 <mpinit_uefi+0xfa>

      case 1:
        ioapic = (struct uefi_ioapic *)entry_type;
80108194:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108197:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        ioapicid = ioapic->ioapic_id;
8010819a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010819d:	0f b6 40 02          	movzbl 0x2(%eax),%eax
801081a1:	a2 84 9e 11 80       	mov    %al,0x80119e84
        i += ioapic->record_len;
801081a6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801081a9:	0f b6 40 01          	movzbl 0x1(%eax),%eax
801081ad:	0f b6 c0             	movzbl %al,%eax
801081b0:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
801081b3:	eb 2f                	jmp    801081e4 <mpinit_uefi+0xfa>

      case 2:
        iso = (struct uefi_iso *)entry_type;
801081b5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801081b8:	89 45 e8             	mov    %eax,-0x18(%ebp)
        i += iso->record_len;
801081bb:	8b 45 e8             	mov    -0x18(%ebp),%eax
801081be:	0f b6 40 01          	movzbl 0x1(%eax),%eax
801081c2:	0f b6 c0             	movzbl %al,%eax
801081c5:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
801081c8:	eb 1a                	jmp    801081e4 <mpinit_uefi+0xfa>

      case 4:
        non_mask_intr = (struct uefi_non_maskable_intr *)entry_type;
801081ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
801081cd:	89 45 ec             	mov    %eax,-0x14(%ebp)
        i += non_mask_intr->record_len;
801081d0:	8b 45 ec             	mov    -0x14(%ebp),%eax
801081d3:	0f b6 40 01          	movzbl 0x1(%eax),%eax
801081d7:	0f b6 c0             	movzbl %al,%eax
801081da:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
801081dd:	eb 05                	jmp    801081e4 <mpinit_uefi+0xfa>

      case 5:
        i = i + 0xC;
801081df:	83 45 fc 0c          	addl   $0xc,-0x4(%ebp)
        break;
801081e3:	90                   	nop
  while(i<madt->len){
801081e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081e7:	8b 40 04             	mov    0x4(%eax),%eax
801081ea:	39 45 fc             	cmp    %eax,-0x4(%ebp)
801081ed:	0f 82 34 ff ff ff    	jb     80108127 <mpinit_uefi+0x3d>
    }
  }

}
801081f3:	90                   	nop
801081f4:	90                   	nop
801081f5:	c9                   	leave  
801081f6:	c3                   	ret    

801081f7 <inb>:
{
801081f7:	55                   	push   %ebp
801081f8:	89 e5                	mov    %esp,%ebp
801081fa:	83 ec 14             	sub    $0x14,%esp
801081fd:	8b 45 08             	mov    0x8(%ebp),%eax
80108200:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80108204:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80108208:	89 c2                	mov    %eax,%edx
8010820a:	ec                   	in     (%dx),%al
8010820b:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
8010820e:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80108212:	c9                   	leave  
80108213:	c3                   	ret    

80108214 <outb>:
{
80108214:	55                   	push   %ebp
80108215:	89 e5                	mov    %esp,%ebp
80108217:	83 ec 08             	sub    $0x8,%esp
8010821a:	8b 45 08             	mov    0x8(%ebp),%eax
8010821d:	8b 55 0c             	mov    0xc(%ebp),%edx
80108220:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80108224:	89 d0                	mov    %edx,%eax
80108226:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80108229:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
8010822d:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80108231:	ee                   	out    %al,(%dx)
}
80108232:	90                   	nop
80108233:	c9                   	leave  
80108234:	c3                   	ret    

80108235 <uart_debug>:
#include "proc.h"
#include "x86.h"

#define COM1    0x3f8

void uart_debug(char p){
80108235:	55                   	push   %ebp
80108236:	89 e5                	mov    %esp,%ebp
80108238:	83 ec 28             	sub    $0x28,%esp
8010823b:	8b 45 08             	mov    0x8(%ebp),%eax
8010823e:	88 45 e4             	mov    %al,-0x1c(%ebp)
    // Turn off the FIFO
  outb(COM1+2, 0);
80108241:	6a 00                	push   $0x0
80108243:	68 fa 03 00 00       	push   $0x3fa
80108248:	e8 c7 ff ff ff       	call   80108214 <outb>
8010824d:	83 c4 08             	add    $0x8,%esp

  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
80108250:	68 80 00 00 00       	push   $0x80
80108255:	68 fb 03 00 00       	push   $0x3fb
8010825a:	e8 b5 ff ff ff       	call   80108214 <outb>
8010825f:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
80108262:	6a 0c                	push   $0xc
80108264:	68 f8 03 00 00       	push   $0x3f8
80108269:	e8 a6 ff ff ff       	call   80108214 <outb>
8010826e:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
80108271:	6a 00                	push   $0x0
80108273:	68 f9 03 00 00       	push   $0x3f9
80108278:	e8 97 ff ff ff       	call   80108214 <outb>
8010827d:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
80108280:	6a 03                	push   $0x3
80108282:	68 fb 03 00 00       	push   $0x3fb
80108287:	e8 88 ff ff ff       	call   80108214 <outb>
8010828c:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
8010828f:	6a 00                	push   $0x0
80108291:	68 fc 03 00 00       	push   $0x3fc
80108296:	e8 79 ff ff ff       	call   80108214 <outb>
8010829b:	83 c4 08             	add    $0x8,%esp

  for(int i=0;i<128 && !(inb(COM1+5) & 0x20); i++) microdelay(10);
8010829e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801082a5:	eb 11                	jmp    801082b8 <uart_debug+0x83>
801082a7:	83 ec 0c             	sub    $0xc,%esp
801082aa:	6a 0a                	push   $0xa
801082ac:	e8 6a ad ff ff       	call   8010301b <microdelay>
801082b1:	83 c4 10             	add    $0x10,%esp
801082b4:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801082b8:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
801082bc:	7f 1a                	jg     801082d8 <uart_debug+0xa3>
801082be:	83 ec 0c             	sub    $0xc,%esp
801082c1:	68 fd 03 00 00       	push   $0x3fd
801082c6:	e8 2c ff ff ff       	call   801081f7 <inb>
801082cb:	83 c4 10             	add    $0x10,%esp
801082ce:	0f b6 c0             	movzbl %al,%eax
801082d1:	83 e0 20             	and    $0x20,%eax
801082d4:	85 c0                	test   %eax,%eax
801082d6:	74 cf                	je     801082a7 <uart_debug+0x72>
  outb(COM1+0, p);
801082d8:	0f b6 45 e4          	movzbl -0x1c(%ebp),%eax
801082dc:	0f b6 c0             	movzbl %al,%eax
801082df:	83 ec 08             	sub    $0x8,%esp
801082e2:	50                   	push   %eax
801082e3:	68 f8 03 00 00       	push   $0x3f8
801082e8:	e8 27 ff ff ff       	call   80108214 <outb>
801082ed:	83 c4 10             	add    $0x10,%esp
}
801082f0:	90                   	nop
801082f1:	c9                   	leave  
801082f2:	c3                   	ret    

801082f3 <uart_debugs>:

void uart_debugs(char *p){
801082f3:	55                   	push   %ebp
801082f4:	89 e5                	mov    %esp,%ebp
801082f6:	83 ec 08             	sub    $0x8,%esp
  while(*p){
801082f9:	eb 1b                	jmp    80108316 <uart_debugs+0x23>
    uart_debug(*p++);
801082fb:	8b 45 08             	mov    0x8(%ebp),%eax
801082fe:	8d 50 01             	lea    0x1(%eax),%edx
80108301:	89 55 08             	mov    %edx,0x8(%ebp)
80108304:	0f b6 00             	movzbl (%eax),%eax
80108307:	0f be c0             	movsbl %al,%eax
8010830a:	83 ec 0c             	sub    $0xc,%esp
8010830d:	50                   	push   %eax
8010830e:	e8 22 ff ff ff       	call   80108235 <uart_debug>
80108313:	83 c4 10             	add    $0x10,%esp
  while(*p){
80108316:	8b 45 08             	mov    0x8(%ebp),%eax
80108319:	0f b6 00             	movzbl (%eax),%eax
8010831c:	84 c0                	test   %al,%al
8010831e:	75 db                	jne    801082fb <uart_debugs+0x8>
  }
}
80108320:	90                   	nop
80108321:	90                   	nop
80108322:	c9                   	leave  
80108323:	c3                   	ret    

80108324 <graphic_init>:
 * i%4 = 2 : red
 * i%4 = 3 : black
 */

struct gpu gpu;
void graphic_init(){
80108324:	55                   	push   %ebp
80108325:	89 e5                	mov    %esp,%ebp
80108327:	83 ec 10             	sub    $0x10,%esp
  struct boot_param *boot_param = (struct boot_param *)P2V_WO(BOOTPARAM);
8010832a:	c7 45 fc 00 00 05 80 	movl   $0x80050000,-0x4(%ebp)
  gpu.pvram_addr = boot_param->graphic_config.frame_base;
80108331:	8b 45 fc             	mov    -0x4(%ebp),%eax
80108334:	8b 50 14             	mov    0x14(%eax),%edx
80108337:	8b 40 10             	mov    0x10(%eax),%eax
8010833a:	a3 88 9e 11 80       	mov    %eax,0x80119e88
  gpu.vram_size = boot_param->graphic_config.frame_size;
8010833f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80108342:	8b 50 1c             	mov    0x1c(%eax),%edx
80108345:	8b 40 18             	mov    0x18(%eax),%eax
80108348:	a3 90 9e 11 80       	mov    %eax,0x80119e90
  gpu.vvram_addr = DEVSPACE - gpu.vram_size;
8010834d:	8b 15 90 9e 11 80    	mov    0x80119e90,%edx
80108353:	b8 00 00 00 fe       	mov    $0xfe000000,%eax
80108358:	29 d0                	sub    %edx,%eax
8010835a:	a3 8c 9e 11 80       	mov    %eax,0x80119e8c
  gpu.horizontal_resolution = (uint)(boot_param->graphic_config.horizontal_resolution & 0xFFFFFFFF);
8010835f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80108362:	8b 50 24             	mov    0x24(%eax),%edx
80108365:	8b 40 20             	mov    0x20(%eax),%eax
80108368:	a3 94 9e 11 80       	mov    %eax,0x80119e94
  gpu.vertical_resolution = (uint)(boot_param->graphic_config.vertical_resolution & 0xFFFFFFFF);
8010836d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80108370:	8b 50 2c             	mov    0x2c(%eax),%edx
80108373:	8b 40 28             	mov    0x28(%eax),%eax
80108376:	a3 98 9e 11 80       	mov    %eax,0x80119e98
  gpu.pixels_per_line = (uint)(boot_param->graphic_config.pixels_per_line & 0xFFFFFFFF);
8010837b:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010837e:	8b 50 34             	mov    0x34(%eax),%edx
80108381:	8b 40 30             	mov    0x30(%eax),%eax
80108384:	a3 9c 9e 11 80       	mov    %eax,0x80119e9c
}
80108389:	90                   	nop
8010838a:	c9                   	leave  
8010838b:	c3                   	ret    

8010838c <graphic_draw_pixel>:

void graphic_draw_pixel(int x,int y,struct graphic_pixel * buffer){
8010838c:	55                   	push   %ebp
8010838d:	89 e5                	mov    %esp,%ebp
8010838f:	83 ec 10             	sub    $0x10,%esp
  int pixel_addr = (sizeof(struct graphic_pixel))*(y*gpu.pixels_per_line + x);
80108392:	8b 15 9c 9e 11 80    	mov    0x80119e9c,%edx
80108398:	8b 45 0c             	mov    0xc(%ebp),%eax
8010839b:	0f af d0             	imul   %eax,%edx
8010839e:	8b 45 08             	mov    0x8(%ebp),%eax
801083a1:	01 d0                	add    %edx,%eax
801083a3:	c1 e0 02             	shl    $0x2,%eax
801083a6:	89 45 fc             	mov    %eax,-0x4(%ebp)
  struct graphic_pixel *pixel = (struct graphic_pixel *)(gpu.vvram_addr + pixel_addr);
801083a9:	8b 15 8c 9e 11 80    	mov    0x80119e8c,%edx
801083af:	8b 45 fc             	mov    -0x4(%ebp),%eax
801083b2:	01 d0                	add    %edx,%eax
801083b4:	89 45 f8             	mov    %eax,-0x8(%ebp)
  pixel->blue = buffer->blue;
801083b7:	8b 45 10             	mov    0x10(%ebp),%eax
801083ba:	0f b6 10             	movzbl (%eax),%edx
801083bd:	8b 45 f8             	mov    -0x8(%ebp),%eax
801083c0:	88 10                	mov    %dl,(%eax)
  pixel->green = buffer->green;
801083c2:	8b 45 10             	mov    0x10(%ebp),%eax
801083c5:	0f b6 50 01          	movzbl 0x1(%eax),%edx
801083c9:	8b 45 f8             	mov    -0x8(%ebp),%eax
801083cc:	88 50 01             	mov    %dl,0x1(%eax)
  pixel->red = buffer->red;
801083cf:	8b 45 10             	mov    0x10(%ebp),%eax
801083d2:	0f b6 50 02          	movzbl 0x2(%eax),%edx
801083d6:	8b 45 f8             	mov    -0x8(%ebp),%eax
801083d9:	88 50 02             	mov    %dl,0x2(%eax)
}
801083dc:	90                   	nop
801083dd:	c9                   	leave  
801083de:	c3                   	ret    

801083df <graphic_scroll_up>:

void graphic_scroll_up(int height){
801083df:	55                   	push   %ebp
801083e0:	89 e5                	mov    %esp,%ebp
801083e2:	83 ec 18             	sub    $0x18,%esp
  int addr_diff = (sizeof(struct graphic_pixel))*gpu.pixels_per_line*height;
801083e5:	8b 15 9c 9e 11 80    	mov    0x80119e9c,%edx
801083eb:	8b 45 08             	mov    0x8(%ebp),%eax
801083ee:	0f af c2             	imul   %edx,%eax
801083f1:	c1 e0 02             	shl    $0x2,%eax
801083f4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove((unsigned int *)gpu.vvram_addr,(unsigned int *)(gpu.vvram_addr + addr_diff),gpu.vram_size - addr_diff);
801083f7:	a1 90 9e 11 80       	mov    0x80119e90,%eax
801083fc:	8b 55 f4             	mov    -0xc(%ebp),%edx
801083ff:	29 d0                	sub    %edx,%eax
80108401:	8b 0d 8c 9e 11 80    	mov    0x80119e8c,%ecx
80108407:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010840a:	01 ca                	add    %ecx,%edx
8010840c:	89 d1                	mov    %edx,%ecx
8010840e:	8b 15 8c 9e 11 80    	mov    0x80119e8c,%edx
80108414:	83 ec 04             	sub    $0x4,%esp
80108417:	50                   	push   %eax
80108418:	51                   	push   %ecx
80108419:	52                   	push   %edx
8010841a:	e8 03 cb ff ff       	call   80104f22 <memmove>
8010841f:	83 c4 10             	add    $0x10,%esp
  memset((unsigned int *)(gpu.vvram_addr + gpu.vram_size - addr_diff),0,addr_diff);
80108422:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108425:	8b 0d 8c 9e 11 80    	mov    0x80119e8c,%ecx
8010842b:	8b 15 90 9e 11 80    	mov    0x80119e90,%edx
80108431:	01 ca                	add    %ecx,%edx
80108433:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80108436:	29 ca                	sub    %ecx,%edx
80108438:	83 ec 04             	sub    $0x4,%esp
8010843b:	50                   	push   %eax
8010843c:	6a 00                	push   $0x0
8010843e:	52                   	push   %edx
8010843f:	e8 1f ca ff ff       	call   80104e63 <memset>
80108444:	83 c4 10             	add    $0x10,%esp
}
80108447:	90                   	nop
80108448:	c9                   	leave  
80108449:	c3                   	ret    

8010844a <font_render>:
#include "font.h"


struct graphic_pixel black_pixel = {0x0,0x0,0x0,0x0};
struct graphic_pixel white_pixel = {0xFF,0xFF,0xFF,0x0};
void font_render(int x,int y,int index){
8010844a:	55                   	push   %ebp
8010844b:	89 e5                	mov    %esp,%ebp
8010844d:	53                   	push   %ebx
8010844e:	83 ec 14             	sub    $0x14,%esp
  int bin;
  for(int i=0;i<30;i++){
80108451:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108458:	e9 b1 00 00 00       	jmp    8010850e <font_render+0xc4>
    for(int j=14;j>-1;j--){
8010845d:	c7 45 f0 0e 00 00 00 	movl   $0xe,-0x10(%ebp)
80108464:	e9 97 00 00 00       	jmp    80108500 <font_render+0xb6>
      bin = (font_bin[index-0x20][i])&(1 << j);
80108469:	8b 45 10             	mov    0x10(%ebp),%eax
8010846c:	83 e8 20             	sub    $0x20,%eax
8010846f:	6b d0 1e             	imul   $0x1e,%eax,%edx
80108472:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108475:	01 d0                	add    %edx,%eax
80108477:	0f b7 84 00 c0 ab 10 	movzwl -0x7fef5440(%eax,%eax,1),%eax
8010847e:	80 
8010847f:	0f b7 d0             	movzwl %ax,%edx
80108482:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108485:	bb 01 00 00 00       	mov    $0x1,%ebx
8010848a:	89 c1                	mov    %eax,%ecx
8010848c:	d3 e3                	shl    %cl,%ebx
8010848e:	89 d8                	mov    %ebx,%eax
80108490:	21 d0                	and    %edx,%eax
80108492:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(bin == (1 << j)){
80108495:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108498:	ba 01 00 00 00       	mov    $0x1,%edx
8010849d:	89 c1                	mov    %eax,%ecx
8010849f:	d3 e2                	shl    %cl,%edx
801084a1:	89 d0                	mov    %edx,%eax
801084a3:	39 45 ec             	cmp    %eax,-0x14(%ebp)
801084a6:	75 2b                	jne    801084d3 <font_render+0x89>
        graphic_draw_pixel(x+(14-j),y+i,&white_pixel);
801084a8:	8b 55 0c             	mov    0xc(%ebp),%edx
801084ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084ae:	01 c2                	add    %eax,%edx
801084b0:	b8 0e 00 00 00       	mov    $0xe,%eax
801084b5:	2b 45 f0             	sub    -0x10(%ebp),%eax
801084b8:	89 c1                	mov    %eax,%ecx
801084ba:	8b 45 08             	mov    0x8(%ebp),%eax
801084bd:	01 c8                	add    %ecx,%eax
801084bf:	83 ec 04             	sub    $0x4,%esp
801084c2:	68 e0 f4 10 80       	push   $0x8010f4e0
801084c7:	52                   	push   %edx
801084c8:	50                   	push   %eax
801084c9:	e8 be fe ff ff       	call   8010838c <graphic_draw_pixel>
801084ce:	83 c4 10             	add    $0x10,%esp
801084d1:	eb 29                	jmp    801084fc <font_render+0xb2>
      } else {
        graphic_draw_pixel(x+(14-j),y+i,&black_pixel);
801084d3:	8b 55 0c             	mov    0xc(%ebp),%edx
801084d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084d9:	01 c2                	add    %eax,%edx
801084db:	b8 0e 00 00 00       	mov    $0xe,%eax
801084e0:	2b 45 f0             	sub    -0x10(%ebp),%eax
801084e3:	89 c1                	mov    %eax,%ecx
801084e5:	8b 45 08             	mov    0x8(%ebp),%eax
801084e8:	01 c8                	add    %ecx,%eax
801084ea:	83 ec 04             	sub    $0x4,%esp
801084ed:	68 a0 9e 11 80       	push   $0x80119ea0
801084f2:	52                   	push   %edx
801084f3:	50                   	push   %eax
801084f4:	e8 93 fe ff ff       	call   8010838c <graphic_draw_pixel>
801084f9:	83 c4 10             	add    $0x10,%esp
    for(int j=14;j>-1;j--){
801084fc:	83 6d f0 01          	subl   $0x1,-0x10(%ebp)
80108500:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108504:	0f 89 5f ff ff ff    	jns    80108469 <font_render+0x1f>
  for(int i=0;i<30;i++){
8010850a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010850e:	83 7d f4 1d          	cmpl   $0x1d,-0xc(%ebp)
80108512:	0f 8e 45 ff ff ff    	jle    8010845d <font_render+0x13>
      }
    }
  }
}
80108518:	90                   	nop
80108519:	90                   	nop
8010851a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010851d:	c9                   	leave  
8010851e:	c3                   	ret    

8010851f <font_render_string>:

void font_render_string(char *string,int row){
8010851f:	55                   	push   %ebp
80108520:	89 e5                	mov    %esp,%ebp
80108522:	53                   	push   %ebx
80108523:	83 ec 14             	sub    $0x14,%esp
  int i = 0;
80108526:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  while(string[i] && i < 52){
8010852d:	eb 33                	jmp    80108562 <font_render_string+0x43>
    font_render(i*15+2,row*30,string[i]);
8010852f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108532:	8b 45 08             	mov    0x8(%ebp),%eax
80108535:	01 d0                	add    %edx,%eax
80108537:	0f b6 00             	movzbl (%eax),%eax
8010853a:	0f be c8             	movsbl %al,%ecx
8010853d:	8b 45 0c             	mov    0xc(%ebp),%eax
80108540:	6b d0 1e             	imul   $0x1e,%eax,%edx
80108543:	8b 5d f4             	mov    -0xc(%ebp),%ebx
80108546:	89 d8                	mov    %ebx,%eax
80108548:	c1 e0 04             	shl    $0x4,%eax
8010854b:	29 d8                	sub    %ebx,%eax
8010854d:	83 c0 02             	add    $0x2,%eax
80108550:	83 ec 04             	sub    $0x4,%esp
80108553:	51                   	push   %ecx
80108554:	52                   	push   %edx
80108555:	50                   	push   %eax
80108556:	e8 ef fe ff ff       	call   8010844a <font_render>
8010855b:	83 c4 10             	add    $0x10,%esp
    i++;
8010855e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  while(string[i] && i < 52){
80108562:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108565:	8b 45 08             	mov    0x8(%ebp),%eax
80108568:	01 d0                	add    %edx,%eax
8010856a:	0f b6 00             	movzbl (%eax),%eax
8010856d:	84 c0                	test   %al,%al
8010856f:	74 06                	je     80108577 <font_render_string+0x58>
80108571:	83 7d f4 33          	cmpl   $0x33,-0xc(%ebp)
80108575:	7e b8                	jle    8010852f <font_render_string+0x10>
  }
}
80108577:	90                   	nop
80108578:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010857b:	c9                   	leave  
8010857c:	c3                   	ret    

8010857d <pci_init>:
#include "pci.h"
#include "defs.h"
#include "types.h"
#include "i8254.h"

void pci_init(){
8010857d:	55                   	push   %ebp
8010857e:	89 e5                	mov    %esp,%ebp
80108580:	53                   	push   %ebx
80108581:	83 ec 14             	sub    $0x14,%esp
  uint data;
  for(int i=0;i<256;i++){
80108584:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010858b:	eb 6b                	jmp    801085f8 <pci_init+0x7b>
    for(int j=0;j<32;j++){
8010858d:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80108594:	eb 58                	jmp    801085ee <pci_init+0x71>
      for(int k=0;k<8;k++){
80108596:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
8010859d:	eb 45                	jmp    801085e4 <pci_init+0x67>
      pci_access_config(i,j,k,0,&data);
8010859f:	8b 4d ec             	mov    -0x14(%ebp),%ecx
801085a2:	8b 55 f0             	mov    -0x10(%ebp),%edx
801085a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085a8:	83 ec 0c             	sub    $0xc,%esp
801085ab:	8d 5d e8             	lea    -0x18(%ebp),%ebx
801085ae:	53                   	push   %ebx
801085af:	6a 00                	push   $0x0
801085b1:	51                   	push   %ecx
801085b2:	52                   	push   %edx
801085b3:	50                   	push   %eax
801085b4:	e8 b0 00 00 00       	call   80108669 <pci_access_config>
801085b9:	83 c4 20             	add    $0x20,%esp
      if((data&0xFFFF) != 0xFFFF){
801085bc:	8b 45 e8             	mov    -0x18(%ebp),%eax
801085bf:	0f b7 c0             	movzwl %ax,%eax
801085c2:	3d ff ff 00 00       	cmp    $0xffff,%eax
801085c7:	74 17                	je     801085e0 <pci_init+0x63>
        pci_init_device(i,j,k);
801085c9:	8b 4d ec             	mov    -0x14(%ebp),%ecx
801085cc:	8b 55 f0             	mov    -0x10(%ebp),%edx
801085cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085d2:	83 ec 04             	sub    $0x4,%esp
801085d5:	51                   	push   %ecx
801085d6:	52                   	push   %edx
801085d7:	50                   	push   %eax
801085d8:	e8 37 01 00 00       	call   80108714 <pci_init_device>
801085dd:	83 c4 10             	add    $0x10,%esp
      for(int k=0;k<8;k++){
801085e0:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
801085e4:	83 7d ec 07          	cmpl   $0x7,-0x14(%ebp)
801085e8:	7e b5                	jle    8010859f <pci_init+0x22>
    for(int j=0;j<32;j++){
801085ea:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
801085ee:	83 7d f0 1f          	cmpl   $0x1f,-0x10(%ebp)
801085f2:	7e a2                	jle    80108596 <pci_init+0x19>
  for(int i=0;i<256;i++){
801085f4:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801085f8:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
801085ff:	7e 8c                	jle    8010858d <pci_init+0x10>
      }
      }
    }
  }
}
80108601:	90                   	nop
80108602:	90                   	nop
80108603:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108606:	c9                   	leave  
80108607:	c3                   	ret    

80108608 <pci_write_config>:

void pci_write_config(uint config){
80108608:	55                   	push   %ebp
80108609:	89 e5                	mov    %esp,%ebp
  asm("mov $0xCF8,%%edx\n\t"
8010860b:	8b 45 08             	mov    0x8(%ebp),%eax
8010860e:	ba f8 0c 00 00       	mov    $0xcf8,%edx
80108613:	89 c0                	mov    %eax,%eax
80108615:	ef                   	out    %eax,(%dx)
      "mov %0,%%eax\n\t"
      "out %%eax,%%dx\n\t"
      : :"r"(config));
}
80108616:	90                   	nop
80108617:	5d                   	pop    %ebp
80108618:	c3                   	ret    

80108619 <pci_write_data>:

void pci_write_data(uint config){
80108619:	55                   	push   %ebp
8010861a:	89 e5                	mov    %esp,%ebp
  asm("mov $0xCFC,%%edx\n\t"
8010861c:	8b 45 08             	mov    0x8(%ebp),%eax
8010861f:	ba fc 0c 00 00       	mov    $0xcfc,%edx
80108624:	89 c0                	mov    %eax,%eax
80108626:	ef                   	out    %eax,(%dx)
      "mov %0,%%eax\n\t"
      "out %%eax,%%dx\n\t"
      : :"r"(config));
}
80108627:	90                   	nop
80108628:	5d                   	pop    %ebp
80108629:	c3                   	ret    

8010862a <pci_read_config>:
uint pci_read_config(){
8010862a:	55                   	push   %ebp
8010862b:	89 e5                	mov    %esp,%ebp
8010862d:	83 ec 18             	sub    $0x18,%esp
  uint data;
  asm("mov $0xCFC,%%edx\n\t"
80108630:	ba fc 0c 00 00       	mov    $0xcfc,%edx
80108635:	ed                   	in     (%dx),%eax
80108636:	89 45 f4             	mov    %eax,-0xc(%ebp)
      "in %%dx,%%eax\n\t"
      "mov %%eax,%0"
      :"=m"(data):);
  microdelay(200);
80108639:	83 ec 0c             	sub    $0xc,%esp
8010863c:	68 c8 00 00 00       	push   $0xc8
80108641:	e8 d5 a9 ff ff       	call   8010301b <microdelay>
80108646:	83 c4 10             	add    $0x10,%esp
  return data;
80108649:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010864c:	c9                   	leave  
8010864d:	c3                   	ret    

8010864e <pci_test>:


void pci_test(){
8010864e:	55                   	push   %ebp
8010864f:	89 e5                	mov    %esp,%ebp
80108651:	83 ec 10             	sub    $0x10,%esp
  uint data = 0x80001804;
80108654:	c7 45 fc 04 18 00 80 	movl   $0x80001804,-0x4(%ebp)
  pci_write_config(data);
8010865b:	ff 75 fc             	push   -0x4(%ebp)
8010865e:	e8 a5 ff ff ff       	call   80108608 <pci_write_config>
80108663:	83 c4 04             	add    $0x4,%esp
}
80108666:	90                   	nop
80108667:	c9                   	leave  
80108668:	c3                   	ret    

80108669 <pci_access_config>:

void pci_access_config(uint bus_num,uint device_num,uint function_num,uint reg_addr,uint *data){
80108669:	55                   	push   %ebp
8010866a:	89 e5                	mov    %esp,%ebp
8010866c:	83 ec 18             	sub    $0x18,%esp
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
8010866f:	8b 45 08             	mov    0x8(%ebp),%eax
80108672:	c1 e0 10             	shl    $0x10,%eax
80108675:	25 00 00 ff 00       	and    $0xff0000,%eax
8010867a:	89 c2                	mov    %eax,%edx
8010867c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010867f:	c1 e0 0b             	shl    $0xb,%eax
80108682:	0f b7 c0             	movzwl %ax,%eax
80108685:	09 c2                	or     %eax,%edx
80108687:	8b 45 10             	mov    0x10(%ebp),%eax
8010868a:	c1 e0 08             	shl    $0x8,%eax
8010868d:	25 00 07 00 00       	and    $0x700,%eax
80108692:	09 c2                	or     %eax,%edx
    (reg_addr & 0xFC) | 0x80000000;
80108694:	8b 45 14             	mov    0x14(%ebp),%eax
80108697:	25 fc 00 00 00       	and    $0xfc,%eax
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
8010869c:	09 d0                	or     %edx,%eax
8010869e:	0d 00 00 00 80       	or     $0x80000000,%eax
801086a3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  pci_write_config(config_addr);
801086a6:	ff 75 f4             	push   -0xc(%ebp)
801086a9:	e8 5a ff ff ff       	call   80108608 <pci_write_config>
801086ae:	83 c4 04             	add    $0x4,%esp
  *data = pci_read_config();
801086b1:	e8 74 ff ff ff       	call   8010862a <pci_read_config>
801086b6:	8b 55 18             	mov    0x18(%ebp),%edx
801086b9:	89 02                	mov    %eax,(%edx)
}
801086bb:	90                   	nop
801086bc:	c9                   	leave  
801086bd:	c3                   	ret    

801086be <pci_write_config_register>:

void pci_write_config_register(uint bus_num,uint device_num,uint function_num,uint reg_addr,uint data){
801086be:	55                   	push   %ebp
801086bf:	89 e5                	mov    %esp,%ebp
801086c1:	83 ec 10             	sub    $0x10,%esp
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
801086c4:	8b 45 08             	mov    0x8(%ebp),%eax
801086c7:	c1 e0 10             	shl    $0x10,%eax
801086ca:	25 00 00 ff 00       	and    $0xff0000,%eax
801086cf:	89 c2                	mov    %eax,%edx
801086d1:	8b 45 0c             	mov    0xc(%ebp),%eax
801086d4:	c1 e0 0b             	shl    $0xb,%eax
801086d7:	0f b7 c0             	movzwl %ax,%eax
801086da:	09 c2                	or     %eax,%edx
801086dc:	8b 45 10             	mov    0x10(%ebp),%eax
801086df:	c1 e0 08             	shl    $0x8,%eax
801086e2:	25 00 07 00 00       	and    $0x700,%eax
801086e7:	09 c2                	or     %eax,%edx
    (reg_addr & 0xFC) | 0x80000000;
801086e9:	8b 45 14             	mov    0x14(%ebp),%eax
801086ec:	25 fc 00 00 00       	and    $0xfc,%eax
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
801086f1:	09 d0                	or     %edx,%eax
801086f3:	0d 00 00 00 80       	or     $0x80000000,%eax
801086f8:	89 45 fc             	mov    %eax,-0x4(%ebp)
  pci_write_config(config_addr);
801086fb:	ff 75 fc             	push   -0x4(%ebp)
801086fe:	e8 05 ff ff ff       	call   80108608 <pci_write_config>
80108703:	83 c4 04             	add    $0x4,%esp
  pci_write_data(data);
80108706:	ff 75 18             	push   0x18(%ebp)
80108709:	e8 0b ff ff ff       	call   80108619 <pci_write_data>
8010870e:	83 c4 04             	add    $0x4,%esp
}
80108711:	90                   	nop
80108712:	c9                   	leave  
80108713:	c3                   	ret    

80108714 <pci_init_device>:

struct pci_dev dev;
void pci_init_device(uint bus_num,uint device_num,uint function_num){
80108714:	55                   	push   %ebp
80108715:	89 e5                	mov    %esp,%ebp
80108717:	53                   	push   %ebx
80108718:	83 ec 14             	sub    $0x14,%esp
  uint data;
  dev.bus_num = bus_num;
8010871b:	8b 45 08             	mov    0x8(%ebp),%eax
8010871e:	a2 a4 9e 11 80       	mov    %al,0x80119ea4
  dev.device_num = device_num;
80108723:	8b 45 0c             	mov    0xc(%ebp),%eax
80108726:	a2 a5 9e 11 80       	mov    %al,0x80119ea5
  dev.function_num = function_num;
8010872b:	8b 45 10             	mov    0x10(%ebp),%eax
8010872e:	a2 a6 9e 11 80       	mov    %al,0x80119ea6
  cprintf("PCI Device Found Bus:0x%x Device:0x%x Function:%x\n",bus_num,device_num,function_num);
80108733:	ff 75 10             	push   0x10(%ebp)
80108736:	ff 75 0c             	push   0xc(%ebp)
80108739:	ff 75 08             	push   0x8(%ebp)
8010873c:	68 04 c2 10 80       	push   $0x8010c204
80108741:	e8 ae 7c ff ff       	call   801003f4 <cprintf>
80108746:	83 c4 10             	add    $0x10,%esp
  
  pci_access_config(bus_num,device_num,function_num,0,&data);
80108749:	83 ec 0c             	sub    $0xc,%esp
8010874c:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010874f:	50                   	push   %eax
80108750:	6a 00                	push   $0x0
80108752:	ff 75 10             	push   0x10(%ebp)
80108755:	ff 75 0c             	push   0xc(%ebp)
80108758:	ff 75 08             	push   0x8(%ebp)
8010875b:	e8 09 ff ff ff       	call   80108669 <pci_access_config>
80108760:	83 c4 20             	add    $0x20,%esp
  uint device_id = data>>16;
80108763:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108766:	c1 e8 10             	shr    $0x10,%eax
80108769:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint vendor_id = data&0xFFFF;
8010876c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010876f:	25 ff ff 00 00       	and    $0xffff,%eax
80108774:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dev.device_id = device_id;
80108777:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010877a:	a3 a8 9e 11 80       	mov    %eax,0x80119ea8
  dev.vendor_id = vendor_id;
8010877f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108782:	a3 ac 9e 11 80       	mov    %eax,0x80119eac
  cprintf("  Device ID:0x%x  Vendor ID:0x%x\n",device_id,vendor_id);
80108787:	83 ec 04             	sub    $0x4,%esp
8010878a:	ff 75 f0             	push   -0x10(%ebp)
8010878d:	ff 75 f4             	push   -0xc(%ebp)
80108790:	68 38 c2 10 80       	push   $0x8010c238
80108795:	e8 5a 7c ff ff       	call   801003f4 <cprintf>
8010879a:	83 c4 10             	add    $0x10,%esp
  
  pci_access_config(bus_num,device_num,function_num,0x8,&data);
8010879d:	83 ec 0c             	sub    $0xc,%esp
801087a0:	8d 45 ec             	lea    -0x14(%ebp),%eax
801087a3:	50                   	push   %eax
801087a4:	6a 08                	push   $0x8
801087a6:	ff 75 10             	push   0x10(%ebp)
801087a9:	ff 75 0c             	push   0xc(%ebp)
801087ac:	ff 75 08             	push   0x8(%ebp)
801087af:	e8 b5 fe ff ff       	call   80108669 <pci_access_config>
801087b4:	83 c4 20             	add    $0x20,%esp
  cprintf("  Base Class:0x%x  Sub Class:0x%x  Interface:0x%x  Revision ID:0x%x\n",
801087b7:	8b 45 ec             	mov    -0x14(%ebp),%eax
801087ba:	0f b6 c8             	movzbl %al,%ecx
      data>>24,(data>>16)&0xFF,(data>>8)&0xFF,data&0xFF);
801087bd:	8b 45 ec             	mov    -0x14(%ebp),%eax
801087c0:	c1 e8 08             	shr    $0x8,%eax
  cprintf("  Base Class:0x%x  Sub Class:0x%x  Interface:0x%x  Revision ID:0x%x\n",
801087c3:	0f b6 d0             	movzbl %al,%edx
      data>>24,(data>>16)&0xFF,(data>>8)&0xFF,data&0xFF);
801087c6:	8b 45 ec             	mov    -0x14(%ebp),%eax
801087c9:	c1 e8 10             	shr    $0x10,%eax
  cprintf("  Base Class:0x%x  Sub Class:0x%x  Interface:0x%x  Revision ID:0x%x\n",
801087cc:	0f b6 c0             	movzbl %al,%eax
801087cf:	8b 5d ec             	mov    -0x14(%ebp),%ebx
801087d2:	c1 eb 18             	shr    $0x18,%ebx
801087d5:	83 ec 0c             	sub    $0xc,%esp
801087d8:	51                   	push   %ecx
801087d9:	52                   	push   %edx
801087da:	50                   	push   %eax
801087db:	53                   	push   %ebx
801087dc:	68 5c c2 10 80       	push   $0x8010c25c
801087e1:	e8 0e 7c ff ff       	call   801003f4 <cprintf>
801087e6:	83 c4 20             	add    $0x20,%esp
  dev.base_class = data>>24;
801087e9:	8b 45 ec             	mov    -0x14(%ebp),%eax
801087ec:	c1 e8 18             	shr    $0x18,%eax
801087ef:	a2 b0 9e 11 80       	mov    %al,0x80119eb0
  dev.sub_class = (data>>16)&0xFF;
801087f4:	8b 45 ec             	mov    -0x14(%ebp),%eax
801087f7:	c1 e8 10             	shr    $0x10,%eax
801087fa:	a2 b1 9e 11 80       	mov    %al,0x80119eb1
  dev.interface = (data>>8)&0xFF;
801087ff:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108802:	c1 e8 08             	shr    $0x8,%eax
80108805:	a2 b2 9e 11 80       	mov    %al,0x80119eb2
  dev.revision_id = data&0xFF;
8010880a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010880d:	a2 b3 9e 11 80       	mov    %al,0x80119eb3
  
  pci_access_config(bus_num,device_num,function_num,0x10,&data);
80108812:	83 ec 0c             	sub    $0xc,%esp
80108815:	8d 45 ec             	lea    -0x14(%ebp),%eax
80108818:	50                   	push   %eax
80108819:	6a 10                	push   $0x10
8010881b:	ff 75 10             	push   0x10(%ebp)
8010881e:	ff 75 0c             	push   0xc(%ebp)
80108821:	ff 75 08             	push   0x8(%ebp)
80108824:	e8 40 fe ff ff       	call   80108669 <pci_access_config>
80108829:	83 c4 20             	add    $0x20,%esp
  dev.bar0 = data;
8010882c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010882f:	a3 b4 9e 11 80       	mov    %eax,0x80119eb4
  pci_access_config(bus_num,device_num,function_num,0x14,&data);
80108834:	83 ec 0c             	sub    $0xc,%esp
80108837:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010883a:	50                   	push   %eax
8010883b:	6a 14                	push   $0x14
8010883d:	ff 75 10             	push   0x10(%ebp)
80108840:	ff 75 0c             	push   0xc(%ebp)
80108843:	ff 75 08             	push   0x8(%ebp)
80108846:	e8 1e fe ff ff       	call   80108669 <pci_access_config>
8010884b:	83 c4 20             	add    $0x20,%esp
  dev.bar1 = data;
8010884e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108851:	a3 b8 9e 11 80       	mov    %eax,0x80119eb8
  if(device_id == I8254_DEVICE_ID && vendor_id == I8254_VENDOR_ID){
80108856:	81 7d f4 0e 10 00 00 	cmpl   $0x100e,-0xc(%ebp)
8010885d:	75 5a                	jne    801088b9 <pci_init_device+0x1a5>
8010885f:	81 7d f0 86 80 00 00 	cmpl   $0x8086,-0x10(%ebp)
80108866:	75 51                	jne    801088b9 <pci_init_device+0x1a5>
    cprintf("E1000 Ethernet NIC Found\n");
80108868:	83 ec 0c             	sub    $0xc,%esp
8010886b:	68 a1 c2 10 80       	push   $0x8010c2a1
80108870:	e8 7f 7b ff ff       	call   801003f4 <cprintf>
80108875:	83 c4 10             	add    $0x10,%esp
    pci_access_config(bus_num,device_num,function_num,0xF0,&data);
80108878:	83 ec 0c             	sub    $0xc,%esp
8010887b:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010887e:	50                   	push   %eax
8010887f:	68 f0 00 00 00       	push   $0xf0
80108884:	ff 75 10             	push   0x10(%ebp)
80108887:	ff 75 0c             	push   0xc(%ebp)
8010888a:	ff 75 08             	push   0x8(%ebp)
8010888d:	e8 d7 fd ff ff       	call   80108669 <pci_access_config>
80108892:	83 c4 20             	add    $0x20,%esp
    cprintf("Message Control:%x\n",data);
80108895:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108898:	83 ec 08             	sub    $0x8,%esp
8010889b:	50                   	push   %eax
8010889c:	68 bb c2 10 80       	push   $0x8010c2bb
801088a1:	e8 4e 7b ff ff       	call   801003f4 <cprintf>
801088a6:	83 c4 10             	add    $0x10,%esp
    i8254_init(&dev);
801088a9:	83 ec 0c             	sub    $0xc,%esp
801088ac:	68 a4 9e 11 80       	push   $0x80119ea4
801088b1:	e8 09 00 00 00       	call   801088bf <i8254_init>
801088b6:	83 c4 10             	add    $0x10,%esp
  }
}
801088b9:	90                   	nop
801088ba:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801088bd:	c9                   	leave  
801088be:	c3                   	ret    

801088bf <i8254_init>:

uint base_addr;
uchar mac_addr[6] = {0};
uchar my_ip[4] = {10,0,1,10}; 
uint *intr_addr;
void i8254_init(struct pci_dev *dev){
801088bf:	55                   	push   %ebp
801088c0:	89 e5                	mov    %esp,%ebp
801088c2:	53                   	push   %ebx
801088c3:	83 ec 14             	sub    $0x14,%esp
  uint cmd_reg;
  //Enable Bus Master
  pci_access_config(dev->bus_num,dev->device_num,dev->function_num,0x04,&cmd_reg);
801088c6:	8b 45 08             	mov    0x8(%ebp),%eax
801088c9:	0f b6 40 02          	movzbl 0x2(%eax),%eax
801088cd:	0f b6 c8             	movzbl %al,%ecx
801088d0:	8b 45 08             	mov    0x8(%ebp),%eax
801088d3:	0f b6 40 01          	movzbl 0x1(%eax),%eax
801088d7:	0f b6 d0             	movzbl %al,%edx
801088da:	8b 45 08             	mov    0x8(%ebp),%eax
801088dd:	0f b6 00             	movzbl (%eax),%eax
801088e0:	0f b6 c0             	movzbl %al,%eax
801088e3:	83 ec 0c             	sub    $0xc,%esp
801088e6:	8d 5d ec             	lea    -0x14(%ebp),%ebx
801088e9:	53                   	push   %ebx
801088ea:	6a 04                	push   $0x4
801088ec:	51                   	push   %ecx
801088ed:	52                   	push   %edx
801088ee:	50                   	push   %eax
801088ef:	e8 75 fd ff ff       	call   80108669 <pci_access_config>
801088f4:	83 c4 20             	add    $0x20,%esp
  cmd_reg = cmd_reg | PCI_CMD_BUS_MASTER;
801088f7:	8b 45 ec             	mov    -0x14(%ebp),%eax
801088fa:	83 c8 04             	or     $0x4,%eax
801088fd:	89 45 ec             	mov    %eax,-0x14(%ebp)
  pci_write_config_register(dev->bus_num,dev->device_num,dev->function_num,0x04,cmd_reg);
80108900:	8b 5d ec             	mov    -0x14(%ebp),%ebx
80108903:	8b 45 08             	mov    0x8(%ebp),%eax
80108906:	0f b6 40 02          	movzbl 0x2(%eax),%eax
8010890a:	0f b6 c8             	movzbl %al,%ecx
8010890d:	8b 45 08             	mov    0x8(%ebp),%eax
80108910:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80108914:	0f b6 d0             	movzbl %al,%edx
80108917:	8b 45 08             	mov    0x8(%ebp),%eax
8010891a:	0f b6 00             	movzbl (%eax),%eax
8010891d:	0f b6 c0             	movzbl %al,%eax
80108920:	83 ec 0c             	sub    $0xc,%esp
80108923:	53                   	push   %ebx
80108924:	6a 04                	push   $0x4
80108926:	51                   	push   %ecx
80108927:	52                   	push   %edx
80108928:	50                   	push   %eax
80108929:	e8 90 fd ff ff       	call   801086be <pci_write_config_register>
8010892e:	83 c4 20             	add    $0x20,%esp
  
  base_addr = PCI_P2V(dev->bar0);
80108931:	8b 45 08             	mov    0x8(%ebp),%eax
80108934:	8b 40 10             	mov    0x10(%eax),%eax
80108937:	05 00 00 00 40       	add    $0x40000000,%eax
8010893c:	a3 bc 9e 11 80       	mov    %eax,0x80119ebc
  uint *ctrl = (uint *)base_addr;
80108941:	a1 bc 9e 11 80       	mov    0x80119ebc,%eax
80108946:	89 45 f4             	mov    %eax,-0xc(%ebp)
  //Disable Interrupts
  uint *imc = (uint *)(base_addr+0xD8);
80108949:	a1 bc 9e 11 80       	mov    0x80119ebc,%eax
8010894e:	05 d8 00 00 00       	add    $0xd8,%eax
80108953:	89 45 f0             	mov    %eax,-0x10(%ebp)
  *imc = 0xFFFFFFFF;
80108956:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108959:	c7 00 ff ff ff ff    	movl   $0xffffffff,(%eax)
  
  //Reset NIC
  *ctrl = *ctrl | I8254_CTRL_RST;
8010895f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108962:	8b 00                	mov    (%eax),%eax
80108964:	0d 00 00 00 04       	or     $0x4000000,%eax
80108969:	89 c2                	mov    %eax,%edx
8010896b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010896e:	89 10                	mov    %edx,(%eax)

  //Enable Interrupts
  *imc = 0xFFFFFFFF;
80108970:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108973:	c7 00 ff ff ff ff    	movl   $0xffffffff,(%eax)

  //Enable Link
  *ctrl |= I8254_CTRL_SLU;
80108979:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010897c:	8b 00                	mov    (%eax),%eax
8010897e:	83 c8 40             	or     $0x40,%eax
80108981:	89 c2                	mov    %eax,%edx
80108983:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108986:	89 10                	mov    %edx,(%eax)
  
  //General Configuration
  *ctrl &= (~I8254_CTRL_PHY_RST | ~I8254_CTRL_VME | ~I8254_CTRL_ILOS);
80108988:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010898b:	8b 10                	mov    (%eax),%edx
8010898d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108990:	89 10                	mov    %edx,(%eax)
  cprintf("E1000 General Configuration Done\n");
80108992:	83 ec 0c             	sub    $0xc,%esp
80108995:	68 d0 c2 10 80       	push   $0x8010c2d0
8010899a:	e8 55 7a ff ff       	call   801003f4 <cprintf>
8010899f:	83 c4 10             	add    $0x10,%esp
  intr_addr = (uint *)kalloc();
801089a2:	e8 dd a2 ff ff       	call   80102c84 <kalloc>
801089a7:	a3 c8 9e 11 80       	mov    %eax,0x80119ec8
  *intr_addr = 0;
801089ac:	a1 c8 9e 11 80       	mov    0x80119ec8,%eax
801089b1:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  cprintf("INTR_ADDR:%x\n",intr_addr);
801089b7:	a1 c8 9e 11 80       	mov    0x80119ec8,%eax
801089bc:	83 ec 08             	sub    $0x8,%esp
801089bf:	50                   	push   %eax
801089c0:	68 f2 c2 10 80       	push   $0x8010c2f2
801089c5:	e8 2a 7a ff ff       	call   801003f4 <cprintf>
801089ca:	83 c4 10             	add    $0x10,%esp
  i8254_init_recv();
801089cd:	e8 50 00 00 00       	call   80108a22 <i8254_init_recv>
  i8254_init_send();
801089d2:	e8 69 03 00 00       	call   80108d40 <i8254_init_send>
  cprintf("IP Address %d.%d.%d.%d\n",
      my_ip[0],
      my_ip[1],
      my_ip[2],
      my_ip[3]);
801089d7:	0f b6 05 e7 f4 10 80 	movzbl 0x8010f4e7,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
801089de:	0f b6 d8             	movzbl %al,%ebx
      my_ip[2],
801089e1:	0f b6 05 e6 f4 10 80 	movzbl 0x8010f4e6,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
801089e8:	0f b6 c8             	movzbl %al,%ecx
      my_ip[1],
801089eb:	0f b6 05 e5 f4 10 80 	movzbl 0x8010f4e5,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
801089f2:	0f b6 d0             	movzbl %al,%edx
      my_ip[0],
801089f5:	0f b6 05 e4 f4 10 80 	movzbl 0x8010f4e4,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
801089fc:	0f b6 c0             	movzbl %al,%eax
801089ff:	83 ec 0c             	sub    $0xc,%esp
80108a02:	53                   	push   %ebx
80108a03:	51                   	push   %ecx
80108a04:	52                   	push   %edx
80108a05:	50                   	push   %eax
80108a06:	68 00 c3 10 80       	push   $0x8010c300
80108a0b:	e8 e4 79 ff ff       	call   801003f4 <cprintf>
80108a10:	83 c4 20             	add    $0x20,%esp
  *imc = 0x0;
80108a13:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108a16:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
}
80108a1c:	90                   	nop
80108a1d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108a20:	c9                   	leave  
80108a21:	c3                   	ret    

80108a22 <i8254_init_recv>:

void i8254_init_recv(){
80108a22:	55                   	push   %ebp
80108a23:	89 e5                	mov    %esp,%ebp
80108a25:	57                   	push   %edi
80108a26:	56                   	push   %esi
80108a27:	53                   	push   %ebx
80108a28:	83 ec 6c             	sub    $0x6c,%esp
  
  uint data_l = i8254_read_eeprom(0x0);
80108a2b:	83 ec 0c             	sub    $0xc,%esp
80108a2e:	6a 00                	push   $0x0
80108a30:	e8 e8 04 00 00       	call   80108f1d <i8254_read_eeprom>
80108a35:	83 c4 10             	add    $0x10,%esp
80108a38:	89 45 d8             	mov    %eax,-0x28(%ebp)
  mac_addr[0] = data_l&0xFF;
80108a3b:	8b 45 d8             	mov    -0x28(%ebp),%eax
80108a3e:	a2 c0 9e 11 80       	mov    %al,0x80119ec0
  mac_addr[1] = data_l>>8;
80108a43:	8b 45 d8             	mov    -0x28(%ebp),%eax
80108a46:	c1 e8 08             	shr    $0x8,%eax
80108a49:	a2 c1 9e 11 80       	mov    %al,0x80119ec1
  uint data_m = i8254_read_eeprom(0x1);
80108a4e:	83 ec 0c             	sub    $0xc,%esp
80108a51:	6a 01                	push   $0x1
80108a53:	e8 c5 04 00 00       	call   80108f1d <i8254_read_eeprom>
80108a58:	83 c4 10             	add    $0x10,%esp
80108a5b:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  mac_addr[2] = data_m&0xFF;
80108a5e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80108a61:	a2 c2 9e 11 80       	mov    %al,0x80119ec2
  mac_addr[3] = data_m>>8;
80108a66:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80108a69:	c1 e8 08             	shr    $0x8,%eax
80108a6c:	a2 c3 9e 11 80       	mov    %al,0x80119ec3
  uint data_h = i8254_read_eeprom(0x2);
80108a71:	83 ec 0c             	sub    $0xc,%esp
80108a74:	6a 02                	push   $0x2
80108a76:	e8 a2 04 00 00       	call   80108f1d <i8254_read_eeprom>
80108a7b:	83 c4 10             	add    $0x10,%esp
80108a7e:	89 45 d0             	mov    %eax,-0x30(%ebp)
  mac_addr[4] = data_h&0xFF;
80108a81:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108a84:	a2 c4 9e 11 80       	mov    %al,0x80119ec4
  mac_addr[5] = data_h>>8;
80108a89:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108a8c:	c1 e8 08             	shr    $0x8,%eax
80108a8f:	a2 c5 9e 11 80       	mov    %al,0x80119ec5
      mac_addr[0],
      mac_addr[1],
      mac_addr[2],
      mac_addr[3],
      mac_addr[4],
      mac_addr[5]);
80108a94:	0f b6 05 c5 9e 11 80 	movzbl 0x80119ec5,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108a9b:	0f b6 f8             	movzbl %al,%edi
      mac_addr[4],
80108a9e:	0f b6 05 c4 9e 11 80 	movzbl 0x80119ec4,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108aa5:	0f b6 f0             	movzbl %al,%esi
      mac_addr[3],
80108aa8:	0f b6 05 c3 9e 11 80 	movzbl 0x80119ec3,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108aaf:	0f b6 d8             	movzbl %al,%ebx
      mac_addr[2],
80108ab2:	0f b6 05 c2 9e 11 80 	movzbl 0x80119ec2,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108ab9:	0f b6 c8             	movzbl %al,%ecx
      mac_addr[1],
80108abc:	0f b6 05 c1 9e 11 80 	movzbl 0x80119ec1,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108ac3:	0f b6 d0             	movzbl %al,%edx
      mac_addr[0],
80108ac6:	0f b6 05 c0 9e 11 80 	movzbl 0x80119ec0,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108acd:	0f b6 c0             	movzbl %al,%eax
80108ad0:	83 ec 04             	sub    $0x4,%esp
80108ad3:	57                   	push   %edi
80108ad4:	56                   	push   %esi
80108ad5:	53                   	push   %ebx
80108ad6:	51                   	push   %ecx
80108ad7:	52                   	push   %edx
80108ad8:	50                   	push   %eax
80108ad9:	68 18 c3 10 80       	push   $0x8010c318
80108ade:	e8 11 79 ff ff       	call   801003f4 <cprintf>
80108ae3:	83 c4 20             	add    $0x20,%esp

  uint *ral = (uint *)(base_addr + 0x5400);
80108ae6:	a1 bc 9e 11 80       	mov    0x80119ebc,%eax
80108aeb:	05 00 54 00 00       	add    $0x5400,%eax
80108af0:	89 45 cc             	mov    %eax,-0x34(%ebp)
  uint *rah = (uint *)(base_addr + 0x5404);
80108af3:	a1 bc 9e 11 80       	mov    0x80119ebc,%eax
80108af8:	05 04 54 00 00       	add    $0x5404,%eax
80108afd:	89 45 c8             	mov    %eax,-0x38(%ebp)

  *ral = (data_l | (data_m << 16));
80108b00:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80108b03:	c1 e0 10             	shl    $0x10,%eax
80108b06:	0b 45 d8             	or     -0x28(%ebp),%eax
80108b09:	89 c2                	mov    %eax,%edx
80108b0b:	8b 45 cc             	mov    -0x34(%ebp),%eax
80108b0e:	89 10                	mov    %edx,(%eax)
  *rah = (data_h | I8254_RAH_AS_DEST | I8254_RAH_AV);
80108b10:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108b13:	0d 00 00 00 80       	or     $0x80000000,%eax
80108b18:	89 c2                	mov    %eax,%edx
80108b1a:	8b 45 c8             	mov    -0x38(%ebp),%eax
80108b1d:	89 10                	mov    %edx,(%eax)

  uint *mta = (uint *)(base_addr + 0x5200);
80108b1f:	a1 bc 9e 11 80       	mov    0x80119ebc,%eax
80108b24:	05 00 52 00 00       	add    $0x5200,%eax
80108b29:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  for(int i=0;i<128;i++){
80108b2c:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80108b33:	eb 19                	jmp    80108b4e <i8254_init_recv+0x12c>
    mta[i] = 0;
80108b35:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108b38:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108b3f:	8b 45 c4             	mov    -0x3c(%ebp),%eax
80108b42:	01 d0                	add    %edx,%eax
80108b44:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(int i=0;i<128;i++){
80108b4a:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80108b4e:	83 7d e4 7f          	cmpl   $0x7f,-0x1c(%ebp)
80108b52:	7e e1                	jle    80108b35 <i8254_init_recv+0x113>
  }

  uint *ims = (uint *)(base_addr + 0xD0);
80108b54:	a1 bc 9e 11 80       	mov    0x80119ebc,%eax
80108b59:	05 d0 00 00 00       	add    $0xd0,%eax
80108b5e:	89 45 c0             	mov    %eax,-0x40(%ebp)
  *ims = (I8254_IMS_RXT0 | I8254_IMS_RXDMT0 | I8254_IMS_RXSEQ | I8254_IMS_LSC | I8254_IMS_RXO);
80108b61:	8b 45 c0             	mov    -0x40(%ebp),%eax
80108b64:	c7 00 dc 00 00 00    	movl   $0xdc,(%eax)
  uint *ics = (uint *)(base_addr + 0xC8);
80108b6a:	a1 bc 9e 11 80       	mov    0x80119ebc,%eax
80108b6f:	05 c8 00 00 00       	add    $0xc8,%eax
80108b74:	89 45 bc             	mov    %eax,-0x44(%ebp)
  *ics = (I8254_IMS_RXT0 | I8254_IMS_RXDMT0 | I8254_IMS_RXSEQ | I8254_IMS_LSC | I8254_IMS_RXO);
80108b77:	8b 45 bc             	mov    -0x44(%ebp),%eax
80108b7a:	c7 00 dc 00 00 00    	movl   $0xdc,(%eax)



  uint *rxdctl = (uint *)(base_addr + 0x2828);
80108b80:	a1 bc 9e 11 80       	mov    0x80119ebc,%eax
80108b85:	05 28 28 00 00       	add    $0x2828,%eax
80108b8a:	89 45 b8             	mov    %eax,-0x48(%ebp)
  *rxdctl = 0;
80108b8d:	8b 45 b8             	mov    -0x48(%ebp),%eax
80108b90:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  uint *rctl = (uint *)(base_addr + 0x100);
80108b96:	a1 bc 9e 11 80       	mov    0x80119ebc,%eax
80108b9b:	05 00 01 00 00       	add    $0x100,%eax
80108ba0:	89 45 b4             	mov    %eax,-0x4c(%ebp)
  *rctl = (I8254_RCTL_UPE | I8254_RCTL_MPE | I8254_RCTL_BAM | I8254_RCTL_BSIZE | I8254_RCTL_SECRC);
80108ba3:	8b 45 b4             	mov    -0x4c(%ebp),%eax
80108ba6:	c7 00 18 80 00 04    	movl   $0x4008018,(%eax)

  uint recv_desc_addr = (uint)kalloc();
80108bac:	e8 d3 a0 ff ff       	call   80102c84 <kalloc>
80108bb1:	89 45 b0             	mov    %eax,-0x50(%ebp)
  uint *rdbal = (uint *)(base_addr + 0x2800);
80108bb4:	a1 bc 9e 11 80       	mov    0x80119ebc,%eax
80108bb9:	05 00 28 00 00       	add    $0x2800,%eax
80108bbe:	89 45 ac             	mov    %eax,-0x54(%ebp)
  uint *rdbah = (uint *)(base_addr + 0x2804);
80108bc1:	a1 bc 9e 11 80       	mov    0x80119ebc,%eax
80108bc6:	05 04 28 00 00       	add    $0x2804,%eax
80108bcb:	89 45 a8             	mov    %eax,-0x58(%ebp)
  uint *rdlen = (uint *)(base_addr + 0x2808);
80108bce:	a1 bc 9e 11 80       	mov    0x80119ebc,%eax
80108bd3:	05 08 28 00 00       	add    $0x2808,%eax
80108bd8:	89 45 a4             	mov    %eax,-0x5c(%ebp)
  uint *rdh = (uint *)(base_addr + 0x2810);
80108bdb:	a1 bc 9e 11 80       	mov    0x80119ebc,%eax
80108be0:	05 10 28 00 00       	add    $0x2810,%eax
80108be5:	89 45 a0             	mov    %eax,-0x60(%ebp)
  uint *rdt = (uint *)(base_addr + 0x2818);
80108be8:	a1 bc 9e 11 80       	mov    0x80119ebc,%eax
80108bed:	05 18 28 00 00       	add    $0x2818,%eax
80108bf2:	89 45 9c             	mov    %eax,-0x64(%ebp)

  *rdbal = V2P(recv_desc_addr);
80108bf5:	8b 45 b0             	mov    -0x50(%ebp),%eax
80108bf8:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80108bfe:	8b 45 ac             	mov    -0x54(%ebp),%eax
80108c01:	89 10                	mov    %edx,(%eax)
  *rdbah = 0;
80108c03:	8b 45 a8             	mov    -0x58(%ebp),%eax
80108c06:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *rdlen = sizeof(struct i8254_recv_desc)*I8254_RECV_DESC_NUM;
80108c0c:	8b 45 a4             	mov    -0x5c(%ebp),%eax
80108c0f:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  *rdh = 0;
80108c15:	8b 45 a0             	mov    -0x60(%ebp),%eax
80108c18:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *rdt = I8254_RECV_DESC_NUM;
80108c1e:	8b 45 9c             	mov    -0x64(%ebp),%eax
80108c21:	c7 00 00 01 00 00    	movl   $0x100,(%eax)

  struct i8254_recv_desc *recv_desc = (struct i8254_recv_desc *)recv_desc_addr;
80108c27:	8b 45 b0             	mov    -0x50(%ebp),%eax
80108c2a:	89 45 98             	mov    %eax,-0x68(%ebp)
  for(int i=0;i<I8254_RECV_DESC_NUM;i++){
80108c2d:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
80108c34:	eb 73                	jmp    80108ca9 <i8254_init_recv+0x287>
    recv_desc[i].padding = 0;
80108c36:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108c39:	c1 e0 04             	shl    $0x4,%eax
80108c3c:	89 c2                	mov    %eax,%edx
80108c3e:	8b 45 98             	mov    -0x68(%ebp),%eax
80108c41:	01 d0                	add    %edx,%eax
80108c43:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    recv_desc[i].len = 0;
80108c4a:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108c4d:	c1 e0 04             	shl    $0x4,%eax
80108c50:	89 c2                	mov    %eax,%edx
80108c52:	8b 45 98             	mov    -0x68(%ebp),%eax
80108c55:	01 d0                	add    %edx,%eax
80108c57:	66 c7 40 08 00 00    	movw   $0x0,0x8(%eax)
    recv_desc[i].chk_sum = 0;
80108c5d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108c60:	c1 e0 04             	shl    $0x4,%eax
80108c63:	89 c2                	mov    %eax,%edx
80108c65:	8b 45 98             	mov    -0x68(%ebp),%eax
80108c68:	01 d0                	add    %edx,%eax
80108c6a:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
    recv_desc[i].status = 0;
80108c70:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108c73:	c1 e0 04             	shl    $0x4,%eax
80108c76:	89 c2                	mov    %eax,%edx
80108c78:	8b 45 98             	mov    -0x68(%ebp),%eax
80108c7b:	01 d0                	add    %edx,%eax
80108c7d:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
    recv_desc[i].errors = 0;
80108c81:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108c84:	c1 e0 04             	shl    $0x4,%eax
80108c87:	89 c2                	mov    %eax,%edx
80108c89:	8b 45 98             	mov    -0x68(%ebp),%eax
80108c8c:	01 d0                	add    %edx,%eax
80108c8e:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
    recv_desc[i].special = 0;
80108c92:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108c95:	c1 e0 04             	shl    $0x4,%eax
80108c98:	89 c2                	mov    %eax,%edx
80108c9a:	8b 45 98             	mov    -0x68(%ebp),%eax
80108c9d:	01 d0                	add    %edx,%eax
80108c9f:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
  for(int i=0;i<I8254_RECV_DESC_NUM;i++){
80108ca5:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
80108ca9:	81 7d e0 ff 00 00 00 	cmpl   $0xff,-0x20(%ebp)
80108cb0:	7e 84                	jle    80108c36 <i8254_init_recv+0x214>
  }

  for(int i=0;i<(I8254_RECV_DESC_NUM)/2;i++){
80108cb2:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
80108cb9:	eb 57                	jmp    80108d12 <i8254_init_recv+0x2f0>
    uint buf_addr = (uint)kalloc();
80108cbb:	e8 c4 9f ff ff       	call   80102c84 <kalloc>
80108cc0:	89 45 94             	mov    %eax,-0x6c(%ebp)
    if(buf_addr == 0){
80108cc3:	83 7d 94 00          	cmpl   $0x0,-0x6c(%ebp)
80108cc7:	75 12                	jne    80108cdb <i8254_init_recv+0x2b9>
      cprintf("failed to allocate buffer area\n");
80108cc9:	83 ec 0c             	sub    $0xc,%esp
80108ccc:	68 38 c3 10 80       	push   $0x8010c338
80108cd1:	e8 1e 77 ff ff       	call   801003f4 <cprintf>
80108cd6:	83 c4 10             	add    $0x10,%esp
      break;
80108cd9:	eb 3d                	jmp    80108d18 <i8254_init_recv+0x2f6>
    }
    recv_desc[i].buf_addr = V2P(buf_addr);
80108cdb:	8b 45 dc             	mov    -0x24(%ebp),%eax
80108cde:	c1 e0 04             	shl    $0x4,%eax
80108ce1:	89 c2                	mov    %eax,%edx
80108ce3:	8b 45 98             	mov    -0x68(%ebp),%eax
80108ce6:	01 d0                	add    %edx,%eax
80108ce8:	8b 55 94             	mov    -0x6c(%ebp),%edx
80108ceb:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80108cf1:	89 10                	mov    %edx,(%eax)
    recv_desc[i+1].buf_addr = V2P(buf_addr + 0x800);
80108cf3:	8b 45 dc             	mov    -0x24(%ebp),%eax
80108cf6:	83 c0 01             	add    $0x1,%eax
80108cf9:	c1 e0 04             	shl    $0x4,%eax
80108cfc:	89 c2                	mov    %eax,%edx
80108cfe:	8b 45 98             	mov    -0x68(%ebp),%eax
80108d01:	01 d0                	add    %edx,%eax
80108d03:	8b 55 94             	mov    -0x6c(%ebp),%edx
80108d06:	81 ea 00 f8 ff 7f    	sub    $0x7ffff800,%edx
80108d0c:	89 10                	mov    %edx,(%eax)
  for(int i=0;i<(I8254_RECV_DESC_NUM)/2;i++){
80108d0e:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
80108d12:	83 7d dc 7f          	cmpl   $0x7f,-0x24(%ebp)
80108d16:	7e a3                	jle    80108cbb <i8254_init_recv+0x299>
  }

  *rctl |= I8254_RCTL_EN;
80108d18:	8b 45 b4             	mov    -0x4c(%ebp),%eax
80108d1b:	8b 00                	mov    (%eax),%eax
80108d1d:	83 c8 02             	or     $0x2,%eax
80108d20:	89 c2                	mov    %eax,%edx
80108d22:	8b 45 b4             	mov    -0x4c(%ebp),%eax
80108d25:	89 10                	mov    %edx,(%eax)
  cprintf("E1000 Recieve Initialize Done\n");
80108d27:	83 ec 0c             	sub    $0xc,%esp
80108d2a:	68 58 c3 10 80       	push   $0x8010c358
80108d2f:	e8 c0 76 ff ff       	call   801003f4 <cprintf>
80108d34:	83 c4 10             	add    $0x10,%esp
}
80108d37:	90                   	nop
80108d38:	8d 65 f4             	lea    -0xc(%ebp),%esp
80108d3b:	5b                   	pop    %ebx
80108d3c:	5e                   	pop    %esi
80108d3d:	5f                   	pop    %edi
80108d3e:	5d                   	pop    %ebp
80108d3f:	c3                   	ret    

80108d40 <i8254_init_send>:

void i8254_init_send(){
80108d40:	55                   	push   %ebp
80108d41:	89 e5                	mov    %esp,%ebp
80108d43:	83 ec 48             	sub    $0x48,%esp
  uint *txdctl = (uint *)(base_addr + 0x3828);
80108d46:	a1 bc 9e 11 80       	mov    0x80119ebc,%eax
80108d4b:	05 28 38 00 00       	add    $0x3828,%eax
80108d50:	89 45 ec             	mov    %eax,-0x14(%ebp)
  *txdctl = (I8254_TXDCTL_WTHRESH | I8254_TXDCTL_GRAN_DESC);
80108d53:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108d56:	c7 00 00 00 01 01    	movl   $0x1010000,(%eax)

  uint tx_desc_addr = (uint)kalloc();
80108d5c:	e8 23 9f ff ff       	call   80102c84 <kalloc>
80108d61:	89 45 e8             	mov    %eax,-0x18(%ebp)
  uint *tdbal = (uint *)(base_addr + 0x3800);
80108d64:	a1 bc 9e 11 80       	mov    0x80119ebc,%eax
80108d69:	05 00 38 00 00       	add    $0x3800,%eax
80108d6e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  uint *tdbah = (uint *)(base_addr + 0x3804);
80108d71:	a1 bc 9e 11 80       	mov    0x80119ebc,%eax
80108d76:	05 04 38 00 00       	add    $0x3804,%eax
80108d7b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  uint *tdlen = (uint *)(base_addr + 0x3808);
80108d7e:	a1 bc 9e 11 80       	mov    0x80119ebc,%eax
80108d83:	05 08 38 00 00       	add    $0x3808,%eax
80108d88:	89 45 dc             	mov    %eax,-0x24(%ebp)

  *tdbal = V2P(tx_desc_addr);
80108d8b:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108d8e:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80108d94:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108d97:	89 10                	mov    %edx,(%eax)
  *tdbah = 0;
80108d99:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108d9c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *tdlen = sizeof(struct i8254_send_desc)*I8254_SEND_DESC_NUM;
80108da2:	8b 45 dc             	mov    -0x24(%ebp),%eax
80108da5:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  uint *tdh = (uint *)(base_addr + 0x3810);
80108dab:	a1 bc 9e 11 80       	mov    0x80119ebc,%eax
80108db0:	05 10 38 00 00       	add    $0x3810,%eax
80108db5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  uint *tdt = (uint *)(base_addr + 0x3818);
80108db8:	a1 bc 9e 11 80       	mov    0x80119ebc,%eax
80108dbd:	05 18 38 00 00       	add    $0x3818,%eax
80108dc2:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  
  *tdh = 0;
80108dc5:	8b 45 d8             	mov    -0x28(%ebp),%eax
80108dc8:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *tdt = 0;
80108dce:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80108dd1:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  struct i8254_send_desc *send_desc = (struct i8254_send_desc *)tx_desc_addr;
80108dd7:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108dda:	89 45 d0             	mov    %eax,-0x30(%ebp)
  for(int i=0;i<I8254_SEND_DESC_NUM;i++){
80108ddd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108de4:	e9 82 00 00 00       	jmp    80108e6b <i8254_init_send+0x12b>
    send_desc[i].padding = 0;
80108de9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108dec:	c1 e0 04             	shl    $0x4,%eax
80108def:	89 c2                	mov    %eax,%edx
80108df1:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108df4:	01 d0                	add    %edx,%eax
80108df6:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    send_desc[i].len = 0;
80108dfd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e00:	c1 e0 04             	shl    $0x4,%eax
80108e03:	89 c2                	mov    %eax,%edx
80108e05:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108e08:	01 d0                	add    %edx,%eax
80108e0a:	66 c7 40 08 00 00    	movw   $0x0,0x8(%eax)
    send_desc[i].cso = 0;
80108e10:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e13:	c1 e0 04             	shl    $0x4,%eax
80108e16:	89 c2                	mov    %eax,%edx
80108e18:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108e1b:	01 d0                	add    %edx,%eax
80108e1d:	c6 40 0a 00          	movb   $0x0,0xa(%eax)
    send_desc[i].cmd = 0;
80108e21:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e24:	c1 e0 04             	shl    $0x4,%eax
80108e27:	89 c2                	mov    %eax,%edx
80108e29:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108e2c:	01 d0                	add    %edx,%eax
80108e2e:	c6 40 0b 00          	movb   $0x0,0xb(%eax)
    send_desc[i].sta = 0;
80108e32:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e35:	c1 e0 04             	shl    $0x4,%eax
80108e38:	89 c2                	mov    %eax,%edx
80108e3a:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108e3d:	01 d0                	add    %edx,%eax
80108e3f:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
    send_desc[i].css = 0;
80108e43:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e46:	c1 e0 04             	shl    $0x4,%eax
80108e49:	89 c2                	mov    %eax,%edx
80108e4b:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108e4e:	01 d0                	add    %edx,%eax
80108e50:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
    send_desc[i].special = 0;
80108e54:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e57:	c1 e0 04             	shl    $0x4,%eax
80108e5a:	89 c2                	mov    %eax,%edx
80108e5c:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108e5f:	01 d0                	add    %edx,%eax
80108e61:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
  for(int i=0;i<I8254_SEND_DESC_NUM;i++){
80108e67:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108e6b:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80108e72:	0f 8e 71 ff ff ff    	jle    80108de9 <i8254_init_send+0xa9>
  }

  for(int i=0;i<(I8254_SEND_DESC_NUM)/2;i++){
80108e78:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80108e7f:	eb 57                	jmp    80108ed8 <i8254_init_send+0x198>
    uint buf_addr = (uint)kalloc();
80108e81:	e8 fe 9d ff ff       	call   80102c84 <kalloc>
80108e86:	89 45 cc             	mov    %eax,-0x34(%ebp)
    if(buf_addr == 0){
80108e89:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
80108e8d:	75 12                	jne    80108ea1 <i8254_init_send+0x161>
      cprintf("failed to allocate buffer area\n");
80108e8f:	83 ec 0c             	sub    $0xc,%esp
80108e92:	68 38 c3 10 80       	push   $0x8010c338
80108e97:	e8 58 75 ff ff       	call   801003f4 <cprintf>
80108e9c:	83 c4 10             	add    $0x10,%esp
      break;
80108e9f:	eb 3d                	jmp    80108ede <i8254_init_send+0x19e>
    }
    send_desc[i].buf_addr = V2P(buf_addr);
80108ea1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108ea4:	c1 e0 04             	shl    $0x4,%eax
80108ea7:	89 c2                	mov    %eax,%edx
80108ea9:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108eac:	01 d0                	add    %edx,%eax
80108eae:	8b 55 cc             	mov    -0x34(%ebp),%edx
80108eb1:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80108eb7:	89 10                	mov    %edx,(%eax)
    send_desc[i+1].buf_addr = V2P(buf_addr + 0x800);
80108eb9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108ebc:	83 c0 01             	add    $0x1,%eax
80108ebf:	c1 e0 04             	shl    $0x4,%eax
80108ec2:	89 c2                	mov    %eax,%edx
80108ec4:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108ec7:	01 d0                	add    %edx,%eax
80108ec9:	8b 55 cc             	mov    -0x34(%ebp),%edx
80108ecc:	81 ea 00 f8 ff 7f    	sub    $0x7ffff800,%edx
80108ed2:	89 10                	mov    %edx,(%eax)
  for(int i=0;i<(I8254_SEND_DESC_NUM)/2;i++){
80108ed4:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80108ed8:	83 7d f0 7f          	cmpl   $0x7f,-0x10(%ebp)
80108edc:	7e a3                	jle    80108e81 <i8254_init_send+0x141>
  }

  uint *tctl = (uint *)(base_addr + 0x400);
80108ede:	a1 bc 9e 11 80       	mov    0x80119ebc,%eax
80108ee3:	05 00 04 00 00       	add    $0x400,%eax
80108ee8:	89 45 c8             	mov    %eax,-0x38(%ebp)
  *tctl = (I8254_TCTL_EN | I8254_TCTL_PSP | I8254_TCTL_COLD | I8254_TCTL_CT);
80108eeb:	8b 45 c8             	mov    -0x38(%ebp),%eax
80108eee:	c7 00 fa 00 04 00    	movl   $0x400fa,(%eax)

  uint *tipg = (uint *)(base_addr + 0x410);
80108ef4:	a1 bc 9e 11 80       	mov    0x80119ebc,%eax
80108ef9:	05 10 04 00 00       	add    $0x410,%eax
80108efe:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  *tipg = (10 | (10<<10) | (10<<20));
80108f01:	8b 45 c4             	mov    -0x3c(%ebp),%eax
80108f04:	c7 00 0a 28 a0 00    	movl   $0xa0280a,(%eax)
  cprintf("E1000 Transmit Initialize Done\n");
80108f0a:	83 ec 0c             	sub    $0xc,%esp
80108f0d:	68 78 c3 10 80       	push   $0x8010c378
80108f12:	e8 dd 74 ff ff       	call   801003f4 <cprintf>
80108f17:	83 c4 10             	add    $0x10,%esp

}
80108f1a:	90                   	nop
80108f1b:	c9                   	leave  
80108f1c:	c3                   	ret    

80108f1d <i8254_read_eeprom>:
uint i8254_read_eeprom(uint addr){
80108f1d:	55                   	push   %ebp
80108f1e:	89 e5                	mov    %esp,%ebp
80108f20:	83 ec 18             	sub    $0x18,%esp
  uint *eerd = (uint *)(base_addr + 0x14);
80108f23:	a1 bc 9e 11 80       	mov    0x80119ebc,%eax
80108f28:	83 c0 14             	add    $0x14,%eax
80108f2b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  *eerd = (((addr & 0xFF) << 8) | 1);
80108f2e:	8b 45 08             	mov    0x8(%ebp),%eax
80108f31:	c1 e0 08             	shl    $0x8,%eax
80108f34:	0f b7 c0             	movzwl %ax,%eax
80108f37:	83 c8 01             	or     $0x1,%eax
80108f3a:	89 c2                	mov    %eax,%edx
80108f3c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f3f:	89 10                	mov    %edx,(%eax)
  while(1){
    cprintf("");
80108f41:	83 ec 0c             	sub    $0xc,%esp
80108f44:	68 98 c3 10 80       	push   $0x8010c398
80108f49:	e8 a6 74 ff ff       	call   801003f4 <cprintf>
80108f4e:	83 c4 10             	add    $0x10,%esp
    volatile uint data = *eerd;
80108f51:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f54:	8b 00                	mov    (%eax),%eax
80108f56:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((data & (1<<4)) != 0){
80108f59:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108f5c:	83 e0 10             	and    $0x10,%eax
80108f5f:	85 c0                	test   %eax,%eax
80108f61:	75 02                	jne    80108f65 <i8254_read_eeprom+0x48>
  while(1){
80108f63:	eb dc                	jmp    80108f41 <i8254_read_eeprom+0x24>
      break;
80108f65:	90                   	nop
    }
  }

  return (*eerd >> 16) & 0xFFFF;
80108f66:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f69:	8b 00                	mov    (%eax),%eax
80108f6b:	c1 e8 10             	shr    $0x10,%eax
}
80108f6e:	c9                   	leave  
80108f6f:	c3                   	ret    

80108f70 <i8254_recv>:
void i8254_recv(){
80108f70:	55                   	push   %ebp
80108f71:	89 e5                	mov    %esp,%ebp
80108f73:	83 ec 28             	sub    $0x28,%esp
  uint *rdh = (uint *)(base_addr + 0x2810);
80108f76:	a1 bc 9e 11 80       	mov    0x80119ebc,%eax
80108f7b:	05 10 28 00 00       	add    $0x2810,%eax
80108f80:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint *rdt = (uint *)(base_addr + 0x2818);
80108f83:	a1 bc 9e 11 80       	mov    0x80119ebc,%eax
80108f88:	05 18 28 00 00       	add    $0x2818,%eax
80108f8d:	89 45 f0             	mov    %eax,-0x10(%ebp)
//  uint *torl = (uint *)(base_addr + 0x40C0);
//  uint *tpr = (uint *)(base_addr + 0x40D0);
//  uint *icr = (uint *)(base_addr + 0xC0);
  uint *rdbal = (uint *)(base_addr + 0x2800);
80108f90:	a1 bc 9e 11 80       	mov    0x80119ebc,%eax
80108f95:	05 00 28 00 00       	add    $0x2800,%eax
80108f9a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct i8254_recv_desc *recv_desc = (struct i8254_recv_desc *)(P2V(*rdbal));
80108f9d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108fa0:	8b 00                	mov    (%eax),%eax
80108fa2:	05 00 00 00 80       	add    $0x80000000,%eax
80108fa7:	89 45 e8             	mov    %eax,-0x18(%ebp)
  while(1){
    int rx_available = (I8254_RECV_DESC_NUM - *rdt + *rdh)%I8254_RECV_DESC_NUM;
80108faa:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108fad:	8b 10                	mov    (%eax),%edx
80108faf:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108fb2:	8b 08                	mov    (%eax),%ecx
80108fb4:	89 d0                	mov    %edx,%eax
80108fb6:	29 c8                	sub    %ecx,%eax
80108fb8:	25 ff 00 00 00       	and    $0xff,%eax
80108fbd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(rx_available > 0){
80108fc0:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80108fc4:	7e 37                	jle    80108ffd <i8254_recv+0x8d>
      uint buffer_addr = P2V_WO(recv_desc[*rdt].buf_addr);
80108fc6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108fc9:	8b 00                	mov    (%eax),%eax
80108fcb:	c1 e0 04             	shl    $0x4,%eax
80108fce:	89 c2                	mov    %eax,%edx
80108fd0:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108fd3:	01 d0                	add    %edx,%eax
80108fd5:	8b 00                	mov    (%eax),%eax
80108fd7:	05 00 00 00 80       	add    $0x80000000,%eax
80108fdc:	89 45 e0             	mov    %eax,-0x20(%ebp)
      *rdt = (*rdt + 1)%I8254_RECV_DESC_NUM;
80108fdf:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108fe2:	8b 00                	mov    (%eax),%eax
80108fe4:	83 c0 01             	add    $0x1,%eax
80108fe7:	0f b6 d0             	movzbl %al,%edx
80108fea:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108fed:	89 10                	mov    %edx,(%eax)
      eth_proc(buffer_addr);
80108fef:	83 ec 0c             	sub    $0xc,%esp
80108ff2:	ff 75 e0             	push   -0x20(%ebp)
80108ff5:	e8 15 09 00 00       	call   8010990f <eth_proc>
80108ffa:	83 c4 10             	add    $0x10,%esp
    }
    if(*rdt == *rdh) {
80108ffd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109000:	8b 10                	mov    (%eax),%edx
80109002:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109005:	8b 00                	mov    (%eax),%eax
80109007:	39 c2                	cmp    %eax,%edx
80109009:	75 9f                	jne    80108faa <i8254_recv+0x3a>
      (*rdt)--;
8010900b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010900e:	8b 00                	mov    (%eax),%eax
80109010:	8d 50 ff             	lea    -0x1(%eax),%edx
80109013:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109016:	89 10                	mov    %edx,(%eax)
  while(1){
80109018:	eb 90                	jmp    80108faa <i8254_recv+0x3a>

8010901a <i8254_send>:
    }
  }
}

int i8254_send(const uint pkt_addr,uint len){
8010901a:	55                   	push   %ebp
8010901b:	89 e5                	mov    %esp,%ebp
8010901d:	83 ec 28             	sub    $0x28,%esp
  uint *tdh = (uint *)(base_addr + 0x3810);
80109020:	a1 bc 9e 11 80       	mov    0x80119ebc,%eax
80109025:	05 10 38 00 00       	add    $0x3810,%eax
8010902a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint *tdt = (uint *)(base_addr + 0x3818);
8010902d:	a1 bc 9e 11 80       	mov    0x80119ebc,%eax
80109032:	05 18 38 00 00       	add    $0x3818,%eax
80109037:	89 45 f0             	mov    %eax,-0x10(%ebp)
  uint *tdbal = (uint *)(base_addr + 0x3800);
8010903a:	a1 bc 9e 11 80       	mov    0x80119ebc,%eax
8010903f:	05 00 38 00 00       	add    $0x3800,%eax
80109044:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct i8254_send_desc *txdesc = (struct i8254_send_desc *)P2V_WO(*tdbal);
80109047:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010904a:	8b 00                	mov    (%eax),%eax
8010904c:	05 00 00 00 80       	add    $0x80000000,%eax
80109051:	89 45 e8             	mov    %eax,-0x18(%ebp)
  int tx_available = I8254_SEND_DESC_NUM - ((I8254_SEND_DESC_NUM - *tdh + *tdt) % I8254_SEND_DESC_NUM);
80109054:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109057:	8b 10                	mov    (%eax),%edx
80109059:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010905c:	8b 08                	mov    (%eax),%ecx
8010905e:	89 d0                	mov    %edx,%eax
80109060:	29 c8                	sub    %ecx,%eax
80109062:	0f b6 d0             	movzbl %al,%edx
80109065:	b8 00 01 00 00       	mov    $0x100,%eax
8010906a:	29 d0                	sub    %edx,%eax
8010906c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  uint index = *tdt%I8254_SEND_DESC_NUM;
8010906f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109072:	8b 00                	mov    (%eax),%eax
80109074:	25 ff 00 00 00       	and    $0xff,%eax
80109079:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if(tx_available > 0) {
8010907c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80109080:	0f 8e a8 00 00 00    	jle    8010912e <i8254_send+0x114>
    memmove(P2V_WO((void *)txdesc[index].buf_addr),(void *)pkt_addr,len);
80109086:	8b 45 08             	mov    0x8(%ebp),%eax
80109089:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010908c:	89 d1                	mov    %edx,%ecx
8010908e:	c1 e1 04             	shl    $0x4,%ecx
80109091:	8b 55 e8             	mov    -0x18(%ebp),%edx
80109094:	01 ca                	add    %ecx,%edx
80109096:	8b 12                	mov    (%edx),%edx
80109098:	81 c2 00 00 00 80    	add    $0x80000000,%edx
8010909e:	83 ec 04             	sub    $0x4,%esp
801090a1:	ff 75 0c             	push   0xc(%ebp)
801090a4:	50                   	push   %eax
801090a5:	52                   	push   %edx
801090a6:	e8 77 be ff ff       	call   80104f22 <memmove>
801090ab:	83 c4 10             	add    $0x10,%esp
    txdesc[index].len = len;
801090ae:	8b 45 e0             	mov    -0x20(%ebp),%eax
801090b1:	c1 e0 04             	shl    $0x4,%eax
801090b4:	89 c2                	mov    %eax,%edx
801090b6:	8b 45 e8             	mov    -0x18(%ebp),%eax
801090b9:	01 d0                	add    %edx,%eax
801090bb:	8b 55 0c             	mov    0xc(%ebp),%edx
801090be:	66 89 50 08          	mov    %dx,0x8(%eax)
    txdesc[index].sta = 0;
801090c2:	8b 45 e0             	mov    -0x20(%ebp),%eax
801090c5:	c1 e0 04             	shl    $0x4,%eax
801090c8:	89 c2                	mov    %eax,%edx
801090ca:	8b 45 e8             	mov    -0x18(%ebp),%eax
801090cd:	01 d0                	add    %edx,%eax
801090cf:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
    txdesc[index].css = 0;
801090d3:	8b 45 e0             	mov    -0x20(%ebp),%eax
801090d6:	c1 e0 04             	shl    $0x4,%eax
801090d9:	89 c2                	mov    %eax,%edx
801090db:	8b 45 e8             	mov    -0x18(%ebp),%eax
801090de:	01 d0                	add    %edx,%eax
801090e0:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
    txdesc[index].cmd = 0xb;
801090e4:	8b 45 e0             	mov    -0x20(%ebp),%eax
801090e7:	c1 e0 04             	shl    $0x4,%eax
801090ea:	89 c2                	mov    %eax,%edx
801090ec:	8b 45 e8             	mov    -0x18(%ebp),%eax
801090ef:	01 d0                	add    %edx,%eax
801090f1:	c6 40 0b 0b          	movb   $0xb,0xb(%eax)
    txdesc[index].special = 0;
801090f5:	8b 45 e0             	mov    -0x20(%ebp),%eax
801090f8:	c1 e0 04             	shl    $0x4,%eax
801090fb:	89 c2                	mov    %eax,%edx
801090fd:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109100:	01 d0                	add    %edx,%eax
80109102:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
    txdesc[index].cso = 0;
80109108:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010910b:	c1 e0 04             	shl    $0x4,%eax
8010910e:	89 c2                	mov    %eax,%edx
80109110:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109113:	01 d0                	add    %edx,%eax
80109115:	c6 40 0a 00          	movb   $0x0,0xa(%eax)
    *tdt = (*tdt + 1)%I8254_SEND_DESC_NUM;
80109119:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010911c:	8b 00                	mov    (%eax),%eax
8010911e:	83 c0 01             	add    $0x1,%eax
80109121:	0f b6 d0             	movzbl %al,%edx
80109124:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109127:	89 10                	mov    %edx,(%eax)
    return len;
80109129:	8b 45 0c             	mov    0xc(%ebp),%eax
8010912c:	eb 05                	jmp    80109133 <i8254_send+0x119>
  }else{
    return -1;
8010912e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
  return 0;
}
80109133:	c9                   	leave  
80109134:	c3                   	ret    

80109135 <i8254_intr>:

void i8254_intr(){
80109135:	55                   	push   %ebp
80109136:	89 e5                	mov    %esp,%ebp
  *intr_addr = 0xEEEEEE;
80109138:	a1 c8 9e 11 80       	mov    0x80119ec8,%eax
8010913d:	c7 00 ee ee ee 00    	movl   $0xeeeeee,(%eax)
}
80109143:	90                   	nop
80109144:	5d                   	pop    %ebp
80109145:	c3                   	ret    

80109146 <arp_proc>:
extern uchar mac_addr[6];
extern uchar my_ip[4];

struct arp_entry arp_table[ARP_TABLE_MAX] = {0};

int arp_proc(uint buffer_addr){
80109146:	55                   	push   %ebp
80109147:	89 e5                	mov    %esp,%ebp
80109149:	83 ec 18             	sub    $0x18,%esp
  struct arp_pkt *arp_p = (struct arp_pkt *)(buffer_addr);
8010914c:	8b 45 08             	mov    0x8(%ebp),%eax
8010914f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(arp_p->hrd_type != ARP_HARDWARE_TYPE) return -1;
80109152:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109155:	0f b7 00             	movzwl (%eax),%eax
80109158:	66 3d 00 01          	cmp    $0x100,%ax
8010915c:	74 0a                	je     80109168 <arp_proc+0x22>
8010915e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80109163:	e9 4f 01 00 00       	jmp    801092b7 <arp_proc+0x171>
  if(arp_p->pro_type != ARP_PROTOCOL_TYPE) return -1;
80109168:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010916b:	0f b7 40 02          	movzwl 0x2(%eax),%eax
8010916f:	66 83 f8 08          	cmp    $0x8,%ax
80109173:	74 0a                	je     8010917f <arp_proc+0x39>
80109175:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010917a:	e9 38 01 00 00       	jmp    801092b7 <arp_proc+0x171>
  if(arp_p->hrd_len != 6) return -1;
8010917f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109182:	0f b6 40 04          	movzbl 0x4(%eax),%eax
80109186:	3c 06                	cmp    $0x6,%al
80109188:	74 0a                	je     80109194 <arp_proc+0x4e>
8010918a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010918f:	e9 23 01 00 00       	jmp    801092b7 <arp_proc+0x171>
  if(arp_p->pro_len != 4) return -1;
80109194:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109197:	0f b6 40 05          	movzbl 0x5(%eax),%eax
8010919b:	3c 04                	cmp    $0x4,%al
8010919d:	74 0a                	je     801091a9 <arp_proc+0x63>
8010919f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801091a4:	e9 0e 01 00 00       	jmp    801092b7 <arp_proc+0x171>
  if(memcmp(my_ip,arp_p->dst_ip,4) != 0 && memcmp(my_ip,arp_p->src_ip,4) != 0) return -1;
801091a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801091ac:	83 c0 18             	add    $0x18,%eax
801091af:	83 ec 04             	sub    $0x4,%esp
801091b2:	6a 04                	push   $0x4
801091b4:	50                   	push   %eax
801091b5:	68 e4 f4 10 80       	push   $0x8010f4e4
801091ba:	e8 0b bd ff ff       	call   80104eca <memcmp>
801091bf:	83 c4 10             	add    $0x10,%esp
801091c2:	85 c0                	test   %eax,%eax
801091c4:	74 27                	je     801091ed <arp_proc+0xa7>
801091c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801091c9:	83 c0 0e             	add    $0xe,%eax
801091cc:	83 ec 04             	sub    $0x4,%esp
801091cf:	6a 04                	push   $0x4
801091d1:	50                   	push   %eax
801091d2:	68 e4 f4 10 80       	push   $0x8010f4e4
801091d7:	e8 ee bc ff ff       	call   80104eca <memcmp>
801091dc:	83 c4 10             	add    $0x10,%esp
801091df:	85 c0                	test   %eax,%eax
801091e1:	74 0a                	je     801091ed <arp_proc+0xa7>
801091e3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801091e8:	e9 ca 00 00 00       	jmp    801092b7 <arp_proc+0x171>
  if(arp_p->op == ARP_OPS_REQUEST && memcmp(my_ip,arp_p->dst_ip,4) == 0){
801091ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
801091f0:	0f b7 40 06          	movzwl 0x6(%eax),%eax
801091f4:	66 3d 00 01          	cmp    $0x100,%ax
801091f8:	75 69                	jne    80109263 <arp_proc+0x11d>
801091fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801091fd:	83 c0 18             	add    $0x18,%eax
80109200:	83 ec 04             	sub    $0x4,%esp
80109203:	6a 04                	push   $0x4
80109205:	50                   	push   %eax
80109206:	68 e4 f4 10 80       	push   $0x8010f4e4
8010920b:	e8 ba bc ff ff       	call   80104eca <memcmp>
80109210:	83 c4 10             	add    $0x10,%esp
80109213:	85 c0                	test   %eax,%eax
80109215:	75 4c                	jne    80109263 <arp_proc+0x11d>
    uint send = (uint)kalloc();
80109217:	e8 68 9a ff ff       	call   80102c84 <kalloc>
8010921c:	89 45 f0             	mov    %eax,-0x10(%ebp)
    uint send_size=0;
8010921f:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
    arp_reply_pkt_create(arp_p,send,&send_size);
80109226:	83 ec 04             	sub    $0x4,%esp
80109229:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010922c:	50                   	push   %eax
8010922d:	ff 75 f0             	push   -0x10(%ebp)
80109230:	ff 75 f4             	push   -0xc(%ebp)
80109233:	e8 1f 04 00 00       	call   80109657 <arp_reply_pkt_create>
80109238:	83 c4 10             	add    $0x10,%esp
    i8254_send(send,send_size);
8010923b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010923e:	83 ec 08             	sub    $0x8,%esp
80109241:	50                   	push   %eax
80109242:	ff 75 f0             	push   -0x10(%ebp)
80109245:	e8 d0 fd ff ff       	call   8010901a <i8254_send>
8010924a:	83 c4 10             	add    $0x10,%esp
    kfree((char *)send);
8010924d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109250:	83 ec 0c             	sub    $0xc,%esp
80109253:	50                   	push   %eax
80109254:	e8 91 99 ff ff       	call   80102bea <kfree>
80109259:	83 c4 10             	add    $0x10,%esp
    return ARP_CREATED_REPLY;
8010925c:	b8 02 00 00 00       	mov    $0x2,%eax
80109261:	eb 54                	jmp    801092b7 <arp_proc+0x171>
  }else if(arp_p->op == ARP_OPS_REPLY && memcmp(my_ip,arp_p->dst_ip,4) == 0){
80109263:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109266:	0f b7 40 06          	movzwl 0x6(%eax),%eax
8010926a:	66 3d 00 02          	cmp    $0x200,%ax
8010926e:	75 42                	jne    801092b2 <arp_proc+0x16c>
80109270:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109273:	83 c0 18             	add    $0x18,%eax
80109276:	83 ec 04             	sub    $0x4,%esp
80109279:	6a 04                	push   $0x4
8010927b:	50                   	push   %eax
8010927c:	68 e4 f4 10 80       	push   $0x8010f4e4
80109281:	e8 44 bc ff ff       	call   80104eca <memcmp>
80109286:	83 c4 10             	add    $0x10,%esp
80109289:	85 c0                	test   %eax,%eax
8010928b:	75 25                	jne    801092b2 <arp_proc+0x16c>
    cprintf("ARP TABLE UPDATED\n");
8010928d:	83 ec 0c             	sub    $0xc,%esp
80109290:	68 9c c3 10 80       	push   $0x8010c39c
80109295:	e8 5a 71 ff ff       	call   801003f4 <cprintf>
8010929a:	83 c4 10             	add    $0x10,%esp
    arp_table_update(arp_p);
8010929d:	83 ec 0c             	sub    $0xc,%esp
801092a0:	ff 75 f4             	push   -0xc(%ebp)
801092a3:	e8 af 01 00 00       	call   80109457 <arp_table_update>
801092a8:	83 c4 10             	add    $0x10,%esp
    return ARP_UPDATED_TABLE;
801092ab:	b8 01 00 00 00       	mov    $0x1,%eax
801092b0:	eb 05                	jmp    801092b7 <arp_proc+0x171>
  }else{
    return -1;
801092b2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
}
801092b7:	c9                   	leave  
801092b8:	c3                   	ret    

801092b9 <arp_scan>:

void arp_scan(){
801092b9:	55                   	push   %ebp
801092ba:	89 e5                	mov    %esp,%ebp
801092bc:	83 ec 18             	sub    $0x18,%esp
  uint send_size;
  for(int i=0;i<256;i++){
801092bf:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801092c6:	eb 6f                	jmp    80109337 <arp_scan+0x7e>
    uint send = (uint)kalloc();
801092c8:	e8 b7 99 ff ff       	call   80102c84 <kalloc>
801092cd:	89 45 ec             	mov    %eax,-0x14(%ebp)
    arp_broadcast(send,&send_size,i);
801092d0:	83 ec 04             	sub    $0x4,%esp
801092d3:	ff 75 f4             	push   -0xc(%ebp)
801092d6:	8d 45 e8             	lea    -0x18(%ebp),%eax
801092d9:	50                   	push   %eax
801092da:	ff 75 ec             	push   -0x14(%ebp)
801092dd:	e8 62 00 00 00       	call   80109344 <arp_broadcast>
801092e2:	83 c4 10             	add    $0x10,%esp
    uint res = i8254_send(send,send_size);
801092e5:	8b 45 e8             	mov    -0x18(%ebp),%eax
801092e8:	83 ec 08             	sub    $0x8,%esp
801092eb:	50                   	push   %eax
801092ec:	ff 75 ec             	push   -0x14(%ebp)
801092ef:	e8 26 fd ff ff       	call   8010901a <i8254_send>
801092f4:	83 c4 10             	add    $0x10,%esp
801092f7:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while(res == -1){
801092fa:	eb 22                	jmp    8010931e <arp_scan+0x65>
      microdelay(1);
801092fc:	83 ec 0c             	sub    $0xc,%esp
801092ff:	6a 01                	push   $0x1
80109301:	e8 15 9d ff ff       	call   8010301b <microdelay>
80109306:	83 c4 10             	add    $0x10,%esp
      res = i8254_send(send,send_size);
80109309:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010930c:	83 ec 08             	sub    $0x8,%esp
8010930f:	50                   	push   %eax
80109310:	ff 75 ec             	push   -0x14(%ebp)
80109313:	e8 02 fd ff ff       	call   8010901a <i8254_send>
80109318:	83 c4 10             	add    $0x10,%esp
8010931b:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while(res == -1){
8010931e:	83 7d f0 ff          	cmpl   $0xffffffff,-0x10(%ebp)
80109322:	74 d8                	je     801092fc <arp_scan+0x43>
    }
    kfree((char *)send);
80109324:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109327:	83 ec 0c             	sub    $0xc,%esp
8010932a:	50                   	push   %eax
8010932b:	e8 ba 98 ff ff       	call   80102bea <kfree>
80109330:	83 c4 10             	add    $0x10,%esp
  for(int i=0;i<256;i++){
80109333:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80109337:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
8010933e:	7e 88                	jle    801092c8 <arp_scan+0xf>
  }
}
80109340:	90                   	nop
80109341:	90                   	nop
80109342:	c9                   	leave  
80109343:	c3                   	ret    

80109344 <arp_broadcast>:

void arp_broadcast(uint send,uint *send_size,uint ip){
80109344:	55                   	push   %ebp
80109345:	89 e5                	mov    %esp,%ebp
80109347:	83 ec 28             	sub    $0x28,%esp
  uchar dst_ip[4] = {10,0,1,ip};
8010934a:	c6 45 ec 0a          	movb   $0xa,-0x14(%ebp)
8010934e:	c6 45 ed 00          	movb   $0x0,-0x13(%ebp)
80109352:	c6 45 ee 01          	movb   $0x1,-0x12(%ebp)
80109356:	8b 45 10             	mov    0x10(%ebp),%eax
80109359:	88 45 ef             	mov    %al,-0x11(%ebp)
  uchar dst_mac_eth[6] = {0xff,0xff,0xff,0xff,0xff,0xff};
8010935c:	c7 45 e6 ff ff ff ff 	movl   $0xffffffff,-0x1a(%ebp)
80109363:	66 c7 45 ea ff ff    	movw   $0xffff,-0x16(%ebp)
  uchar dst_mac_arp[6] = {0,0,0,0,0,0};
80109369:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
80109370:	66 c7 45 e4 00 00    	movw   $0x0,-0x1c(%ebp)
  
  *send_size = sizeof(struct eth_pkt) + sizeof(struct arp_pkt);
80109376:	8b 45 0c             	mov    0xc(%ebp),%eax
80109379:	c7 00 2c 00 00 00    	movl   $0x2c,(%eax)

  struct eth_pkt *reply_eth = (struct eth_pkt *)send;
8010937f:	8b 45 08             	mov    0x8(%ebp),%eax
80109382:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct arp_pkt *reply_arp = (struct arp_pkt *)(send + sizeof(struct eth_pkt));
80109385:	8b 45 08             	mov    0x8(%ebp),%eax
80109388:	83 c0 0e             	add    $0xe,%eax
8010938b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  
  reply_eth->type[0] = 0x08;
8010938e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109391:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  reply_eth->type[1] = 0x06;
80109395:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109398:	c6 40 0d 06          	movb   $0x6,0xd(%eax)
  memmove(reply_eth->dst_mac,dst_mac_eth,6);
8010939c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010939f:	83 ec 04             	sub    $0x4,%esp
801093a2:	6a 06                	push   $0x6
801093a4:	8d 55 e6             	lea    -0x1a(%ebp),%edx
801093a7:	52                   	push   %edx
801093a8:	50                   	push   %eax
801093a9:	e8 74 bb ff ff       	call   80104f22 <memmove>
801093ae:	83 c4 10             	add    $0x10,%esp
  memmove(reply_eth->src_mac,mac_addr,6);
801093b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801093b4:	83 c0 06             	add    $0x6,%eax
801093b7:	83 ec 04             	sub    $0x4,%esp
801093ba:	6a 06                	push   $0x6
801093bc:	68 c0 9e 11 80       	push   $0x80119ec0
801093c1:	50                   	push   %eax
801093c2:	e8 5b bb ff ff       	call   80104f22 <memmove>
801093c7:	83 c4 10             	add    $0x10,%esp

  reply_arp->hrd_type = ARP_HARDWARE_TYPE;
801093ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
801093cd:	66 c7 00 00 01       	movw   $0x100,(%eax)
  reply_arp->pro_type = ARP_PROTOCOL_TYPE;
801093d2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801093d5:	66 c7 40 02 08 00    	movw   $0x8,0x2(%eax)
  reply_arp->hrd_len = 6;
801093db:	8b 45 f0             	mov    -0x10(%ebp),%eax
801093de:	c6 40 04 06          	movb   $0x6,0x4(%eax)
  reply_arp->pro_len = 4;
801093e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801093e5:	c6 40 05 04          	movb   $0x4,0x5(%eax)
  reply_arp->op = ARP_OPS_REQUEST;
801093e9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801093ec:	66 c7 40 06 00 01    	movw   $0x100,0x6(%eax)
  memmove(reply_arp->dst_mac,dst_mac_arp,6);
801093f2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801093f5:	8d 50 12             	lea    0x12(%eax),%edx
801093f8:	83 ec 04             	sub    $0x4,%esp
801093fb:	6a 06                	push   $0x6
801093fd:	8d 45 e0             	lea    -0x20(%ebp),%eax
80109400:	50                   	push   %eax
80109401:	52                   	push   %edx
80109402:	e8 1b bb ff ff       	call   80104f22 <memmove>
80109407:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->dst_ip,dst_ip,4);
8010940a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010940d:	8d 50 18             	lea    0x18(%eax),%edx
80109410:	83 ec 04             	sub    $0x4,%esp
80109413:	6a 04                	push   $0x4
80109415:	8d 45 ec             	lea    -0x14(%ebp),%eax
80109418:	50                   	push   %eax
80109419:	52                   	push   %edx
8010941a:	e8 03 bb ff ff       	call   80104f22 <memmove>
8010941f:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_mac,mac_addr,6);
80109422:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109425:	83 c0 08             	add    $0x8,%eax
80109428:	83 ec 04             	sub    $0x4,%esp
8010942b:	6a 06                	push   $0x6
8010942d:	68 c0 9e 11 80       	push   $0x80119ec0
80109432:	50                   	push   %eax
80109433:	e8 ea ba ff ff       	call   80104f22 <memmove>
80109438:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_ip,my_ip,4);
8010943b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010943e:	83 c0 0e             	add    $0xe,%eax
80109441:	83 ec 04             	sub    $0x4,%esp
80109444:	6a 04                	push   $0x4
80109446:	68 e4 f4 10 80       	push   $0x8010f4e4
8010944b:	50                   	push   %eax
8010944c:	e8 d1 ba ff ff       	call   80104f22 <memmove>
80109451:	83 c4 10             	add    $0x10,%esp
}
80109454:	90                   	nop
80109455:	c9                   	leave  
80109456:	c3                   	ret    

80109457 <arp_table_update>:

void arp_table_update(struct arp_pkt *recv_arp){
80109457:	55                   	push   %ebp
80109458:	89 e5                	mov    %esp,%ebp
8010945a:	83 ec 18             	sub    $0x18,%esp
  int index = arp_table_search(recv_arp->src_ip);
8010945d:	8b 45 08             	mov    0x8(%ebp),%eax
80109460:	83 c0 0e             	add    $0xe,%eax
80109463:	83 ec 0c             	sub    $0xc,%esp
80109466:	50                   	push   %eax
80109467:	e8 bc 00 00 00       	call   80109528 <arp_table_search>
8010946c:	83 c4 10             	add    $0x10,%esp
8010946f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(index > -1){
80109472:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80109476:	78 2d                	js     801094a5 <arp_table_update+0x4e>
    memmove(arp_table[index].mac,recv_arp->src_mac,6);
80109478:	8b 45 08             	mov    0x8(%ebp),%eax
8010947b:	8d 48 08             	lea    0x8(%eax),%ecx
8010947e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109481:	89 d0                	mov    %edx,%eax
80109483:	c1 e0 02             	shl    $0x2,%eax
80109486:	01 d0                	add    %edx,%eax
80109488:	01 c0                	add    %eax,%eax
8010948a:	01 d0                	add    %edx,%eax
8010948c:	05 e0 9e 11 80       	add    $0x80119ee0,%eax
80109491:	83 c0 04             	add    $0x4,%eax
80109494:	83 ec 04             	sub    $0x4,%esp
80109497:	6a 06                	push   $0x6
80109499:	51                   	push   %ecx
8010949a:	50                   	push   %eax
8010949b:	e8 82 ba ff ff       	call   80104f22 <memmove>
801094a0:	83 c4 10             	add    $0x10,%esp
801094a3:	eb 70                	jmp    80109515 <arp_table_update+0xbe>
  }else{
    index += 1;
801094a5:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    index = -index;
801094a9:	f7 5d f4             	negl   -0xc(%ebp)
    memmove(arp_table[index].mac,recv_arp->src_mac,6);
801094ac:	8b 45 08             	mov    0x8(%ebp),%eax
801094af:	8d 48 08             	lea    0x8(%eax),%ecx
801094b2:	8b 55 f4             	mov    -0xc(%ebp),%edx
801094b5:	89 d0                	mov    %edx,%eax
801094b7:	c1 e0 02             	shl    $0x2,%eax
801094ba:	01 d0                	add    %edx,%eax
801094bc:	01 c0                	add    %eax,%eax
801094be:	01 d0                	add    %edx,%eax
801094c0:	05 e0 9e 11 80       	add    $0x80119ee0,%eax
801094c5:	83 c0 04             	add    $0x4,%eax
801094c8:	83 ec 04             	sub    $0x4,%esp
801094cb:	6a 06                	push   $0x6
801094cd:	51                   	push   %ecx
801094ce:	50                   	push   %eax
801094cf:	e8 4e ba ff ff       	call   80104f22 <memmove>
801094d4:	83 c4 10             	add    $0x10,%esp
    memmove(arp_table[index].ip,recv_arp->src_ip,4);
801094d7:	8b 45 08             	mov    0x8(%ebp),%eax
801094da:	8d 48 0e             	lea    0xe(%eax),%ecx
801094dd:	8b 55 f4             	mov    -0xc(%ebp),%edx
801094e0:	89 d0                	mov    %edx,%eax
801094e2:	c1 e0 02             	shl    $0x2,%eax
801094e5:	01 d0                	add    %edx,%eax
801094e7:	01 c0                	add    %eax,%eax
801094e9:	01 d0                	add    %edx,%eax
801094eb:	05 e0 9e 11 80       	add    $0x80119ee0,%eax
801094f0:	83 ec 04             	sub    $0x4,%esp
801094f3:	6a 04                	push   $0x4
801094f5:	51                   	push   %ecx
801094f6:	50                   	push   %eax
801094f7:	e8 26 ba ff ff       	call   80104f22 <memmove>
801094fc:	83 c4 10             	add    $0x10,%esp
    arp_table[index].use = 1;
801094ff:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109502:	89 d0                	mov    %edx,%eax
80109504:	c1 e0 02             	shl    $0x2,%eax
80109507:	01 d0                	add    %edx,%eax
80109509:	01 c0                	add    %eax,%eax
8010950b:	01 d0                	add    %edx,%eax
8010950d:	05 ea 9e 11 80       	add    $0x80119eea,%eax
80109512:	c6 00 01             	movb   $0x1,(%eax)
  }
  print_arp_table(arp_table);
80109515:	83 ec 0c             	sub    $0xc,%esp
80109518:	68 e0 9e 11 80       	push   $0x80119ee0
8010951d:	e8 83 00 00 00       	call   801095a5 <print_arp_table>
80109522:	83 c4 10             	add    $0x10,%esp
}
80109525:	90                   	nop
80109526:	c9                   	leave  
80109527:	c3                   	ret    

80109528 <arp_table_search>:

int arp_table_search(uchar *ip){
80109528:	55                   	push   %ebp
80109529:	89 e5                	mov    %esp,%ebp
8010952b:	83 ec 18             	sub    $0x18,%esp
  int empty=1;
8010952e:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
  for(int i=0;i<ARP_TABLE_MAX;i++){
80109535:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
8010953c:	eb 59                	jmp    80109597 <arp_table_search+0x6f>
    if(memcmp(arp_table[i].ip,ip,4) == 0){
8010953e:	8b 55 f0             	mov    -0x10(%ebp),%edx
80109541:	89 d0                	mov    %edx,%eax
80109543:	c1 e0 02             	shl    $0x2,%eax
80109546:	01 d0                	add    %edx,%eax
80109548:	01 c0                	add    %eax,%eax
8010954a:	01 d0                	add    %edx,%eax
8010954c:	05 e0 9e 11 80       	add    $0x80119ee0,%eax
80109551:	83 ec 04             	sub    $0x4,%esp
80109554:	6a 04                	push   $0x4
80109556:	ff 75 08             	push   0x8(%ebp)
80109559:	50                   	push   %eax
8010955a:	e8 6b b9 ff ff       	call   80104eca <memcmp>
8010955f:	83 c4 10             	add    $0x10,%esp
80109562:	85 c0                	test   %eax,%eax
80109564:	75 05                	jne    8010956b <arp_table_search+0x43>
      return i;
80109566:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109569:	eb 38                	jmp    801095a3 <arp_table_search+0x7b>
    }
    if(arp_table[i].use == 0 && empty == 1){
8010956b:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010956e:	89 d0                	mov    %edx,%eax
80109570:	c1 e0 02             	shl    $0x2,%eax
80109573:	01 d0                	add    %edx,%eax
80109575:	01 c0                	add    %eax,%eax
80109577:	01 d0                	add    %edx,%eax
80109579:	05 ea 9e 11 80       	add    $0x80119eea,%eax
8010957e:	0f b6 00             	movzbl (%eax),%eax
80109581:	84 c0                	test   %al,%al
80109583:	75 0e                	jne    80109593 <arp_table_search+0x6b>
80109585:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
80109589:	75 08                	jne    80109593 <arp_table_search+0x6b>
      empty = -i;
8010958b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010958e:	f7 d8                	neg    %eax
80109590:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(int i=0;i<ARP_TABLE_MAX;i++){
80109593:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80109597:	83 7d f0 3f          	cmpl   $0x3f,-0x10(%ebp)
8010959b:	7e a1                	jle    8010953e <arp_table_search+0x16>
    }
  }
  return empty-1;
8010959d:	8b 45 f4             	mov    -0xc(%ebp),%eax
801095a0:	83 e8 01             	sub    $0x1,%eax
}
801095a3:	c9                   	leave  
801095a4:	c3                   	ret    

801095a5 <print_arp_table>:

void print_arp_table(){
801095a5:	55                   	push   %ebp
801095a6:	89 e5                	mov    %esp,%ebp
801095a8:	83 ec 18             	sub    $0x18,%esp
  for(int i=0;i < ARP_TABLE_MAX;i++){
801095ab:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801095b2:	e9 92 00 00 00       	jmp    80109649 <print_arp_table+0xa4>
    if(arp_table[i].use != 0){
801095b7:	8b 55 f4             	mov    -0xc(%ebp),%edx
801095ba:	89 d0                	mov    %edx,%eax
801095bc:	c1 e0 02             	shl    $0x2,%eax
801095bf:	01 d0                	add    %edx,%eax
801095c1:	01 c0                	add    %eax,%eax
801095c3:	01 d0                	add    %edx,%eax
801095c5:	05 ea 9e 11 80       	add    $0x80119eea,%eax
801095ca:	0f b6 00             	movzbl (%eax),%eax
801095cd:	84 c0                	test   %al,%al
801095cf:	74 74                	je     80109645 <print_arp_table+0xa0>
      cprintf("Entry Num: %d ",i);
801095d1:	83 ec 08             	sub    $0x8,%esp
801095d4:	ff 75 f4             	push   -0xc(%ebp)
801095d7:	68 af c3 10 80       	push   $0x8010c3af
801095dc:	e8 13 6e ff ff       	call   801003f4 <cprintf>
801095e1:	83 c4 10             	add    $0x10,%esp
      print_ipv4(arp_table[i].ip);
801095e4:	8b 55 f4             	mov    -0xc(%ebp),%edx
801095e7:	89 d0                	mov    %edx,%eax
801095e9:	c1 e0 02             	shl    $0x2,%eax
801095ec:	01 d0                	add    %edx,%eax
801095ee:	01 c0                	add    %eax,%eax
801095f0:	01 d0                	add    %edx,%eax
801095f2:	05 e0 9e 11 80       	add    $0x80119ee0,%eax
801095f7:	83 ec 0c             	sub    $0xc,%esp
801095fa:	50                   	push   %eax
801095fb:	e8 54 02 00 00       	call   80109854 <print_ipv4>
80109600:	83 c4 10             	add    $0x10,%esp
      cprintf(" ");
80109603:	83 ec 0c             	sub    $0xc,%esp
80109606:	68 be c3 10 80       	push   $0x8010c3be
8010960b:	e8 e4 6d ff ff       	call   801003f4 <cprintf>
80109610:	83 c4 10             	add    $0x10,%esp
      print_mac(arp_table[i].mac);
80109613:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109616:	89 d0                	mov    %edx,%eax
80109618:	c1 e0 02             	shl    $0x2,%eax
8010961b:	01 d0                	add    %edx,%eax
8010961d:	01 c0                	add    %eax,%eax
8010961f:	01 d0                	add    %edx,%eax
80109621:	05 e0 9e 11 80       	add    $0x80119ee0,%eax
80109626:	83 c0 04             	add    $0x4,%eax
80109629:	83 ec 0c             	sub    $0xc,%esp
8010962c:	50                   	push   %eax
8010962d:	e8 70 02 00 00       	call   801098a2 <print_mac>
80109632:	83 c4 10             	add    $0x10,%esp
      cprintf("\n");
80109635:	83 ec 0c             	sub    $0xc,%esp
80109638:	68 c0 c3 10 80       	push   $0x8010c3c0
8010963d:	e8 b2 6d ff ff       	call   801003f4 <cprintf>
80109642:	83 c4 10             	add    $0x10,%esp
  for(int i=0;i < ARP_TABLE_MAX;i++){
80109645:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80109649:	83 7d f4 3f          	cmpl   $0x3f,-0xc(%ebp)
8010964d:	0f 8e 64 ff ff ff    	jle    801095b7 <print_arp_table+0x12>
    }
  }
}
80109653:	90                   	nop
80109654:	90                   	nop
80109655:	c9                   	leave  
80109656:	c3                   	ret    

80109657 <arp_reply_pkt_create>:


void arp_reply_pkt_create(struct arp_pkt *arp_recv,uint send,uint *send_size){
80109657:	55                   	push   %ebp
80109658:	89 e5                	mov    %esp,%ebp
8010965a:	83 ec 18             	sub    $0x18,%esp
  *send_size = sizeof(struct eth_pkt) + sizeof(struct arp_pkt);
8010965d:	8b 45 10             	mov    0x10(%ebp),%eax
80109660:	c7 00 2c 00 00 00    	movl   $0x2c,(%eax)
  
  struct eth_pkt *reply_eth = (struct eth_pkt *)send;
80109666:	8b 45 0c             	mov    0xc(%ebp),%eax
80109669:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct arp_pkt *reply_arp = (struct arp_pkt *)(send + sizeof(struct eth_pkt));
8010966c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010966f:	83 c0 0e             	add    $0xe,%eax
80109672:	89 45 f0             	mov    %eax,-0x10(%ebp)

  reply_eth->type[0] = 0x08;
80109675:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109678:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  reply_eth->type[1] = 0x06;
8010967c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010967f:	c6 40 0d 06          	movb   $0x6,0xd(%eax)
  memmove(reply_eth->dst_mac,arp_recv->src_mac,6);
80109683:	8b 45 08             	mov    0x8(%ebp),%eax
80109686:	8d 50 08             	lea    0x8(%eax),%edx
80109689:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010968c:	83 ec 04             	sub    $0x4,%esp
8010968f:	6a 06                	push   $0x6
80109691:	52                   	push   %edx
80109692:	50                   	push   %eax
80109693:	e8 8a b8 ff ff       	call   80104f22 <memmove>
80109698:	83 c4 10             	add    $0x10,%esp
  memmove(reply_eth->src_mac,mac_addr,6);
8010969b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010969e:	83 c0 06             	add    $0x6,%eax
801096a1:	83 ec 04             	sub    $0x4,%esp
801096a4:	6a 06                	push   $0x6
801096a6:	68 c0 9e 11 80       	push   $0x80119ec0
801096ab:	50                   	push   %eax
801096ac:	e8 71 b8 ff ff       	call   80104f22 <memmove>
801096b1:	83 c4 10             	add    $0x10,%esp

  reply_arp->hrd_type = ARP_HARDWARE_TYPE;
801096b4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801096b7:	66 c7 00 00 01       	movw   $0x100,(%eax)
  reply_arp->pro_type = ARP_PROTOCOL_TYPE;
801096bc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801096bf:	66 c7 40 02 08 00    	movw   $0x8,0x2(%eax)
  reply_arp->hrd_len = 6;
801096c5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801096c8:	c6 40 04 06          	movb   $0x6,0x4(%eax)
  reply_arp->pro_len = 4;
801096cc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801096cf:	c6 40 05 04          	movb   $0x4,0x5(%eax)
  reply_arp->op = ARP_OPS_REPLY;
801096d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801096d6:	66 c7 40 06 00 02    	movw   $0x200,0x6(%eax)
  memmove(reply_arp->dst_mac,arp_recv->src_mac,6);
801096dc:	8b 45 08             	mov    0x8(%ebp),%eax
801096df:	8d 50 08             	lea    0x8(%eax),%edx
801096e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801096e5:	83 c0 12             	add    $0x12,%eax
801096e8:	83 ec 04             	sub    $0x4,%esp
801096eb:	6a 06                	push   $0x6
801096ed:	52                   	push   %edx
801096ee:	50                   	push   %eax
801096ef:	e8 2e b8 ff ff       	call   80104f22 <memmove>
801096f4:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->dst_ip,arp_recv->src_ip,4);
801096f7:	8b 45 08             	mov    0x8(%ebp),%eax
801096fa:	8d 50 0e             	lea    0xe(%eax),%edx
801096fd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109700:	83 c0 18             	add    $0x18,%eax
80109703:	83 ec 04             	sub    $0x4,%esp
80109706:	6a 04                	push   $0x4
80109708:	52                   	push   %edx
80109709:	50                   	push   %eax
8010970a:	e8 13 b8 ff ff       	call   80104f22 <memmove>
8010970f:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_mac,mac_addr,6);
80109712:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109715:	83 c0 08             	add    $0x8,%eax
80109718:	83 ec 04             	sub    $0x4,%esp
8010971b:	6a 06                	push   $0x6
8010971d:	68 c0 9e 11 80       	push   $0x80119ec0
80109722:	50                   	push   %eax
80109723:	e8 fa b7 ff ff       	call   80104f22 <memmove>
80109728:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_ip,my_ip,4);
8010972b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010972e:	83 c0 0e             	add    $0xe,%eax
80109731:	83 ec 04             	sub    $0x4,%esp
80109734:	6a 04                	push   $0x4
80109736:	68 e4 f4 10 80       	push   $0x8010f4e4
8010973b:	50                   	push   %eax
8010973c:	e8 e1 b7 ff ff       	call   80104f22 <memmove>
80109741:	83 c4 10             	add    $0x10,%esp
}
80109744:	90                   	nop
80109745:	c9                   	leave  
80109746:	c3                   	ret    

80109747 <print_arp_info>:

void print_arp_info(struct arp_pkt* arp_p){
80109747:	55                   	push   %ebp
80109748:	89 e5                	mov    %esp,%ebp
8010974a:	83 ec 08             	sub    $0x8,%esp
  cprintf("--------Source-------\n");
8010974d:	83 ec 0c             	sub    $0xc,%esp
80109750:	68 c2 c3 10 80       	push   $0x8010c3c2
80109755:	e8 9a 6c ff ff       	call   801003f4 <cprintf>
8010975a:	83 c4 10             	add    $0x10,%esp
  print_ipv4(arp_p->src_ip);
8010975d:	8b 45 08             	mov    0x8(%ebp),%eax
80109760:	83 c0 0e             	add    $0xe,%eax
80109763:	83 ec 0c             	sub    $0xc,%esp
80109766:	50                   	push   %eax
80109767:	e8 e8 00 00 00       	call   80109854 <print_ipv4>
8010976c:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
8010976f:	83 ec 0c             	sub    $0xc,%esp
80109772:	68 c0 c3 10 80       	push   $0x8010c3c0
80109777:	e8 78 6c ff ff       	call   801003f4 <cprintf>
8010977c:	83 c4 10             	add    $0x10,%esp
  print_mac(arp_p->src_mac);
8010977f:	8b 45 08             	mov    0x8(%ebp),%eax
80109782:	83 c0 08             	add    $0x8,%eax
80109785:	83 ec 0c             	sub    $0xc,%esp
80109788:	50                   	push   %eax
80109789:	e8 14 01 00 00       	call   801098a2 <print_mac>
8010978e:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
80109791:	83 ec 0c             	sub    $0xc,%esp
80109794:	68 c0 c3 10 80       	push   $0x8010c3c0
80109799:	e8 56 6c ff ff       	call   801003f4 <cprintf>
8010979e:	83 c4 10             	add    $0x10,%esp
  cprintf("-----Destination-----\n");
801097a1:	83 ec 0c             	sub    $0xc,%esp
801097a4:	68 d9 c3 10 80       	push   $0x8010c3d9
801097a9:	e8 46 6c ff ff       	call   801003f4 <cprintf>
801097ae:	83 c4 10             	add    $0x10,%esp
  print_ipv4(arp_p->dst_ip);
801097b1:	8b 45 08             	mov    0x8(%ebp),%eax
801097b4:	83 c0 18             	add    $0x18,%eax
801097b7:	83 ec 0c             	sub    $0xc,%esp
801097ba:	50                   	push   %eax
801097bb:	e8 94 00 00 00       	call   80109854 <print_ipv4>
801097c0:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
801097c3:	83 ec 0c             	sub    $0xc,%esp
801097c6:	68 c0 c3 10 80       	push   $0x8010c3c0
801097cb:	e8 24 6c ff ff       	call   801003f4 <cprintf>
801097d0:	83 c4 10             	add    $0x10,%esp
  print_mac(arp_p->dst_mac);
801097d3:	8b 45 08             	mov    0x8(%ebp),%eax
801097d6:	83 c0 12             	add    $0x12,%eax
801097d9:	83 ec 0c             	sub    $0xc,%esp
801097dc:	50                   	push   %eax
801097dd:	e8 c0 00 00 00       	call   801098a2 <print_mac>
801097e2:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
801097e5:	83 ec 0c             	sub    $0xc,%esp
801097e8:	68 c0 c3 10 80       	push   $0x8010c3c0
801097ed:	e8 02 6c ff ff       	call   801003f4 <cprintf>
801097f2:	83 c4 10             	add    $0x10,%esp
  cprintf("Operation: ");
801097f5:	83 ec 0c             	sub    $0xc,%esp
801097f8:	68 f0 c3 10 80       	push   $0x8010c3f0
801097fd:	e8 f2 6b ff ff       	call   801003f4 <cprintf>
80109802:	83 c4 10             	add    $0x10,%esp
  if(arp_p->op == ARP_OPS_REQUEST) cprintf("Request\n");
80109805:	8b 45 08             	mov    0x8(%ebp),%eax
80109808:	0f b7 40 06          	movzwl 0x6(%eax),%eax
8010980c:	66 3d 00 01          	cmp    $0x100,%ax
80109810:	75 12                	jne    80109824 <print_arp_info+0xdd>
80109812:	83 ec 0c             	sub    $0xc,%esp
80109815:	68 fc c3 10 80       	push   $0x8010c3fc
8010981a:	e8 d5 6b ff ff       	call   801003f4 <cprintf>
8010981f:	83 c4 10             	add    $0x10,%esp
80109822:	eb 1d                	jmp    80109841 <print_arp_info+0xfa>
  else if(arp_p->op == ARP_OPS_REPLY) {
80109824:	8b 45 08             	mov    0x8(%ebp),%eax
80109827:	0f b7 40 06          	movzwl 0x6(%eax),%eax
8010982b:	66 3d 00 02          	cmp    $0x200,%ax
8010982f:	75 10                	jne    80109841 <print_arp_info+0xfa>
    cprintf("Reply\n");
80109831:	83 ec 0c             	sub    $0xc,%esp
80109834:	68 05 c4 10 80       	push   $0x8010c405
80109839:	e8 b6 6b ff ff       	call   801003f4 <cprintf>
8010983e:	83 c4 10             	add    $0x10,%esp
  }
  cprintf("\n");
80109841:	83 ec 0c             	sub    $0xc,%esp
80109844:	68 c0 c3 10 80       	push   $0x8010c3c0
80109849:	e8 a6 6b ff ff       	call   801003f4 <cprintf>
8010984e:	83 c4 10             	add    $0x10,%esp
}
80109851:	90                   	nop
80109852:	c9                   	leave  
80109853:	c3                   	ret    

80109854 <print_ipv4>:

void print_ipv4(uchar *ip){
80109854:	55                   	push   %ebp
80109855:	89 e5                	mov    %esp,%ebp
80109857:	53                   	push   %ebx
80109858:	83 ec 04             	sub    $0x4,%esp
  cprintf("IP address: %d.%d.%d.%d",ip[0],ip[1],ip[2],ip[3]);
8010985b:	8b 45 08             	mov    0x8(%ebp),%eax
8010985e:	83 c0 03             	add    $0x3,%eax
80109861:	0f b6 00             	movzbl (%eax),%eax
80109864:	0f b6 d8             	movzbl %al,%ebx
80109867:	8b 45 08             	mov    0x8(%ebp),%eax
8010986a:	83 c0 02             	add    $0x2,%eax
8010986d:	0f b6 00             	movzbl (%eax),%eax
80109870:	0f b6 c8             	movzbl %al,%ecx
80109873:	8b 45 08             	mov    0x8(%ebp),%eax
80109876:	83 c0 01             	add    $0x1,%eax
80109879:	0f b6 00             	movzbl (%eax),%eax
8010987c:	0f b6 d0             	movzbl %al,%edx
8010987f:	8b 45 08             	mov    0x8(%ebp),%eax
80109882:	0f b6 00             	movzbl (%eax),%eax
80109885:	0f b6 c0             	movzbl %al,%eax
80109888:	83 ec 0c             	sub    $0xc,%esp
8010988b:	53                   	push   %ebx
8010988c:	51                   	push   %ecx
8010988d:	52                   	push   %edx
8010988e:	50                   	push   %eax
8010988f:	68 0c c4 10 80       	push   $0x8010c40c
80109894:	e8 5b 6b ff ff       	call   801003f4 <cprintf>
80109899:	83 c4 20             	add    $0x20,%esp
}
8010989c:	90                   	nop
8010989d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801098a0:	c9                   	leave  
801098a1:	c3                   	ret    

801098a2 <print_mac>:

void print_mac(uchar *mac){
801098a2:	55                   	push   %ebp
801098a3:	89 e5                	mov    %esp,%ebp
801098a5:	57                   	push   %edi
801098a6:	56                   	push   %esi
801098a7:	53                   	push   %ebx
801098a8:	83 ec 0c             	sub    $0xc,%esp
  cprintf("MAC address: %x:%x:%x:%x:%x:%x",mac[0],mac[1],mac[2],mac[3],mac[4],mac[5]);
801098ab:	8b 45 08             	mov    0x8(%ebp),%eax
801098ae:	83 c0 05             	add    $0x5,%eax
801098b1:	0f b6 00             	movzbl (%eax),%eax
801098b4:	0f b6 f8             	movzbl %al,%edi
801098b7:	8b 45 08             	mov    0x8(%ebp),%eax
801098ba:	83 c0 04             	add    $0x4,%eax
801098bd:	0f b6 00             	movzbl (%eax),%eax
801098c0:	0f b6 f0             	movzbl %al,%esi
801098c3:	8b 45 08             	mov    0x8(%ebp),%eax
801098c6:	83 c0 03             	add    $0x3,%eax
801098c9:	0f b6 00             	movzbl (%eax),%eax
801098cc:	0f b6 d8             	movzbl %al,%ebx
801098cf:	8b 45 08             	mov    0x8(%ebp),%eax
801098d2:	83 c0 02             	add    $0x2,%eax
801098d5:	0f b6 00             	movzbl (%eax),%eax
801098d8:	0f b6 c8             	movzbl %al,%ecx
801098db:	8b 45 08             	mov    0x8(%ebp),%eax
801098de:	83 c0 01             	add    $0x1,%eax
801098e1:	0f b6 00             	movzbl (%eax),%eax
801098e4:	0f b6 d0             	movzbl %al,%edx
801098e7:	8b 45 08             	mov    0x8(%ebp),%eax
801098ea:	0f b6 00             	movzbl (%eax),%eax
801098ed:	0f b6 c0             	movzbl %al,%eax
801098f0:	83 ec 04             	sub    $0x4,%esp
801098f3:	57                   	push   %edi
801098f4:	56                   	push   %esi
801098f5:	53                   	push   %ebx
801098f6:	51                   	push   %ecx
801098f7:	52                   	push   %edx
801098f8:	50                   	push   %eax
801098f9:	68 24 c4 10 80       	push   $0x8010c424
801098fe:	e8 f1 6a ff ff       	call   801003f4 <cprintf>
80109903:	83 c4 20             	add    $0x20,%esp
}
80109906:	90                   	nop
80109907:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010990a:	5b                   	pop    %ebx
8010990b:	5e                   	pop    %esi
8010990c:	5f                   	pop    %edi
8010990d:	5d                   	pop    %ebp
8010990e:	c3                   	ret    

8010990f <eth_proc>:
#include "arp.h"
#include "types.h"
#include "eth.h"
#include "defs.h"
#include "ipv4.h"
void eth_proc(uint buffer_addr){
8010990f:	55                   	push   %ebp
80109910:	89 e5                	mov    %esp,%ebp
80109912:	83 ec 18             	sub    $0x18,%esp
  struct eth_pkt *eth_pkt = (struct eth_pkt *)buffer_addr;
80109915:	8b 45 08             	mov    0x8(%ebp),%eax
80109918:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint pkt_addr = buffer_addr+sizeof(struct eth_pkt);
8010991b:	8b 45 08             	mov    0x8(%ebp),%eax
8010991e:	83 c0 0e             	add    $0xe,%eax
80109921:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x06){
80109924:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109927:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
8010992b:	3c 08                	cmp    $0x8,%al
8010992d:	75 1b                	jne    8010994a <eth_proc+0x3b>
8010992f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109932:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
80109936:	3c 06                	cmp    $0x6,%al
80109938:	75 10                	jne    8010994a <eth_proc+0x3b>
    arp_proc(pkt_addr);
8010993a:	83 ec 0c             	sub    $0xc,%esp
8010993d:	ff 75 f0             	push   -0x10(%ebp)
80109940:	e8 01 f8 ff ff       	call   80109146 <arp_proc>
80109945:	83 c4 10             	add    $0x10,%esp
  }else if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x00){
    ipv4_proc(buffer_addr);
  }else{
  }
}
80109948:	eb 24                	jmp    8010996e <eth_proc+0x5f>
  }else if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x00){
8010994a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010994d:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
80109951:	3c 08                	cmp    $0x8,%al
80109953:	75 19                	jne    8010996e <eth_proc+0x5f>
80109955:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109958:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
8010995c:	84 c0                	test   %al,%al
8010995e:	75 0e                	jne    8010996e <eth_proc+0x5f>
    ipv4_proc(buffer_addr);
80109960:	83 ec 0c             	sub    $0xc,%esp
80109963:	ff 75 08             	push   0x8(%ebp)
80109966:	e8 a3 00 00 00       	call   80109a0e <ipv4_proc>
8010996b:	83 c4 10             	add    $0x10,%esp
}
8010996e:	90                   	nop
8010996f:	c9                   	leave  
80109970:	c3                   	ret    

80109971 <N2H_ushort>:

ushort N2H_ushort(ushort value){
80109971:	55                   	push   %ebp
80109972:	89 e5                	mov    %esp,%ebp
80109974:	83 ec 04             	sub    $0x4,%esp
80109977:	8b 45 08             	mov    0x8(%ebp),%eax
8010997a:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  return (((value)&0xFF)<<8)+(value>>8);
8010997e:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80109982:	c1 e0 08             	shl    $0x8,%eax
80109985:	89 c2                	mov    %eax,%edx
80109987:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
8010998b:	66 c1 e8 08          	shr    $0x8,%ax
8010998f:	01 d0                	add    %edx,%eax
}
80109991:	c9                   	leave  
80109992:	c3                   	ret    

80109993 <H2N_ushort>:

ushort H2N_ushort(ushort value){
80109993:	55                   	push   %ebp
80109994:	89 e5                	mov    %esp,%ebp
80109996:	83 ec 04             	sub    $0x4,%esp
80109999:	8b 45 08             	mov    0x8(%ebp),%eax
8010999c:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  return (((value)&0xFF)<<8)+(value>>8);
801099a0:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
801099a4:	c1 e0 08             	shl    $0x8,%eax
801099a7:	89 c2                	mov    %eax,%edx
801099a9:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
801099ad:	66 c1 e8 08          	shr    $0x8,%ax
801099b1:	01 d0                	add    %edx,%eax
}
801099b3:	c9                   	leave  
801099b4:	c3                   	ret    

801099b5 <H2N_uint>:

uint H2N_uint(uint value){
801099b5:	55                   	push   %ebp
801099b6:	89 e5                	mov    %esp,%ebp
  return ((value&0xF)<<24)+((value&0xF0)<<8)+((value&0xF00)>>8)+((value&0xF000)>>24);
801099b8:	8b 45 08             	mov    0x8(%ebp),%eax
801099bb:	c1 e0 18             	shl    $0x18,%eax
801099be:	25 00 00 00 0f       	and    $0xf000000,%eax
801099c3:	89 c2                	mov    %eax,%edx
801099c5:	8b 45 08             	mov    0x8(%ebp),%eax
801099c8:	c1 e0 08             	shl    $0x8,%eax
801099cb:	25 00 f0 00 00       	and    $0xf000,%eax
801099d0:	09 c2                	or     %eax,%edx
801099d2:	8b 45 08             	mov    0x8(%ebp),%eax
801099d5:	c1 e8 08             	shr    $0x8,%eax
801099d8:	83 e0 0f             	and    $0xf,%eax
801099db:	01 d0                	add    %edx,%eax
}
801099dd:	5d                   	pop    %ebp
801099de:	c3                   	ret    

801099df <N2H_uint>:

uint N2H_uint(uint value){
801099df:	55                   	push   %ebp
801099e0:	89 e5                	mov    %esp,%ebp
  return ((value&0xFF)<<24)+((value&0xFF00)<<8)+((value&0xFF0000)>>8)+((value&0xFF000000)>>24);
801099e2:	8b 45 08             	mov    0x8(%ebp),%eax
801099e5:	c1 e0 18             	shl    $0x18,%eax
801099e8:	89 c2                	mov    %eax,%edx
801099ea:	8b 45 08             	mov    0x8(%ebp),%eax
801099ed:	c1 e0 08             	shl    $0x8,%eax
801099f0:	25 00 00 ff 00       	and    $0xff0000,%eax
801099f5:	01 c2                	add    %eax,%edx
801099f7:	8b 45 08             	mov    0x8(%ebp),%eax
801099fa:	c1 e8 08             	shr    $0x8,%eax
801099fd:	25 00 ff 00 00       	and    $0xff00,%eax
80109a02:	01 c2                	add    %eax,%edx
80109a04:	8b 45 08             	mov    0x8(%ebp),%eax
80109a07:	c1 e8 18             	shr    $0x18,%eax
80109a0a:	01 d0                	add    %edx,%eax
}
80109a0c:	5d                   	pop    %ebp
80109a0d:	c3                   	ret    

80109a0e <ipv4_proc>:
extern uchar mac_addr[6];
extern uchar my_ip[4];

int ip_id = -1;
ushort send_id = 0;
void ipv4_proc(uint buffer_addr){
80109a0e:	55                   	push   %ebp
80109a0f:	89 e5                	mov    %esp,%ebp
80109a11:	83 ec 18             	sub    $0x18,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(buffer_addr+14);
80109a14:	8b 45 08             	mov    0x8(%ebp),%eax
80109a17:	83 c0 0e             	add    $0xe,%eax
80109a1a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(ip_id != ipv4_p->id && memcmp(my_ip,ipv4_p->src_ip,4) != 0){
80109a1d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109a20:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80109a24:	0f b7 d0             	movzwl %ax,%edx
80109a27:	a1 e8 f4 10 80       	mov    0x8010f4e8,%eax
80109a2c:	39 c2                	cmp    %eax,%edx
80109a2e:	74 60                	je     80109a90 <ipv4_proc+0x82>
80109a30:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109a33:	83 c0 0c             	add    $0xc,%eax
80109a36:	83 ec 04             	sub    $0x4,%esp
80109a39:	6a 04                	push   $0x4
80109a3b:	50                   	push   %eax
80109a3c:	68 e4 f4 10 80       	push   $0x8010f4e4
80109a41:	e8 84 b4 ff ff       	call   80104eca <memcmp>
80109a46:	83 c4 10             	add    $0x10,%esp
80109a49:	85 c0                	test   %eax,%eax
80109a4b:	74 43                	je     80109a90 <ipv4_proc+0x82>
    ip_id = ipv4_p->id;
80109a4d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109a50:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80109a54:	0f b7 c0             	movzwl %ax,%eax
80109a57:	a3 e8 f4 10 80       	mov    %eax,0x8010f4e8
      if(ipv4_p->protocol == IPV4_TYPE_ICMP){
80109a5c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109a5f:	0f b6 40 09          	movzbl 0x9(%eax),%eax
80109a63:	3c 01                	cmp    $0x1,%al
80109a65:	75 10                	jne    80109a77 <ipv4_proc+0x69>
        icmp_proc(buffer_addr);
80109a67:	83 ec 0c             	sub    $0xc,%esp
80109a6a:	ff 75 08             	push   0x8(%ebp)
80109a6d:	e8 a3 00 00 00       	call   80109b15 <icmp_proc>
80109a72:	83 c4 10             	add    $0x10,%esp
      }else if(ipv4_p->protocol == IPV4_TYPE_TCP){
        tcp_proc(buffer_addr);
      }
  }
}
80109a75:	eb 19                	jmp    80109a90 <ipv4_proc+0x82>
      }else if(ipv4_p->protocol == IPV4_TYPE_TCP){
80109a77:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109a7a:	0f b6 40 09          	movzbl 0x9(%eax),%eax
80109a7e:	3c 06                	cmp    $0x6,%al
80109a80:	75 0e                	jne    80109a90 <ipv4_proc+0x82>
        tcp_proc(buffer_addr);
80109a82:	83 ec 0c             	sub    $0xc,%esp
80109a85:	ff 75 08             	push   0x8(%ebp)
80109a88:	e8 b3 03 00 00       	call   80109e40 <tcp_proc>
80109a8d:	83 c4 10             	add    $0x10,%esp
}
80109a90:	90                   	nop
80109a91:	c9                   	leave  
80109a92:	c3                   	ret    

80109a93 <ipv4_chksum>:

ushort ipv4_chksum(uint ipv4_addr){
80109a93:	55                   	push   %ebp
80109a94:	89 e5                	mov    %esp,%ebp
80109a96:	83 ec 10             	sub    $0x10,%esp
  uchar* bin = (uchar *)ipv4_addr;
80109a99:	8b 45 08             	mov    0x8(%ebp),%eax
80109a9c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uchar len = (bin[0]&0xF)*2;
80109a9f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109aa2:	0f b6 00             	movzbl (%eax),%eax
80109aa5:	83 e0 0f             	and    $0xf,%eax
80109aa8:	01 c0                	add    %eax,%eax
80109aaa:	88 45 f3             	mov    %al,-0xd(%ebp)
  uint chk_sum = 0;
80109aad:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  for(int i=0;i<len;i++){
80109ab4:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80109abb:	eb 48                	jmp    80109b05 <ipv4_chksum+0x72>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
80109abd:	8b 45 f8             	mov    -0x8(%ebp),%eax
80109ac0:	01 c0                	add    %eax,%eax
80109ac2:	89 c2                	mov    %eax,%edx
80109ac4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109ac7:	01 d0                	add    %edx,%eax
80109ac9:	0f b6 00             	movzbl (%eax),%eax
80109acc:	0f b6 c0             	movzbl %al,%eax
80109acf:	c1 e0 08             	shl    $0x8,%eax
80109ad2:	89 c2                	mov    %eax,%edx
80109ad4:	8b 45 f8             	mov    -0x8(%ebp),%eax
80109ad7:	01 c0                	add    %eax,%eax
80109ad9:	8d 48 01             	lea    0x1(%eax),%ecx
80109adc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109adf:	01 c8                	add    %ecx,%eax
80109ae1:	0f b6 00             	movzbl (%eax),%eax
80109ae4:	0f b6 c0             	movzbl %al,%eax
80109ae7:	01 d0                	add    %edx,%eax
80109ae9:	01 45 fc             	add    %eax,-0x4(%ebp)
    if(chk_sum > 0xFFFF){
80109aec:	81 7d fc ff ff 00 00 	cmpl   $0xffff,-0x4(%ebp)
80109af3:	76 0c                	jbe    80109b01 <ipv4_chksum+0x6e>
      chk_sum = (chk_sum&0xFFFF)+1;
80109af5:	8b 45 fc             	mov    -0x4(%ebp),%eax
80109af8:	0f b7 c0             	movzwl %ax,%eax
80109afb:	83 c0 01             	add    $0x1,%eax
80109afe:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(int i=0;i<len;i++){
80109b01:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80109b05:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
80109b09:	39 45 f8             	cmp    %eax,-0x8(%ebp)
80109b0c:	7c af                	jl     80109abd <ipv4_chksum+0x2a>
    }
  }
  return ~(chk_sum);
80109b0e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80109b11:	f7 d0                	not    %eax
}
80109b13:	c9                   	leave  
80109b14:	c3                   	ret    

80109b15 <icmp_proc>:
#include "eth.h"

extern uchar mac_addr[6];
extern uchar my_ip[4];
extern ushort send_id;
void icmp_proc(uint buffer_addr){
80109b15:	55                   	push   %ebp
80109b16:	89 e5                	mov    %esp,%ebp
80109b18:	83 ec 18             	sub    $0x18,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(buffer_addr+sizeof(struct eth_pkt));
80109b1b:	8b 45 08             	mov    0x8(%ebp),%eax
80109b1e:	83 c0 0e             	add    $0xe,%eax
80109b21:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct icmp_echo_pkt *icmp_p = (struct icmp_echo_pkt *)((uint)ipv4_p + (ipv4_p->ver&0xF)*4);
80109b24:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109b27:	0f b6 00             	movzbl (%eax),%eax
80109b2a:	0f b6 c0             	movzbl %al,%eax
80109b2d:	83 e0 0f             	and    $0xf,%eax
80109b30:	c1 e0 02             	shl    $0x2,%eax
80109b33:	89 c2                	mov    %eax,%edx
80109b35:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109b38:	01 d0                	add    %edx,%eax
80109b3a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(icmp_p->code == 0){
80109b3d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109b40:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80109b44:	84 c0                	test   %al,%al
80109b46:	75 4f                	jne    80109b97 <icmp_proc+0x82>
    if(icmp_p->type == ICMP_TYPE_ECHO_REQUEST){
80109b48:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109b4b:	0f b6 00             	movzbl (%eax),%eax
80109b4e:	3c 08                	cmp    $0x8,%al
80109b50:	75 45                	jne    80109b97 <icmp_proc+0x82>
      uint send_addr = (uint)kalloc();
80109b52:	e8 2d 91 ff ff       	call   80102c84 <kalloc>
80109b57:	89 45 ec             	mov    %eax,-0x14(%ebp)
      uint send_size = 0;
80109b5a:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
      icmp_reply_pkt_create(buffer_addr,send_addr,&send_size);
80109b61:	83 ec 04             	sub    $0x4,%esp
80109b64:	8d 45 e8             	lea    -0x18(%ebp),%eax
80109b67:	50                   	push   %eax
80109b68:	ff 75 ec             	push   -0x14(%ebp)
80109b6b:	ff 75 08             	push   0x8(%ebp)
80109b6e:	e8 78 00 00 00       	call   80109beb <icmp_reply_pkt_create>
80109b73:	83 c4 10             	add    $0x10,%esp
      i8254_send(send_addr,send_size);
80109b76:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109b79:	83 ec 08             	sub    $0x8,%esp
80109b7c:	50                   	push   %eax
80109b7d:	ff 75 ec             	push   -0x14(%ebp)
80109b80:	e8 95 f4 ff ff       	call   8010901a <i8254_send>
80109b85:	83 c4 10             	add    $0x10,%esp
      kfree((char *)send_addr);
80109b88:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109b8b:	83 ec 0c             	sub    $0xc,%esp
80109b8e:	50                   	push   %eax
80109b8f:	e8 56 90 ff ff       	call   80102bea <kfree>
80109b94:	83 c4 10             	add    $0x10,%esp
    }
  }
}
80109b97:	90                   	nop
80109b98:	c9                   	leave  
80109b99:	c3                   	ret    

80109b9a <icmp_proc_req>:

void icmp_proc_req(struct icmp_echo_pkt * icmp_p){
80109b9a:	55                   	push   %ebp
80109b9b:	89 e5                	mov    %esp,%ebp
80109b9d:	53                   	push   %ebx
80109b9e:	83 ec 04             	sub    $0x4,%esp
  cprintf("ICMP ID:0x%x SEQ NUM:0x%x\n",N2H_ushort(icmp_p->id),N2H_ushort(icmp_p->seq_num));
80109ba1:	8b 45 08             	mov    0x8(%ebp),%eax
80109ba4:	0f b7 40 06          	movzwl 0x6(%eax),%eax
80109ba8:	0f b7 c0             	movzwl %ax,%eax
80109bab:	83 ec 0c             	sub    $0xc,%esp
80109bae:	50                   	push   %eax
80109baf:	e8 bd fd ff ff       	call   80109971 <N2H_ushort>
80109bb4:	83 c4 10             	add    $0x10,%esp
80109bb7:	0f b7 d8             	movzwl %ax,%ebx
80109bba:	8b 45 08             	mov    0x8(%ebp),%eax
80109bbd:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80109bc1:	0f b7 c0             	movzwl %ax,%eax
80109bc4:	83 ec 0c             	sub    $0xc,%esp
80109bc7:	50                   	push   %eax
80109bc8:	e8 a4 fd ff ff       	call   80109971 <N2H_ushort>
80109bcd:	83 c4 10             	add    $0x10,%esp
80109bd0:	0f b7 c0             	movzwl %ax,%eax
80109bd3:	83 ec 04             	sub    $0x4,%esp
80109bd6:	53                   	push   %ebx
80109bd7:	50                   	push   %eax
80109bd8:	68 43 c4 10 80       	push   $0x8010c443
80109bdd:	e8 12 68 ff ff       	call   801003f4 <cprintf>
80109be2:	83 c4 10             	add    $0x10,%esp
}
80109be5:	90                   	nop
80109be6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80109be9:	c9                   	leave  
80109bea:	c3                   	ret    

80109beb <icmp_reply_pkt_create>:

void icmp_reply_pkt_create(uint recv_addr,uint send_addr,uint *send_size){
80109beb:	55                   	push   %ebp
80109bec:	89 e5                	mov    %esp,%ebp
80109bee:	83 ec 28             	sub    $0x28,%esp
  struct eth_pkt *eth_recv = (struct eth_pkt *)(recv_addr);
80109bf1:	8b 45 08             	mov    0x8(%ebp),%eax
80109bf4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct ipv4_pkt *ipv4_recv = (struct ipv4_pkt *)(recv_addr+sizeof(struct eth_pkt));
80109bf7:	8b 45 08             	mov    0x8(%ebp),%eax
80109bfa:	83 c0 0e             	add    $0xe,%eax
80109bfd:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct icmp_echo_pkt *icmp_recv = (struct icmp_echo_pkt *)((uint)ipv4_recv+(ipv4_recv->ver&0xF)*4);
80109c00:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109c03:	0f b6 00             	movzbl (%eax),%eax
80109c06:	0f b6 c0             	movzbl %al,%eax
80109c09:	83 e0 0f             	and    $0xf,%eax
80109c0c:	c1 e0 02             	shl    $0x2,%eax
80109c0f:	89 c2                	mov    %eax,%edx
80109c11:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109c14:	01 d0                	add    %edx,%eax
80109c16:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct eth_pkt *eth_send = (struct eth_pkt *)(send_addr);
80109c19:	8b 45 0c             	mov    0xc(%ebp),%eax
80109c1c:	89 45 e8             	mov    %eax,-0x18(%ebp)
  struct ipv4_pkt *ipv4_send = (struct ipv4_pkt *)(send_addr+sizeof(struct eth_pkt));
80109c1f:	8b 45 0c             	mov    0xc(%ebp),%eax
80109c22:	83 c0 0e             	add    $0xe,%eax
80109c25:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct icmp_echo_pkt *icmp_send = (struct icmp_echo_pkt *)((uint)ipv4_send+sizeof(struct ipv4_pkt));
80109c28:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109c2b:	83 c0 14             	add    $0x14,%eax
80109c2e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  
  *send_size = sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct icmp_echo_pkt);
80109c31:	8b 45 10             	mov    0x10(%ebp),%eax
80109c34:	c7 00 62 00 00 00    	movl   $0x62,(%eax)
  memmove(eth_send->dst_mac,eth_recv->src_mac,6);
80109c3a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109c3d:	8d 50 06             	lea    0x6(%eax),%edx
80109c40:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109c43:	83 ec 04             	sub    $0x4,%esp
80109c46:	6a 06                	push   $0x6
80109c48:	52                   	push   %edx
80109c49:	50                   	push   %eax
80109c4a:	e8 d3 b2 ff ff       	call   80104f22 <memmove>
80109c4f:	83 c4 10             	add    $0x10,%esp
  memmove(eth_send->src_mac,mac_addr,6);
80109c52:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109c55:	83 c0 06             	add    $0x6,%eax
80109c58:	83 ec 04             	sub    $0x4,%esp
80109c5b:	6a 06                	push   $0x6
80109c5d:	68 c0 9e 11 80       	push   $0x80119ec0
80109c62:	50                   	push   %eax
80109c63:	e8 ba b2 ff ff       	call   80104f22 <memmove>
80109c68:	83 c4 10             	add    $0x10,%esp
  eth_send->type[0] = 0x08;
80109c6b:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109c6e:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  eth_send->type[1] = 0x00;
80109c72:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109c75:	c6 40 0d 00          	movb   $0x0,0xd(%eax)

  ipv4_send->ver = ((0x4)<<4)+((sizeof(struct ipv4_pkt)/4)&0xF);
80109c79:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109c7c:	c6 00 45             	movb   $0x45,(%eax)
  ipv4_send->srv_type = 0;
80109c7f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109c82:	c6 40 01 00          	movb   $0x0,0x1(%eax)
  ipv4_send->total_len = H2N_ushort(sizeof(struct ipv4_pkt) + sizeof(struct icmp_echo_pkt));
80109c86:	83 ec 0c             	sub    $0xc,%esp
80109c89:	6a 54                	push   $0x54
80109c8b:	e8 03 fd ff ff       	call   80109993 <H2N_ushort>
80109c90:	83 c4 10             	add    $0x10,%esp
80109c93:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80109c96:	66 89 42 02          	mov    %ax,0x2(%edx)
  ipv4_send->id = send_id;
80109c9a:	0f b7 15 a0 a1 11 80 	movzwl 0x8011a1a0,%edx
80109ca1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109ca4:	66 89 50 04          	mov    %dx,0x4(%eax)
  send_id++;
80109ca8:	0f b7 05 a0 a1 11 80 	movzwl 0x8011a1a0,%eax
80109caf:	83 c0 01             	add    $0x1,%eax
80109cb2:	66 a3 a0 a1 11 80    	mov    %ax,0x8011a1a0
  ipv4_send->fragment = H2N_ushort(0x4000);
80109cb8:	83 ec 0c             	sub    $0xc,%esp
80109cbb:	68 00 40 00 00       	push   $0x4000
80109cc0:	e8 ce fc ff ff       	call   80109993 <H2N_ushort>
80109cc5:	83 c4 10             	add    $0x10,%esp
80109cc8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80109ccb:	66 89 42 06          	mov    %ax,0x6(%edx)
  ipv4_send->ttl = 255;
80109ccf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109cd2:	c6 40 08 ff          	movb   $0xff,0x8(%eax)
  ipv4_send->protocol = 0x1;
80109cd6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109cd9:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  memmove(ipv4_send->src_ip,my_ip,4);
80109cdd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109ce0:	83 c0 0c             	add    $0xc,%eax
80109ce3:	83 ec 04             	sub    $0x4,%esp
80109ce6:	6a 04                	push   $0x4
80109ce8:	68 e4 f4 10 80       	push   $0x8010f4e4
80109ced:	50                   	push   %eax
80109cee:	e8 2f b2 ff ff       	call   80104f22 <memmove>
80109cf3:	83 c4 10             	add    $0x10,%esp
  memmove(ipv4_send->dst_ip,ipv4_recv->src_ip,4);
80109cf6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109cf9:	8d 50 0c             	lea    0xc(%eax),%edx
80109cfc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109cff:	83 c0 10             	add    $0x10,%eax
80109d02:	83 ec 04             	sub    $0x4,%esp
80109d05:	6a 04                	push   $0x4
80109d07:	52                   	push   %edx
80109d08:	50                   	push   %eax
80109d09:	e8 14 b2 ff ff       	call   80104f22 <memmove>
80109d0e:	83 c4 10             	add    $0x10,%esp
  ipv4_send->chk_sum = 0;
80109d11:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109d14:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
  ipv4_send->chk_sum = H2N_ushort(ipv4_chksum((uint)ipv4_send));
80109d1a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109d1d:	83 ec 0c             	sub    $0xc,%esp
80109d20:	50                   	push   %eax
80109d21:	e8 6d fd ff ff       	call   80109a93 <ipv4_chksum>
80109d26:	83 c4 10             	add    $0x10,%esp
80109d29:	0f b7 c0             	movzwl %ax,%eax
80109d2c:	83 ec 0c             	sub    $0xc,%esp
80109d2f:	50                   	push   %eax
80109d30:	e8 5e fc ff ff       	call   80109993 <H2N_ushort>
80109d35:	83 c4 10             	add    $0x10,%esp
80109d38:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80109d3b:	66 89 42 0a          	mov    %ax,0xa(%edx)

  icmp_send->type = ICMP_TYPE_ECHO_REPLY;
80109d3f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109d42:	c6 00 00             	movb   $0x0,(%eax)
  icmp_send->code = 0;
80109d45:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109d48:	c6 40 01 00          	movb   $0x0,0x1(%eax)
  icmp_send->id = icmp_recv->id;
80109d4c:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109d4f:	0f b7 50 04          	movzwl 0x4(%eax),%edx
80109d53:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109d56:	66 89 50 04          	mov    %dx,0x4(%eax)
  icmp_send->seq_num = icmp_recv->seq_num;
80109d5a:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109d5d:	0f b7 50 06          	movzwl 0x6(%eax),%edx
80109d61:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109d64:	66 89 50 06          	mov    %dx,0x6(%eax)
  memmove(icmp_send->time_stamp,icmp_recv->time_stamp,8);
80109d68:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109d6b:	8d 50 08             	lea    0x8(%eax),%edx
80109d6e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109d71:	83 c0 08             	add    $0x8,%eax
80109d74:	83 ec 04             	sub    $0x4,%esp
80109d77:	6a 08                	push   $0x8
80109d79:	52                   	push   %edx
80109d7a:	50                   	push   %eax
80109d7b:	e8 a2 b1 ff ff       	call   80104f22 <memmove>
80109d80:	83 c4 10             	add    $0x10,%esp
  memmove(icmp_send->data,icmp_recv->data,48);
80109d83:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109d86:	8d 50 10             	lea    0x10(%eax),%edx
80109d89:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109d8c:	83 c0 10             	add    $0x10,%eax
80109d8f:	83 ec 04             	sub    $0x4,%esp
80109d92:	6a 30                	push   $0x30
80109d94:	52                   	push   %edx
80109d95:	50                   	push   %eax
80109d96:	e8 87 b1 ff ff       	call   80104f22 <memmove>
80109d9b:	83 c4 10             	add    $0x10,%esp
  icmp_send->chk_sum = 0;
80109d9e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109da1:	66 c7 40 02 00 00    	movw   $0x0,0x2(%eax)
  icmp_send->chk_sum = H2N_ushort(icmp_chksum((uint)icmp_send));
80109da7:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109daa:	83 ec 0c             	sub    $0xc,%esp
80109dad:	50                   	push   %eax
80109dae:	e8 1c 00 00 00       	call   80109dcf <icmp_chksum>
80109db3:	83 c4 10             	add    $0x10,%esp
80109db6:	0f b7 c0             	movzwl %ax,%eax
80109db9:	83 ec 0c             	sub    $0xc,%esp
80109dbc:	50                   	push   %eax
80109dbd:	e8 d1 fb ff ff       	call   80109993 <H2N_ushort>
80109dc2:	83 c4 10             	add    $0x10,%esp
80109dc5:	8b 55 e0             	mov    -0x20(%ebp),%edx
80109dc8:	66 89 42 02          	mov    %ax,0x2(%edx)
}
80109dcc:	90                   	nop
80109dcd:	c9                   	leave  
80109dce:	c3                   	ret    

80109dcf <icmp_chksum>:

ushort icmp_chksum(uint icmp_addr){
80109dcf:	55                   	push   %ebp
80109dd0:	89 e5                	mov    %esp,%ebp
80109dd2:	83 ec 10             	sub    $0x10,%esp
  uchar* bin = (uchar *)icmp_addr;
80109dd5:	8b 45 08             	mov    0x8(%ebp),%eax
80109dd8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint chk_sum = 0;
80109ddb:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  for(int i=0;i<32;i++){
80109de2:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80109de9:	eb 48                	jmp    80109e33 <icmp_chksum+0x64>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
80109deb:	8b 45 f8             	mov    -0x8(%ebp),%eax
80109dee:	01 c0                	add    %eax,%eax
80109df0:	89 c2                	mov    %eax,%edx
80109df2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109df5:	01 d0                	add    %edx,%eax
80109df7:	0f b6 00             	movzbl (%eax),%eax
80109dfa:	0f b6 c0             	movzbl %al,%eax
80109dfd:	c1 e0 08             	shl    $0x8,%eax
80109e00:	89 c2                	mov    %eax,%edx
80109e02:	8b 45 f8             	mov    -0x8(%ebp),%eax
80109e05:	01 c0                	add    %eax,%eax
80109e07:	8d 48 01             	lea    0x1(%eax),%ecx
80109e0a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109e0d:	01 c8                	add    %ecx,%eax
80109e0f:	0f b6 00             	movzbl (%eax),%eax
80109e12:	0f b6 c0             	movzbl %al,%eax
80109e15:	01 d0                	add    %edx,%eax
80109e17:	01 45 fc             	add    %eax,-0x4(%ebp)
    if(chk_sum > 0xFFFF){
80109e1a:	81 7d fc ff ff 00 00 	cmpl   $0xffff,-0x4(%ebp)
80109e21:	76 0c                	jbe    80109e2f <icmp_chksum+0x60>
      chk_sum = (chk_sum&0xFFFF)+1;
80109e23:	8b 45 fc             	mov    -0x4(%ebp),%eax
80109e26:	0f b7 c0             	movzwl %ax,%eax
80109e29:	83 c0 01             	add    $0x1,%eax
80109e2c:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(int i=0;i<32;i++){
80109e2f:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80109e33:	83 7d f8 1f          	cmpl   $0x1f,-0x8(%ebp)
80109e37:	7e b2                	jle    80109deb <icmp_chksum+0x1c>
    }
  }
  return ~(chk_sum);
80109e39:	8b 45 fc             	mov    -0x4(%ebp),%eax
80109e3c:	f7 d0                	not    %eax
}
80109e3e:	c9                   	leave  
80109e3f:	c3                   	ret    

80109e40 <tcp_proc>:
extern ushort send_id;
extern uchar mac_addr[6];
extern uchar my_ip[4];
int fin_flag = 0;

void tcp_proc(uint buffer_addr){
80109e40:	55                   	push   %ebp
80109e41:	89 e5                	mov    %esp,%ebp
80109e43:	83 ec 38             	sub    $0x38,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(buffer_addr + sizeof(struct eth_pkt));
80109e46:	8b 45 08             	mov    0x8(%ebp),%eax
80109e49:	83 c0 0e             	add    $0xe,%eax
80109e4c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct tcp_pkt *tcp_p = (struct tcp_pkt *)((uint)ipv4_p + (ipv4_p->ver&0xF)*4);
80109e4f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109e52:	0f b6 00             	movzbl (%eax),%eax
80109e55:	0f b6 c0             	movzbl %al,%eax
80109e58:	83 e0 0f             	and    $0xf,%eax
80109e5b:	c1 e0 02             	shl    $0x2,%eax
80109e5e:	89 c2                	mov    %eax,%edx
80109e60:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109e63:	01 d0                	add    %edx,%eax
80109e65:	89 45 f0             	mov    %eax,-0x10(%ebp)
  char *payload = (char *)((uint)tcp_p + 20);
80109e68:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109e6b:	83 c0 14             	add    $0x14,%eax
80109e6e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  uint send_addr = (uint)kalloc();
80109e71:	e8 0e 8e ff ff       	call   80102c84 <kalloc>
80109e76:	89 45 e8             	mov    %eax,-0x18(%ebp)
  uint send_size = 0;
80109e79:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  if(tcp_p->code_bits[1]&TCP_CODEBITS_SYN){
80109e80:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109e83:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
80109e87:	0f b6 c0             	movzbl %al,%eax
80109e8a:	83 e0 02             	and    $0x2,%eax
80109e8d:	85 c0                	test   %eax,%eax
80109e8f:	74 3d                	je     80109ece <tcp_proc+0x8e>
    tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_ACK | TCP_CODEBITS_SYN,0);
80109e91:	83 ec 0c             	sub    $0xc,%esp
80109e94:	6a 00                	push   $0x0
80109e96:	6a 12                	push   $0x12
80109e98:	8d 45 dc             	lea    -0x24(%ebp),%eax
80109e9b:	50                   	push   %eax
80109e9c:	ff 75 e8             	push   -0x18(%ebp)
80109e9f:	ff 75 08             	push   0x8(%ebp)
80109ea2:	e8 a2 01 00 00       	call   8010a049 <tcp_pkt_create>
80109ea7:	83 c4 20             	add    $0x20,%esp
    i8254_send(send_addr,send_size);
80109eaa:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109ead:	83 ec 08             	sub    $0x8,%esp
80109eb0:	50                   	push   %eax
80109eb1:	ff 75 e8             	push   -0x18(%ebp)
80109eb4:	e8 61 f1 ff ff       	call   8010901a <i8254_send>
80109eb9:	83 c4 10             	add    $0x10,%esp
    seq_num++;
80109ebc:	a1 a4 a1 11 80       	mov    0x8011a1a4,%eax
80109ec1:	83 c0 01             	add    $0x1,%eax
80109ec4:	a3 a4 a1 11 80       	mov    %eax,0x8011a1a4
80109ec9:	e9 69 01 00 00       	jmp    8010a037 <tcp_proc+0x1f7>
  }else if(tcp_p->code_bits[1] == (TCP_CODEBITS_PSH | TCP_CODEBITS_ACK)){
80109ece:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109ed1:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
80109ed5:	3c 18                	cmp    $0x18,%al
80109ed7:	0f 85 10 01 00 00    	jne    80109fed <tcp_proc+0x1ad>
    if(memcmp(payload,"GET",3)){
80109edd:	83 ec 04             	sub    $0x4,%esp
80109ee0:	6a 03                	push   $0x3
80109ee2:	68 5e c4 10 80       	push   $0x8010c45e
80109ee7:	ff 75 ec             	push   -0x14(%ebp)
80109eea:	e8 db af ff ff       	call   80104eca <memcmp>
80109eef:	83 c4 10             	add    $0x10,%esp
80109ef2:	85 c0                	test   %eax,%eax
80109ef4:	74 74                	je     80109f6a <tcp_proc+0x12a>
      cprintf("ACK PSH\n");
80109ef6:	83 ec 0c             	sub    $0xc,%esp
80109ef9:	68 62 c4 10 80       	push   $0x8010c462
80109efe:	e8 f1 64 ff ff       	call   801003f4 <cprintf>
80109f03:	83 c4 10             	add    $0x10,%esp
      tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_ACK,0);
80109f06:	83 ec 0c             	sub    $0xc,%esp
80109f09:	6a 00                	push   $0x0
80109f0b:	6a 10                	push   $0x10
80109f0d:	8d 45 dc             	lea    -0x24(%ebp),%eax
80109f10:	50                   	push   %eax
80109f11:	ff 75 e8             	push   -0x18(%ebp)
80109f14:	ff 75 08             	push   0x8(%ebp)
80109f17:	e8 2d 01 00 00       	call   8010a049 <tcp_pkt_create>
80109f1c:	83 c4 20             	add    $0x20,%esp
      i8254_send(send_addr,send_size);
80109f1f:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109f22:	83 ec 08             	sub    $0x8,%esp
80109f25:	50                   	push   %eax
80109f26:	ff 75 e8             	push   -0x18(%ebp)
80109f29:	e8 ec f0 ff ff       	call   8010901a <i8254_send>
80109f2e:	83 c4 10             	add    $0x10,%esp
      uint send_payload = (send_addr + sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt));
80109f31:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109f34:	83 c0 36             	add    $0x36,%eax
80109f37:	89 45 e0             	mov    %eax,-0x20(%ebp)
      uint payload_size;
      http_proc(0,0,send_payload,&payload_size);
80109f3a:	8d 45 d8             	lea    -0x28(%ebp),%eax
80109f3d:	50                   	push   %eax
80109f3e:	ff 75 e0             	push   -0x20(%ebp)
80109f41:	6a 00                	push   $0x0
80109f43:	6a 00                	push   $0x0
80109f45:	e8 5a 04 00 00       	call   8010a3a4 <http_proc>
80109f4a:	83 c4 10             	add    $0x10,%esp
      tcp_pkt_create(buffer_addr,send_addr,&send_size,(TCP_CODEBITS_ACK|TCP_CODEBITS_PSH),payload_size);
80109f4d:	8b 45 d8             	mov    -0x28(%ebp),%eax
80109f50:	83 ec 0c             	sub    $0xc,%esp
80109f53:	50                   	push   %eax
80109f54:	6a 18                	push   $0x18
80109f56:	8d 45 dc             	lea    -0x24(%ebp),%eax
80109f59:	50                   	push   %eax
80109f5a:	ff 75 e8             	push   -0x18(%ebp)
80109f5d:	ff 75 08             	push   0x8(%ebp)
80109f60:	e8 e4 00 00 00       	call   8010a049 <tcp_pkt_create>
80109f65:	83 c4 20             	add    $0x20,%esp
80109f68:	eb 62                	jmp    80109fcc <tcp_proc+0x18c>
    }else{
     tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_ACK,0);
80109f6a:	83 ec 0c             	sub    $0xc,%esp
80109f6d:	6a 00                	push   $0x0
80109f6f:	6a 10                	push   $0x10
80109f71:	8d 45 dc             	lea    -0x24(%ebp),%eax
80109f74:	50                   	push   %eax
80109f75:	ff 75 e8             	push   -0x18(%ebp)
80109f78:	ff 75 08             	push   0x8(%ebp)
80109f7b:	e8 c9 00 00 00       	call   8010a049 <tcp_pkt_create>
80109f80:	83 c4 20             	add    $0x20,%esp
     i8254_send(send_addr,send_size);
80109f83:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109f86:	83 ec 08             	sub    $0x8,%esp
80109f89:	50                   	push   %eax
80109f8a:	ff 75 e8             	push   -0x18(%ebp)
80109f8d:	e8 88 f0 ff ff       	call   8010901a <i8254_send>
80109f92:	83 c4 10             	add    $0x10,%esp
      uint send_payload = (send_addr + sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt));
80109f95:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109f98:	83 c0 36             	add    $0x36,%eax
80109f9b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      uint payload_size;
      http_proc(0,0,send_payload,&payload_size);
80109f9e:	8d 45 d4             	lea    -0x2c(%ebp),%eax
80109fa1:	50                   	push   %eax
80109fa2:	ff 75 e4             	push   -0x1c(%ebp)
80109fa5:	6a 00                	push   $0x0
80109fa7:	6a 00                	push   $0x0
80109fa9:	e8 f6 03 00 00       	call   8010a3a4 <http_proc>
80109fae:	83 c4 10             	add    $0x10,%esp
      tcp_pkt_create(buffer_addr,send_addr,&send_size,(TCP_CODEBITS_ACK|TCP_CODEBITS_PSH),payload_size);
80109fb1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80109fb4:	83 ec 0c             	sub    $0xc,%esp
80109fb7:	50                   	push   %eax
80109fb8:	6a 18                	push   $0x18
80109fba:	8d 45 dc             	lea    -0x24(%ebp),%eax
80109fbd:	50                   	push   %eax
80109fbe:	ff 75 e8             	push   -0x18(%ebp)
80109fc1:	ff 75 08             	push   0x8(%ebp)
80109fc4:	e8 80 00 00 00       	call   8010a049 <tcp_pkt_create>
80109fc9:	83 c4 20             	add    $0x20,%esp
    }
    i8254_send(send_addr,send_size);
80109fcc:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109fcf:	83 ec 08             	sub    $0x8,%esp
80109fd2:	50                   	push   %eax
80109fd3:	ff 75 e8             	push   -0x18(%ebp)
80109fd6:	e8 3f f0 ff ff       	call   8010901a <i8254_send>
80109fdb:	83 c4 10             	add    $0x10,%esp
    seq_num++;
80109fde:	a1 a4 a1 11 80       	mov    0x8011a1a4,%eax
80109fe3:	83 c0 01             	add    $0x1,%eax
80109fe6:	a3 a4 a1 11 80       	mov    %eax,0x8011a1a4
80109feb:	eb 4a                	jmp    8010a037 <tcp_proc+0x1f7>
  }else if(tcp_p->code_bits[1] == TCP_CODEBITS_ACK){
80109fed:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109ff0:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
80109ff4:	3c 10                	cmp    $0x10,%al
80109ff6:	75 3f                	jne    8010a037 <tcp_proc+0x1f7>
    if(fin_flag == 1){
80109ff8:	a1 a8 a1 11 80       	mov    0x8011a1a8,%eax
80109ffd:	83 f8 01             	cmp    $0x1,%eax
8010a000:	75 35                	jne    8010a037 <tcp_proc+0x1f7>
      tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_FIN,0);
8010a002:	83 ec 0c             	sub    $0xc,%esp
8010a005:	6a 00                	push   $0x0
8010a007:	6a 01                	push   $0x1
8010a009:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010a00c:	50                   	push   %eax
8010a00d:	ff 75 e8             	push   -0x18(%ebp)
8010a010:	ff 75 08             	push   0x8(%ebp)
8010a013:	e8 31 00 00 00       	call   8010a049 <tcp_pkt_create>
8010a018:	83 c4 20             	add    $0x20,%esp
      i8254_send(send_addr,send_size);
8010a01b:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010a01e:	83 ec 08             	sub    $0x8,%esp
8010a021:	50                   	push   %eax
8010a022:	ff 75 e8             	push   -0x18(%ebp)
8010a025:	e8 f0 ef ff ff       	call   8010901a <i8254_send>
8010a02a:	83 c4 10             	add    $0x10,%esp
      fin_flag = 0;
8010a02d:	c7 05 a8 a1 11 80 00 	movl   $0x0,0x8011a1a8
8010a034:	00 00 00 
    }
  }
  kfree((char *)send_addr);
8010a037:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a03a:	83 ec 0c             	sub    $0xc,%esp
8010a03d:	50                   	push   %eax
8010a03e:	e8 a7 8b ff ff       	call   80102bea <kfree>
8010a043:	83 c4 10             	add    $0x10,%esp
}
8010a046:	90                   	nop
8010a047:	c9                   	leave  
8010a048:	c3                   	ret    

8010a049 <tcp_pkt_create>:

void tcp_pkt_create(uint recv_addr,uint send_addr,uint *send_size,uint pkt_type,uint payload_size){
8010a049:	55                   	push   %ebp
8010a04a:	89 e5                	mov    %esp,%ebp
8010a04c:	83 ec 28             	sub    $0x28,%esp
  struct eth_pkt *eth_recv = (struct eth_pkt *)(recv_addr);
8010a04f:	8b 45 08             	mov    0x8(%ebp),%eax
8010a052:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct ipv4_pkt *ipv4_recv = (struct ipv4_pkt *)(recv_addr+sizeof(struct eth_pkt));
8010a055:	8b 45 08             	mov    0x8(%ebp),%eax
8010a058:	83 c0 0e             	add    $0xe,%eax
8010a05b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct tcp_pkt *tcp_recv = (struct tcp_pkt *)((uint)ipv4_recv + (ipv4_recv->ver&0xF)*4);
8010a05e:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a061:	0f b6 00             	movzbl (%eax),%eax
8010a064:	0f b6 c0             	movzbl %al,%eax
8010a067:	83 e0 0f             	and    $0xf,%eax
8010a06a:	c1 e0 02             	shl    $0x2,%eax
8010a06d:	89 c2                	mov    %eax,%edx
8010a06f:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a072:	01 d0                	add    %edx,%eax
8010a074:	89 45 ec             	mov    %eax,-0x14(%ebp)

  struct eth_pkt *eth_send = (struct eth_pkt *)(send_addr);
8010a077:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a07a:	89 45 e8             	mov    %eax,-0x18(%ebp)
  struct ipv4_pkt *ipv4_send = (struct ipv4_pkt *)(send_addr + sizeof(struct eth_pkt));
8010a07d:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a080:	83 c0 0e             	add    $0xe,%eax
8010a083:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct tcp_pkt *tcp_send = (struct tcp_pkt *)((uint)ipv4_send + sizeof(struct ipv4_pkt));
8010a086:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a089:	83 c0 14             	add    $0x14,%eax
8010a08c:	89 45 e0             	mov    %eax,-0x20(%ebp)

  *send_size = sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt) + payload_size;
8010a08f:	8b 45 18             	mov    0x18(%ebp),%eax
8010a092:	8d 50 36             	lea    0x36(%eax),%edx
8010a095:	8b 45 10             	mov    0x10(%ebp),%eax
8010a098:	89 10                	mov    %edx,(%eax)

  memmove(eth_send->dst_mac,eth_recv->src_mac,6);
8010a09a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a09d:	8d 50 06             	lea    0x6(%eax),%edx
8010a0a0:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a0a3:	83 ec 04             	sub    $0x4,%esp
8010a0a6:	6a 06                	push   $0x6
8010a0a8:	52                   	push   %edx
8010a0a9:	50                   	push   %eax
8010a0aa:	e8 73 ae ff ff       	call   80104f22 <memmove>
8010a0af:	83 c4 10             	add    $0x10,%esp
  memmove(eth_send->src_mac,mac_addr,6);
8010a0b2:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a0b5:	83 c0 06             	add    $0x6,%eax
8010a0b8:	83 ec 04             	sub    $0x4,%esp
8010a0bb:	6a 06                	push   $0x6
8010a0bd:	68 c0 9e 11 80       	push   $0x80119ec0
8010a0c2:	50                   	push   %eax
8010a0c3:	e8 5a ae ff ff       	call   80104f22 <memmove>
8010a0c8:	83 c4 10             	add    $0x10,%esp
  eth_send->type[0] = 0x08;
8010a0cb:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a0ce:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  eth_send->type[1] = 0x00;
8010a0d2:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a0d5:	c6 40 0d 00          	movb   $0x0,0xd(%eax)

  ipv4_send->ver = ((0x4)<<4)+((sizeof(struct ipv4_pkt)/4)&0xF);
8010a0d9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a0dc:	c6 00 45             	movb   $0x45,(%eax)
  ipv4_send->srv_type = 0;
8010a0df:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a0e2:	c6 40 01 00          	movb   $0x0,0x1(%eax)
  ipv4_send->total_len = H2N_ushort(sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt) + payload_size);
8010a0e6:	8b 45 18             	mov    0x18(%ebp),%eax
8010a0e9:	83 c0 28             	add    $0x28,%eax
8010a0ec:	0f b7 c0             	movzwl %ax,%eax
8010a0ef:	83 ec 0c             	sub    $0xc,%esp
8010a0f2:	50                   	push   %eax
8010a0f3:	e8 9b f8 ff ff       	call   80109993 <H2N_ushort>
8010a0f8:	83 c4 10             	add    $0x10,%esp
8010a0fb:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010a0fe:	66 89 42 02          	mov    %ax,0x2(%edx)
  ipv4_send->id = send_id;
8010a102:	0f b7 15 a0 a1 11 80 	movzwl 0x8011a1a0,%edx
8010a109:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a10c:	66 89 50 04          	mov    %dx,0x4(%eax)
  send_id++;
8010a110:	0f b7 05 a0 a1 11 80 	movzwl 0x8011a1a0,%eax
8010a117:	83 c0 01             	add    $0x1,%eax
8010a11a:	66 a3 a0 a1 11 80    	mov    %ax,0x8011a1a0
  ipv4_send->fragment = H2N_ushort(0x0000);
8010a120:	83 ec 0c             	sub    $0xc,%esp
8010a123:	6a 00                	push   $0x0
8010a125:	e8 69 f8 ff ff       	call   80109993 <H2N_ushort>
8010a12a:	83 c4 10             	add    $0x10,%esp
8010a12d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010a130:	66 89 42 06          	mov    %ax,0x6(%edx)
  ipv4_send->ttl = 255;
8010a134:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a137:	c6 40 08 ff          	movb   $0xff,0x8(%eax)
  ipv4_send->protocol = IPV4_TYPE_TCP;
8010a13b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a13e:	c6 40 09 06          	movb   $0x6,0x9(%eax)
  memmove(ipv4_send->src_ip,my_ip,4);
8010a142:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a145:	83 c0 0c             	add    $0xc,%eax
8010a148:	83 ec 04             	sub    $0x4,%esp
8010a14b:	6a 04                	push   $0x4
8010a14d:	68 e4 f4 10 80       	push   $0x8010f4e4
8010a152:	50                   	push   %eax
8010a153:	e8 ca ad ff ff       	call   80104f22 <memmove>
8010a158:	83 c4 10             	add    $0x10,%esp
  memmove(ipv4_send->dst_ip,ipv4_recv->src_ip,4);
8010a15b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a15e:	8d 50 0c             	lea    0xc(%eax),%edx
8010a161:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a164:	83 c0 10             	add    $0x10,%eax
8010a167:	83 ec 04             	sub    $0x4,%esp
8010a16a:	6a 04                	push   $0x4
8010a16c:	52                   	push   %edx
8010a16d:	50                   	push   %eax
8010a16e:	e8 af ad ff ff       	call   80104f22 <memmove>
8010a173:	83 c4 10             	add    $0x10,%esp
  ipv4_send->chk_sum = 0;
8010a176:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a179:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
  ipv4_send->chk_sum = H2N_ushort(ipv4_chksum((uint)ipv4_send));
8010a17f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a182:	83 ec 0c             	sub    $0xc,%esp
8010a185:	50                   	push   %eax
8010a186:	e8 08 f9 ff ff       	call   80109a93 <ipv4_chksum>
8010a18b:	83 c4 10             	add    $0x10,%esp
8010a18e:	0f b7 c0             	movzwl %ax,%eax
8010a191:	83 ec 0c             	sub    $0xc,%esp
8010a194:	50                   	push   %eax
8010a195:	e8 f9 f7 ff ff       	call   80109993 <H2N_ushort>
8010a19a:	83 c4 10             	add    $0x10,%esp
8010a19d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010a1a0:	66 89 42 0a          	mov    %ax,0xa(%edx)
  

  tcp_send->src_port = tcp_recv->dst_port;
8010a1a4:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a1a7:	0f b7 50 02          	movzwl 0x2(%eax),%edx
8010a1ab:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a1ae:	66 89 10             	mov    %dx,(%eax)
  tcp_send->dst_port = tcp_recv->src_port;
8010a1b1:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a1b4:	0f b7 10             	movzwl (%eax),%edx
8010a1b7:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a1ba:	66 89 50 02          	mov    %dx,0x2(%eax)
  tcp_send->seq_num = H2N_uint(seq_num);
8010a1be:	a1 a4 a1 11 80       	mov    0x8011a1a4,%eax
8010a1c3:	83 ec 0c             	sub    $0xc,%esp
8010a1c6:	50                   	push   %eax
8010a1c7:	e8 e9 f7 ff ff       	call   801099b5 <H2N_uint>
8010a1cc:	83 c4 10             	add    $0x10,%esp
8010a1cf:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010a1d2:	89 42 04             	mov    %eax,0x4(%edx)
  tcp_send->ack_num = tcp_recv->seq_num + (1<<(8*3));
8010a1d5:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a1d8:	8b 40 04             	mov    0x4(%eax),%eax
8010a1db:	8d 90 00 00 00 01    	lea    0x1000000(%eax),%edx
8010a1e1:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a1e4:	89 50 08             	mov    %edx,0x8(%eax)

  tcp_send->code_bits[0] = 0;
8010a1e7:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a1ea:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
  tcp_send->code_bits[1] = 0;
8010a1ee:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a1f1:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
  tcp_send->code_bits[0] = 5<<4;
8010a1f5:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a1f8:	c6 40 0c 50          	movb   $0x50,0xc(%eax)
  tcp_send->code_bits[1] = pkt_type;
8010a1fc:	8b 45 14             	mov    0x14(%ebp),%eax
8010a1ff:	89 c2                	mov    %eax,%edx
8010a201:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a204:	88 50 0d             	mov    %dl,0xd(%eax)

  tcp_send->window = H2N_ushort(14480);
8010a207:	83 ec 0c             	sub    $0xc,%esp
8010a20a:	68 90 38 00 00       	push   $0x3890
8010a20f:	e8 7f f7 ff ff       	call   80109993 <H2N_ushort>
8010a214:	83 c4 10             	add    $0x10,%esp
8010a217:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010a21a:	66 89 42 0e          	mov    %ax,0xe(%edx)
  tcp_send->urgent_ptr = 0;
8010a21e:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a221:	66 c7 40 12 00 00    	movw   $0x0,0x12(%eax)
  tcp_send->chk_sum = 0;
8010a227:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a22a:	66 c7 40 10 00 00    	movw   $0x0,0x10(%eax)

  tcp_send->chk_sum = H2N_ushort(tcp_chksum((uint)(ipv4_send))+8);
8010a230:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a233:	83 ec 0c             	sub    $0xc,%esp
8010a236:	50                   	push   %eax
8010a237:	e8 1f 00 00 00       	call   8010a25b <tcp_chksum>
8010a23c:	83 c4 10             	add    $0x10,%esp
8010a23f:	83 c0 08             	add    $0x8,%eax
8010a242:	0f b7 c0             	movzwl %ax,%eax
8010a245:	83 ec 0c             	sub    $0xc,%esp
8010a248:	50                   	push   %eax
8010a249:	e8 45 f7 ff ff       	call   80109993 <H2N_ushort>
8010a24e:	83 c4 10             	add    $0x10,%esp
8010a251:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010a254:	66 89 42 10          	mov    %ax,0x10(%edx)


}
8010a258:	90                   	nop
8010a259:	c9                   	leave  
8010a25a:	c3                   	ret    

8010a25b <tcp_chksum>:

ushort tcp_chksum(uint tcp_addr){
8010a25b:	55                   	push   %ebp
8010a25c:	89 e5                	mov    %esp,%ebp
8010a25e:	83 ec 38             	sub    $0x38,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(tcp_addr);
8010a261:	8b 45 08             	mov    0x8(%ebp),%eax
8010a264:	89 45 e8             	mov    %eax,-0x18(%ebp)
  struct tcp_pkt *tcp_p = (struct tcp_pkt *)((uint)ipv4_p + sizeof(struct ipv4_pkt));
8010a267:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a26a:	83 c0 14             	add    $0x14,%eax
8010a26d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct tcp_dummy tcp_dummy;
  
  memmove(tcp_dummy.src_ip,my_ip,4);
8010a270:	83 ec 04             	sub    $0x4,%esp
8010a273:	6a 04                	push   $0x4
8010a275:	68 e4 f4 10 80       	push   $0x8010f4e4
8010a27a:	8d 45 d4             	lea    -0x2c(%ebp),%eax
8010a27d:	50                   	push   %eax
8010a27e:	e8 9f ac ff ff       	call   80104f22 <memmove>
8010a283:	83 c4 10             	add    $0x10,%esp
  memmove(tcp_dummy.dst_ip,ipv4_p->src_ip,4);
8010a286:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a289:	83 c0 0c             	add    $0xc,%eax
8010a28c:	83 ec 04             	sub    $0x4,%esp
8010a28f:	6a 04                	push   $0x4
8010a291:	50                   	push   %eax
8010a292:	8d 45 d4             	lea    -0x2c(%ebp),%eax
8010a295:	83 c0 04             	add    $0x4,%eax
8010a298:	50                   	push   %eax
8010a299:	e8 84 ac ff ff       	call   80104f22 <memmove>
8010a29e:	83 c4 10             	add    $0x10,%esp
  tcp_dummy.padding = 0;
8010a2a1:	c6 45 dc 00          	movb   $0x0,-0x24(%ebp)
  tcp_dummy.protocol = IPV4_TYPE_TCP;
8010a2a5:	c6 45 dd 06          	movb   $0x6,-0x23(%ebp)
  tcp_dummy.tcp_len = H2N_ushort(N2H_ushort(ipv4_p->total_len) - sizeof(struct ipv4_pkt));
8010a2a9:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a2ac:	0f b7 40 02          	movzwl 0x2(%eax),%eax
8010a2b0:	0f b7 c0             	movzwl %ax,%eax
8010a2b3:	83 ec 0c             	sub    $0xc,%esp
8010a2b6:	50                   	push   %eax
8010a2b7:	e8 b5 f6 ff ff       	call   80109971 <N2H_ushort>
8010a2bc:	83 c4 10             	add    $0x10,%esp
8010a2bf:	83 e8 14             	sub    $0x14,%eax
8010a2c2:	0f b7 c0             	movzwl %ax,%eax
8010a2c5:	83 ec 0c             	sub    $0xc,%esp
8010a2c8:	50                   	push   %eax
8010a2c9:	e8 c5 f6 ff ff       	call   80109993 <H2N_ushort>
8010a2ce:	83 c4 10             	add    $0x10,%esp
8010a2d1:	66 89 45 de          	mov    %ax,-0x22(%ebp)
  uint chk_sum = 0;
8010a2d5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  uchar *bin = (uchar *)(&tcp_dummy);
8010a2dc:	8d 45 d4             	lea    -0x2c(%ebp),%eax
8010a2df:	89 45 e0             	mov    %eax,-0x20(%ebp)
  for(int i=0;i<6;i++){
8010a2e2:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
8010a2e9:	eb 33                	jmp    8010a31e <tcp_chksum+0xc3>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
8010a2eb:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a2ee:	01 c0                	add    %eax,%eax
8010a2f0:	89 c2                	mov    %eax,%edx
8010a2f2:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a2f5:	01 d0                	add    %edx,%eax
8010a2f7:	0f b6 00             	movzbl (%eax),%eax
8010a2fa:	0f b6 c0             	movzbl %al,%eax
8010a2fd:	c1 e0 08             	shl    $0x8,%eax
8010a300:	89 c2                	mov    %eax,%edx
8010a302:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a305:	01 c0                	add    %eax,%eax
8010a307:	8d 48 01             	lea    0x1(%eax),%ecx
8010a30a:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a30d:	01 c8                	add    %ecx,%eax
8010a30f:	0f b6 00             	movzbl (%eax),%eax
8010a312:	0f b6 c0             	movzbl %al,%eax
8010a315:	01 d0                	add    %edx,%eax
8010a317:	01 45 f4             	add    %eax,-0xc(%ebp)
  for(int i=0;i<6;i++){
8010a31a:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
8010a31e:	83 7d f0 05          	cmpl   $0x5,-0x10(%ebp)
8010a322:	7e c7                	jle    8010a2eb <tcp_chksum+0x90>
  }

  bin = (uchar *)(tcp_p);
8010a324:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a327:	89 45 e0             	mov    %eax,-0x20(%ebp)
  for(int i=0;i<(N2H_ushort(tcp_dummy.tcp_len)/2);i++){
8010a32a:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
8010a331:	eb 33                	jmp    8010a366 <tcp_chksum+0x10b>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
8010a333:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a336:	01 c0                	add    %eax,%eax
8010a338:	89 c2                	mov    %eax,%edx
8010a33a:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a33d:	01 d0                	add    %edx,%eax
8010a33f:	0f b6 00             	movzbl (%eax),%eax
8010a342:	0f b6 c0             	movzbl %al,%eax
8010a345:	c1 e0 08             	shl    $0x8,%eax
8010a348:	89 c2                	mov    %eax,%edx
8010a34a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a34d:	01 c0                	add    %eax,%eax
8010a34f:	8d 48 01             	lea    0x1(%eax),%ecx
8010a352:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a355:	01 c8                	add    %ecx,%eax
8010a357:	0f b6 00             	movzbl (%eax),%eax
8010a35a:	0f b6 c0             	movzbl %al,%eax
8010a35d:	01 d0                	add    %edx,%eax
8010a35f:	01 45 f4             	add    %eax,-0xc(%ebp)
  for(int i=0;i<(N2H_ushort(tcp_dummy.tcp_len)/2);i++){
8010a362:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
8010a366:	0f b7 45 de          	movzwl -0x22(%ebp),%eax
8010a36a:	0f b7 c0             	movzwl %ax,%eax
8010a36d:	83 ec 0c             	sub    $0xc,%esp
8010a370:	50                   	push   %eax
8010a371:	e8 fb f5 ff ff       	call   80109971 <N2H_ushort>
8010a376:	83 c4 10             	add    $0x10,%esp
8010a379:	66 d1 e8             	shr    %ax
8010a37c:	0f b7 c0             	movzwl %ax,%eax
8010a37f:	39 45 ec             	cmp    %eax,-0x14(%ebp)
8010a382:	7c af                	jl     8010a333 <tcp_chksum+0xd8>
  }
  chk_sum += (chk_sum>>8*2);
8010a384:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a387:	c1 e8 10             	shr    $0x10,%eax
8010a38a:	01 45 f4             	add    %eax,-0xc(%ebp)
  return ~(chk_sum);
8010a38d:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a390:	f7 d0                	not    %eax
}
8010a392:	c9                   	leave  
8010a393:	c3                   	ret    

8010a394 <tcp_fin>:

void tcp_fin(){
8010a394:	55                   	push   %ebp
8010a395:	89 e5                	mov    %esp,%ebp
  fin_flag =1;
8010a397:	c7 05 a8 a1 11 80 01 	movl   $0x1,0x8011a1a8
8010a39e:	00 00 00 
}
8010a3a1:	90                   	nop
8010a3a2:	5d                   	pop    %ebp
8010a3a3:	c3                   	ret    

8010a3a4 <http_proc>:
#include "defs.h"
#include "types.h"
#include "tcp.h"


void http_proc(uint recv, uint recv_size, uint send, uint *send_size){
8010a3a4:	55                   	push   %ebp
8010a3a5:	89 e5                	mov    %esp,%ebp
8010a3a7:	83 ec 18             	sub    $0x18,%esp
  int len;
  len = http_strcpy((char *)send,"HTTP/1.0 200 OK \r\n",0);
8010a3aa:	8b 45 10             	mov    0x10(%ebp),%eax
8010a3ad:	83 ec 04             	sub    $0x4,%esp
8010a3b0:	6a 00                	push   $0x0
8010a3b2:	68 6b c4 10 80       	push   $0x8010c46b
8010a3b7:	50                   	push   %eax
8010a3b8:	e8 65 00 00 00       	call   8010a422 <http_strcpy>
8010a3bd:	83 c4 10             	add    $0x10,%esp
8010a3c0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  len += http_strcpy((char *)send,"Content-Type: text/html \r\n",len);
8010a3c3:	8b 45 10             	mov    0x10(%ebp),%eax
8010a3c6:	83 ec 04             	sub    $0x4,%esp
8010a3c9:	ff 75 f4             	push   -0xc(%ebp)
8010a3cc:	68 7e c4 10 80       	push   $0x8010c47e
8010a3d1:	50                   	push   %eax
8010a3d2:	e8 4b 00 00 00       	call   8010a422 <http_strcpy>
8010a3d7:	83 c4 10             	add    $0x10,%esp
8010a3da:	01 45 f4             	add    %eax,-0xc(%ebp)
  len += http_strcpy((char *)send,"\r\nHello World!\r\n",len);
8010a3dd:	8b 45 10             	mov    0x10(%ebp),%eax
8010a3e0:	83 ec 04             	sub    $0x4,%esp
8010a3e3:	ff 75 f4             	push   -0xc(%ebp)
8010a3e6:	68 99 c4 10 80       	push   $0x8010c499
8010a3eb:	50                   	push   %eax
8010a3ec:	e8 31 00 00 00       	call   8010a422 <http_strcpy>
8010a3f1:	83 c4 10             	add    $0x10,%esp
8010a3f4:	01 45 f4             	add    %eax,-0xc(%ebp)
  if(len%2 != 0){
8010a3f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a3fa:	83 e0 01             	and    $0x1,%eax
8010a3fd:	85 c0                	test   %eax,%eax
8010a3ff:	74 11                	je     8010a412 <http_proc+0x6e>
    char *payload = (char *)send;
8010a401:	8b 45 10             	mov    0x10(%ebp),%eax
8010a404:	89 45 f0             	mov    %eax,-0x10(%ebp)
    payload[len] = 0;
8010a407:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010a40a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a40d:	01 d0                	add    %edx,%eax
8010a40f:	c6 00 00             	movb   $0x0,(%eax)
  }
  *send_size = len;
8010a412:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010a415:	8b 45 14             	mov    0x14(%ebp),%eax
8010a418:	89 10                	mov    %edx,(%eax)
  tcp_fin();
8010a41a:	e8 75 ff ff ff       	call   8010a394 <tcp_fin>
}
8010a41f:	90                   	nop
8010a420:	c9                   	leave  
8010a421:	c3                   	ret    

8010a422 <http_strcpy>:

int http_strcpy(char *dst,const char *src,int start_index){
8010a422:	55                   	push   %ebp
8010a423:	89 e5                	mov    %esp,%ebp
8010a425:	83 ec 10             	sub    $0x10,%esp
  int i = 0;
8010a428:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while(src[i]){
8010a42f:	eb 20                	jmp    8010a451 <http_strcpy+0x2f>
    dst[start_index+i] = src[i];
8010a431:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010a434:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a437:	01 d0                	add    %edx,%eax
8010a439:	8b 4d 10             	mov    0x10(%ebp),%ecx
8010a43c:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010a43f:	01 ca                	add    %ecx,%edx
8010a441:	89 d1                	mov    %edx,%ecx
8010a443:	8b 55 08             	mov    0x8(%ebp),%edx
8010a446:	01 ca                	add    %ecx,%edx
8010a448:	0f b6 00             	movzbl (%eax),%eax
8010a44b:	88 02                	mov    %al,(%edx)
    i++;
8010a44d:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  while(src[i]){
8010a451:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010a454:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a457:	01 d0                	add    %edx,%eax
8010a459:	0f b6 00             	movzbl (%eax),%eax
8010a45c:	84 c0                	test   %al,%al
8010a45e:	75 d1                	jne    8010a431 <http_strcpy+0xf>
  }
  return i;
8010a460:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010a463:	c9                   	leave  
8010a464:	c3                   	ret    
