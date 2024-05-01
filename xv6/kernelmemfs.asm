
kernelmemfs:     file format elf32-i386


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
8010005a:	bc 80 81 19 80       	mov    $0x80198180,%esp
  # Jump to main(), and switch to executing at
  # high addresses. The indirect call is needed because
  # the assembler produces a PC-relative instruction
  # for a direct jump.
#  jz .waiting_main
  movl $main, %edx
8010005f:	ba 65 33 10 80       	mov    $0x80103365,%edx
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
8010006f:	68 00 a1 10 80       	push   $0x8010a100
80100074:	68 00 d0 18 80       	push   $0x8018d000
80100079:	e8 69 46 00 00       	call   801046e7 <initlock>
8010007e:	83 c4 10             	add    $0x10,%esp

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
80100081:	c7 05 4c 17 19 80 fc 	movl   $0x801916fc,0x8019174c
80100088:	16 19 80 
  bcache.head.next = &bcache.head;
8010008b:	c7 05 50 17 19 80 fc 	movl   $0x801916fc,0x80191750
80100092:	16 19 80 
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
80100095:	c7 45 f4 34 d0 18 80 	movl   $0x8018d034,-0xc(%ebp)
8010009c:	eb 47                	jmp    801000e5 <binit+0x7f>
    b->next = bcache.head.next;
8010009e:	8b 15 50 17 19 80    	mov    0x80191750,%edx
801000a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000a7:	89 50 54             	mov    %edx,0x54(%eax)
    b->prev = &bcache.head;
801000aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000ad:	c7 40 50 fc 16 19 80 	movl   $0x801916fc,0x50(%eax)
    initsleeplock(&b->lock, "buffer");
801000b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000b7:	83 c0 0c             	add    $0xc,%eax
801000ba:	83 ec 08             	sub    $0x8,%esp
801000bd:	68 07 a1 10 80       	push   $0x8010a107
801000c2:	50                   	push   %eax
801000c3:	e8 c2 44 00 00       	call   8010458a <initsleeplock>
801000c8:	83 c4 10             	add    $0x10,%esp
    bcache.head.next->prev = b;
801000cb:	a1 50 17 19 80       	mov    0x80191750,%eax
801000d0:	8b 55 f4             	mov    -0xc(%ebp),%edx
801000d3:	89 50 50             	mov    %edx,0x50(%eax)
    bcache.head.next = b;
801000d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000d9:	a3 50 17 19 80       	mov    %eax,0x80191750
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
801000de:	81 45 f4 5c 02 00 00 	addl   $0x25c,-0xc(%ebp)
801000e5:	b8 fc 16 19 80       	mov    $0x801916fc,%eax
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
801000fc:	68 00 d0 18 80       	push   $0x8018d000
80100101:	e8 03 46 00 00       	call   80104709 <acquire>
80100106:	83 c4 10             	add    $0x10,%esp

  // Is the block already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
80100109:	a1 50 17 19 80       	mov    0x80191750,%eax
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
8010013b:	68 00 d0 18 80       	push   $0x8018d000
80100140:	e8 32 46 00 00       	call   80104777 <release>
80100145:	83 c4 10             	add    $0x10,%esp
      acquiresleep(&b->lock);
80100148:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010014b:	83 c0 0c             	add    $0xc,%eax
8010014e:	83 ec 0c             	sub    $0xc,%esp
80100151:	50                   	push   %eax
80100152:	e8 6f 44 00 00       	call   801045c6 <acquiresleep>
80100157:	83 c4 10             	add    $0x10,%esp
      return b;
8010015a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010015d:	e9 9d 00 00 00       	jmp    801001ff <bget+0x10c>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
80100162:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100165:	8b 40 54             	mov    0x54(%eax),%eax
80100168:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010016b:	81 7d f4 fc 16 19 80 	cmpl   $0x801916fc,-0xc(%ebp)
80100172:	75 9f                	jne    80100113 <bget+0x20>
  }

  // Not cached; recycle an unused buffer.
  // Even if refcnt==0, B_DIRTY indicates a buffer is in use
  // because log.c has modified it but not yet committed it.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100174:	a1 4c 17 19 80       	mov    0x8019174c,%eax
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
801001bc:	68 00 d0 18 80       	push   $0x8018d000
801001c1:	e8 b1 45 00 00       	call   80104777 <release>
801001c6:	83 c4 10             	add    $0x10,%esp
      acquiresleep(&b->lock);
801001c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001cc:	83 c0 0c             	add    $0xc,%eax
801001cf:	83 ec 0c             	sub    $0xc,%esp
801001d2:	50                   	push   %eax
801001d3:	e8 ee 43 00 00       	call   801045c6 <acquiresleep>
801001d8:	83 c4 10             	add    $0x10,%esp
      return b;
801001db:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001de:	eb 1f                	jmp    801001ff <bget+0x10c>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
801001e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001e3:	8b 40 50             	mov    0x50(%eax),%eax
801001e6:	89 45 f4             	mov    %eax,-0xc(%ebp)
801001e9:	81 7d f4 fc 16 19 80 	cmpl   $0x801916fc,-0xc(%ebp)
801001f0:	75 8c                	jne    8010017e <bget+0x8b>
    }
  }
  panic("bget: no buffers");
801001f2:	83 ec 0c             	sub    $0xc,%esp
801001f5:	68 0e a1 10 80       	push   $0x8010a10e
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
8010022d:	e8 cd 9d 00 00       	call   80109fff <iderw>
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
8010024a:	e8 29 44 00 00       	call   80104678 <holdingsleep>
8010024f:	83 c4 10             	add    $0x10,%esp
80100252:	85 c0                	test   %eax,%eax
80100254:	75 0d                	jne    80100263 <bwrite+0x29>
    panic("bwrite");
80100256:	83 ec 0c             	sub    $0xc,%esp
80100259:	68 1f a1 10 80       	push   $0x8010a11f
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
80100278:	e8 82 9d 00 00       	call   80109fff <iderw>
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
80100293:	e8 e0 43 00 00       	call   80104678 <holdingsleep>
80100298:	83 c4 10             	add    $0x10,%esp
8010029b:	85 c0                	test   %eax,%eax
8010029d:	75 0d                	jne    801002ac <brelse+0x29>
    panic("brelse");
8010029f:	83 ec 0c             	sub    $0xc,%esp
801002a2:	68 26 a1 10 80       	push   $0x8010a126
801002a7:	e8 fd 02 00 00       	call   801005a9 <panic>

  releasesleep(&b->lock);
801002ac:	8b 45 08             	mov    0x8(%ebp),%eax
801002af:	83 c0 0c             	add    $0xc,%eax
801002b2:	83 ec 0c             	sub    $0xc,%esp
801002b5:	50                   	push   %eax
801002b6:	e8 6f 43 00 00       	call   8010462a <releasesleep>
801002bb:	83 c4 10             	add    $0x10,%esp

  acquire(&bcache.lock);
801002be:	83 ec 0c             	sub    $0xc,%esp
801002c1:	68 00 d0 18 80       	push   $0x8018d000
801002c6:	e8 3e 44 00 00       	call   80104709 <acquire>
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
80100305:	8b 15 50 17 19 80    	mov    0x80191750,%edx
8010030b:	8b 45 08             	mov    0x8(%ebp),%eax
8010030e:	89 50 54             	mov    %edx,0x54(%eax)
    b->prev = &bcache.head;
80100311:	8b 45 08             	mov    0x8(%ebp),%eax
80100314:	c7 40 50 fc 16 19 80 	movl   $0x801916fc,0x50(%eax)
    bcache.head.next->prev = b;
8010031b:	a1 50 17 19 80       	mov    0x80191750,%eax
80100320:	8b 55 08             	mov    0x8(%ebp),%edx
80100323:	89 50 50             	mov    %edx,0x50(%eax)
    bcache.head.next = b;
80100326:	8b 45 08             	mov    0x8(%ebp),%eax
80100329:	a3 50 17 19 80       	mov    %eax,0x80191750
  }
  
  release(&bcache.lock);
8010032e:	83 ec 0c             	sub    $0xc,%esp
80100331:	68 00 d0 18 80       	push   $0x8018d000
80100336:	e8 3c 44 00 00       	call   80104777 <release>
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
801003fa:	a1 34 1a 19 80       	mov    0x80191a34,%eax
801003ff:	89 45 e8             	mov    %eax,-0x18(%ebp)
  if(locking)
80100402:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80100406:	74 10                	je     80100418 <cprintf+0x24>
    acquire(&cons.lock);
80100408:	83 ec 0c             	sub    $0xc,%esp
8010040b:	68 00 1a 19 80       	push   $0x80191a00
80100410:	e8 f4 42 00 00       	call   80104709 <acquire>
80100415:	83 c4 10             	add    $0x10,%esp

  if (fmt == 0)
80100418:	8b 45 08             	mov    0x8(%ebp),%eax
8010041b:	85 c0                	test   %eax,%eax
8010041d:	75 0d                	jne    8010042c <cprintf+0x38>
    panic("null fmt");
8010041f:	83 ec 0c             	sub    $0xc,%esp
80100422:	68 2d a1 10 80       	push   $0x8010a12d
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
80100510:	c7 45 ec 36 a1 10 80 	movl   $0x8010a136,-0x14(%ebp)
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
80100599:	68 00 1a 19 80       	push   $0x80191a00
8010059e:	e8 d4 41 00 00       	call   80104777 <release>
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
801005b4:	c7 05 34 1a 19 80 00 	movl   $0x0,0x80191a34
801005bb:	00 00 00 
  // use lapiccpunum so that we can call panic from mycpu()
  cprintf("lapicid %d: panic: ", lapicid());
801005be:	e8 37 25 00 00       	call   80102afa <lapicid>
801005c3:	83 ec 08             	sub    $0x8,%esp
801005c6:	50                   	push   %eax
801005c7:	68 3d a1 10 80       	push   $0x8010a13d
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
801005e6:	68 51 a1 10 80       	push   $0x8010a151
801005eb:	e8 04 fe ff ff       	call   801003f4 <cprintf>
801005f0:	83 c4 10             	add    $0x10,%esp
  getcallerpcs(&s, pcs);
801005f3:	83 ec 08             	sub    $0x8,%esp
801005f6:	8d 45 cc             	lea    -0x34(%ebp),%eax
801005f9:	50                   	push   %eax
801005fa:	8d 45 08             	lea    0x8(%ebp),%eax
801005fd:	50                   	push   %eax
801005fe:	e8 c6 41 00 00       	call   801047c9 <getcallerpcs>
80100603:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<10; i++)
80100606:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010060d:	eb 1c                	jmp    8010062b <panic+0x82>
    cprintf(" %p", pcs[i]);
8010060f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100612:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
80100616:	83 ec 08             	sub    $0x8,%esp
80100619:	50                   	push   %eax
8010061a:	68 53 a1 10 80       	push   $0x8010a153
8010061f:	e8 d0 fd ff ff       	call   801003f4 <cprintf>
80100624:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<10; i++)
80100627:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010062b:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
8010062f:	7e de                	jle    8010060f <panic+0x66>
  panicked = 1; // freeze other CPU
80100631:	c7 05 ec 19 19 80 01 	movl   $0x1,0x801919ec
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
801006a0:	e8 b1 78 00 00       	call   80107f56 <graphic_scroll_up>
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
801006f3:	e8 5e 78 00 00       	call   80107f56 <graphic_scroll_up>
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
80100757:	e8 65 78 00 00       	call   80107fc1 <font_render>
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
80100775:	a1 ec 19 19 80       	mov    0x801919ec,%eax
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
80100793:	e8 35 5c 00 00       	call   801063cd <uartputc>
80100798:	83 c4 10             	add    $0x10,%esp
8010079b:	83 ec 0c             	sub    $0xc,%esp
8010079e:	6a 20                	push   $0x20
801007a0:	e8 28 5c 00 00       	call   801063cd <uartputc>
801007a5:	83 c4 10             	add    $0x10,%esp
801007a8:	83 ec 0c             	sub    $0xc,%esp
801007ab:	6a 08                	push   $0x8
801007ad:	e8 1b 5c 00 00       	call   801063cd <uartputc>
801007b2:	83 c4 10             	add    $0x10,%esp
801007b5:	eb 0e                	jmp    801007c5 <consputc+0x56>
  } else {
    uartputc(c);
801007b7:	83 ec 0c             	sub    $0xc,%esp
801007ba:	ff 75 08             	push   0x8(%ebp)
801007bd:	e8 0b 5c 00 00       	call   801063cd <uartputc>
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
801007e6:	68 00 1a 19 80       	push   $0x80191a00
801007eb:	e8 19 3f 00 00       	call   80104709 <acquire>
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
80100838:	a1 e8 19 19 80       	mov    0x801919e8,%eax
8010083d:	83 e8 01             	sub    $0x1,%eax
80100840:	a3 e8 19 19 80       	mov    %eax,0x801919e8
        consputc(BACKSPACE);
80100845:	83 ec 0c             	sub    $0xc,%esp
80100848:	68 00 01 00 00       	push   $0x100
8010084d:	e8 1d ff ff ff       	call   8010076f <consputc>
80100852:	83 c4 10             	add    $0x10,%esp
      while(input.e != input.w &&
80100855:	8b 15 e8 19 19 80    	mov    0x801919e8,%edx
8010085b:	a1 e4 19 19 80       	mov    0x801919e4,%eax
80100860:	39 c2                	cmp    %eax,%edx
80100862:	0f 84 e0 00 00 00    	je     80100948 <consoleintr+0x172>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
80100868:	a1 e8 19 19 80       	mov    0x801919e8,%eax
8010086d:	83 e8 01             	sub    $0x1,%eax
80100870:	83 e0 7f             	and    $0x7f,%eax
80100873:	0f b6 80 60 19 19 80 	movzbl -0x7fe6e6a0(%eax),%eax
      while(input.e != input.w &&
8010087a:	3c 0a                	cmp    $0xa,%al
8010087c:	75 ba                	jne    80100838 <consoleintr+0x62>
      }
      break;
8010087e:	e9 c5 00 00 00       	jmp    80100948 <consoleintr+0x172>
    case C('H'): case '\x7f':  // Backspace
      if(input.e != input.w){
80100883:	8b 15 e8 19 19 80    	mov    0x801919e8,%edx
80100889:	a1 e4 19 19 80       	mov    0x801919e4,%eax
8010088e:	39 c2                	cmp    %eax,%edx
80100890:	0f 84 b2 00 00 00    	je     80100948 <consoleintr+0x172>
        input.e--;
80100896:	a1 e8 19 19 80       	mov    0x801919e8,%eax
8010089b:	83 e8 01             	sub    $0x1,%eax
8010089e:	a3 e8 19 19 80       	mov    %eax,0x801919e8
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
801008c2:	a1 e8 19 19 80       	mov    0x801919e8,%eax
801008c7:	8b 15 e0 19 19 80    	mov    0x801919e0,%edx
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
801008e7:	a1 e8 19 19 80       	mov    0x801919e8,%eax
801008ec:	8d 50 01             	lea    0x1(%eax),%edx
801008ef:	89 15 e8 19 19 80    	mov    %edx,0x801919e8
801008f5:	83 e0 7f             	and    $0x7f,%eax
801008f8:	8b 55 f0             	mov    -0x10(%ebp),%edx
801008fb:	88 90 60 19 19 80    	mov    %dl,-0x7fe6e6a0(%eax)
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
8010091b:	a1 e8 19 19 80       	mov    0x801919e8,%eax
80100920:	8b 15 e0 19 19 80    	mov    0x801919e0,%edx
80100926:	83 ea 80             	sub    $0xffffff80,%edx
80100929:	39 d0                	cmp    %edx,%eax
8010092b:	75 1a                	jne    80100947 <consoleintr+0x171>
          input.w = input.e;
8010092d:	a1 e8 19 19 80       	mov    0x801919e8,%eax
80100932:	a3 e4 19 19 80       	mov    %eax,0x801919e4
          wakeup(&input.r);
80100937:	83 ec 0c             	sub    $0xc,%esp
8010093a:	68 e0 19 19 80       	push   $0x801919e0
8010093f:	e8 8b 3a 00 00       	call   801043cf <wakeup>
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
8010095d:	68 00 1a 19 80       	push   $0x80191a00
80100962:	e8 10 3e 00 00       	call   80104777 <release>
80100967:	83 c4 10             	add    $0x10,%esp
  if(doprocdump) {
8010096a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010096e:	74 05                	je     80100975 <consoleintr+0x19f>
    procdump();  // now call procdump() wo. cons.lock held
80100970:	e8 18 3b 00 00       	call   8010448d <procdump>
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
80100995:	68 00 1a 19 80       	push   $0x80191a00
8010099a:	e8 6a 3d 00 00       	call   80104709 <acquire>
8010099f:	83 c4 10             	add    $0x10,%esp
  while(n > 0){
801009a2:	e9 ab 00 00 00       	jmp    80100a52 <consoleread+0xda>
    while(input.r == input.w){
      if(myproc()->killed){
801009a7:	e8 84 30 00 00       	call   80103a30 <myproc>
801009ac:	8b 40 24             	mov    0x24(%eax),%eax
801009af:	85 c0                	test   %eax,%eax
801009b1:	74 28                	je     801009db <consoleread+0x63>
        release(&cons.lock);
801009b3:	83 ec 0c             	sub    $0xc,%esp
801009b6:	68 00 1a 19 80       	push   $0x80191a00
801009bb:	e8 b7 3d 00 00       	call   80104777 <release>
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
801009de:	68 00 1a 19 80       	push   $0x80191a00
801009e3:	68 e0 19 19 80       	push   $0x801919e0
801009e8:	e8 f8 38 00 00       	call   801042e5 <sleep>
801009ed:	83 c4 10             	add    $0x10,%esp
    while(input.r == input.w){
801009f0:	8b 15 e0 19 19 80    	mov    0x801919e0,%edx
801009f6:	a1 e4 19 19 80       	mov    0x801919e4,%eax
801009fb:	39 c2                	cmp    %eax,%edx
801009fd:	74 a8                	je     801009a7 <consoleread+0x2f>
    }
    c = input.buf[input.r++ % INPUT_BUF];
801009ff:	a1 e0 19 19 80       	mov    0x801919e0,%eax
80100a04:	8d 50 01             	lea    0x1(%eax),%edx
80100a07:	89 15 e0 19 19 80    	mov    %edx,0x801919e0
80100a0d:	83 e0 7f             	and    $0x7f,%eax
80100a10:	0f b6 80 60 19 19 80 	movzbl -0x7fe6e6a0(%eax),%eax
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
80100a2b:	a1 e0 19 19 80       	mov    0x801919e0,%eax
80100a30:	83 e8 01             	sub    $0x1,%eax
80100a33:	a3 e0 19 19 80       	mov    %eax,0x801919e0
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
80100a61:	68 00 1a 19 80       	push   $0x80191a00
80100a66:	e8 0c 3d 00 00       	call   80104777 <release>
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
80100a9d:	68 00 1a 19 80       	push   $0x80191a00
80100aa2:	e8 62 3c 00 00       	call   80104709 <acquire>
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
80100adf:	68 00 1a 19 80       	push   $0x80191a00
80100ae4:	e8 8e 3c 00 00       	call   80104777 <release>
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
80100b05:	c7 05 ec 19 19 80 00 	movl   $0x0,0x801919ec
80100b0c:	00 00 00 
  initlock(&cons.lock, "console");
80100b0f:	83 ec 08             	sub    $0x8,%esp
80100b12:	68 57 a1 10 80       	push   $0x8010a157
80100b17:	68 00 1a 19 80       	push   $0x80191a00
80100b1c:	e8 c6 3b 00 00       	call   801046e7 <initlock>
80100b21:	83 c4 10             	add    $0x10,%esp

  devsw[CONSOLE].write = consolewrite;
80100b24:	c7 05 4c 1a 19 80 86 	movl   $0x80100a86,0x80191a4c
80100b2b:	0a 10 80 
  devsw[CONSOLE].read = consoleread;
80100b2e:	c7 05 48 1a 19 80 78 	movl   $0x80100978,0x80191a48
80100b35:	09 10 80 
  
  char *p;
  for(p="Starting XV6_UEFI...\n"; *p; p++)
80100b38:	c7 45 f4 5f a1 10 80 	movl   $0x8010a15f,-0xc(%ebp)
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
80100b64:	c7 05 34 1a 19 80 01 	movl   $0x1,0x80191a34
80100b6b:	00 00 00 

  ioapicenable(IRQ_KBD, 0);
80100b6e:	83 ec 08             	sub    $0x8,%esp
80100b71:	6a 00                	push   $0x0
80100b73:	6a 01                	push   $0x1
80100b75:	e8 b4 1a 00 00       	call   8010262e <ioapicenable>
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
80100b89:	e8 a2 2e 00 00       	call   80103a30 <myproc>
80100b8e:	89 45 d0             	mov    %eax,-0x30(%ebp)

  begin_op();
80100b91:	e8 a6 24 00 00       	call   8010303c <begin_op>

  if((ip = namei(path)) == 0){
80100b96:	83 ec 0c             	sub    $0xc,%esp
80100b99:	ff 75 08             	push   0x8(%ebp)
80100b9c:	e8 7c 19 00 00       	call   8010251d <namei>
80100ba1:	83 c4 10             	add    $0x10,%esp
80100ba4:	89 45 d8             	mov    %eax,-0x28(%ebp)
80100ba7:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100bab:	75 1f                	jne    80100bcc <exec+0x4c>
    end_op();
80100bad:	e8 16 25 00 00       	call   801030c8 <end_op>
    cprintf("exec: fail\n");
80100bb2:	83 ec 0c             	sub    $0xc,%esp
80100bb5:	68 75 a1 10 80       	push   $0x8010a175
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
80100c11:	e8 b3 67 00 00       	call   801073c9 <setupkvm>
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
80100cb7:	e8 06 6b 00 00       	call   801077c2 <allocuvm>
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
80100cfd:	e8 f3 69 00 00       	call   801076f5 <loaduvm>
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
80100d3e:	e8 85 23 00 00       	call   801030c8 <end_op>
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
80100d6c:	e8 51 6a 00 00       	call   801077c2 <allocuvm>
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
80100d90:	e8 8f 6c 00 00       	call   80107a24 <clearpteu>
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
80100dc9:	e8 ff 3d 00 00       	call   80104bcd <strlen>
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
80100df6:	e8 d2 3d 00 00       	call   80104bcd <strlen>
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
80100e1c:	e8 a2 6d 00 00       	call   80107bc3 <copyout>
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
80100eb8:	e8 06 6d 00 00       	call   80107bc3 <copyout>
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
80100f06:	e8 77 3c 00 00       	call   80104b82 <safestrcpy>
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
80100f49:	e8 98 65 00 00       	call   801074e6 <switchuvm>
80100f4e:	83 c4 10             	add    $0x10,%esp
  freevm(oldpgdir);
80100f51:	83 ec 0c             	sub    $0xc,%esp
80100f54:	ff 75 cc             	push   -0x34(%ebp)
80100f57:	e8 2f 6a 00 00       	call   8010798b <freevm>
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
80100f97:	e8 ef 69 00 00       	call   8010798b <freevm>
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
80100fb3:	e8 10 21 00 00       	call   801030c8 <end_op>
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
80100fc8:	68 81 a1 10 80       	push   $0x8010a181
80100fcd:	68 a0 1a 19 80       	push   $0x80191aa0
80100fd2:	e8 10 37 00 00       	call   801046e7 <initlock>
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
80100fe6:	68 a0 1a 19 80       	push   $0x80191aa0
80100feb:	e8 19 37 00 00       	call   80104709 <acquire>
80100ff0:	83 c4 10             	add    $0x10,%esp
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80100ff3:	c7 45 f4 d4 1a 19 80 	movl   $0x80191ad4,-0xc(%ebp)
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
80101013:	68 a0 1a 19 80       	push   $0x80191aa0
80101018:	e8 5a 37 00 00       	call   80104777 <release>
8010101d:	83 c4 10             	add    $0x10,%esp
      return f;
80101020:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101023:	eb 23                	jmp    80101048 <filealloc+0x6b>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80101025:	83 45 f4 18          	addl   $0x18,-0xc(%ebp)
80101029:	b8 34 24 19 80       	mov    $0x80192434,%eax
8010102e:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80101031:	72 c9                	jb     80100ffc <filealloc+0x1f>
    }
  }
  release(&ftable.lock);
80101033:	83 ec 0c             	sub    $0xc,%esp
80101036:	68 a0 1a 19 80       	push   $0x80191aa0
8010103b:	e8 37 37 00 00       	call   80104777 <release>
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
80101053:	68 a0 1a 19 80       	push   $0x80191aa0
80101058:	e8 ac 36 00 00       	call   80104709 <acquire>
8010105d:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
80101060:	8b 45 08             	mov    0x8(%ebp),%eax
80101063:	8b 40 04             	mov    0x4(%eax),%eax
80101066:	85 c0                	test   %eax,%eax
80101068:	7f 0d                	jg     80101077 <filedup+0x2d>
    panic("filedup");
8010106a:	83 ec 0c             	sub    $0xc,%esp
8010106d:	68 88 a1 10 80       	push   $0x8010a188
80101072:	e8 32 f5 ff ff       	call   801005a9 <panic>
  f->ref++;
80101077:	8b 45 08             	mov    0x8(%ebp),%eax
8010107a:	8b 40 04             	mov    0x4(%eax),%eax
8010107d:	8d 50 01             	lea    0x1(%eax),%edx
80101080:	8b 45 08             	mov    0x8(%ebp),%eax
80101083:	89 50 04             	mov    %edx,0x4(%eax)
  release(&ftable.lock);
80101086:	83 ec 0c             	sub    $0xc,%esp
80101089:	68 a0 1a 19 80       	push   $0x80191aa0
8010108e:	e8 e4 36 00 00       	call   80104777 <release>
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
801010a4:	68 a0 1a 19 80       	push   $0x80191aa0
801010a9:	e8 5b 36 00 00       	call   80104709 <acquire>
801010ae:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
801010b1:	8b 45 08             	mov    0x8(%ebp),%eax
801010b4:	8b 40 04             	mov    0x4(%eax),%eax
801010b7:	85 c0                	test   %eax,%eax
801010b9:	7f 0d                	jg     801010c8 <fileclose+0x2d>
    panic("fileclose");
801010bb:	83 ec 0c             	sub    $0xc,%esp
801010be:	68 90 a1 10 80       	push   $0x8010a190
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
801010e4:	68 a0 1a 19 80       	push   $0x80191aa0
801010e9:	e8 89 36 00 00       	call   80104777 <release>
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
80101132:	68 a0 1a 19 80       	push   $0x80191aa0
80101137:	e8 3b 36 00 00       	call   80104777 <release>
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
80101156:	e8 64 25 00 00       	call   801036bf <pipeclose>
8010115b:	83 c4 10             	add    $0x10,%esp
8010115e:	eb 21                	jmp    80101181 <fileclose+0xe6>
  else if(ff.type == FD_INODE){
80101160:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101163:	83 f8 02             	cmp    $0x2,%eax
80101166:	75 19                	jne    80101181 <fileclose+0xe6>
    begin_op();
80101168:	e8 cf 1e 00 00       	call   8010303c <begin_op>
    iput(ff.ip);
8010116d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101170:	83 ec 0c             	sub    $0xc,%esp
80101173:	50                   	push   %eax
80101174:	e8 d2 09 00 00       	call   80101b4b <iput>
80101179:	83 c4 10             	add    $0x10,%esp
    end_op();
8010117c:	e8 47 1f 00 00       	call   801030c8 <end_op>
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
8010120f:	e8 58 26 00 00       	call   8010386c <piperead>
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
80101286:	68 9a a1 10 80       	push   $0x8010a19a
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
801012c8:	e8 9d 24 00 00       	call   8010376a <pipewrite>
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
8010130d:	e8 2a 1d 00 00       	call   8010303c <begin_op>
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
80101373:	e8 50 1d 00 00       	call   801030c8 <end_op>

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
80101389:	68 a3 a1 10 80       	push   $0x8010a1a3
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
801013bf:	68 b3 a1 10 80       	push   $0x8010a1b3
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
801013f7:	e8 42 36 00 00       	call   80104a3e <memmove>
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
8010143d:	e8 3d 35 00 00       	call   8010497f <memset>
80101442:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
80101445:	83 ec 0c             	sub    $0xc,%esp
80101448:	ff 75 f4             	push   -0xc(%ebp)
8010144b:	e8 25 1e 00 00       	call   80103275 <log_write>
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
80101490:	a1 58 24 19 80       	mov    0x80192458,%eax
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
80101517:	e8 59 1d 00 00       	call   80103275 <log_write>
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
80101566:	a1 40 24 19 80       	mov    0x80192440,%eax
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
80101588:	8b 15 40 24 19 80    	mov    0x80192440,%edx
8010158e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101591:	39 c2                	cmp    %eax,%edx
80101593:	0f 87 e4 fe ff ff    	ja     8010147d <balloc+0x19>
  }
  panic("balloc: out of blocks");
80101599:	83 ec 0c             	sub    $0xc,%esp
8010159c:	68 c0 a1 10 80       	push   $0x8010a1c0
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
801015b1:	68 40 24 19 80       	push   $0x80192440
801015b6:	ff 75 08             	push   0x8(%ebp)
801015b9:	e8 10 fe ff ff       	call   801013ce <readsb>
801015be:	83 c4 10             	add    $0x10,%esp
  bp = bread(dev, BBLOCK(b, sb));
801015c1:	8b 45 0c             	mov    0xc(%ebp),%eax
801015c4:	c1 e8 0c             	shr    $0xc,%eax
801015c7:	89 c2                	mov    %eax,%edx
801015c9:	a1 58 24 19 80       	mov    0x80192458,%eax
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
80101627:	68 d6 a1 10 80       	push   $0x8010a1d6
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
8010165f:	e8 11 1c 00 00       	call   80103275 <log_write>
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
8010168b:	68 e9 a1 10 80       	push   $0x8010a1e9
80101690:	68 60 24 19 80       	push   $0x80192460
80101695:	e8 4d 30 00 00       	call   801046e7 <initlock>
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
801016b6:	05 60 24 19 80       	add    $0x80192460,%eax
801016bb:	83 c0 10             	add    $0x10,%eax
801016be:	83 ec 08             	sub    $0x8,%esp
801016c1:	68 f0 a1 10 80       	push   $0x8010a1f0
801016c6:	50                   	push   %eax
801016c7:	e8 be 2e 00 00       	call   8010458a <initsleeplock>
801016cc:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NINODE; i++) {
801016cf:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
801016d3:	83 7d e4 31          	cmpl   $0x31,-0x1c(%ebp)
801016d7:	7e cd                	jle    801016a6 <iinit+0x2e>
  }

  readsb(dev, &sb);
801016d9:	83 ec 08             	sub    $0x8,%esp
801016dc:	68 40 24 19 80       	push   $0x80192440
801016e1:	ff 75 08             	push   0x8(%ebp)
801016e4:	e8 e5 fc ff ff       	call   801013ce <readsb>
801016e9:	83 c4 10             	add    $0x10,%esp
  cprintf("sb: size %d nblocks %d ninodes %d nlog %d logstart %d\
801016ec:	a1 58 24 19 80       	mov    0x80192458,%eax
801016f1:	89 45 d4             	mov    %eax,-0x2c(%ebp)
801016f4:	8b 3d 54 24 19 80    	mov    0x80192454,%edi
801016fa:	8b 35 50 24 19 80    	mov    0x80192450,%esi
80101700:	8b 1d 4c 24 19 80    	mov    0x8019244c,%ebx
80101706:	8b 0d 48 24 19 80    	mov    0x80192448,%ecx
8010170c:	8b 15 44 24 19 80    	mov    0x80192444,%edx
80101712:	a1 40 24 19 80       	mov    0x80192440,%eax
80101717:	ff 75 d4             	push   -0x2c(%ebp)
8010171a:	57                   	push   %edi
8010171b:	56                   	push   %esi
8010171c:	53                   	push   %ebx
8010171d:	51                   	push   %ecx
8010171e:	52                   	push   %edx
8010171f:	50                   	push   %eax
80101720:	68 f8 a1 10 80       	push   $0x8010a1f8
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
80101757:	a1 54 24 19 80       	mov    0x80192454,%eax
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
80101799:	e8 e1 31 00 00       	call   8010497f <memset>
8010179e:	83 c4 10             	add    $0x10,%esp
      dip->type = type;
801017a1:	8b 45 ec             	mov    -0x14(%ebp),%eax
801017a4:	0f b7 55 e4          	movzwl -0x1c(%ebp),%edx
801017a8:	66 89 10             	mov    %dx,(%eax)
      log_write(bp);   // mark it allocated on the disk
801017ab:	83 ec 0c             	sub    $0xc,%esp
801017ae:	ff 75 f0             	push   -0x10(%ebp)
801017b1:	e8 bf 1a 00 00       	call   80103275 <log_write>
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
801017ed:	8b 15 48 24 19 80    	mov    0x80192448,%edx
801017f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017f6:	39 c2                	cmp    %eax,%edx
801017f8:	0f 87 51 ff ff ff    	ja     8010174f <ialloc+0x19>
  }
  panic("ialloc: no inodes");
801017fe:	83 ec 0c             	sub    $0xc,%esp
80101801:	68 4b a2 10 80       	push   $0x8010a24b
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
8010181e:	a1 54 24 19 80       	mov    0x80192454,%eax
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
801018a7:	e8 92 31 00 00       	call   80104a3e <memmove>
801018ac:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
801018af:	83 ec 0c             	sub    $0xc,%esp
801018b2:	ff 75 f4             	push   -0xc(%ebp)
801018b5:	e8 bb 19 00 00       	call   80103275 <log_write>
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
801018d7:	68 60 24 19 80       	push   $0x80192460
801018dc:	e8 28 2e 00 00       	call   80104709 <acquire>
801018e1:	83 c4 10             	add    $0x10,%esp

  // Is the inode already cached?
  empty = 0;
801018e4:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
801018eb:	c7 45 f4 94 24 19 80 	movl   $0x80192494,-0xc(%ebp)
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
80101925:	68 60 24 19 80       	push   $0x80192460
8010192a:	e8 48 2e 00 00       	call   80104777 <release>
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
80101954:	81 7d f4 b4 40 19 80 	cmpl   $0x801940b4,-0xc(%ebp)
8010195b:	72 97                	jb     801018f4 <iget+0x26>
  }

  // Recycle an inode cache entry.
  if(empty == 0)
8010195d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80101961:	75 0d                	jne    80101970 <iget+0xa2>
    panic("iget: no inodes");
80101963:	83 ec 0c             	sub    $0xc,%esp
80101966:	68 5d a2 10 80       	push   $0x8010a25d
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
8010199e:	68 60 24 19 80       	push   $0x80192460
801019a3:	e8 cf 2d 00 00       	call   80104777 <release>
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
801019b9:	68 60 24 19 80       	push   $0x80192460
801019be:	e8 46 2d 00 00       	call   80104709 <acquire>
801019c3:	83 c4 10             	add    $0x10,%esp
  ip->ref++;
801019c6:	8b 45 08             	mov    0x8(%ebp),%eax
801019c9:	8b 40 08             	mov    0x8(%eax),%eax
801019cc:	8d 50 01             	lea    0x1(%eax),%edx
801019cf:	8b 45 08             	mov    0x8(%ebp),%eax
801019d2:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
801019d5:	83 ec 0c             	sub    $0xc,%esp
801019d8:	68 60 24 19 80       	push   $0x80192460
801019dd:	e8 95 2d 00 00       	call   80104777 <release>
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
80101a03:	68 6d a2 10 80       	push   $0x8010a26d
80101a08:	e8 9c eb ff ff       	call   801005a9 <panic>

  acquiresleep(&ip->lock);
80101a0d:	8b 45 08             	mov    0x8(%ebp),%eax
80101a10:	83 c0 0c             	add    $0xc,%eax
80101a13:	83 ec 0c             	sub    $0xc,%esp
80101a16:	50                   	push   %eax
80101a17:	e8 aa 2b 00 00       	call   801045c6 <acquiresleep>
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
80101a38:	a1 54 24 19 80       	mov    0x80192454,%eax
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
80101ac1:	e8 78 2f 00 00       	call   80104a3e <memmove>
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
80101af0:	68 73 a2 10 80       	push   $0x8010a273
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
80101b13:	e8 60 2b 00 00       	call   80104678 <holdingsleep>
80101b18:	83 c4 10             	add    $0x10,%esp
80101b1b:	85 c0                	test   %eax,%eax
80101b1d:	74 0a                	je     80101b29 <iunlock+0x2c>
80101b1f:	8b 45 08             	mov    0x8(%ebp),%eax
80101b22:	8b 40 08             	mov    0x8(%eax),%eax
80101b25:	85 c0                	test   %eax,%eax
80101b27:	7f 0d                	jg     80101b36 <iunlock+0x39>
    panic("iunlock");
80101b29:	83 ec 0c             	sub    $0xc,%esp
80101b2c:	68 82 a2 10 80       	push   $0x8010a282
80101b31:	e8 73 ea ff ff       	call   801005a9 <panic>

  releasesleep(&ip->lock);
80101b36:	8b 45 08             	mov    0x8(%ebp),%eax
80101b39:	83 c0 0c             	add    $0xc,%eax
80101b3c:	83 ec 0c             	sub    $0xc,%esp
80101b3f:	50                   	push   %eax
80101b40:	e8 e5 2a 00 00       	call   8010462a <releasesleep>
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
80101b5b:	e8 66 2a 00 00       	call   801045c6 <acquiresleep>
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
80101b7c:	68 60 24 19 80       	push   $0x80192460
80101b81:	e8 83 2b 00 00       	call   80104709 <acquire>
80101b86:	83 c4 10             	add    $0x10,%esp
    int r = ip->ref;
80101b89:	8b 45 08             	mov    0x8(%ebp),%eax
80101b8c:	8b 40 08             	mov    0x8(%eax),%eax
80101b8f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    release(&icache.lock);
80101b92:	83 ec 0c             	sub    $0xc,%esp
80101b95:	68 60 24 19 80       	push   $0x80192460
80101b9a:	e8 d8 2b 00 00       	call   80104777 <release>
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
80101be1:	e8 44 2a 00 00       	call   8010462a <releasesleep>
80101be6:	83 c4 10             	add    $0x10,%esp

  acquire(&icache.lock);
80101be9:	83 ec 0c             	sub    $0xc,%esp
80101bec:	68 60 24 19 80       	push   $0x80192460
80101bf1:	e8 13 2b 00 00       	call   80104709 <acquire>
80101bf6:	83 c4 10             	add    $0x10,%esp
  ip->ref--;
80101bf9:	8b 45 08             	mov    0x8(%ebp),%eax
80101bfc:	8b 40 08             	mov    0x8(%eax),%eax
80101bff:	8d 50 ff             	lea    -0x1(%eax),%edx
80101c02:	8b 45 08             	mov    0x8(%ebp),%eax
80101c05:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101c08:	83 ec 0c             	sub    $0xc,%esp
80101c0b:	68 60 24 19 80       	push   $0x80192460
80101c10:	e8 62 2b 00 00       	call   80104777 <release>
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
80101d36:	e8 3a 15 00 00       	call   80103275 <log_write>
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
80101d54:	68 8a a2 10 80       	push   $0x8010a28a
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
80101f0a:	8b 04 c5 40 1a 19 80 	mov    -0x7fe6e5c0(,%eax,8),%eax
80101f11:	85 c0                	test   %eax,%eax
80101f13:	75 0a                	jne    80101f1f <readi+0x49>
      return -1;
80101f15:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101f1a:	e9 0a 01 00 00       	jmp    80102029 <readi+0x153>
    return devsw[ip->major].read(ip, dst, n);
80101f1f:	8b 45 08             	mov    0x8(%ebp),%eax
80101f22:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101f26:	98                   	cwtl   
80101f27:	8b 04 c5 40 1a 19 80 	mov    -0x7fe6e5c0(,%eax,8),%eax
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
80101ff2:	e8 47 2a 00 00       	call   80104a3e <memmove>
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
8010205f:	8b 04 c5 44 1a 19 80 	mov    -0x7fe6e5bc(,%eax,8),%eax
80102066:	85 c0                	test   %eax,%eax
80102068:	75 0a                	jne    80102074 <writei+0x49>
      return -1;
8010206a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010206f:	e9 3b 01 00 00       	jmp    801021af <writei+0x184>
    return devsw[ip->major].write(ip, src, n);
80102074:	8b 45 08             	mov    0x8(%ebp),%eax
80102077:	0f b7 40 52          	movzwl 0x52(%eax),%eax
8010207b:	98                   	cwtl   
8010207c:	8b 04 c5 44 1a 19 80 	mov    -0x7fe6e5bc(,%eax,8),%eax
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
80102142:	e8 f7 28 00 00       	call   80104a3e <memmove>
80102147:	83 c4 10             	add    $0x10,%esp
    log_write(bp);
8010214a:	83 ec 0c             	sub    $0xc,%esp
8010214d:	ff 75 f0             	push   -0x10(%ebp)
80102150:	e8 20 11 00 00       	call   80103275 <log_write>
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
801021c2:	e8 0d 29 00 00       	call   80104ad4 <strncmp>
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
801021e2:	68 9d a2 10 80       	push   $0x8010a29d
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
80102211:	68 af a2 10 80       	push   $0x8010a2af
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
801022e6:	68 be a2 10 80       	push   $0x8010a2be
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
80102321:	e8 04 28 00 00       	call   80104b2a <strncpy>
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
8010234d:	68 cb a2 10 80       	push   $0x8010a2cb
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
801023bf:	e8 7a 26 00 00       	call   80104a3e <memmove>
801023c4:	83 c4 10             	add    $0x10,%esp
801023c7:	eb 26                	jmp    801023ef <skipelem+0x91>
  else {
    memmove(name, s, len);
801023c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801023cc:	83 ec 04             	sub    $0x4,%esp
801023cf:	50                   	push   %eax
801023d0:	ff 75 f4             	push   -0xc(%ebp)
801023d3:	ff 75 0c             	push   0xc(%ebp)
801023d6:	e8 63 26 00 00       	call   80104a3e <memmove>
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
80102425:	e8 06 16 00 00       	call   80103a30 <myproc>
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

80102554 <ioapicread>:
  uint data;
};

static uint
ioapicread(int reg)
{
80102554:	55                   	push   %ebp
80102555:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102557:	a1 b4 40 19 80       	mov    0x801940b4,%eax
8010255c:	8b 55 08             	mov    0x8(%ebp),%edx
8010255f:	89 10                	mov    %edx,(%eax)
  return ioapic->data;
80102561:	a1 b4 40 19 80       	mov    0x801940b4,%eax
80102566:	8b 40 10             	mov    0x10(%eax),%eax
}
80102569:	5d                   	pop    %ebp
8010256a:	c3                   	ret    

8010256b <ioapicwrite>:

static void
ioapicwrite(int reg, uint data)
{
8010256b:	55                   	push   %ebp
8010256c:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
8010256e:	a1 b4 40 19 80       	mov    0x801940b4,%eax
80102573:	8b 55 08             	mov    0x8(%ebp),%edx
80102576:	89 10                	mov    %edx,(%eax)
  ioapic->data = data;
80102578:	a1 b4 40 19 80       	mov    0x801940b4,%eax
8010257d:	8b 55 0c             	mov    0xc(%ebp),%edx
80102580:	89 50 10             	mov    %edx,0x10(%eax)
}
80102583:	90                   	nop
80102584:	5d                   	pop    %ebp
80102585:	c3                   	ret    

80102586 <ioapicinit>:

void
ioapicinit(void)
{
80102586:	55                   	push   %ebp
80102587:	89 e5                	mov    %esp,%ebp
80102589:	83 ec 18             	sub    $0x18,%esp
  int i, id, maxintr;

  ioapic = (volatile struct ioapic*)IOAPIC;
8010258c:	c7 05 b4 40 19 80 00 	movl   $0xfec00000,0x801940b4
80102593:	00 c0 fe 
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
80102596:	6a 01                	push   $0x1
80102598:	e8 b7 ff ff ff       	call   80102554 <ioapicread>
8010259d:	83 c4 04             	add    $0x4,%esp
801025a0:	c1 e8 10             	shr    $0x10,%eax
801025a3:	25 ff 00 00 00       	and    $0xff,%eax
801025a8:	89 45 f0             	mov    %eax,-0x10(%ebp)
  id = ioapicread(REG_ID) >> 24;
801025ab:	6a 00                	push   $0x0
801025ad:	e8 a2 ff ff ff       	call   80102554 <ioapicread>
801025b2:	83 c4 04             	add    $0x4,%esp
801025b5:	c1 e8 18             	shr    $0x18,%eax
801025b8:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(id != ioapicid)
801025bb:	0f b6 05 44 6e 19 80 	movzbl 0x80196e44,%eax
801025c2:	0f b6 c0             	movzbl %al,%eax
801025c5:	39 45 ec             	cmp    %eax,-0x14(%ebp)
801025c8:	74 10                	je     801025da <ioapicinit+0x54>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
801025ca:	83 ec 0c             	sub    $0xc,%esp
801025cd:	68 d4 a2 10 80       	push   $0x8010a2d4
801025d2:	e8 1d de ff ff       	call   801003f4 <cprintf>
801025d7:	83 c4 10             	add    $0x10,%esp

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
801025da:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801025e1:	eb 3f                	jmp    80102622 <ioapicinit+0x9c>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
801025e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801025e6:	83 c0 20             	add    $0x20,%eax
801025e9:	0d 00 00 01 00       	or     $0x10000,%eax
801025ee:	89 c2                	mov    %eax,%edx
801025f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801025f3:	83 c0 08             	add    $0x8,%eax
801025f6:	01 c0                	add    %eax,%eax
801025f8:	83 ec 08             	sub    $0x8,%esp
801025fb:	52                   	push   %edx
801025fc:	50                   	push   %eax
801025fd:	e8 69 ff ff ff       	call   8010256b <ioapicwrite>
80102602:	83 c4 10             	add    $0x10,%esp
    ioapicwrite(REG_TABLE+2*i+1, 0);
80102605:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102608:	83 c0 08             	add    $0x8,%eax
8010260b:	01 c0                	add    %eax,%eax
8010260d:	83 c0 01             	add    $0x1,%eax
80102610:	83 ec 08             	sub    $0x8,%esp
80102613:	6a 00                	push   $0x0
80102615:	50                   	push   %eax
80102616:	e8 50 ff ff ff       	call   8010256b <ioapicwrite>
8010261b:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i <= maxintr; i++){
8010261e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102622:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102625:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80102628:	7e b9                	jle    801025e3 <ioapicinit+0x5d>
  }
}
8010262a:	90                   	nop
8010262b:	90                   	nop
8010262c:	c9                   	leave  
8010262d:	c3                   	ret    

8010262e <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
8010262e:	55                   	push   %ebp
8010262f:	89 e5                	mov    %esp,%ebp
  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
80102631:	8b 45 08             	mov    0x8(%ebp),%eax
80102634:	83 c0 20             	add    $0x20,%eax
80102637:	89 c2                	mov    %eax,%edx
80102639:	8b 45 08             	mov    0x8(%ebp),%eax
8010263c:	83 c0 08             	add    $0x8,%eax
8010263f:	01 c0                	add    %eax,%eax
80102641:	52                   	push   %edx
80102642:	50                   	push   %eax
80102643:	e8 23 ff ff ff       	call   8010256b <ioapicwrite>
80102648:	83 c4 08             	add    $0x8,%esp
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
8010264b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010264e:	c1 e0 18             	shl    $0x18,%eax
80102651:	89 c2                	mov    %eax,%edx
80102653:	8b 45 08             	mov    0x8(%ebp),%eax
80102656:	83 c0 08             	add    $0x8,%eax
80102659:	01 c0                	add    %eax,%eax
8010265b:	83 c0 01             	add    $0x1,%eax
8010265e:	52                   	push   %edx
8010265f:	50                   	push   %eax
80102660:	e8 06 ff ff ff       	call   8010256b <ioapicwrite>
80102665:	83 c4 08             	add    $0x8,%esp
}
80102668:	90                   	nop
80102669:	c9                   	leave  
8010266a:	c3                   	ret    

8010266b <kinit1>:
// the pages mapped by entrypgdir on free list.
// 2. main() calls kinit2() with the rest of the physical pages
// after installing a full page table that maps them on all cores.
void
kinit1(void *vstart, void *vend)
{
8010266b:	55                   	push   %ebp
8010266c:	89 e5                	mov    %esp,%ebp
8010266e:	83 ec 08             	sub    $0x8,%esp
  initlock(&kmem.lock, "kmem");
80102671:	83 ec 08             	sub    $0x8,%esp
80102674:	68 06 a3 10 80       	push   $0x8010a306
80102679:	68 c0 40 19 80       	push   $0x801940c0
8010267e:	e8 64 20 00 00       	call   801046e7 <initlock>
80102683:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 0;
80102686:	c7 05 f4 40 19 80 00 	movl   $0x0,0x801940f4
8010268d:	00 00 00 
  freerange(vstart, vend);
80102690:	83 ec 08             	sub    $0x8,%esp
80102693:	ff 75 0c             	push   0xc(%ebp)
80102696:	ff 75 08             	push   0x8(%ebp)
80102699:	e8 2a 00 00 00       	call   801026c8 <freerange>
8010269e:	83 c4 10             	add    $0x10,%esp
}
801026a1:	90                   	nop
801026a2:	c9                   	leave  
801026a3:	c3                   	ret    

801026a4 <kinit2>:

void
kinit2(void *vstart, void *vend)
{
801026a4:	55                   	push   %ebp
801026a5:	89 e5                	mov    %esp,%ebp
801026a7:	83 ec 08             	sub    $0x8,%esp
  freerange(vstart, vend);
801026aa:	83 ec 08             	sub    $0x8,%esp
801026ad:	ff 75 0c             	push   0xc(%ebp)
801026b0:	ff 75 08             	push   0x8(%ebp)
801026b3:	e8 10 00 00 00       	call   801026c8 <freerange>
801026b8:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 1;
801026bb:	c7 05 f4 40 19 80 01 	movl   $0x1,0x801940f4
801026c2:	00 00 00 
}
801026c5:	90                   	nop
801026c6:	c9                   	leave  
801026c7:	c3                   	ret    

801026c8 <freerange>:

void
freerange(void *vstart, void *vend)
{
801026c8:	55                   	push   %ebp
801026c9:	89 e5                	mov    %esp,%ebp
801026cb:	83 ec 18             	sub    $0x18,%esp
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
801026ce:	8b 45 08             	mov    0x8(%ebp),%eax
801026d1:	05 ff 0f 00 00       	add    $0xfff,%eax
801026d6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801026db:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
801026de:	eb 15                	jmp    801026f5 <freerange+0x2d>
    kfree(p);
801026e0:	83 ec 0c             	sub    $0xc,%esp
801026e3:	ff 75 f4             	push   -0xc(%ebp)
801026e6:	e8 1b 00 00 00       	call   80102706 <kfree>
801026eb:	83 c4 10             	add    $0x10,%esp
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
801026ee:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801026f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801026f8:	05 00 10 00 00       	add    $0x1000,%eax
801026fd:	39 45 0c             	cmp    %eax,0xc(%ebp)
80102700:	73 de                	jae    801026e0 <freerange+0x18>
}
80102702:	90                   	nop
80102703:	90                   	nop
80102704:	c9                   	leave  
80102705:	c3                   	ret    

80102706 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
80102706:	55                   	push   %ebp
80102707:	89 e5                	mov    %esp,%ebp
80102709:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if((uint)v % PGSIZE || v < end || V2P(v) >= PHYSTOP)
8010270c:	8b 45 08             	mov    0x8(%ebp),%eax
8010270f:	25 ff 0f 00 00       	and    $0xfff,%eax
80102714:	85 c0                	test   %eax,%eax
80102716:	75 18                	jne    80102730 <kfree+0x2a>
80102718:	81 7d 08 00 90 19 80 	cmpl   $0x80199000,0x8(%ebp)
8010271f:	72 0f                	jb     80102730 <kfree+0x2a>
80102721:	8b 45 08             	mov    0x8(%ebp),%eax
80102724:	05 00 00 00 80       	add    $0x80000000,%eax
80102729:	3d ff ff ff 1f       	cmp    $0x1fffffff,%eax
8010272e:	76 0d                	jbe    8010273d <kfree+0x37>
    panic("kfree");
80102730:	83 ec 0c             	sub    $0xc,%esp
80102733:	68 0b a3 10 80       	push   $0x8010a30b
80102738:	e8 6c de ff ff       	call   801005a9 <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
8010273d:	83 ec 04             	sub    $0x4,%esp
80102740:	68 00 10 00 00       	push   $0x1000
80102745:	6a 01                	push   $0x1
80102747:	ff 75 08             	push   0x8(%ebp)
8010274a:	e8 30 22 00 00       	call   8010497f <memset>
8010274f:	83 c4 10             	add    $0x10,%esp

  if(kmem.use_lock)
80102752:	a1 f4 40 19 80       	mov    0x801940f4,%eax
80102757:	85 c0                	test   %eax,%eax
80102759:	74 10                	je     8010276b <kfree+0x65>
    acquire(&kmem.lock);
8010275b:	83 ec 0c             	sub    $0xc,%esp
8010275e:	68 c0 40 19 80       	push   $0x801940c0
80102763:	e8 a1 1f 00 00       	call   80104709 <acquire>
80102768:	83 c4 10             	add    $0x10,%esp
  r = (struct run*)v;
8010276b:	8b 45 08             	mov    0x8(%ebp),%eax
8010276e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  r->next = kmem.freelist;
80102771:	8b 15 f8 40 19 80    	mov    0x801940f8,%edx
80102777:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010277a:	89 10                	mov    %edx,(%eax)
  kmem.freelist = r;
8010277c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010277f:	a3 f8 40 19 80       	mov    %eax,0x801940f8
  if(kmem.use_lock)
80102784:	a1 f4 40 19 80       	mov    0x801940f4,%eax
80102789:	85 c0                	test   %eax,%eax
8010278b:	74 10                	je     8010279d <kfree+0x97>
    release(&kmem.lock);
8010278d:	83 ec 0c             	sub    $0xc,%esp
80102790:	68 c0 40 19 80       	push   $0x801940c0
80102795:	e8 dd 1f 00 00       	call   80104777 <release>
8010279a:	83 c4 10             	add    $0x10,%esp
}
8010279d:	90                   	nop
8010279e:	c9                   	leave  
8010279f:	c3                   	ret    

801027a0 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
801027a0:	55                   	push   %ebp
801027a1:	89 e5                	mov    %esp,%ebp
801027a3:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if(kmem.use_lock)
801027a6:	a1 f4 40 19 80       	mov    0x801940f4,%eax
801027ab:	85 c0                	test   %eax,%eax
801027ad:	74 10                	je     801027bf <kalloc+0x1f>
    acquire(&kmem.lock);
801027af:	83 ec 0c             	sub    $0xc,%esp
801027b2:	68 c0 40 19 80       	push   $0x801940c0
801027b7:	e8 4d 1f 00 00       	call   80104709 <acquire>
801027bc:	83 c4 10             	add    $0x10,%esp
  r = kmem.freelist;
801027bf:	a1 f8 40 19 80       	mov    0x801940f8,%eax
801027c4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(r)
801027c7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801027cb:	74 0a                	je     801027d7 <kalloc+0x37>
    kmem.freelist = r->next;
801027cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801027d0:	8b 00                	mov    (%eax),%eax
801027d2:	a3 f8 40 19 80       	mov    %eax,0x801940f8
  if(kmem.use_lock)
801027d7:	a1 f4 40 19 80       	mov    0x801940f4,%eax
801027dc:	85 c0                	test   %eax,%eax
801027de:	74 10                	je     801027f0 <kalloc+0x50>
    release(&kmem.lock);
801027e0:	83 ec 0c             	sub    $0xc,%esp
801027e3:	68 c0 40 19 80       	push   $0x801940c0
801027e8:	e8 8a 1f 00 00       	call   80104777 <release>
801027ed:	83 c4 10             	add    $0x10,%esp
  return (char*)r;
801027f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801027f3:	c9                   	leave  
801027f4:	c3                   	ret    

801027f5 <inb>:
{
801027f5:	55                   	push   %ebp
801027f6:	89 e5                	mov    %esp,%ebp
801027f8:	83 ec 14             	sub    $0x14,%esp
801027fb:	8b 45 08             	mov    0x8(%ebp),%eax
801027fe:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102802:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102806:	89 c2                	mov    %eax,%edx
80102808:	ec                   	in     (%dx),%al
80102809:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
8010280c:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102810:	c9                   	leave  
80102811:	c3                   	ret    

80102812 <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
80102812:	55                   	push   %ebp
80102813:	89 e5                	mov    %esp,%ebp
80102815:	83 ec 10             	sub    $0x10,%esp
  static uchar *charcode[4] = {
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
80102818:	6a 64                	push   $0x64
8010281a:	e8 d6 ff ff ff       	call   801027f5 <inb>
8010281f:	83 c4 04             	add    $0x4,%esp
80102822:	0f b6 c0             	movzbl %al,%eax
80102825:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((st & KBS_DIB) == 0)
80102828:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010282b:	83 e0 01             	and    $0x1,%eax
8010282e:	85 c0                	test   %eax,%eax
80102830:	75 0a                	jne    8010283c <kbdgetc+0x2a>
    return -1;
80102832:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102837:	e9 23 01 00 00       	jmp    8010295f <kbdgetc+0x14d>
  data = inb(KBDATAP);
8010283c:	6a 60                	push   $0x60
8010283e:	e8 b2 ff ff ff       	call   801027f5 <inb>
80102843:	83 c4 04             	add    $0x4,%esp
80102846:	0f b6 c0             	movzbl %al,%eax
80102849:	89 45 fc             	mov    %eax,-0x4(%ebp)

  if(data == 0xE0){
8010284c:	81 7d fc e0 00 00 00 	cmpl   $0xe0,-0x4(%ebp)
80102853:	75 17                	jne    8010286c <kbdgetc+0x5a>
    shift |= E0ESC;
80102855:	a1 fc 40 19 80       	mov    0x801940fc,%eax
8010285a:	83 c8 40             	or     $0x40,%eax
8010285d:	a3 fc 40 19 80       	mov    %eax,0x801940fc
    return 0;
80102862:	b8 00 00 00 00       	mov    $0x0,%eax
80102867:	e9 f3 00 00 00       	jmp    8010295f <kbdgetc+0x14d>
  } else if(data & 0x80){
8010286c:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010286f:	25 80 00 00 00       	and    $0x80,%eax
80102874:	85 c0                	test   %eax,%eax
80102876:	74 45                	je     801028bd <kbdgetc+0xab>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
80102878:	a1 fc 40 19 80       	mov    0x801940fc,%eax
8010287d:	83 e0 40             	and    $0x40,%eax
80102880:	85 c0                	test   %eax,%eax
80102882:	75 08                	jne    8010288c <kbdgetc+0x7a>
80102884:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102887:	83 e0 7f             	and    $0x7f,%eax
8010288a:	eb 03                	jmp    8010288f <kbdgetc+0x7d>
8010288c:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010288f:	89 45 fc             	mov    %eax,-0x4(%ebp)
    shift &= ~(shiftcode[data] | E0ESC);
80102892:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102895:	05 20 d0 10 80       	add    $0x8010d020,%eax
8010289a:	0f b6 00             	movzbl (%eax),%eax
8010289d:	83 c8 40             	or     $0x40,%eax
801028a0:	0f b6 c0             	movzbl %al,%eax
801028a3:	f7 d0                	not    %eax
801028a5:	89 c2                	mov    %eax,%edx
801028a7:	a1 fc 40 19 80       	mov    0x801940fc,%eax
801028ac:	21 d0                	and    %edx,%eax
801028ae:	a3 fc 40 19 80       	mov    %eax,0x801940fc
    return 0;
801028b3:	b8 00 00 00 00       	mov    $0x0,%eax
801028b8:	e9 a2 00 00 00       	jmp    8010295f <kbdgetc+0x14d>
  } else if(shift & E0ESC){
801028bd:	a1 fc 40 19 80       	mov    0x801940fc,%eax
801028c2:	83 e0 40             	and    $0x40,%eax
801028c5:	85 c0                	test   %eax,%eax
801028c7:	74 14                	je     801028dd <kbdgetc+0xcb>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
801028c9:	81 4d fc 80 00 00 00 	orl    $0x80,-0x4(%ebp)
    shift &= ~E0ESC;
801028d0:	a1 fc 40 19 80       	mov    0x801940fc,%eax
801028d5:	83 e0 bf             	and    $0xffffffbf,%eax
801028d8:	a3 fc 40 19 80       	mov    %eax,0x801940fc
  }

  shift |= shiftcode[data];
801028dd:	8b 45 fc             	mov    -0x4(%ebp),%eax
801028e0:	05 20 d0 10 80       	add    $0x8010d020,%eax
801028e5:	0f b6 00             	movzbl (%eax),%eax
801028e8:	0f b6 d0             	movzbl %al,%edx
801028eb:	a1 fc 40 19 80       	mov    0x801940fc,%eax
801028f0:	09 d0                	or     %edx,%eax
801028f2:	a3 fc 40 19 80       	mov    %eax,0x801940fc
  shift ^= togglecode[data];
801028f7:	8b 45 fc             	mov    -0x4(%ebp),%eax
801028fa:	05 20 d1 10 80       	add    $0x8010d120,%eax
801028ff:	0f b6 00             	movzbl (%eax),%eax
80102902:	0f b6 d0             	movzbl %al,%edx
80102905:	a1 fc 40 19 80       	mov    0x801940fc,%eax
8010290a:	31 d0                	xor    %edx,%eax
8010290c:	a3 fc 40 19 80       	mov    %eax,0x801940fc
  c = charcode[shift & (CTL | SHIFT)][data];
80102911:	a1 fc 40 19 80       	mov    0x801940fc,%eax
80102916:	83 e0 03             	and    $0x3,%eax
80102919:	8b 14 85 20 d5 10 80 	mov    -0x7fef2ae0(,%eax,4),%edx
80102920:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102923:	01 d0                	add    %edx,%eax
80102925:	0f b6 00             	movzbl (%eax),%eax
80102928:	0f b6 c0             	movzbl %al,%eax
8010292b:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(shift & CAPSLOCK){
8010292e:	a1 fc 40 19 80       	mov    0x801940fc,%eax
80102933:	83 e0 08             	and    $0x8,%eax
80102936:	85 c0                	test   %eax,%eax
80102938:	74 22                	je     8010295c <kbdgetc+0x14a>
    if('a' <= c && c <= 'z')
8010293a:	83 7d f8 60          	cmpl   $0x60,-0x8(%ebp)
8010293e:	76 0c                	jbe    8010294c <kbdgetc+0x13a>
80102940:	83 7d f8 7a          	cmpl   $0x7a,-0x8(%ebp)
80102944:	77 06                	ja     8010294c <kbdgetc+0x13a>
      c += 'A' - 'a';
80102946:	83 6d f8 20          	subl   $0x20,-0x8(%ebp)
8010294a:	eb 10                	jmp    8010295c <kbdgetc+0x14a>
    else if('A' <= c && c <= 'Z')
8010294c:	83 7d f8 40          	cmpl   $0x40,-0x8(%ebp)
80102950:	76 0a                	jbe    8010295c <kbdgetc+0x14a>
80102952:	83 7d f8 5a          	cmpl   $0x5a,-0x8(%ebp)
80102956:	77 04                	ja     8010295c <kbdgetc+0x14a>
      c += 'a' - 'A';
80102958:	83 45 f8 20          	addl   $0x20,-0x8(%ebp)
  }
  return c;
8010295c:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
8010295f:	c9                   	leave  
80102960:	c3                   	ret    

80102961 <kbdintr>:

void
kbdintr(void)
{
80102961:	55                   	push   %ebp
80102962:	89 e5                	mov    %esp,%ebp
80102964:	83 ec 08             	sub    $0x8,%esp
  consoleintr(kbdgetc);
80102967:	83 ec 0c             	sub    $0xc,%esp
8010296a:	68 12 28 10 80       	push   $0x80102812
8010296f:	e8 62 de ff ff       	call   801007d6 <consoleintr>
80102974:	83 c4 10             	add    $0x10,%esp
}
80102977:	90                   	nop
80102978:	c9                   	leave  
80102979:	c3                   	ret    

8010297a <inb>:
{
8010297a:	55                   	push   %ebp
8010297b:	89 e5                	mov    %esp,%ebp
8010297d:	83 ec 14             	sub    $0x14,%esp
80102980:	8b 45 08             	mov    0x8(%ebp),%eax
80102983:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102987:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
8010298b:	89 c2                	mov    %eax,%edx
8010298d:	ec                   	in     (%dx),%al
8010298e:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102991:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102995:	c9                   	leave  
80102996:	c3                   	ret    

80102997 <outb>:
{
80102997:	55                   	push   %ebp
80102998:	89 e5                	mov    %esp,%ebp
8010299a:	83 ec 08             	sub    $0x8,%esp
8010299d:	8b 45 08             	mov    0x8(%ebp),%eax
801029a0:	8b 55 0c             	mov    0xc(%ebp),%edx
801029a3:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
801029a7:	89 d0                	mov    %edx,%eax
801029a9:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801029ac:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801029b0:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801029b4:	ee                   	out    %al,(%dx)
}
801029b5:	90                   	nop
801029b6:	c9                   	leave  
801029b7:	c3                   	ret    

801029b8 <lapicw>:
volatile uint *lapic;  // Initialized in mp.c

//PAGEBREAK!
static void
lapicw(int index, int value)
{
801029b8:	55                   	push   %ebp
801029b9:	89 e5                	mov    %esp,%ebp
  lapic[index] = value;
801029bb:	8b 15 00 41 19 80    	mov    0x80194100,%edx
801029c1:	8b 45 08             	mov    0x8(%ebp),%eax
801029c4:	c1 e0 02             	shl    $0x2,%eax
801029c7:	01 c2                	add    %eax,%edx
801029c9:	8b 45 0c             	mov    0xc(%ebp),%eax
801029cc:	89 02                	mov    %eax,(%edx)
  lapic[ID];  // wait for write to finish, by reading
801029ce:	a1 00 41 19 80       	mov    0x80194100,%eax
801029d3:	83 c0 20             	add    $0x20,%eax
801029d6:	8b 00                	mov    (%eax),%eax
}
801029d8:	90                   	nop
801029d9:	5d                   	pop    %ebp
801029da:	c3                   	ret    

801029db <lapicinit>:

void
lapicinit(void)
{
801029db:	55                   	push   %ebp
801029dc:	89 e5                	mov    %esp,%ebp
  if(!lapic)
801029de:	a1 00 41 19 80       	mov    0x80194100,%eax
801029e3:	85 c0                	test   %eax,%eax
801029e5:	0f 84 0c 01 00 00    	je     80102af7 <lapicinit+0x11c>
    return;

  // Enable local APIC; set spurious interrupt vector.
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
801029eb:	68 3f 01 00 00       	push   $0x13f
801029f0:	6a 3c                	push   $0x3c
801029f2:	e8 c1 ff ff ff       	call   801029b8 <lapicw>
801029f7:	83 c4 08             	add    $0x8,%esp

  // The timer repeatedly counts down at bus frequency
  // from lapic[TICR] and then issues an interrupt.
  // If xv6 cared more about precise timekeeping,
  // TICR would be calibrated using an external time source.
  lapicw(TDCR, X1);
801029fa:	6a 0b                	push   $0xb
801029fc:	68 f8 00 00 00       	push   $0xf8
80102a01:	e8 b2 ff ff ff       	call   801029b8 <lapicw>
80102a06:	83 c4 08             	add    $0x8,%esp
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
80102a09:	68 20 00 02 00       	push   $0x20020
80102a0e:	68 c8 00 00 00       	push   $0xc8
80102a13:	e8 a0 ff ff ff       	call   801029b8 <lapicw>
80102a18:	83 c4 08             	add    $0x8,%esp
  lapicw(TICR, 10000000);
80102a1b:	68 80 96 98 00       	push   $0x989680
80102a20:	68 e0 00 00 00       	push   $0xe0
80102a25:	e8 8e ff ff ff       	call   801029b8 <lapicw>
80102a2a:	83 c4 08             	add    $0x8,%esp

  // Disable logical interrupt lines.
  lapicw(LINT0, MASKED);
80102a2d:	68 00 00 01 00       	push   $0x10000
80102a32:	68 d4 00 00 00       	push   $0xd4
80102a37:	e8 7c ff ff ff       	call   801029b8 <lapicw>
80102a3c:	83 c4 08             	add    $0x8,%esp
  lapicw(LINT1, MASKED);
80102a3f:	68 00 00 01 00       	push   $0x10000
80102a44:	68 d8 00 00 00       	push   $0xd8
80102a49:	e8 6a ff ff ff       	call   801029b8 <lapicw>
80102a4e:	83 c4 08             	add    $0x8,%esp

  // Disable performance counter overflow interrupts
  // on machines that provide that interrupt entry.
  if(((lapic[VER]>>16) & 0xFF) >= 4)
80102a51:	a1 00 41 19 80       	mov    0x80194100,%eax
80102a56:	83 c0 30             	add    $0x30,%eax
80102a59:	8b 00                	mov    (%eax),%eax
80102a5b:	c1 e8 10             	shr    $0x10,%eax
80102a5e:	25 fc 00 00 00       	and    $0xfc,%eax
80102a63:	85 c0                	test   %eax,%eax
80102a65:	74 12                	je     80102a79 <lapicinit+0x9e>
    lapicw(PCINT, MASKED);
80102a67:	68 00 00 01 00       	push   $0x10000
80102a6c:	68 d0 00 00 00       	push   $0xd0
80102a71:	e8 42 ff ff ff       	call   801029b8 <lapicw>
80102a76:	83 c4 08             	add    $0x8,%esp

  // Map error interrupt to IRQ_ERROR.
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
80102a79:	6a 33                	push   $0x33
80102a7b:	68 dc 00 00 00       	push   $0xdc
80102a80:	e8 33 ff ff ff       	call   801029b8 <lapicw>
80102a85:	83 c4 08             	add    $0x8,%esp

  // Clear error status register (requires back-to-back writes).
  lapicw(ESR, 0);
80102a88:	6a 00                	push   $0x0
80102a8a:	68 a0 00 00 00       	push   $0xa0
80102a8f:	e8 24 ff ff ff       	call   801029b8 <lapicw>
80102a94:	83 c4 08             	add    $0x8,%esp
  lapicw(ESR, 0);
80102a97:	6a 00                	push   $0x0
80102a99:	68 a0 00 00 00       	push   $0xa0
80102a9e:	e8 15 ff ff ff       	call   801029b8 <lapicw>
80102aa3:	83 c4 08             	add    $0x8,%esp

  // Ack any outstanding interrupts.
  lapicw(EOI, 0);
80102aa6:	6a 00                	push   $0x0
80102aa8:	6a 2c                	push   $0x2c
80102aaa:	e8 09 ff ff ff       	call   801029b8 <lapicw>
80102aaf:	83 c4 08             	add    $0x8,%esp

  // Send an Init Level De-Assert to synchronise arbitration ID's.
  lapicw(ICRHI, 0);
80102ab2:	6a 00                	push   $0x0
80102ab4:	68 c4 00 00 00       	push   $0xc4
80102ab9:	e8 fa fe ff ff       	call   801029b8 <lapicw>
80102abe:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, BCAST | INIT | LEVEL);
80102ac1:	68 00 85 08 00       	push   $0x88500
80102ac6:	68 c0 00 00 00       	push   $0xc0
80102acb:	e8 e8 fe ff ff       	call   801029b8 <lapicw>
80102ad0:	83 c4 08             	add    $0x8,%esp
  while(lapic[ICRLO] & DELIVS)
80102ad3:	90                   	nop
80102ad4:	a1 00 41 19 80       	mov    0x80194100,%eax
80102ad9:	05 00 03 00 00       	add    $0x300,%eax
80102ade:	8b 00                	mov    (%eax),%eax
80102ae0:	25 00 10 00 00       	and    $0x1000,%eax
80102ae5:	85 c0                	test   %eax,%eax
80102ae7:	75 eb                	jne    80102ad4 <lapicinit+0xf9>
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
80102ae9:	6a 00                	push   $0x0
80102aeb:	6a 20                	push   $0x20
80102aed:	e8 c6 fe ff ff       	call   801029b8 <lapicw>
80102af2:	83 c4 08             	add    $0x8,%esp
80102af5:	eb 01                	jmp    80102af8 <lapicinit+0x11d>
    return;
80102af7:	90                   	nop
}
80102af8:	c9                   	leave  
80102af9:	c3                   	ret    

80102afa <lapicid>:

int
lapicid(void)
{
80102afa:	55                   	push   %ebp
80102afb:	89 e5                	mov    %esp,%ebp

  if (!lapic){
80102afd:	a1 00 41 19 80       	mov    0x80194100,%eax
80102b02:	85 c0                	test   %eax,%eax
80102b04:	75 07                	jne    80102b0d <lapicid+0x13>
    return 0;
80102b06:	b8 00 00 00 00       	mov    $0x0,%eax
80102b0b:	eb 0d                	jmp    80102b1a <lapicid+0x20>
  }
  return lapic[ID] >> 24;
80102b0d:	a1 00 41 19 80       	mov    0x80194100,%eax
80102b12:	83 c0 20             	add    $0x20,%eax
80102b15:	8b 00                	mov    (%eax),%eax
80102b17:	c1 e8 18             	shr    $0x18,%eax
}
80102b1a:	5d                   	pop    %ebp
80102b1b:	c3                   	ret    

80102b1c <lapiceoi>:

// Acknowledge interrupt.
void
lapiceoi(void)
{
80102b1c:	55                   	push   %ebp
80102b1d:	89 e5                	mov    %esp,%ebp
  if(lapic)
80102b1f:	a1 00 41 19 80       	mov    0x80194100,%eax
80102b24:	85 c0                	test   %eax,%eax
80102b26:	74 0c                	je     80102b34 <lapiceoi+0x18>
    lapicw(EOI, 0);
80102b28:	6a 00                	push   $0x0
80102b2a:	6a 2c                	push   $0x2c
80102b2c:	e8 87 fe ff ff       	call   801029b8 <lapicw>
80102b31:	83 c4 08             	add    $0x8,%esp
}
80102b34:	90                   	nop
80102b35:	c9                   	leave  
80102b36:	c3                   	ret    

80102b37 <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
void
microdelay(int us)
{
80102b37:	55                   	push   %ebp
80102b38:	89 e5                	mov    %esp,%ebp
}
80102b3a:	90                   	nop
80102b3b:	5d                   	pop    %ebp
80102b3c:	c3                   	ret    

80102b3d <lapicstartap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapicstartap(uchar apicid, uint addr)
{
80102b3d:	55                   	push   %ebp
80102b3e:	89 e5                	mov    %esp,%ebp
80102b40:	83 ec 14             	sub    $0x14,%esp
80102b43:	8b 45 08             	mov    0x8(%ebp),%eax
80102b46:	88 45 ec             	mov    %al,-0x14(%ebp)
  ushort *wrv;

  // "The BSP must initialize CMOS shutdown code to 0AH
  // and the warm reset vector (DWORD based at 40:67) to point at
  // the AP startup code prior to the [universal startup algorithm]."
  outb(CMOS_PORT, 0xF);  // offset 0xF is shutdown code
80102b49:	6a 0f                	push   $0xf
80102b4b:	6a 70                	push   $0x70
80102b4d:	e8 45 fe ff ff       	call   80102997 <outb>
80102b52:	83 c4 08             	add    $0x8,%esp
  outb(CMOS_PORT+1, 0x0A);
80102b55:	6a 0a                	push   $0xa
80102b57:	6a 71                	push   $0x71
80102b59:	e8 39 fe ff ff       	call   80102997 <outb>
80102b5e:	83 c4 08             	add    $0x8,%esp
  wrv = (ushort*)P2V((0x40<<4 | 0x67));  // Warm reset vector
80102b61:	c7 45 f8 67 04 00 80 	movl   $0x80000467,-0x8(%ebp)
  wrv[0] = 0;
80102b68:	8b 45 f8             	mov    -0x8(%ebp),%eax
80102b6b:	66 c7 00 00 00       	movw   $0x0,(%eax)
  wrv[1] = addr >> 4;
80102b70:	8b 45 0c             	mov    0xc(%ebp),%eax
80102b73:	c1 e8 04             	shr    $0x4,%eax
80102b76:	89 c2                	mov    %eax,%edx
80102b78:	8b 45 f8             	mov    -0x8(%ebp),%eax
80102b7b:	83 c0 02             	add    $0x2,%eax
80102b7e:	66 89 10             	mov    %dx,(%eax)

  // "Universal startup algorithm."
  // Send INIT (level-triggered) interrupt to reset other CPU.
  lapicw(ICRHI, apicid<<24);
80102b81:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80102b85:	c1 e0 18             	shl    $0x18,%eax
80102b88:	50                   	push   %eax
80102b89:	68 c4 00 00 00       	push   $0xc4
80102b8e:	e8 25 fe ff ff       	call   801029b8 <lapicw>
80102b93:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
80102b96:	68 00 c5 00 00       	push   $0xc500
80102b9b:	68 c0 00 00 00       	push   $0xc0
80102ba0:	e8 13 fe ff ff       	call   801029b8 <lapicw>
80102ba5:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
80102ba8:	68 c8 00 00 00       	push   $0xc8
80102bad:	e8 85 ff ff ff       	call   80102b37 <microdelay>
80102bb2:	83 c4 04             	add    $0x4,%esp
  lapicw(ICRLO, INIT | LEVEL);
80102bb5:	68 00 85 00 00       	push   $0x8500
80102bba:	68 c0 00 00 00       	push   $0xc0
80102bbf:	e8 f4 fd ff ff       	call   801029b8 <lapicw>
80102bc4:	83 c4 08             	add    $0x8,%esp
  microdelay(100);    // should be 10ms, but too slow in Bochs!
80102bc7:	6a 64                	push   $0x64
80102bc9:	e8 69 ff ff ff       	call   80102b37 <microdelay>
80102bce:	83 c4 04             	add    $0x4,%esp
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
80102bd1:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80102bd8:	eb 3d                	jmp    80102c17 <lapicstartap+0xda>
    lapicw(ICRHI, apicid<<24);
80102bda:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80102bde:	c1 e0 18             	shl    $0x18,%eax
80102be1:	50                   	push   %eax
80102be2:	68 c4 00 00 00       	push   $0xc4
80102be7:	e8 cc fd ff ff       	call   801029b8 <lapicw>
80102bec:	83 c4 08             	add    $0x8,%esp
    lapicw(ICRLO, STARTUP | (addr>>12));
80102bef:	8b 45 0c             	mov    0xc(%ebp),%eax
80102bf2:	c1 e8 0c             	shr    $0xc,%eax
80102bf5:	80 cc 06             	or     $0x6,%ah
80102bf8:	50                   	push   %eax
80102bf9:	68 c0 00 00 00       	push   $0xc0
80102bfe:	e8 b5 fd ff ff       	call   801029b8 <lapicw>
80102c03:	83 c4 08             	add    $0x8,%esp
    microdelay(200);
80102c06:	68 c8 00 00 00       	push   $0xc8
80102c0b:	e8 27 ff ff ff       	call   80102b37 <microdelay>
80102c10:	83 c4 04             	add    $0x4,%esp
  for(i = 0; i < 2; i++){
80102c13:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80102c17:	83 7d fc 01          	cmpl   $0x1,-0x4(%ebp)
80102c1b:	7e bd                	jle    80102bda <lapicstartap+0x9d>
  }
}
80102c1d:	90                   	nop
80102c1e:	90                   	nop
80102c1f:	c9                   	leave  
80102c20:	c3                   	ret    

80102c21 <cmos_read>:
#define DAY     0x07
#define MONTH   0x08
#define YEAR    0x09

static uint cmos_read(uint reg)
{
80102c21:	55                   	push   %ebp
80102c22:	89 e5                	mov    %esp,%ebp
  outb(CMOS_PORT,  reg);
80102c24:	8b 45 08             	mov    0x8(%ebp),%eax
80102c27:	0f b6 c0             	movzbl %al,%eax
80102c2a:	50                   	push   %eax
80102c2b:	6a 70                	push   $0x70
80102c2d:	e8 65 fd ff ff       	call   80102997 <outb>
80102c32:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
80102c35:	68 c8 00 00 00       	push   $0xc8
80102c3a:	e8 f8 fe ff ff       	call   80102b37 <microdelay>
80102c3f:	83 c4 04             	add    $0x4,%esp

  return inb(CMOS_RETURN);
80102c42:	6a 71                	push   $0x71
80102c44:	e8 31 fd ff ff       	call   8010297a <inb>
80102c49:	83 c4 04             	add    $0x4,%esp
80102c4c:	0f b6 c0             	movzbl %al,%eax
}
80102c4f:	c9                   	leave  
80102c50:	c3                   	ret    

80102c51 <fill_rtcdate>:

static void fill_rtcdate(struct rtcdate *r)
{
80102c51:	55                   	push   %ebp
80102c52:	89 e5                	mov    %esp,%ebp
  r->second = cmos_read(SECS);
80102c54:	6a 00                	push   $0x0
80102c56:	e8 c6 ff ff ff       	call   80102c21 <cmos_read>
80102c5b:	83 c4 04             	add    $0x4,%esp
80102c5e:	8b 55 08             	mov    0x8(%ebp),%edx
80102c61:	89 02                	mov    %eax,(%edx)
  r->minute = cmos_read(MINS);
80102c63:	6a 02                	push   $0x2
80102c65:	e8 b7 ff ff ff       	call   80102c21 <cmos_read>
80102c6a:	83 c4 04             	add    $0x4,%esp
80102c6d:	8b 55 08             	mov    0x8(%ebp),%edx
80102c70:	89 42 04             	mov    %eax,0x4(%edx)
  r->hour   = cmos_read(HOURS);
80102c73:	6a 04                	push   $0x4
80102c75:	e8 a7 ff ff ff       	call   80102c21 <cmos_read>
80102c7a:	83 c4 04             	add    $0x4,%esp
80102c7d:	8b 55 08             	mov    0x8(%ebp),%edx
80102c80:	89 42 08             	mov    %eax,0x8(%edx)
  r->day    = cmos_read(DAY);
80102c83:	6a 07                	push   $0x7
80102c85:	e8 97 ff ff ff       	call   80102c21 <cmos_read>
80102c8a:	83 c4 04             	add    $0x4,%esp
80102c8d:	8b 55 08             	mov    0x8(%ebp),%edx
80102c90:	89 42 0c             	mov    %eax,0xc(%edx)
  r->month  = cmos_read(MONTH);
80102c93:	6a 08                	push   $0x8
80102c95:	e8 87 ff ff ff       	call   80102c21 <cmos_read>
80102c9a:	83 c4 04             	add    $0x4,%esp
80102c9d:	8b 55 08             	mov    0x8(%ebp),%edx
80102ca0:	89 42 10             	mov    %eax,0x10(%edx)
  r->year   = cmos_read(YEAR);
80102ca3:	6a 09                	push   $0x9
80102ca5:	e8 77 ff ff ff       	call   80102c21 <cmos_read>
80102caa:	83 c4 04             	add    $0x4,%esp
80102cad:	8b 55 08             	mov    0x8(%ebp),%edx
80102cb0:	89 42 14             	mov    %eax,0x14(%edx)
}
80102cb3:	90                   	nop
80102cb4:	c9                   	leave  
80102cb5:	c3                   	ret    

80102cb6 <cmostime>:

// qemu seems to use 24-hour GWT and the values are BCD encoded
void cmostime(struct rtcdate *r)
{
80102cb6:	55                   	push   %ebp
80102cb7:	89 e5                	mov    %esp,%ebp
80102cb9:	83 ec 48             	sub    $0x48,%esp
  struct rtcdate t1, t2;
  int sb, bcd;

  sb = cmos_read(CMOS_STATB);
80102cbc:	6a 0b                	push   $0xb
80102cbe:	e8 5e ff ff ff       	call   80102c21 <cmos_read>
80102cc3:	83 c4 04             	add    $0x4,%esp
80102cc6:	89 45 f4             	mov    %eax,-0xc(%ebp)

  bcd = (sb & (1 << 2)) == 0;
80102cc9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ccc:	83 e0 04             	and    $0x4,%eax
80102ccf:	85 c0                	test   %eax,%eax
80102cd1:	0f 94 c0             	sete   %al
80102cd4:	0f b6 c0             	movzbl %al,%eax
80102cd7:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // make sure CMOS doesn't modify time while we read it
  for(;;) {
    fill_rtcdate(&t1);
80102cda:	8d 45 d8             	lea    -0x28(%ebp),%eax
80102cdd:	50                   	push   %eax
80102cde:	e8 6e ff ff ff       	call   80102c51 <fill_rtcdate>
80102ce3:	83 c4 04             	add    $0x4,%esp
    if(cmos_read(CMOS_STATA) & CMOS_UIP)
80102ce6:	6a 0a                	push   $0xa
80102ce8:	e8 34 ff ff ff       	call   80102c21 <cmos_read>
80102ced:	83 c4 04             	add    $0x4,%esp
80102cf0:	25 80 00 00 00       	and    $0x80,%eax
80102cf5:	85 c0                	test   %eax,%eax
80102cf7:	75 27                	jne    80102d20 <cmostime+0x6a>
        continue;
    fill_rtcdate(&t2);
80102cf9:	8d 45 c0             	lea    -0x40(%ebp),%eax
80102cfc:	50                   	push   %eax
80102cfd:	e8 4f ff ff ff       	call   80102c51 <fill_rtcdate>
80102d02:	83 c4 04             	add    $0x4,%esp
    if(memcmp(&t1, &t2, sizeof(t1)) == 0)
80102d05:	83 ec 04             	sub    $0x4,%esp
80102d08:	6a 18                	push   $0x18
80102d0a:	8d 45 c0             	lea    -0x40(%ebp),%eax
80102d0d:	50                   	push   %eax
80102d0e:	8d 45 d8             	lea    -0x28(%ebp),%eax
80102d11:	50                   	push   %eax
80102d12:	e8 cf 1c 00 00       	call   801049e6 <memcmp>
80102d17:	83 c4 10             	add    $0x10,%esp
80102d1a:	85 c0                	test   %eax,%eax
80102d1c:	74 05                	je     80102d23 <cmostime+0x6d>
80102d1e:	eb ba                	jmp    80102cda <cmostime+0x24>
        continue;
80102d20:	90                   	nop
    fill_rtcdate(&t1);
80102d21:	eb b7                	jmp    80102cda <cmostime+0x24>
      break;
80102d23:	90                   	nop
  }

  // convert
  if(bcd) {
80102d24:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80102d28:	0f 84 b4 00 00 00    	je     80102de2 <cmostime+0x12c>
#define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
    CONV(second);
80102d2e:	8b 45 d8             	mov    -0x28(%ebp),%eax
80102d31:	c1 e8 04             	shr    $0x4,%eax
80102d34:	89 c2                	mov    %eax,%edx
80102d36:	89 d0                	mov    %edx,%eax
80102d38:	c1 e0 02             	shl    $0x2,%eax
80102d3b:	01 d0                	add    %edx,%eax
80102d3d:	01 c0                	add    %eax,%eax
80102d3f:	89 c2                	mov    %eax,%edx
80102d41:	8b 45 d8             	mov    -0x28(%ebp),%eax
80102d44:	83 e0 0f             	and    $0xf,%eax
80102d47:	01 d0                	add    %edx,%eax
80102d49:	89 45 d8             	mov    %eax,-0x28(%ebp)
    CONV(minute);
80102d4c:	8b 45 dc             	mov    -0x24(%ebp),%eax
80102d4f:	c1 e8 04             	shr    $0x4,%eax
80102d52:	89 c2                	mov    %eax,%edx
80102d54:	89 d0                	mov    %edx,%eax
80102d56:	c1 e0 02             	shl    $0x2,%eax
80102d59:	01 d0                	add    %edx,%eax
80102d5b:	01 c0                	add    %eax,%eax
80102d5d:	89 c2                	mov    %eax,%edx
80102d5f:	8b 45 dc             	mov    -0x24(%ebp),%eax
80102d62:	83 e0 0f             	and    $0xf,%eax
80102d65:	01 d0                	add    %edx,%eax
80102d67:	89 45 dc             	mov    %eax,-0x24(%ebp)
    CONV(hour  );
80102d6a:	8b 45 e0             	mov    -0x20(%ebp),%eax
80102d6d:	c1 e8 04             	shr    $0x4,%eax
80102d70:	89 c2                	mov    %eax,%edx
80102d72:	89 d0                	mov    %edx,%eax
80102d74:	c1 e0 02             	shl    $0x2,%eax
80102d77:	01 d0                	add    %edx,%eax
80102d79:	01 c0                	add    %eax,%eax
80102d7b:	89 c2                	mov    %eax,%edx
80102d7d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80102d80:	83 e0 0f             	and    $0xf,%eax
80102d83:	01 d0                	add    %edx,%eax
80102d85:	89 45 e0             	mov    %eax,-0x20(%ebp)
    CONV(day   );
80102d88:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80102d8b:	c1 e8 04             	shr    $0x4,%eax
80102d8e:	89 c2                	mov    %eax,%edx
80102d90:	89 d0                	mov    %edx,%eax
80102d92:	c1 e0 02             	shl    $0x2,%eax
80102d95:	01 d0                	add    %edx,%eax
80102d97:	01 c0                	add    %eax,%eax
80102d99:	89 c2                	mov    %eax,%edx
80102d9b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80102d9e:	83 e0 0f             	and    $0xf,%eax
80102da1:	01 d0                	add    %edx,%eax
80102da3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    CONV(month );
80102da6:	8b 45 e8             	mov    -0x18(%ebp),%eax
80102da9:	c1 e8 04             	shr    $0x4,%eax
80102dac:	89 c2                	mov    %eax,%edx
80102dae:	89 d0                	mov    %edx,%eax
80102db0:	c1 e0 02             	shl    $0x2,%eax
80102db3:	01 d0                	add    %edx,%eax
80102db5:	01 c0                	add    %eax,%eax
80102db7:	89 c2                	mov    %eax,%edx
80102db9:	8b 45 e8             	mov    -0x18(%ebp),%eax
80102dbc:	83 e0 0f             	and    $0xf,%eax
80102dbf:	01 d0                	add    %edx,%eax
80102dc1:	89 45 e8             	mov    %eax,-0x18(%ebp)
    CONV(year  );
80102dc4:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102dc7:	c1 e8 04             	shr    $0x4,%eax
80102dca:	89 c2                	mov    %eax,%edx
80102dcc:	89 d0                	mov    %edx,%eax
80102dce:	c1 e0 02             	shl    $0x2,%eax
80102dd1:	01 d0                	add    %edx,%eax
80102dd3:	01 c0                	add    %eax,%eax
80102dd5:	89 c2                	mov    %eax,%edx
80102dd7:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102dda:	83 e0 0f             	and    $0xf,%eax
80102ddd:	01 d0                	add    %edx,%eax
80102ddf:	89 45 ec             	mov    %eax,-0x14(%ebp)
#undef     CONV
  }

  *r = t1;
80102de2:	8b 45 08             	mov    0x8(%ebp),%eax
80102de5:	8b 55 d8             	mov    -0x28(%ebp),%edx
80102de8:	89 10                	mov    %edx,(%eax)
80102dea:	8b 55 dc             	mov    -0x24(%ebp),%edx
80102ded:	89 50 04             	mov    %edx,0x4(%eax)
80102df0:	8b 55 e0             	mov    -0x20(%ebp),%edx
80102df3:	89 50 08             	mov    %edx,0x8(%eax)
80102df6:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80102df9:	89 50 0c             	mov    %edx,0xc(%eax)
80102dfc:	8b 55 e8             	mov    -0x18(%ebp),%edx
80102dff:	89 50 10             	mov    %edx,0x10(%eax)
80102e02:	8b 55 ec             	mov    -0x14(%ebp),%edx
80102e05:	89 50 14             	mov    %edx,0x14(%eax)
  r->year += 2000;
80102e08:	8b 45 08             	mov    0x8(%ebp),%eax
80102e0b:	8b 40 14             	mov    0x14(%eax),%eax
80102e0e:	8d 90 d0 07 00 00    	lea    0x7d0(%eax),%edx
80102e14:	8b 45 08             	mov    0x8(%ebp),%eax
80102e17:	89 50 14             	mov    %edx,0x14(%eax)
}
80102e1a:	90                   	nop
80102e1b:	c9                   	leave  
80102e1c:	c3                   	ret    

80102e1d <initlog>:
static void recover_from_log(void);
static void commit();

void
initlog(int dev)
{
80102e1d:	55                   	push   %ebp
80102e1e:	89 e5                	mov    %esp,%ebp
80102e20:	83 ec 28             	sub    $0x28,%esp
  if (sizeof(struct logheader) >= BSIZE)
    panic("initlog: too big logheader");

  struct superblock sb;
  initlock(&log.lock, "log");
80102e23:	83 ec 08             	sub    $0x8,%esp
80102e26:	68 11 a3 10 80       	push   $0x8010a311
80102e2b:	68 20 41 19 80       	push   $0x80194120
80102e30:	e8 b2 18 00 00       	call   801046e7 <initlock>
80102e35:	83 c4 10             	add    $0x10,%esp
  readsb(dev, &sb);
80102e38:	83 ec 08             	sub    $0x8,%esp
80102e3b:	8d 45 dc             	lea    -0x24(%ebp),%eax
80102e3e:	50                   	push   %eax
80102e3f:	ff 75 08             	push   0x8(%ebp)
80102e42:	e8 87 e5 ff ff       	call   801013ce <readsb>
80102e47:	83 c4 10             	add    $0x10,%esp
  log.start = sb.logstart;
80102e4a:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102e4d:	a3 54 41 19 80       	mov    %eax,0x80194154
  log.size = sb.nlog;
80102e52:	8b 45 e8             	mov    -0x18(%ebp),%eax
80102e55:	a3 58 41 19 80       	mov    %eax,0x80194158
  log.dev = dev;
80102e5a:	8b 45 08             	mov    0x8(%ebp),%eax
80102e5d:	a3 64 41 19 80       	mov    %eax,0x80194164
  recover_from_log();
80102e62:	e8 b3 01 00 00       	call   8010301a <recover_from_log>
}
80102e67:	90                   	nop
80102e68:	c9                   	leave  
80102e69:	c3                   	ret    

80102e6a <install_trans>:

// Copy committed blocks from log to their home location
static void
install_trans(void)
{
80102e6a:	55                   	push   %ebp
80102e6b:	89 e5                	mov    %esp,%ebp
80102e6d:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80102e70:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102e77:	e9 95 00 00 00       	jmp    80102f11 <install_trans+0xa7>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
80102e7c:	8b 15 54 41 19 80    	mov    0x80194154,%edx
80102e82:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102e85:	01 d0                	add    %edx,%eax
80102e87:	83 c0 01             	add    $0x1,%eax
80102e8a:	89 c2                	mov    %eax,%edx
80102e8c:	a1 64 41 19 80       	mov    0x80194164,%eax
80102e91:	83 ec 08             	sub    $0x8,%esp
80102e94:	52                   	push   %edx
80102e95:	50                   	push   %eax
80102e96:	e8 66 d3 ff ff       	call   80100201 <bread>
80102e9b:	83 c4 10             	add    $0x10,%esp
80102e9e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
80102ea1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ea4:	83 c0 10             	add    $0x10,%eax
80102ea7:	8b 04 85 2c 41 19 80 	mov    -0x7fe6bed4(,%eax,4),%eax
80102eae:	89 c2                	mov    %eax,%edx
80102eb0:	a1 64 41 19 80       	mov    0x80194164,%eax
80102eb5:	83 ec 08             	sub    $0x8,%esp
80102eb8:	52                   	push   %edx
80102eb9:	50                   	push   %eax
80102eba:	e8 42 d3 ff ff       	call   80100201 <bread>
80102ebf:	83 c4 10             	add    $0x10,%esp
80102ec2:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
80102ec5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102ec8:	8d 50 5c             	lea    0x5c(%eax),%edx
80102ecb:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102ece:	83 c0 5c             	add    $0x5c,%eax
80102ed1:	83 ec 04             	sub    $0x4,%esp
80102ed4:	68 00 02 00 00       	push   $0x200
80102ed9:	52                   	push   %edx
80102eda:	50                   	push   %eax
80102edb:	e8 5e 1b 00 00       	call   80104a3e <memmove>
80102ee0:	83 c4 10             	add    $0x10,%esp
    bwrite(dbuf);  // write dst to disk
80102ee3:	83 ec 0c             	sub    $0xc,%esp
80102ee6:	ff 75 ec             	push   -0x14(%ebp)
80102ee9:	e8 4c d3 ff ff       	call   8010023a <bwrite>
80102eee:	83 c4 10             	add    $0x10,%esp
    brelse(lbuf);
80102ef1:	83 ec 0c             	sub    $0xc,%esp
80102ef4:	ff 75 f0             	push   -0x10(%ebp)
80102ef7:	e8 87 d3 ff ff       	call   80100283 <brelse>
80102efc:	83 c4 10             	add    $0x10,%esp
    brelse(dbuf);
80102eff:	83 ec 0c             	sub    $0xc,%esp
80102f02:	ff 75 ec             	push   -0x14(%ebp)
80102f05:	e8 79 d3 ff ff       	call   80100283 <brelse>
80102f0a:	83 c4 10             	add    $0x10,%esp
  for (tail = 0; tail < log.lh.n; tail++) {
80102f0d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102f11:	a1 68 41 19 80       	mov    0x80194168,%eax
80102f16:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80102f19:	0f 8c 5d ff ff ff    	jl     80102e7c <install_trans+0x12>
  }
}
80102f1f:	90                   	nop
80102f20:	90                   	nop
80102f21:	c9                   	leave  
80102f22:	c3                   	ret    

80102f23 <read_head>:

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
80102f23:	55                   	push   %ebp
80102f24:	89 e5                	mov    %esp,%ebp
80102f26:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
80102f29:	a1 54 41 19 80       	mov    0x80194154,%eax
80102f2e:	89 c2                	mov    %eax,%edx
80102f30:	a1 64 41 19 80       	mov    0x80194164,%eax
80102f35:	83 ec 08             	sub    $0x8,%esp
80102f38:	52                   	push   %edx
80102f39:	50                   	push   %eax
80102f3a:	e8 c2 d2 ff ff       	call   80100201 <bread>
80102f3f:	83 c4 10             	add    $0x10,%esp
80102f42:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *lh = (struct logheader *) (buf->data);
80102f45:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102f48:	83 c0 5c             	add    $0x5c,%eax
80102f4b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  log.lh.n = lh->n;
80102f4e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102f51:	8b 00                	mov    (%eax),%eax
80102f53:	a3 68 41 19 80       	mov    %eax,0x80194168
  for (i = 0; i < log.lh.n; i++) {
80102f58:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102f5f:	eb 1b                	jmp    80102f7c <read_head+0x59>
    log.lh.block[i] = lh->block[i];
80102f61:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102f64:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102f67:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
80102f6b:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102f6e:	83 c2 10             	add    $0x10,%edx
80102f71:	89 04 95 2c 41 19 80 	mov    %eax,-0x7fe6bed4(,%edx,4)
  for (i = 0; i < log.lh.n; i++) {
80102f78:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102f7c:	a1 68 41 19 80       	mov    0x80194168,%eax
80102f81:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80102f84:	7c db                	jl     80102f61 <read_head+0x3e>
  }
  brelse(buf);
80102f86:	83 ec 0c             	sub    $0xc,%esp
80102f89:	ff 75 f0             	push   -0x10(%ebp)
80102f8c:	e8 f2 d2 ff ff       	call   80100283 <brelse>
80102f91:	83 c4 10             	add    $0x10,%esp
}
80102f94:	90                   	nop
80102f95:	c9                   	leave  
80102f96:	c3                   	ret    

80102f97 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
80102f97:	55                   	push   %ebp
80102f98:	89 e5                	mov    %esp,%ebp
80102f9a:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
80102f9d:	a1 54 41 19 80       	mov    0x80194154,%eax
80102fa2:	89 c2                	mov    %eax,%edx
80102fa4:	a1 64 41 19 80       	mov    0x80194164,%eax
80102fa9:	83 ec 08             	sub    $0x8,%esp
80102fac:	52                   	push   %edx
80102fad:	50                   	push   %eax
80102fae:	e8 4e d2 ff ff       	call   80100201 <bread>
80102fb3:	83 c4 10             	add    $0x10,%esp
80102fb6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *hb = (struct logheader *) (buf->data);
80102fb9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102fbc:	83 c0 5c             	add    $0x5c,%eax
80102fbf:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  hb->n = log.lh.n;
80102fc2:	8b 15 68 41 19 80    	mov    0x80194168,%edx
80102fc8:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102fcb:	89 10                	mov    %edx,(%eax)
  for (i = 0; i < log.lh.n; i++) {
80102fcd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102fd4:	eb 1b                	jmp    80102ff1 <write_head+0x5a>
    hb->block[i] = log.lh.block[i];
80102fd6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102fd9:	83 c0 10             	add    $0x10,%eax
80102fdc:	8b 0c 85 2c 41 19 80 	mov    -0x7fe6bed4(,%eax,4),%ecx
80102fe3:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102fe6:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102fe9:	89 4c 90 04          	mov    %ecx,0x4(%eax,%edx,4)
  for (i = 0; i < log.lh.n; i++) {
80102fed:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102ff1:	a1 68 41 19 80       	mov    0x80194168,%eax
80102ff6:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80102ff9:	7c db                	jl     80102fd6 <write_head+0x3f>
  }
  bwrite(buf);
80102ffb:	83 ec 0c             	sub    $0xc,%esp
80102ffe:	ff 75 f0             	push   -0x10(%ebp)
80103001:	e8 34 d2 ff ff       	call   8010023a <bwrite>
80103006:	83 c4 10             	add    $0x10,%esp
  brelse(buf);
80103009:	83 ec 0c             	sub    $0xc,%esp
8010300c:	ff 75 f0             	push   -0x10(%ebp)
8010300f:	e8 6f d2 ff ff       	call   80100283 <brelse>
80103014:	83 c4 10             	add    $0x10,%esp
}
80103017:	90                   	nop
80103018:	c9                   	leave  
80103019:	c3                   	ret    

8010301a <recover_from_log>:

static void
recover_from_log(void)
{
8010301a:	55                   	push   %ebp
8010301b:	89 e5                	mov    %esp,%ebp
8010301d:	83 ec 08             	sub    $0x8,%esp
  read_head();
80103020:	e8 fe fe ff ff       	call   80102f23 <read_head>
  install_trans(); // if committed, copy from log to disk
80103025:	e8 40 fe ff ff       	call   80102e6a <install_trans>
  log.lh.n = 0;
8010302a:	c7 05 68 41 19 80 00 	movl   $0x0,0x80194168
80103031:	00 00 00 
  write_head(); // clear the log
80103034:	e8 5e ff ff ff       	call   80102f97 <write_head>
}
80103039:	90                   	nop
8010303a:	c9                   	leave  
8010303b:	c3                   	ret    

8010303c <begin_op>:

// called at the start of each FS system call.
void
begin_op(void)
{
8010303c:	55                   	push   %ebp
8010303d:	89 e5                	mov    %esp,%ebp
8010303f:	83 ec 08             	sub    $0x8,%esp
  acquire(&log.lock);
80103042:	83 ec 0c             	sub    $0xc,%esp
80103045:	68 20 41 19 80       	push   $0x80194120
8010304a:	e8 ba 16 00 00       	call   80104709 <acquire>
8010304f:	83 c4 10             	add    $0x10,%esp
  while(1){
    if(log.committing){
80103052:	a1 60 41 19 80       	mov    0x80194160,%eax
80103057:	85 c0                	test   %eax,%eax
80103059:	74 17                	je     80103072 <begin_op+0x36>
      sleep(&log, &log.lock);
8010305b:	83 ec 08             	sub    $0x8,%esp
8010305e:	68 20 41 19 80       	push   $0x80194120
80103063:	68 20 41 19 80       	push   $0x80194120
80103068:	e8 78 12 00 00       	call   801042e5 <sleep>
8010306d:	83 c4 10             	add    $0x10,%esp
80103070:	eb e0                	jmp    80103052 <begin_op+0x16>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
80103072:	8b 0d 68 41 19 80    	mov    0x80194168,%ecx
80103078:	a1 5c 41 19 80       	mov    0x8019415c,%eax
8010307d:	8d 50 01             	lea    0x1(%eax),%edx
80103080:	89 d0                	mov    %edx,%eax
80103082:	c1 e0 02             	shl    $0x2,%eax
80103085:	01 d0                	add    %edx,%eax
80103087:	01 c0                	add    %eax,%eax
80103089:	01 c8                	add    %ecx,%eax
8010308b:	83 f8 1e             	cmp    $0x1e,%eax
8010308e:	7e 17                	jle    801030a7 <begin_op+0x6b>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
80103090:	83 ec 08             	sub    $0x8,%esp
80103093:	68 20 41 19 80       	push   $0x80194120
80103098:	68 20 41 19 80       	push   $0x80194120
8010309d:	e8 43 12 00 00       	call   801042e5 <sleep>
801030a2:	83 c4 10             	add    $0x10,%esp
801030a5:	eb ab                	jmp    80103052 <begin_op+0x16>
    } else {
      log.outstanding += 1;
801030a7:	a1 5c 41 19 80       	mov    0x8019415c,%eax
801030ac:	83 c0 01             	add    $0x1,%eax
801030af:	a3 5c 41 19 80       	mov    %eax,0x8019415c
      release(&log.lock);
801030b4:	83 ec 0c             	sub    $0xc,%esp
801030b7:	68 20 41 19 80       	push   $0x80194120
801030bc:	e8 b6 16 00 00       	call   80104777 <release>
801030c1:	83 c4 10             	add    $0x10,%esp
      break;
801030c4:	90                   	nop
    }
  }
}
801030c5:	90                   	nop
801030c6:	c9                   	leave  
801030c7:	c3                   	ret    

801030c8 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
801030c8:	55                   	push   %ebp
801030c9:	89 e5                	mov    %esp,%ebp
801030cb:	83 ec 18             	sub    $0x18,%esp
  int do_commit = 0;
801030ce:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&log.lock);
801030d5:	83 ec 0c             	sub    $0xc,%esp
801030d8:	68 20 41 19 80       	push   $0x80194120
801030dd:	e8 27 16 00 00       	call   80104709 <acquire>
801030e2:	83 c4 10             	add    $0x10,%esp
  log.outstanding -= 1;
801030e5:	a1 5c 41 19 80       	mov    0x8019415c,%eax
801030ea:	83 e8 01             	sub    $0x1,%eax
801030ed:	a3 5c 41 19 80       	mov    %eax,0x8019415c
  if(log.committing)
801030f2:	a1 60 41 19 80       	mov    0x80194160,%eax
801030f7:	85 c0                	test   %eax,%eax
801030f9:	74 0d                	je     80103108 <end_op+0x40>
    panic("log.committing");
801030fb:	83 ec 0c             	sub    $0xc,%esp
801030fe:	68 15 a3 10 80       	push   $0x8010a315
80103103:	e8 a1 d4 ff ff       	call   801005a9 <panic>
  if(log.outstanding == 0){
80103108:	a1 5c 41 19 80       	mov    0x8019415c,%eax
8010310d:	85 c0                	test   %eax,%eax
8010310f:	75 13                	jne    80103124 <end_op+0x5c>
    do_commit = 1;
80103111:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
    log.committing = 1;
80103118:	c7 05 60 41 19 80 01 	movl   $0x1,0x80194160
8010311f:	00 00 00 
80103122:	eb 10                	jmp    80103134 <end_op+0x6c>
  } else {
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
80103124:	83 ec 0c             	sub    $0xc,%esp
80103127:	68 20 41 19 80       	push   $0x80194120
8010312c:	e8 9e 12 00 00       	call   801043cf <wakeup>
80103131:	83 c4 10             	add    $0x10,%esp
  }
  release(&log.lock);
80103134:	83 ec 0c             	sub    $0xc,%esp
80103137:	68 20 41 19 80       	push   $0x80194120
8010313c:	e8 36 16 00 00       	call   80104777 <release>
80103141:	83 c4 10             	add    $0x10,%esp

  if(do_commit){
80103144:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103148:	74 3f                	je     80103189 <end_op+0xc1>
    // call commit w/o holding locks, since not allowed
    // to sleep with locks.
    commit();
8010314a:	e8 f6 00 00 00       	call   80103245 <commit>
    acquire(&log.lock);
8010314f:	83 ec 0c             	sub    $0xc,%esp
80103152:	68 20 41 19 80       	push   $0x80194120
80103157:	e8 ad 15 00 00       	call   80104709 <acquire>
8010315c:	83 c4 10             	add    $0x10,%esp
    log.committing = 0;
8010315f:	c7 05 60 41 19 80 00 	movl   $0x0,0x80194160
80103166:	00 00 00 
    wakeup(&log);
80103169:	83 ec 0c             	sub    $0xc,%esp
8010316c:	68 20 41 19 80       	push   $0x80194120
80103171:	e8 59 12 00 00       	call   801043cf <wakeup>
80103176:	83 c4 10             	add    $0x10,%esp
    release(&log.lock);
80103179:	83 ec 0c             	sub    $0xc,%esp
8010317c:	68 20 41 19 80       	push   $0x80194120
80103181:	e8 f1 15 00 00       	call   80104777 <release>
80103186:	83 c4 10             	add    $0x10,%esp
  }
}
80103189:	90                   	nop
8010318a:	c9                   	leave  
8010318b:	c3                   	ret    

8010318c <write_log>:

// Copy modified blocks from cache to log.
static void
write_log(void)
{
8010318c:	55                   	push   %ebp
8010318d:	89 e5                	mov    %esp,%ebp
8010318f:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103192:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103199:	e9 95 00 00 00       	jmp    80103233 <write_log+0xa7>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
8010319e:	8b 15 54 41 19 80    	mov    0x80194154,%edx
801031a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801031a7:	01 d0                	add    %edx,%eax
801031a9:	83 c0 01             	add    $0x1,%eax
801031ac:	89 c2                	mov    %eax,%edx
801031ae:	a1 64 41 19 80       	mov    0x80194164,%eax
801031b3:	83 ec 08             	sub    $0x8,%esp
801031b6:	52                   	push   %edx
801031b7:	50                   	push   %eax
801031b8:	e8 44 d0 ff ff       	call   80100201 <bread>
801031bd:	83 c4 10             	add    $0x10,%esp
801031c0:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
801031c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801031c6:	83 c0 10             	add    $0x10,%eax
801031c9:	8b 04 85 2c 41 19 80 	mov    -0x7fe6bed4(,%eax,4),%eax
801031d0:	89 c2                	mov    %eax,%edx
801031d2:	a1 64 41 19 80       	mov    0x80194164,%eax
801031d7:	83 ec 08             	sub    $0x8,%esp
801031da:	52                   	push   %edx
801031db:	50                   	push   %eax
801031dc:	e8 20 d0 ff ff       	call   80100201 <bread>
801031e1:	83 c4 10             	add    $0x10,%esp
801031e4:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(to->data, from->data, BSIZE);
801031e7:	8b 45 ec             	mov    -0x14(%ebp),%eax
801031ea:	8d 50 5c             	lea    0x5c(%eax),%edx
801031ed:	8b 45 f0             	mov    -0x10(%ebp),%eax
801031f0:	83 c0 5c             	add    $0x5c,%eax
801031f3:	83 ec 04             	sub    $0x4,%esp
801031f6:	68 00 02 00 00       	push   $0x200
801031fb:	52                   	push   %edx
801031fc:	50                   	push   %eax
801031fd:	e8 3c 18 00 00       	call   80104a3e <memmove>
80103202:	83 c4 10             	add    $0x10,%esp
    bwrite(to);  // write the log
80103205:	83 ec 0c             	sub    $0xc,%esp
80103208:	ff 75 f0             	push   -0x10(%ebp)
8010320b:	e8 2a d0 ff ff       	call   8010023a <bwrite>
80103210:	83 c4 10             	add    $0x10,%esp
    brelse(from);
80103213:	83 ec 0c             	sub    $0xc,%esp
80103216:	ff 75 ec             	push   -0x14(%ebp)
80103219:	e8 65 d0 ff ff       	call   80100283 <brelse>
8010321e:	83 c4 10             	add    $0x10,%esp
    brelse(to);
80103221:	83 ec 0c             	sub    $0xc,%esp
80103224:	ff 75 f0             	push   -0x10(%ebp)
80103227:	e8 57 d0 ff ff       	call   80100283 <brelse>
8010322c:	83 c4 10             	add    $0x10,%esp
  for (tail = 0; tail < log.lh.n; tail++) {
8010322f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103233:	a1 68 41 19 80       	mov    0x80194168,%eax
80103238:	39 45 f4             	cmp    %eax,-0xc(%ebp)
8010323b:	0f 8c 5d ff ff ff    	jl     8010319e <write_log+0x12>
  }
}
80103241:	90                   	nop
80103242:	90                   	nop
80103243:	c9                   	leave  
80103244:	c3                   	ret    

80103245 <commit>:

static void
commit()
{
80103245:	55                   	push   %ebp
80103246:	89 e5                	mov    %esp,%ebp
80103248:	83 ec 08             	sub    $0x8,%esp
  if (log.lh.n > 0) {
8010324b:	a1 68 41 19 80       	mov    0x80194168,%eax
80103250:	85 c0                	test   %eax,%eax
80103252:	7e 1e                	jle    80103272 <commit+0x2d>
    write_log();     // Write modified blocks from cache to log
80103254:	e8 33 ff ff ff       	call   8010318c <write_log>
    write_head();    // Write header to disk -- the real commit
80103259:	e8 39 fd ff ff       	call   80102f97 <write_head>
    install_trans(); // Now install writes to home locations
8010325e:	e8 07 fc ff ff       	call   80102e6a <install_trans>
    log.lh.n = 0;
80103263:	c7 05 68 41 19 80 00 	movl   $0x0,0x80194168
8010326a:	00 00 00 
    write_head();    // Erase the transaction from the log
8010326d:	e8 25 fd ff ff       	call   80102f97 <write_head>
  }
}
80103272:	90                   	nop
80103273:	c9                   	leave  
80103274:	c3                   	ret    

80103275 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
80103275:	55                   	push   %ebp
80103276:	89 e5                	mov    %esp,%ebp
80103278:	83 ec 18             	sub    $0x18,%esp
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
8010327b:	a1 68 41 19 80       	mov    0x80194168,%eax
80103280:	83 f8 1d             	cmp    $0x1d,%eax
80103283:	7f 12                	jg     80103297 <log_write+0x22>
80103285:	a1 68 41 19 80       	mov    0x80194168,%eax
8010328a:	8b 15 58 41 19 80    	mov    0x80194158,%edx
80103290:	83 ea 01             	sub    $0x1,%edx
80103293:	39 d0                	cmp    %edx,%eax
80103295:	7c 0d                	jl     801032a4 <log_write+0x2f>
    panic("too big a transaction");
80103297:	83 ec 0c             	sub    $0xc,%esp
8010329a:	68 24 a3 10 80       	push   $0x8010a324
8010329f:	e8 05 d3 ff ff       	call   801005a9 <panic>
  if (log.outstanding < 1)
801032a4:	a1 5c 41 19 80       	mov    0x8019415c,%eax
801032a9:	85 c0                	test   %eax,%eax
801032ab:	7f 0d                	jg     801032ba <log_write+0x45>
    panic("log_write outside of trans");
801032ad:	83 ec 0c             	sub    $0xc,%esp
801032b0:	68 3a a3 10 80       	push   $0x8010a33a
801032b5:	e8 ef d2 ff ff       	call   801005a9 <panic>

  acquire(&log.lock);
801032ba:	83 ec 0c             	sub    $0xc,%esp
801032bd:	68 20 41 19 80       	push   $0x80194120
801032c2:	e8 42 14 00 00       	call   80104709 <acquire>
801032c7:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < log.lh.n; i++) {
801032ca:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801032d1:	eb 1d                	jmp    801032f0 <log_write+0x7b>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
801032d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801032d6:	83 c0 10             	add    $0x10,%eax
801032d9:	8b 04 85 2c 41 19 80 	mov    -0x7fe6bed4(,%eax,4),%eax
801032e0:	89 c2                	mov    %eax,%edx
801032e2:	8b 45 08             	mov    0x8(%ebp),%eax
801032e5:	8b 40 08             	mov    0x8(%eax),%eax
801032e8:	39 c2                	cmp    %eax,%edx
801032ea:	74 10                	je     801032fc <log_write+0x87>
  for (i = 0; i < log.lh.n; i++) {
801032ec:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801032f0:	a1 68 41 19 80       	mov    0x80194168,%eax
801032f5:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801032f8:	7c d9                	jl     801032d3 <log_write+0x5e>
801032fa:	eb 01                	jmp    801032fd <log_write+0x88>
      break;
801032fc:	90                   	nop
  }
  log.lh.block[i] = b->blockno;
801032fd:	8b 45 08             	mov    0x8(%ebp),%eax
80103300:	8b 40 08             	mov    0x8(%eax),%eax
80103303:	89 c2                	mov    %eax,%edx
80103305:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103308:	83 c0 10             	add    $0x10,%eax
8010330b:	89 14 85 2c 41 19 80 	mov    %edx,-0x7fe6bed4(,%eax,4)
  if (i == log.lh.n)
80103312:	a1 68 41 19 80       	mov    0x80194168,%eax
80103317:	39 45 f4             	cmp    %eax,-0xc(%ebp)
8010331a:	75 0d                	jne    80103329 <log_write+0xb4>
    log.lh.n++;
8010331c:	a1 68 41 19 80       	mov    0x80194168,%eax
80103321:	83 c0 01             	add    $0x1,%eax
80103324:	a3 68 41 19 80       	mov    %eax,0x80194168
  b->flags |= B_DIRTY; // prevent eviction
80103329:	8b 45 08             	mov    0x8(%ebp),%eax
8010332c:	8b 00                	mov    (%eax),%eax
8010332e:	83 c8 04             	or     $0x4,%eax
80103331:	89 c2                	mov    %eax,%edx
80103333:	8b 45 08             	mov    0x8(%ebp),%eax
80103336:	89 10                	mov    %edx,(%eax)
  release(&log.lock);
80103338:	83 ec 0c             	sub    $0xc,%esp
8010333b:	68 20 41 19 80       	push   $0x80194120
80103340:	e8 32 14 00 00       	call   80104777 <release>
80103345:	83 c4 10             	add    $0x10,%esp
}
80103348:	90                   	nop
80103349:	c9                   	leave  
8010334a:	c3                   	ret    

8010334b <xchg>:
  asm volatile("sti");
}

static inline uint
xchg(volatile uint *addr, uint newval)
{
8010334b:	55                   	push   %ebp
8010334c:	89 e5                	mov    %esp,%ebp
8010334e:	83 ec 10             	sub    $0x10,%esp
  uint result;

  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80103351:	8b 55 08             	mov    0x8(%ebp),%edx
80103354:	8b 45 0c             	mov    0xc(%ebp),%eax
80103357:	8b 4d 08             	mov    0x8(%ebp),%ecx
8010335a:	f0 87 02             	lock xchg %eax,(%edx)
8010335d:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
80103360:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80103363:	c9                   	leave  
80103364:	c3                   	ret    

80103365 <main>:
// Bootstrap processor starts running C code here.
// Allocate a real stack and switch to it, first
// doing some setup required for memory allocator to work.
int
main(void)
{
80103365:	8d 4c 24 04          	lea    0x4(%esp),%ecx
80103369:	83 e4 f0             	and    $0xfffffff0,%esp
8010336c:	ff 71 fc             	push   -0x4(%ecx)
8010336f:	55                   	push   %ebp
80103370:	89 e5                	mov    %esp,%ebp
80103372:	51                   	push   %ecx
80103373:	83 ec 04             	sub    $0x4,%esp
  graphic_init();
80103376:	e8 20 4b 00 00       	call   80107e9b <graphic_init>
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
8010337b:	83 ec 08             	sub    $0x8,%esp
8010337e:	68 00 00 40 80       	push   $0x80400000
80103383:	68 00 90 19 80       	push   $0x80199000
80103388:	e8 de f2 ff ff       	call   8010266b <kinit1>
8010338d:	83 c4 10             	add    $0x10,%esp
  kvmalloc();      // kernel page table
80103390:	e8 20 41 00 00       	call   801074b5 <kvmalloc>
  mpinit_uefi();
80103395:	e8 c7 48 00 00       	call   80107c61 <mpinit_uefi>
  lapicinit();     // interrupt controller
8010339a:	e8 3c f6 ff ff       	call   801029db <lapicinit>
  seginit();       // segment descriptors
8010339f:	e8 a9 3b 00 00       	call   80106f4d <seginit>
  picinit();    // disable pic
801033a4:	e8 9d 01 00 00       	call   80103546 <picinit>
  ioapicinit();    // another interrupt controller
801033a9:	e8 d8 f1 ff ff       	call   80102586 <ioapicinit>
  consoleinit();   // console hardware
801033ae:	e8 4c d7 ff ff       	call   80100aff <consoleinit>
  uartinit();      // serial port
801033b3:	e8 2e 2f 00 00       	call   801062e6 <uartinit>
  pinit();         // process table
801033b8:	e8 c2 05 00 00       	call   8010397f <pinit>
  tvinit();        // trap vectors
801033bd:	e8 0f 2a 00 00       	call   80105dd1 <tvinit>
  binit();         // buffer cache
801033c2:	e8 9f cc ff ff       	call   80100066 <binit>
  fileinit();      // file table
801033c7:	e8 f3 db ff ff       	call   80100fbf <fileinit>
  ideinit();       // disk 
801033cc:	e8 0b 6c 00 00       	call   80109fdc <ideinit>
  startothers();   // start other processors
801033d1:	e8 8a 00 00 00       	call   80103460 <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
801033d6:	83 ec 08             	sub    $0x8,%esp
801033d9:	68 00 00 00 a0       	push   $0xa0000000
801033de:	68 00 00 40 80       	push   $0x80400000
801033e3:	e8 bc f2 ff ff       	call   801026a4 <kinit2>
801033e8:	83 c4 10             	add    $0x10,%esp
  pci_init();
801033eb:	e8 04 4d 00 00       	call   801080f4 <pci_init>
  arp_scan();
801033f0:	e8 3b 5a 00 00       	call   80108e30 <arp_scan>
  //i8254_recv();
  userinit();      // first user process
801033f5:	e8 66 07 00 00       	call   80103b60 <userinit>

  mpmain();        // finish this processor's setup
801033fa:	e8 1a 00 00 00       	call   80103419 <mpmain>

801033ff <mpenter>:
}

// Other CPUs jump here from entryother.S.
static void
mpenter(void)
{
801033ff:	55                   	push   %ebp
80103400:	89 e5                	mov    %esp,%ebp
80103402:	83 ec 08             	sub    $0x8,%esp
  switchkvm();
80103405:	e8 c3 40 00 00       	call   801074cd <switchkvm>
  seginit();
8010340a:	e8 3e 3b 00 00       	call   80106f4d <seginit>
  lapicinit();
8010340f:	e8 c7 f5 ff ff       	call   801029db <lapicinit>
  mpmain();
80103414:	e8 00 00 00 00       	call   80103419 <mpmain>

80103419 <mpmain>:
}

// Common CPU setup code.
static void
mpmain(void)
{
80103419:	55                   	push   %ebp
8010341a:	89 e5                	mov    %esp,%ebp
8010341c:	53                   	push   %ebx
8010341d:	83 ec 04             	sub    $0x4,%esp
  cprintf("cpu%d: starting %d\n", cpuid(), cpuid());
80103420:	e8 78 05 00 00       	call   8010399d <cpuid>
80103425:	89 c3                	mov    %eax,%ebx
80103427:	e8 71 05 00 00       	call   8010399d <cpuid>
8010342c:	83 ec 04             	sub    $0x4,%esp
8010342f:	53                   	push   %ebx
80103430:	50                   	push   %eax
80103431:	68 55 a3 10 80       	push   $0x8010a355
80103436:	e8 b9 cf ff ff       	call   801003f4 <cprintf>
8010343b:	83 c4 10             	add    $0x10,%esp
  idtinit();       // load idt register
8010343e:	e8 04 2b 00 00       	call   80105f47 <idtinit>
  xchg(&(mycpu()->started), 1); // tell startothers() we're up
80103443:	e8 70 05 00 00       	call   801039b8 <mycpu>
80103448:	05 a0 00 00 00       	add    $0xa0,%eax
8010344d:	83 ec 08             	sub    $0x8,%esp
80103450:	6a 01                	push   $0x1
80103452:	50                   	push   %eax
80103453:	e8 f3 fe ff ff       	call   8010334b <xchg>
80103458:	83 c4 10             	add    $0x10,%esp
  scheduler();     // start running processes
8010345b:	e8 91 0c 00 00       	call   801040f1 <scheduler>

80103460 <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
80103460:	55                   	push   %ebp
80103461:	89 e5                	mov    %esp,%ebp
80103463:	83 ec 18             	sub    $0x18,%esp
  char *stack;

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = P2V(0x7000);
80103466:	c7 45 f0 00 70 00 80 	movl   $0x80007000,-0x10(%ebp)
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
8010346d:	b8 8a 00 00 00       	mov    $0x8a,%eax
80103472:	83 ec 04             	sub    $0x4,%esp
80103475:	50                   	push   %eax
80103476:	68 18 f5 10 80       	push   $0x8010f518
8010347b:	ff 75 f0             	push   -0x10(%ebp)
8010347e:	e8 bb 15 00 00       	call   80104a3e <memmove>
80103483:	83 c4 10             	add    $0x10,%esp

  for(c = cpus; c < cpus+ncpu; c++){
80103486:	c7 45 f4 80 6b 19 80 	movl   $0x80196b80,-0xc(%ebp)
8010348d:	eb 79                	jmp    80103508 <startothers+0xa8>
    if(c == mycpu()){  // We've started already.
8010348f:	e8 24 05 00 00       	call   801039b8 <mycpu>
80103494:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103497:	74 67                	je     80103500 <startothers+0xa0>
      continue;
    }
    // Tell entryother.S what stack to use, where to enter, and what
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
80103499:	e8 02 f3 ff ff       	call   801027a0 <kalloc>
8010349e:	89 45 ec             	mov    %eax,-0x14(%ebp)
    *(void**)(code-4) = stack + KSTACKSIZE;
801034a1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801034a4:	83 e8 04             	sub    $0x4,%eax
801034a7:	8b 55 ec             	mov    -0x14(%ebp),%edx
801034aa:	81 c2 00 10 00 00    	add    $0x1000,%edx
801034b0:	89 10                	mov    %edx,(%eax)
    *(void**)(code-8) = mpenter;
801034b2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801034b5:	83 e8 08             	sub    $0x8,%eax
801034b8:	c7 00 ff 33 10 80    	movl   $0x801033ff,(%eax)
    *(int**)(code-12) = (void *) V2P(entrypgdir);
801034be:	b8 00 e0 10 80       	mov    $0x8010e000,%eax
801034c3:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
801034c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801034cc:	83 e8 0c             	sub    $0xc,%eax
801034cf:	89 10                	mov    %edx,(%eax)

    lapicstartap(c->apicid, V2P(code));
801034d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801034d4:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
801034da:	8b 45 f4             	mov    -0xc(%ebp),%eax
801034dd:	0f b6 00             	movzbl (%eax),%eax
801034e0:	0f b6 c0             	movzbl %al,%eax
801034e3:	83 ec 08             	sub    $0x8,%esp
801034e6:	52                   	push   %edx
801034e7:	50                   	push   %eax
801034e8:	e8 50 f6 ff ff       	call   80102b3d <lapicstartap>
801034ed:	83 c4 10             	add    $0x10,%esp

    // wait for cpu to finish mpmain()
    while(c->started == 0)
801034f0:	90                   	nop
801034f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801034f4:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
801034fa:	85 c0                	test   %eax,%eax
801034fc:	74 f3                	je     801034f1 <startothers+0x91>
801034fe:	eb 01                	jmp    80103501 <startothers+0xa1>
      continue;
80103500:	90                   	nop
  for(c = cpus; c < cpus+ncpu; c++){
80103501:	81 45 f4 b0 00 00 00 	addl   $0xb0,-0xc(%ebp)
80103508:	a1 40 6e 19 80       	mov    0x80196e40,%eax
8010350d:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
80103513:	05 80 6b 19 80       	add    $0x80196b80,%eax
80103518:	39 45 f4             	cmp    %eax,-0xc(%ebp)
8010351b:	0f 82 6e ff ff ff    	jb     8010348f <startothers+0x2f>
      ;
  }
}
80103521:	90                   	nop
80103522:	90                   	nop
80103523:	c9                   	leave  
80103524:	c3                   	ret    

80103525 <outb>:
{
80103525:	55                   	push   %ebp
80103526:	89 e5                	mov    %esp,%ebp
80103528:	83 ec 08             	sub    $0x8,%esp
8010352b:	8b 45 08             	mov    0x8(%ebp),%eax
8010352e:	8b 55 0c             	mov    0xc(%ebp),%edx
80103531:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80103535:	89 d0                	mov    %edx,%eax
80103537:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010353a:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
8010353e:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80103542:	ee                   	out    %al,(%dx)
}
80103543:	90                   	nop
80103544:	c9                   	leave  
80103545:	c3                   	ret    

80103546 <picinit>:
#define IO_PIC2         0xA0    // Slave (IRQs 8-15)

// Don't use the 8259A interrupt controllers.  Xv6 assumes SMP hardware.
void
picinit(void)
{
80103546:	55                   	push   %ebp
80103547:	89 e5                	mov    %esp,%ebp
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
80103549:	68 ff 00 00 00       	push   $0xff
8010354e:	6a 21                	push   $0x21
80103550:	e8 d0 ff ff ff       	call   80103525 <outb>
80103555:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, 0xFF);
80103558:	68 ff 00 00 00       	push   $0xff
8010355d:	68 a1 00 00 00       	push   $0xa1
80103562:	e8 be ff ff ff       	call   80103525 <outb>
80103567:	83 c4 08             	add    $0x8,%esp
}
8010356a:	90                   	nop
8010356b:	c9                   	leave  
8010356c:	c3                   	ret    

8010356d <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
8010356d:	55                   	push   %ebp
8010356e:	89 e5                	mov    %esp,%ebp
80103570:	83 ec 18             	sub    $0x18,%esp
  struct pipe *p;

  p = 0;
80103573:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  *f0 = *f1 = 0;
8010357a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010357d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
80103583:	8b 45 0c             	mov    0xc(%ebp),%eax
80103586:	8b 10                	mov    (%eax),%edx
80103588:	8b 45 08             	mov    0x8(%ebp),%eax
8010358b:	89 10                	mov    %edx,(%eax)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
8010358d:	e8 4b da ff ff       	call   80100fdd <filealloc>
80103592:	8b 55 08             	mov    0x8(%ebp),%edx
80103595:	89 02                	mov    %eax,(%edx)
80103597:	8b 45 08             	mov    0x8(%ebp),%eax
8010359a:	8b 00                	mov    (%eax),%eax
8010359c:	85 c0                	test   %eax,%eax
8010359e:	0f 84 c8 00 00 00    	je     8010366c <pipealloc+0xff>
801035a4:	e8 34 da ff ff       	call   80100fdd <filealloc>
801035a9:	8b 55 0c             	mov    0xc(%ebp),%edx
801035ac:	89 02                	mov    %eax,(%edx)
801035ae:	8b 45 0c             	mov    0xc(%ebp),%eax
801035b1:	8b 00                	mov    (%eax),%eax
801035b3:	85 c0                	test   %eax,%eax
801035b5:	0f 84 b1 00 00 00    	je     8010366c <pipealloc+0xff>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
801035bb:	e8 e0 f1 ff ff       	call   801027a0 <kalloc>
801035c0:	89 45 f4             	mov    %eax,-0xc(%ebp)
801035c3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801035c7:	0f 84 a2 00 00 00    	je     8010366f <pipealloc+0x102>
    goto bad;
  p->readopen = 1;
801035cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801035d0:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
801035d7:	00 00 00 
  p->writeopen = 1;
801035da:	8b 45 f4             	mov    -0xc(%ebp),%eax
801035dd:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
801035e4:	00 00 00 
  p->nwrite = 0;
801035e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801035ea:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
801035f1:	00 00 00 
  p->nread = 0;
801035f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801035f7:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
801035fe:	00 00 00 
  initlock(&p->lock, "pipe");
80103601:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103604:	83 ec 08             	sub    $0x8,%esp
80103607:	68 69 a3 10 80       	push   $0x8010a369
8010360c:	50                   	push   %eax
8010360d:	e8 d5 10 00 00       	call   801046e7 <initlock>
80103612:	83 c4 10             	add    $0x10,%esp
  (*f0)->type = FD_PIPE;
80103615:	8b 45 08             	mov    0x8(%ebp),%eax
80103618:	8b 00                	mov    (%eax),%eax
8010361a:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
80103620:	8b 45 08             	mov    0x8(%ebp),%eax
80103623:	8b 00                	mov    (%eax),%eax
80103625:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
80103629:	8b 45 08             	mov    0x8(%ebp),%eax
8010362c:	8b 00                	mov    (%eax),%eax
8010362e:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
80103632:	8b 45 08             	mov    0x8(%ebp),%eax
80103635:	8b 00                	mov    (%eax),%eax
80103637:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010363a:	89 50 0c             	mov    %edx,0xc(%eax)
  (*f1)->type = FD_PIPE;
8010363d:	8b 45 0c             	mov    0xc(%ebp),%eax
80103640:	8b 00                	mov    (%eax),%eax
80103642:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
80103648:	8b 45 0c             	mov    0xc(%ebp),%eax
8010364b:	8b 00                	mov    (%eax),%eax
8010364d:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
80103651:	8b 45 0c             	mov    0xc(%ebp),%eax
80103654:	8b 00                	mov    (%eax),%eax
80103656:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
8010365a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010365d:	8b 00                	mov    (%eax),%eax
8010365f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103662:	89 50 0c             	mov    %edx,0xc(%eax)
  return 0;
80103665:	b8 00 00 00 00       	mov    $0x0,%eax
8010366a:	eb 51                	jmp    801036bd <pipealloc+0x150>
    goto bad;
8010366c:	90                   	nop
8010366d:	eb 01                	jmp    80103670 <pipealloc+0x103>
    goto bad;
8010366f:	90                   	nop

//PAGEBREAK: 20
 bad:
  if(p)
80103670:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103674:	74 0e                	je     80103684 <pipealloc+0x117>
    kfree((char*)p);
80103676:	83 ec 0c             	sub    $0xc,%esp
80103679:	ff 75 f4             	push   -0xc(%ebp)
8010367c:	e8 85 f0 ff ff       	call   80102706 <kfree>
80103681:	83 c4 10             	add    $0x10,%esp
  if(*f0)
80103684:	8b 45 08             	mov    0x8(%ebp),%eax
80103687:	8b 00                	mov    (%eax),%eax
80103689:	85 c0                	test   %eax,%eax
8010368b:	74 11                	je     8010369e <pipealloc+0x131>
    fileclose(*f0);
8010368d:	8b 45 08             	mov    0x8(%ebp),%eax
80103690:	8b 00                	mov    (%eax),%eax
80103692:	83 ec 0c             	sub    $0xc,%esp
80103695:	50                   	push   %eax
80103696:	e8 00 da ff ff       	call   8010109b <fileclose>
8010369b:	83 c4 10             	add    $0x10,%esp
  if(*f1)
8010369e:	8b 45 0c             	mov    0xc(%ebp),%eax
801036a1:	8b 00                	mov    (%eax),%eax
801036a3:	85 c0                	test   %eax,%eax
801036a5:	74 11                	je     801036b8 <pipealloc+0x14b>
    fileclose(*f1);
801036a7:	8b 45 0c             	mov    0xc(%ebp),%eax
801036aa:	8b 00                	mov    (%eax),%eax
801036ac:	83 ec 0c             	sub    $0xc,%esp
801036af:	50                   	push   %eax
801036b0:	e8 e6 d9 ff ff       	call   8010109b <fileclose>
801036b5:	83 c4 10             	add    $0x10,%esp
  return -1;
801036b8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801036bd:	c9                   	leave  
801036be:	c3                   	ret    

801036bf <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
801036bf:	55                   	push   %ebp
801036c0:	89 e5                	mov    %esp,%ebp
801036c2:	83 ec 08             	sub    $0x8,%esp
  acquire(&p->lock);
801036c5:	8b 45 08             	mov    0x8(%ebp),%eax
801036c8:	83 ec 0c             	sub    $0xc,%esp
801036cb:	50                   	push   %eax
801036cc:	e8 38 10 00 00       	call   80104709 <acquire>
801036d1:	83 c4 10             	add    $0x10,%esp
  if(writable){
801036d4:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801036d8:	74 23                	je     801036fd <pipeclose+0x3e>
    p->writeopen = 0;
801036da:	8b 45 08             	mov    0x8(%ebp),%eax
801036dd:	c7 80 40 02 00 00 00 	movl   $0x0,0x240(%eax)
801036e4:	00 00 00 
    wakeup(&p->nread);
801036e7:	8b 45 08             	mov    0x8(%ebp),%eax
801036ea:	05 34 02 00 00       	add    $0x234,%eax
801036ef:	83 ec 0c             	sub    $0xc,%esp
801036f2:	50                   	push   %eax
801036f3:	e8 d7 0c 00 00       	call   801043cf <wakeup>
801036f8:	83 c4 10             	add    $0x10,%esp
801036fb:	eb 21                	jmp    8010371e <pipeclose+0x5f>
  } else {
    p->readopen = 0;
801036fd:	8b 45 08             	mov    0x8(%ebp),%eax
80103700:	c7 80 3c 02 00 00 00 	movl   $0x0,0x23c(%eax)
80103707:	00 00 00 
    wakeup(&p->nwrite);
8010370a:	8b 45 08             	mov    0x8(%ebp),%eax
8010370d:	05 38 02 00 00       	add    $0x238,%eax
80103712:	83 ec 0c             	sub    $0xc,%esp
80103715:	50                   	push   %eax
80103716:	e8 b4 0c 00 00       	call   801043cf <wakeup>
8010371b:	83 c4 10             	add    $0x10,%esp
  }
  if(p->readopen == 0 && p->writeopen == 0){
8010371e:	8b 45 08             	mov    0x8(%ebp),%eax
80103721:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
80103727:	85 c0                	test   %eax,%eax
80103729:	75 2c                	jne    80103757 <pipeclose+0x98>
8010372b:	8b 45 08             	mov    0x8(%ebp),%eax
8010372e:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
80103734:	85 c0                	test   %eax,%eax
80103736:	75 1f                	jne    80103757 <pipeclose+0x98>
    release(&p->lock);
80103738:	8b 45 08             	mov    0x8(%ebp),%eax
8010373b:	83 ec 0c             	sub    $0xc,%esp
8010373e:	50                   	push   %eax
8010373f:	e8 33 10 00 00       	call   80104777 <release>
80103744:	83 c4 10             	add    $0x10,%esp
    kfree((char*)p);
80103747:	83 ec 0c             	sub    $0xc,%esp
8010374a:	ff 75 08             	push   0x8(%ebp)
8010374d:	e8 b4 ef ff ff       	call   80102706 <kfree>
80103752:	83 c4 10             	add    $0x10,%esp
80103755:	eb 10                	jmp    80103767 <pipeclose+0xa8>
  } else
    release(&p->lock);
80103757:	8b 45 08             	mov    0x8(%ebp),%eax
8010375a:	83 ec 0c             	sub    $0xc,%esp
8010375d:	50                   	push   %eax
8010375e:	e8 14 10 00 00       	call   80104777 <release>
80103763:	83 c4 10             	add    $0x10,%esp
}
80103766:	90                   	nop
80103767:	90                   	nop
80103768:	c9                   	leave  
80103769:	c3                   	ret    

8010376a <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
8010376a:	55                   	push   %ebp
8010376b:	89 e5                	mov    %esp,%ebp
8010376d:	53                   	push   %ebx
8010376e:	83 ec 14             	sub    $0x14,%esp
  int i;

  acquire(&p->lock);
80103771:	8b 45 08             	mov    0x8(%ebp),%eax
80103774:	83 ec 0c             	sub    $0xc,%esp
80103777:	50                   	push   %eax
80103778:	e8 8c 0f 00 00       	call   80104709 <acquire>
8010377d:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++){
80103780:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103787:	e9 ad 00 00 00       	jmp    80103839 <pipewrite+0xcf>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
      if(p->readopen == 0 || myproc()->killed){
8010378c:	8b 45 08             	mov    0x8(%ebp),%eax
8010378f:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
80103795:	85 c0                	test   %eax,%eax
80103797:	74 0c                	je     801037a5 <pipewrite+0x3b>
80103799:	e8 92 02 00 00       	call   80103a30 <myproc>
8010379e:	8b 40 24             	mov    0x24(%eax),%eax
801037a1:	85 c0                	test   %eax,%eax
801037a3:	74 19                	je     801037be <pipewrite+0x54>
        release(&p->lock);
801037a5:	8b 45 08             	mov    0x8(%ebp),%eax
801037a8:	83 ec 0c             	sub    $0xc,%esp
801037ab:	50                   	push   %eax
801037ac:	e8 c6 0f 00 00       	call   80104777 <release>
801037b1:	83 c4 10             	add    $0x10,%esp
        return -1;
801037b4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801037b9:	e9 a9 00 00 00       	jmp    80103867 <pipewrite+0xfd>
      }
      wakeup(&p->nread);
801037be:	8b 45 08             	mov    0x8(%ebp),%eax
801037c1:	05 34 02 00 00       	add    $0x234,%eax
801037c6:	83 ec 0c             	sub    $0xc,%esp
801037c9:	50                   	push   %eax
801037ca:	e8 00 0c 00 00       	call   801043cf <wakeup>
801037cf:	83 c4 10             	add    $0x10,%esp
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
801037d2:	8b 45 08             	mov    0x8(%ebp),%eax
801037d5:	8b 55 08             	mov    0x8(%ebp),%edx
801037d8:	81 c2 38 02 00 00    	add    $0x238,%edx
801037de:	83 ec 08             	sub    $0x8,%esp
801037e1:	50                   	push   %eax
801037e2:	52                   	push   %edx
801037e3:	e8 fd 0a 00 00       	call   801042e5 <sleep>
801037e8:	83 c4 10             	add    $0x10,%esp
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
801037eb:	8b 45 08             	mov    0x8(%ebp),%eax
801037ee:	8b 90 38 02 00 00    	mov    0x238(%eax),%edx
801037f4:	8b 45 08             	mov    0x8(%ebp),%eax
801037f7:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
801037fd:	05 00 02 00 00       	add    $0x200,%eax
80103802:	39 c2                	cmp    %eax,%edx
80103804:	74 86                	je     8010378c <pipewrite+0x22>
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
80103806:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103809:	8b 45 0c             	mov    0xc(%ebp),%eax
8010380c:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
8010380f:	8b 45 08             	mov    0x8(%ebp),%eax
80103812:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80103818:	8d 48 01             	lea    0x1(%eax),%ecx
8010381b:	8b 55 08             	mov    0x8(%ebp),%edx
8010381e:	89 8a 38 02 00 00    	mov    %ecx,0x238(%edx)
80103824:	25 ff 01 00 00       	and    $0x1ff,%eax
80103829:	89 c1                	mov    %eax,%ecx
8010382b:	0f b6 13             	movzbl (%ebx),%edx
8010382e:	8b 45 08             	mov    0x8(%ebp),%eax
80103831:	88 54 08 34          	mov    %dl,0x34(%eax,%ecx,1)
  for(i = 0; i < n; i++){
80103835:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103839:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010383c:	3b 45 10             	cmp    0x10(%ebp),%eax
8010383f:	7c aa                	jl     801037eb <pipewrite+0x81>
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
80103841:	8b 45 08             	mov    0x8(%ebp),%eax
80103844:	05 34 02 00 00       	add    $0x234,%eax
80103849:	83 ec 0c             	sub    $0xc,%esp
8010384c:	50                   	push   %eax
8010384d:	e8 7d 0b 00 00       	call   801043cf <wakeup>
80103852:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
80103855:	8b 45 08             	mov    0x8(%ebp),%eax
80103858:	83 ec 0c             	sub    $0xc,%esp
8010385b:	50                   	push   %eax
8010385c:	e8 16 0f 00 00       	call   80104777 <release>
80103861:	83 c4 10             	add    $0x10,%esp
  return n;
80103864:	8b 45 10             	mov    0x10(%ebp),%eax
}
80103867:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010386a:	c9                   	leave  
8010386b:	c3                   	ret    

8010386c <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
8010386c:	55                   	push   %ebp
8010386d:	89 e5                	mov    %esp,%ebp
8010386f:	83 ec 18             	sub    $0x18,%esp
  int i;

  acquire(&p->lock);
80103872:	8b 45 08             	mov    0x8(%ebp),%eax
80103875:	83 ec 0c             	sub    $0xc,%esp
80103878:	50                   	push   %eax
80103879:	e8 8b 0e 00 00       	call   80104709 <acquire>
8010387e:	83 c4 10             	add    $0x10,%esp
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80103881:	eb 3e                	jmp    801038c1 <piperead+0x55>
    if(myproc()->killed){
80103883:	e8 a8 01 00 00       	call   80103a30 <myproc>
80103888:	8b 40 24             	mov    0x24(%eax),%eax
8010388b:	85 c0                	test   %eax,%eax
8010388d:	74 19                	je     801038a8 <piperead+0x3c>
      release(&p->lock);
8010388f:	8b 45 08             	mov    0x8(%ebp),%eax
80103892:	83 ec 0c             	sub    $0xc,%esp
80103895:	50                   	push   %eax
80103896:	e8 dc 0e 00 00       	call   80104777 <release>
8010389b:	83 c4 10             	add    $0x10,%esp
      return -1;
8010389e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801038a3:	e9 be 00 00 00       	jmp    80103966 <piperead+0xfa>
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
801038a8:	8b 45 08             	mov    0x8(%ebp),%eax
801038ab:	8b 55 08             	mov    0x8(%ebp),%edx
801038ae:	81 c2 34 02 00 00    	add    $0x234,%edx
801038b4:	83 ec 08             	sub    $0x8,%esp
801038b7:	50                   	push   %eax
801038b8:	52                   	push   %edx
801038b9:	e8 27 0a 00 00       	call   801042e5 <sleep>
801038be:	83 c4 10             	add    $0x10,%esp
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
801038c1:	8b 45 08             	mov    0x8(%ebp),%eax
801038c4:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
801038ca:	8b 45 08             	mov    0x8(%ebp),%eax
801038cd:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
801038d3:	39 c2                	cmp    %eax,%edx
801038d5:	75 0d                	jne    801038e4 <piperead+0x78>
801038d7:	8b 45 08             	mov    0x8(%ebp),%eax
801038da:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
801038e0:	85 c0                	test   %eax,%eax
801038e2:	75 9f                	jne    80103883 <piperead+0x17>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
801038e4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801038eb:	eb 48                	jmp    80103935 <piperead+0xc9>
    if(p->nread == p->nwrite)
801038ed:	8b 45 08             	mov    0x8(%ebp),%eax
801038f0:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
801038f6:	8b 45 08             	mov    0x8(%ebp),%eax
801038f9:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
801038ff:	39 c2                	cmp    %eax,%edx
80103901:	74 3c                	je     8010393f <piperead+0xd3>
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
80103903:	8b 45 08             	mov    0x8(%ebp),%eax
80103906:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
8010390c:	8d 48 01             	lea    0x1(%eax),%ecx
8010390f:	8b 55 08             	mov    0x8(%ebp),%edx
80103912:	89 8a 34 02 00 00    	mov    %ecx,0x234(%edx)
80103918:	25 ff 01 00 00       	and    $0x1ff,%eax
8010391d:	89 c1                	mov    %eax,%ecx
8010391f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103922:	8b 45 0c             	mov    0xc(%ebp),%eax
80103925:	01 c2                	add    %eax,%edx
80103927:	8b 45 08             	mov    0x8(%ebp),%eax
8010392a:	0f b6 44 08 34       	movzbl 0x34(%eax,%ecx,1),%eax
8010392f:	88 02                	mov    %al,(%edx)
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80103931:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103935:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103938:	3b 45 10             	cmp    0x10(%ebp),%eax
8010393b:	7c b0                	jl     801038ed <piperead+0x81>
8010393d:	eb 01                	jmp    80103940 <piperead+0xd4>
      break;
8010393f:	90                   	nop
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
80103940:	8b 45 08             	mov    0x8(%ebp),%eax
80103943:	05 38 02 00 00       	add    $0x238,%eax
80103948:	83 ec 0c             	sub    $0xc,%esp
8010394b:	50                   	push   %eax
8010394c:	e8 7e 0a 00 00       	call   801043cf <wakeup>
80103951:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
80103954:	8b 45 08             	mov    0x8(%ebp),%eax
80103957:	83 ec 0c             	sub    $0xc,%esp
8010395a:	50                   	push   %eax
8010395b:	e8 17 0e 00 00       	call   80104777 <release>
80103960:	83 c4 10             	add    $0x10,%esp
  return i;
80103963:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80103966:	c9                   	leave  
80103967:	c3                   	ret    

80103968 <readeflags>:
{
80103968:	55                   	push   %ebp
80103969:	89 e5                	mov    %esp,%ebp
8010396b:	83 ec 10             	sub    $0x10,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
8010396e:	9c                   	pushf  
8010396f:	58                   	pop    %eax
80103970:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80103973:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80103976:	c9                   	leave  
80103977:	c3                   	ret    

80103978 <sti>:
{
80103978:	55                   	push   %ebp
80103979:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
8010397b:	fb                   	sti    
}
8010397c:	90                   	nop
8010397d:	5d                   	pop    %ebp
8010397e:	c3                   	ret    

8010397f <pinit>:

static void wakeup1(void *chan);

void
pinit(void)
{
8010397f:	55                   	push   %ebp
80103980:	89 e5                	mov    %esp,%ebp
80103982:	83 ec 08             	sub    $0x8,%esp
  initlock(&ptable.lock, "ptable");
80103985:	83 ec 08             	sub    $0x8,%esp
80103988:	68 70 a3 10 80       	push   $0x8010a370
8010398d:	68 00 42 19 80       	push   $0x80194200
80103992:	e8 50 0d 00 00       	call   801046e7 <initlock>
80103997:	83 c4 10             	add    $0x10,%esp
}
8010399a:	90                   	nop
8010399b:	c9                   	leave  
8010399c:	c3                   	ret    

8010399d <cpuid>:

// Must be called with interrupts disabled
int
cpuid() {
8010399d:	55                   	push   %ebp
8010399e:	89 e5                	mov    %esp,%ebp
801039a0:	83 ec 08             	sub    $0x8,%esp
  return mycpu()-cpus;
801039a3:	e8 10 00 00 00       	call   801039b8 <mycpu>
801039a8:	2d 80 6b 19 80       	sub    $0x80196b80,%eax
801039ad:	c1 f8 04             	sar    $0x4,%eax
801039b0:	69 c0 a3 8b 2e ba    	imul   $0xba2e8ba3,%eax,%eax
}
801039b6:	c9                   	leave  
801039b7:	c3                   	ret    

801039b8 <mycpu>:

// Must be called with interrupts disabled to avoid the caller being
// rescheduled between reading lapicid and running through the loop.
struct cpu*
mycpu(void)
{
801039b8:	55                   	push   %ebp
801039b9:	89 e5                	mov    %esp,%ebp
801039bb:	83 ec 18             	sub    $0x18,%esp
  int apicid, i;
  
  if(readeflags()&FL_IF){
801039be:	e8 a5 ff ff ff       	call   80103968 <readeflags>
801039c3:	25 00 02 00 00       	and    $0x200,%eax
801039c8:	85 c0                	test   %eax,%eax
801039ca:	74 0d                	je     801039d9 <mycpu+0x21>
    panic("mycpu called with interrupts enabled\n");
801039cc:	83 ec 0c             	sub    $0xc,%esp
801039cf:	68 78 a3 10 80       	push   $0x8010a378
801039d4:	e8 d0 cb ff ff       	call   801005a9 <panic>
  }

  apicid = lapicid();
801039d9:	e8 1c f1 ff ff       	call   80102afa <lapicid>
801039de:	89 45 f0             	mov    %eax,-0x10(%ebp)
  // APIC IDs are not guaranteed to be contiguous. Maybe we should have
  // a reverse map, or reserve a register to store &cpus[i].
  for (i = 0; i < ncpu; ++i) {
801039e1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801039e8:	eb 2d                	jmp    80103a17 <mycpu+0x5f>
    if (cpus[i].apicid == apicid){
801039ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
801039ed:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
801039f3:	05 80 6b 19 80       	add    $0x80196b80,%eax
801039f8:	0f b6 00             	movzbl (%eax),%eax
801039fb:	0f b6 c0             	movzbl %al,%eax
801039fe:	39 45 f0             	cmp    %eax,-0x10(%ebp)
80103a01:	75 10                	jne    80103a13 <mycpu+0x5b>
      return &cpus[i];
80103a03:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a06:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
80103a0c:	05 80 6b 19 80       	add    $0x80196b80,%eax
80103a11:	eb 1b                	jmp    80103a2e <mycpu+0x76>
  for (i = 0; i < ncpu; ++i) {
80103a13:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103a17:	a1 40 6e 19 80       	mov    0x80196e40,%eax
80103a1c:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103a1f:	7c c9                	jl     801039ea <mycpu+0x32>
    }
  }
  panic("unknown apicid\n");
80103a21:	83 ec 0c             	sub    $0xc,%esp
80103a24:	68 9e a3 10 80       	push   $0x8010a39e
80103a29:	e8 7b cb ff ff       	call   801005a9 <panic>
}
80103a2e:	c9                   	leave  
80103a2f:	c3                   	ret    

80103a30 <myproc>:

// Disable interrupts so that we are not rescheduled
// while reading proc from the cpu structure
struct proc*
myproc(void) {
80103a30:	55                   	push   %ebp
80103a31:	89 e5                	mov    %esp,%ebp
80103a33:	83 ec 18             	sub    $0x18,%esp
  struct cpu *c;
  struct proc *p;
  pushcli();
80103a36:	e8 39 0e 00 00       	call   80104874 <pushcli>
  c = mycpu();
80103a3b:	e8 78 ff ff ff       	call   801039b8 <mycpu>
80103a40:	89 45 f4             	mov    %eax,-0xc(%ebp)
  p = c->proc;
80103a43:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a46:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80103a4c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  popcli();
80103a4f:	e8 6d 0e 00 00       	call   801048c1 <popcli>
  return p;
80103a54:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80103a57:	c9                   	leave  
80103a58:	c3                   	ret    

80103a59 <allocproc>:
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
80103a59:	55                   	push   %ebp
80103a5a:	89 e5                	mov    %esp,%ebp
80103a5c:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
80103a5f:	83 ec 0c             	sub    $0xc,%esp
80103a62:	68 00 42 19 80       	push   $0x80194200
80103a67:	e8 9d 0c 00 00       	call   80104709 <acquire>
80103a6c:	83 c4 10             	add    $0x10,%esp

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80103a6f:	c7 45 f4 34 42 19 80 	movl   $0x80194234,-0xc(%ebp)
80103a76:	eb 11                	jmp    80103a89 <allocproc+0x30>
    if(p->state == UNUSED){
80103a78:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a7b:	8b 40 0c             	mov    0xc(%eax),%eax
80103a7e:	85 c0                	test   %eax,%eax
80103a80:	74 2a                	je     80103aac <allocproc+0x53>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80103a82:	81 45 f4 84 00 00 00 	addl   $0x84,-0xc(%ebp)
80103a89:	81 7d f4 34 63 19 80 	cmpl   $0x80196334,-0xc(%ebp)
80103a90:	72 e6                	jb     80103a78 <allocproc+0x1f>
      goto found;
    }

  release(&ptable.lock);
80103a92:	83 ec 0c             	sub    $0xc,%esp
80103a95:	68 00 42 19 80       	push   $0x80194200
80103a9a:	e8 d8 0c 00 00       	call   80104777 <release>
80103a9f:	83 c4 10             	add    $0x10,%esp
  return 0;
80103aa2:	b8 00 00 00 00       	mov    $0x0,%eax
80103aa7:	e9 b2 00 00 00       	jmp    80103b5e <allocproc+0x105>
      goto found;
80103aac:	90                   	nop

found:
  p->state = EMBRYO;
80103aad:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ab0:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
  p->pid = nextpid++;
80103ab7:	a1 00 f0 10 80       	mov    0x8010f000,%eax
80103abc:	8d 50 01             	lea    0x1(%eax),%edx
80103abf:	89 15 00 f0 10 80    	mov    %edx,0x8010f000
80103ac5:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103ac8:	89 42 10             	mov    %eax,0x10(%edx)

  release(&ptable.lock);
80103acb:	83 ec 0c             	sub    $0xc,%esp
80103ace:	68 00 42 19 80       	push   $0x80194200
80103ad3:	e8 9f 0c 00 00       	call   80104777 <release>
80103ad8:	83 c4 10             	add    $0x10,%esp


  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
80103adb:	e8 c0 ec ff ff       	call   801027a0 <kalloc>
80103ae0:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103ae3:	89 42 08             	mov    %eax,0x8(%edx)
80103ae6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ae9:	8b 40 08             	mov    0x8(%eax),%eax
80103aec:	85 c0                	test   %eax,%eax
80103aee:	75 11                	jne    80103b01 <allocproc+0xa8>
    p->state = UNUSED;
80103af0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103af3:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return 0;
80103afa:	b8 00 00 00 00       	mov    $0x0,%eax
80103aff:	eb 5d                	jmp    80103b5e <allocproc+0x105>
  }
  sp = p->kstack + KSTACKSIZE;
80103b01:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b04:	8b 40 08             	mov    0x8(%eax),%eax
80103b07:	05 00 10 00 00       	add    $0x1000,%eax
80103b0c:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // Leave room for trap frame.
  sp -= sizeof *p->tf;
80103b0f:	83 6d f0 4c          	subl   $0x4c,-0x10(%ebp)
  p->tf = (struct trapframe*)sp;
80103b13:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b16:	8b 55 f0             	mov    -0x10(%ebp),%edx
80103b19:	89 50 18             	mov    %edx,0x18(%eax)

  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
80103b1c:	83 6d f0 04          	subl   $0x4,-0x10(%ebp)
  *(uint*)sp = (uint)trapret;
80103b20:	ba 8b 5d 10 80       	mov    $0x80105d8b,%edx
80103b25:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b28:	89 10                	mov    %edx,(%eax)

  sp -= sizeof *p->context;
80103b2a:	83 6d f0 14          	subl   $0x14,-0x10(%ebp)
  p->context = (struct context*)sp;
80103b2e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b31:	8b 55 f0             	mov    -0x10(%ebp),%edx
80103b34:	89 50 1c             	mov    %edx,0x1c(%eax)
  memset(p->context, 0, sizeof *p->context);
80103b37:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b3a:	8b 40 1c             	mov    0x1c(%eax),%eax
80103b3d:	83 ec 04             	sub    $0x4,%esp
80103b40:	6a 14                	push   $0x14
80103b42:	6a 00                	push   $0x0
80103b44:	50                   	push   %eax
80103b45:	e8 35 0e 00 00       	call   8010497f <memset>
80103b4a:	83 c4 10             	add    $0x10,%esp
  p->context->eip = (uint)forkret;
80103b4d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b50:	8b 40 1c             	mov    0x1c(%eax),%eax
80103b53:	ba 9f 42 10 80       	mov    $0x8010429f,%edx
80103b58:	89 50 10             	mov    %edx,0x10(%eax)

  return p;
80103b5b:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80103b5e:	c9                   	leave  
80103b5f:	c3                   	ret    

80103b60 <userinit>:

//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
80103b60:	55                   	push   %ebp
80103b61:	89 e5                	mov    %esp,%ebp
80103b63:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];

  p = allocproc();
80103b66:	e8 ee fe ff ff       	call   80103a59 <allocproc>
80103b6b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  initproc = p;
80103b6e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b71:	a3 34 63 19 80       	mov    %eax,0x80196334
  if((p->pgdir = setupkvm()) == 0){
80103b76:	e8 4e 38 00 00       	call   801073c9 <setupkvm>
80103b7b:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103b7e:	89 42 04             	mov    %eax,0x4(%edx)
80103b81:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b84:	8b 40 04             	mov    0x4(%eax),%eax
80103b87:	85 c0                	test   %eax,%eax
80103b89:	75 0d                	jne    80103b98 <userinit+0x38>
    panic("userinit: out of memory?");
80103b8b:	83 ec 0c             	sub    $0xc,%esp
80103b8e:	68 ae a3 10 80       	push   $0x8010a3ae
80103b93:	e8 11 ca ff ff       	call   801005a9 <panic>
  }
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
80103b98:	ba 2c 00 00 00       	mov    $0x2c,%edx
80103b9d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ba0:	8b 40 04             	mov    0x4(%eax),%eax
80103ba3:	83 ec 04             	sub    $0x4,%esp
80103ba6:	52                   	push   %edx
80103ba7:	68 ec f4 10 80       	push   $0x8010f4ec
80103bac:	50                   	push   %eax
80103bad:	e8 d3 3a 00 00       	call   80107685 <inituvm>
80103bb2:	83 c4 10             	add    $0x10,%esp
  p->sz = PGSIZE;
80103bb5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bb8:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  memset(p->tf, 0, sizeof(*p->tf));
80103bbe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bc1:	8b 40 18             	mov    0x18(%eax),%eax
80103bc4:	83 ec 04             	sub    $0x4,%esp
80103bc7:	6a 4c                	push   $0x4c
80103bc9:	6a 00                	push   $0x0
80103bcb:	50                   	push   %eax
80103bcc:	e8 ae 0d 00 00       	call   8010497f <memset>
80103bd1:	83 c4 10             	add    $0x10,%esp
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
80103bd4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bd7:	8b 40 18             	mov    0x18(%eax),%eax
80103bda:	66 c7 40 3c 1b 00    	movw   $0x1b,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
80103be0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103be3:	8b 40 18             	mov    0x18(%eax),%eax
80103be6:	66 c7 40 2c 23 00    	movw   $0x23,0x2c(%eax)
  p->tf->es = p->tf->ds;
80103bec:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bef:	8b 50 18             	mov    0x18(%eax),%edx
80103bf2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bf5:	8b 40 18             	mov    0x18(%eax),%eax
80103bf8:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80103bfc:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
80103c00:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c03:	8b 50 18             	mov    0x18(%eax),%edx
80103c06:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c09:	8b 40 18             	mov    0x18(%eax),%eax
80103c0c:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80103c10:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
80103c14:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c17:	8b 40 18             	mov    0x18(%eax),%eax
80103c1a:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
80103c21:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c24:	8b 40 18             	mov    0x18(%eax),%eax
80103c27:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
80103c2e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c31:	8b 40 18             	mov    0x18(%eax),%eax
80103c34:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

  safestrcpy(p->name, "initcode", sizeof(p->name));
80103c3b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c3e:	83 c0 6c             	add    $0x6c,%eax
80103c41:	83 ec 04             	sub    $0x4,%esp
80103c44:	6a 10                	push   $0x10
80103c46:	68 c7 a3 10 80       	push   $0x8010a3c7
80103c4b:	50                   	push   %eax
80103c4c:	e8 31 0f 00 00       	call   80104b82 <safestrcpy>
80103c51:	83 c4 10             	add    $0x10,%esp
  p->cwd = namei("/");
80103c54:	83 ec 0c             	sub    $0xc,%esp
80103c57:	68 d0 a3 10 80       	push   $0x8010a3d0
80103c5c:	e8 bc e8 ff ff       	call   8010251d <namei>
80103c61:	83 c4 10             	add    $0x10,%esp
80103c64:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103c67:	89 42 68             	mov    %eax,0x68(%edx)

  // this assignment to p->state lets other cores
  // run this process. the acquire forces the above
  // writes to be visible, and the lock is also needed
  // because the assignment might not be atomic.
  acquire(&ptable.lock);
80103c6a:	83 ec 0c             	sub    $0xc,%esp
80103c6d:	68 00 42 19 80       	push   $0x80194200
80103c72:	e8 92 0a 00 00       	call   80104709 <acquire>
80103c77:	83 c4 10             	add    $0x10,%esp

  p->state = RUNNABLE;
80103c7a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c7d:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  release(&ptable.lock);
80103c84:	83 ec 0c             	sub    $0xc,%esp
80103c87:	68 00 42 19 80       	push   $0x80194200
80103c8c:	e8 e6 0a 00 00       	call   80104777 <release>
80103c91:	83 c4 10             	add    $0x10,%esp
}
80103c94:	90                   	nop
80103c95:	c9                   	leave  
80103c96:	c3                   	ret    

80103c97 <growproc>:

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
80103c97:	55                   	push   %ebp
80103c98:	89 e5                	mov    %esp,%ebp
80103c9a:	83 ec 18             	sub    $0x18,%esp
  uint sz;
  struct proc *curproc = myproc();
80103c9d:	e8 8e fd ff ff       	call   80103a30 <myproc>
80103ca2:	89 45 f0             	mov    %eax,-0x10(%ebp)

  sz = curproc->sz;
80103ca5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103ca8:	8b 00                	mov    (%eax),%eax
80103caa:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(n > 0){
80103cad:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80103cb1:	7e 2e                	jle    80103ce1 <growproc+0x4a>
    if((sz = allocuvm(curproc->pgdir, sz, sz + n)) == 0)
80103cb3:	8b 55 08             	mov    0x8(%ebp),%edx
80103cb6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103cb9:	01 c2                	add    %eax,%edx
80103cbb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103cbe:	8b 40 04             	mov    0x4(%eax),%eax
80103cc1:	83 ec 04             	sub    $0x4,%esp
80103cc4:	52                   	push   %edx
80103cc5:	ff 75 f4             	push   -0xc(%ebp)
80103cc8:	50                   	push   %eax
80103cc9:	e8 f4 3a 00 00       	call   801077c2 <allocuvm>
80103cce:	83 c4 10             	add    $0x10,%esp
80103cd1:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103cd4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103cd8:	75 3b                	jne    80103d15 <growproc+0x7e>
      return -1;
80103cda:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103cdf:	eb 4f                	jmp    80103d30 <growproc+0x99>
  } else if(n < 0){
80103ce1:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80103ce5:	79 2e                	jns    80103d15 <growproc+0x7e>
    if((sz = deallocuvm(curproc->pgdir, sz, sz + n)) == 0)
80103ce7:	8b 55 08             	mov    0x8(%ebp),%edx
80103cea:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ced:	01 c2                	add    %eax,%edx
80103cef:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103cf2:	8b 40 04             	mov    0x4(%eax),%eax
80103cf5:	83 ec 04             	sub    $0x4,%esp
80103cf8:	52                   	push   %edx
80103cf9:	ff 75 f4             	push   -0xc(%ebp)
80103cfc:	50                   	push   %eax
80103cfd:	e8 c5 3b 00 00       	call   801078c7 <deallocuvm>
80103d02:	83 c4 10             	add    $0x10,%esp
80103d05:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103d08:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103d0c:	75 07                	jne    80103d15 <growproc+0x7e>
      return -1;
80103d0e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103d13:	eb 1b                	jmp    80103d30 <growproc+0x99>
  }
  curproc->sz = sz;
80103d15:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103d18:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103d1b:	89 10                	mov    %edx,(%eax)
  switchuvm(curproc);
80103d1d:	83 ec 0c             	sub    $0xc,%esp
80103d20:	ff 75 f0             	push   -0x10(%ebp)
80103d23:	e8 be 37 00 00       	call   801074e6 <switchuvm>
80103d28:	83 c4 10             	add    $0x10,%esp
  return 0;
80103d2b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103d30:	c9                   	leave  
80103d31:	c3                   	ret    

80103d32 <fork>:
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
80103d32:	55                   	push   %ebp
80103d33:	89 e5                	mov    %esp,%ebp
80103d35:	57                   	push   %edi
80103d36:	56                   	push   %esi
80103d37:	53                   	push   %ebx
80103d38:	83 ec 1c             	sub    $0x1c,%esp
  int i, pid;
  struct proc *np;
  struct proc *curproc = myproc();
80103d3b:	e8 f0 fc ff ff       	call   80103a30 <myproc>
80103d40:	89 45 e0             	mov    %eax,-0x20(%ebp)

  // Allocate process.
  if((np = allocproc()) == 0){
80103d43:	e8 11 fd ff ff       	call   80103a59 <allocproc>
80103d48:	89 45 dc             	mov    %eax,-0x24(%ebp)
80103d4b:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
80103d4f:	75 0a                	jne    80103d5b <fork+0x29>
    return -1;
80103d51:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103d56:	e9 48 01 00 00       	jmp    80103ea3 <fork+0x171>
  }

  // Copy process state from proc.
  if((np->pgdir = copyuvm(curproc->pgdir, curproc->sz)) == 0){
80103d5b:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103d5e:	8b 10                	mov    (%eax),%edx
80103d60:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103d63:	8b 40 04             	mov    0x4(%eax),%eax
80103d66:	83 ec 08             	sub    $0x8,%esp
80103d69:	52                   	push   %edx
80103d6a:	50                   	push   %eax
80103d6b:	e8 f5 3c 00 00       	call   80107a65 <copyuvm>
80103d70:	83 c4 10             	add    $0x10,%esp
80103d73:	8b 55 dc             	mov    -0x24(%ebp),%edx
80103d76:	89 42 04             	mov    %eax,0x4(%edx)
80103d79:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103d7c:	8b 40 04             	mov    0x4(%eax),%eax
80103d7f:	85 c0                	test   %eax,%eax
80103d81:	75 30                	jne    80103db3 <fork+0x81>
    kfree(np->kstack);
80103d83:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103d86:	8b 40 08             	mov    0x8(%eax),%eax
80103d89:	83 ec 0c             	sub    $0xc,%esp
80103d8c:	50                   	push   %eax
80103d8d:	e8 74 e9 ff ff       	call   80102706 <kfree>
80103d92:	83 c4 10             	add    $0x10,%esp
    np->kstack = 0;
80103d95:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103d98:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    np->state = UNUSED;
80103d9f:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103da2:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return -1;
80103da9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103dae:	e9 f0 00 00 00       	jmp    80103ea3 <fork+0x171>
  }
  np->sz = curproc->sz;
80103db3:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103db6:	8b 10                	mov    (%eax),%edx
80103db8:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103dbb:	89 10                	mov    %edx,(%eax)
  np->parent = curproc;
80103dbd:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103dc0:	8b 55 e0             	mov    -0x20(%ebp),%edx
80103dc3:	89 50 14             	mov    %edx,0x14(%eax)
  *np->tf = *curproc->tf;
80103dc6:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103dc9:	8b 48 18             	mov    0x18(%eax),%ecx
80103dcc:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103dcf:	8b 40 18             	mov    0x18(%eax),%eax
80103dd2:	89 c2                	mov    %eax,%edx
80103dd4:	89 cb                	mov    %ecx,%ebx
80103dd6:	b8 13 00 00 00       	mov    $0x13,%eax
80103ddb:	89 d7                	mov    %edx,%edi
80103ddd:	89 de                	mov    %ebx,%esi
80103ddf:	89 c1                	mov    %eax,%ecx
80103de1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
80103de3:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103de6:	8b 40 18             	mov    0x18(%eax),%eax
80103de9:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  for(i = 0; i < NOFILE; i++)
80103df0:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80103df7:	eb 3b                	jmp    80103e34 <fork+0x102>
    if(curproc->ofile[i])
80103df9:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103dfc:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80103dff:	83 c2 08             	add    $0x8,%edx
80103e02:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80103e06:	85 c0                	test   %eax,%eax
80103e08:	74 26                	je     80103e30 <fork+0xfe>
      np->ofile[i] = filedup(curproc->ofile[i]);
80103e0a:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103e0d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80103e10:	83 c2 08             	add    $0x8,%edx
80103e13:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80103e17:	83 ec 0c             	sub    $0xc,%esp
80103e1a:	50                   	push   %eax
80103e1b:	e8 2a d2 ff ff       	call   8010104a <filedup>
80103e20:	83 c4 10             	add    $0x10,%esp
80103e23:	8b 55 dc             	mov    -0x24(%ebp),%edx
80103e26:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
80103e29:	83 c1 08             	add    $0x8,%ecx
80103e2c:	89 44 8a 08          	mov    %eax,0x8(%edx,%ecx,4)
  for(i = 0; i < NOFILE; i++)
80103e30:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80103e34:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
80103e38:	7e bf                	jle    80103df9 <fork+0xc7>
  np->cwd = idup(curproc->cwd);
80103e3a:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103e3d:	8b 40 68             	mov    0x68(%eax),%eax
80103e40:	83 ec 0c             	sub    $0xc,%esp
80103e43:	50                   	push   %eax
80103e44:	e8 67 db ff ff       	call   801019b0 <idup>
80103e49:	83 c4 10             	add    $0x10,%esp
80103e4c:	8b 55 dc             	mov    -0x24(%ebp),%edx
80103e4f:	89 42 68             	mov    %eax,0x68(%edx)

  safestrcpy(np->name, curproc->name, sizeof(curproc->name));
80103e52:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103e55:	8d 50 6c             	lea    0x6c(%eax),%edx
80103e58:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103e5b:	83 c0 6c             	add    $0x6c,%eax
80103e5e:	83 ec 04             	sub    $0x4,%esp
80103e61:	6a 10                	push   $0x10
80103e63:	52                   	push   %edx
80103e64:	50                   	push   %eax
80103e65:	e8 18 0d 00 00       	call   80104b82 <safestrcpy>
80103e6a:	83 c4 10             	add    $0x10,%esp

  pid = np->pid;
80103e6d:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103e70:	8b 40 10             	mov    0x10(%eax),%eax
80103e73:	89 45 d8             	mov    %eax,-0x28(%ebp)

  acquire(&ptable.lock);
80103e76:	83 ec 0c             	sub    $0xc,%esp
80103e79:	68 00 42 19 80       	push   $0x80194200
80103e7e:	e8 86 08 00 00       	call   80104709 <acquire>
80103e83:	83 c4 10             	add    $0x10,%esp

  np->state = RUNNABLE;
80103e86:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103e89:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  release(&ptable.lock);
80103e90:	83 ec 0c             	sub    $0xc,%esp
80103e93:	68 00 42 19 80       	push   $0x80194200
80103e98:	e8 da 08 00 00       	call   80104777 <release>
80103e9d:	83 c4 10             	add    $0x10,%esp

  return pid;
80103ea0:	8b 45 d8             	mov    -0x28(%ebp),%eax
}
80103ea3:	8d 65 f4             	lea    -0xc(%ebp),%esp
80103ea6:	5b                   	pop    %ebx
80103ea7:	5e                   	pop    %esi
80103ea8:	5f                   	pop    %edi
80103ea9:	5d                   	pop    %ebp
80103eaa:	c3                   	ret    

80103eab <exit>:
// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
80103eab:	55                   	push   %ebp
80103eac:	89 e5                	mov    %esp,%ebp
80103eae:	83 ec 18             	sub    $0x18,%esp
  struct proc *curproc = myproc();
80103eb1:	e8 7a fb ff ff       	call   80103a30 <myproc>
80103eb6:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct proc *p;
  int fd;

  if(curproc == initproc)
80103eb9:	a1 34 63 19 80       	mov    0x80196334,%eax
80103ebe:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80103ec1:	75 0d                	jne    80103ed0 <exit+0x25>
    panic("init exiting");
80103ec3:	83 ec 0c             	sub    $0xc,%esp
80103ec6:	68 d2 a3 10 80       	push   $0x8010a3d2
80103ecb:	e8 d9 c6 ff ff       	call   801005a9 <panic>

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80103ed0:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80103ed7:	eb 3f                	jmp    80103f18 <exit+0x6d>
    if(curproc->ofile[fd]){
80103ed9:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103edc:	8b 55 f0             	mov    -0x10(%ebp),%edx
80103edf:	83 c2 08             	add    $0x8,%edx
80103ee2:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80103ee6:	85 c0                	test   %eax,%eax
80103ee8:	74 2a                	je     80103f14 <exit+0x69>
      fileclose(curproc->ofile[fd]);
80103eea:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103eed:	8b 55 f0             	mov    -0x10(%ebp),%edx
80103ef0:	83 c2 08             	add    $0x8,%edx
80103ef3:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80103ef7:	83 ec 0c             	sub    $0xc,%esp
80103efa:	50                   	push   %eax
80103efb:	e8 9b d1 ff ff       	call   8010109b <fileclose>
80103f00:	83 c4 10             	add    $0x10,%esp
      curproc->ofile[fd] = 0;
80103f03:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103f06:	8b 55 f0             	mov    -0x10(%ebp),%edx
80103f09:	83 c2 08             	add    $0x8,%edx
80103f0c:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80103f13:	00 
  for(fd = 0; fd < NOFILE; fd++){
80103f14:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80103f18:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
80103f1c:	7e bb                	jle    80103ed9 <exit+0x2e>
    }
  }

  begin_op();
80103f1e:	e8 19 f1 ff ff       	call   8010303c <begin_op>
  iput(curproc->cwd);
80103f23:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103f26:	8b 40 68             	mov    0x68(%eax),%eax
80103f29:	83 ec 0c             	sub    $0xc,%esp
80103f2c:	50                   	push   %eax
80103f2d:	e8 19 dc ff ff       	call   80101b4b <iput>
80103f32:	83 c4 10             	add    $0x10,%esp
  end_op();
80103f35:	e8 8e f1 ff ff       	call   801030c8 <end_op>
  curproc->cwd = 0;
80103f3a:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103f3d:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquire(&ptable.lock);
80103f44:	83 ec 0c             	sub    $0xc,%esp
80103f47:	68 00 42 19 80       	push   $0x80194200
80103f4c:	e8 b8 07 00 00       	call   80104709 <acquire>
80103f51:	83 c4 10             	add    $0x10,%esp

  // Parent might be sleeping in wait().
  wakeup1(curproc->parent);
80103f54:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103f57:	8b 40 14             	mov    0x14(%eax),%eax
80103f5a:	83 ec 0c             	sub    $0xc,%esp
80103f5d:	50                   	push   %eax
80103f5e:	e8 29 04 00 00       	call   8010438c <wakeup1>
80103f63:	83 c4 10             	add    $0x10,%esp

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103f66:	c7 45 f4 34 42 19 80 	movl   $0x80194234,-0xc(%ebp)
80103f6d:	eb 3a                	jmp    80103fa9 <exit+0xfe>
    if(p->parent == curproc){
80103f6f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f72:	8b 40 14             	mov    0x14(%eax),%eax
80103f75:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80103f78:	75 28                	jne    80103fa2 <exit+0xf7>
      p->parent = initproc;
80103f7a:	8b 15 34 63 19 80    	mov    0x80196334,%edx
80103f80:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f83:	89 50 14             	mov    %edx,0x14(%eax)
      if(p->state == ZOMBIE)
80103f86:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f89:	8b 40 0c             	mov    0xc(%eax),%eax
80103f8c:	83 f8 05             	cmp    $0x5,%eax
80103f8f:	75 11                	jne    80103fa2 <exit+0xf7>
        wakeup1(initproc);
80103f91:	a1 34 63 19 80       	mov    0x80196334,%eax
80103f96:	83 ec 0c             	sub    $0xc,%esp
80103f99:	50                   	push   %eax
80103f9a:	e8 ed 03 00 00       	call   8010438c <wakeup1>
80103f9f:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103fa2:	81 45 f4 84 00 00 00 	addl   $0x84,-0xc(%ebp)
80103fa9:	81 7d f4 34 63 19 80 	cmpl   $0x80196334,-0xc(%ebp)
80103fb0:	72 bd                	jb     80103f6f <exit+0xc4>
    }
  }

  // Jump into the scheduler, never to return.
  curproc->state = ZOMBIE;
80103fb2:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103fb5:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  sched();
80103fbc:	e8 eb 01 00 00       	call   801041ac <sched>
  panic("zombie exit");
80103fc1:	83 ec 0c             	sub    $0xc,%esp
80103fc4:	68 df a3 10 80       	push   $0x8010a3df
80103fc9:	e8 db c5 ff ff       	call   801005a9 <panic>

80103fce <wait>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
80103fce:	55                   	push   %ebp
80103fcf:	89 e5                	mov    %esp,%ebp
80103fd1:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int havekids, pid;
  struct proc *curproc = myproc();
80103fd4:	e8 57 fa ff ff       	call   80103a30 <myproc>
80103fd9:	89 45 ec             	mov    %eax,-0x14(%ebp)
  
  acquire(&ptable.lock);
80103fdc:	83 ec 0c             	sub    $0xc,%esp
80103fdf:	68 00 42 19 80       	push   $0x80194200
80103fe4:	e8 20 07 00 00       	call   80104709 <acquire>
80103fe9:	83 c4 10             	add    $0x10,%esp
  for(;;){
    // Scan through table looking for exited children.
    havekids = 0;
80103fec:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103ff3:	c7 45 f4 34 42 19 80 	movl   $0x80194234,-0xc(%ebp)
80103ffa:	e9 a4 00 00 00       	jmp    801040a3 <wait+0xd5>
      if(p->parent != curproc)
80103fff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104002:	8b 40 14             	mov    0x14(%eax),%eax
80104005:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80104008:	0f 85 8d 00 00 00    	jne    8010409b <wait+0xcd>
        continue;
      havekids = 1;
8010400e:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
80104015:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104018:	8b 40 0c             	mov    0xc(%eax),%eax
8010401b:	83 f8 05             	cmp    $0x5,%eax
8010401e:	75 7c                	jne    8010409c <wait+0xce>
        // Found one.
        pid = p->pid;
80104020:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104023:	8b 40 10             	mov    0x10(%eax),%eax
80104026:	89 45 e8             	mov    %eax,-0x18(%ebp)
        kfree(p->kstack);
80104029:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010402c:	8b 40 08             	mov    0x8(%eax),%eax
8010402f:	83 ec 0c             	sub    $0xc,%esp
80104032:	50                   	push   %eax
80104033:	e8 ce e6 ff ff       	call   80102706 <kfree>
80104038:	83 c4 10             	add    $0x10,%esp
        p->kstack = 0;
8010403b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010403e:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
80104045:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104048:	8b 40 04             	mov    0x4(%eax),%eax
8010404b:	83 ec 0c             	sub    $0xc,%esp
8010404e:	50                   	push   %eax
8010404f:	e8 37 39 00 00       	call   8010798b <freevm>
80104054:	83 c4 10             	add    $0x10,%esp
        p->pid = 0;
80104057:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010405a:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
80104061:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104064:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
8010406b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010406e:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
80104072:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104075:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        p->state = UNUSED;
8010407c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010407f:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        release(&ptable.lock);
80104086:	83 ec 0c             	sub    $0xc,%esp
80104089:	68 00 42 19 80       	push   $0x80194200
8010408e:	e8 e4 06 00 00       	call   80104777 <release>
80104093:	83 c4 10             	add    $0x10,%esp
        return pid;
80104096:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104099:	eb 54                	jmp    801040ef <wait+0x121>
        continue;
8010409b:	90                   	nop
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010409c:	81 45 f4 84 00 00 00 	addl   $0x84,-0xc(%ebp)
801040a3:	81 7d f4 34 63 19 80 	cmpl   $0x80196334,-0xc(%ebp)
801040aa:	0f 82 4f ff ff ff    	jb     80103fff <wait+0x31>
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || curproc->killed){
801040b0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801040b4:	74 0a                	je     801040c0 <wait+0xf2>
801040b6:	8b 45 ec             	mov    -0x14(%ebp),%eax
801040b9:	8b 40 24             	mov    0x24(%eax),%eax
801040bc:	85 c0                	test   %eax,%eax
801040be:	74 17                	je     801040d7 <wait+0x109>
      release(&ptable.lock);
801040c0:	83 ec 0c             	sub    $0xc,%esp
801040c3:	68 00 42 19 80       	push   $0x80194200
801040c8:	e8 aa 06 00 00       	call   80104777 <release>
801040cd:	83 c4 10             	add    $0x10,%esp
      return -1;
801040d0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801040d5:	eb 18                	jmp    801040ef <wait+0x121>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(curproc, &ptable.lock);  //DOC: wait-sleep
801040d7:	83 ec 08             	sub    $0x8,%esp
801040da:	68 00 42 19 80       	push   $0x80194200
801040df:	ff 75 ec             	push   -0x14(%ebp)
801040e2:	e8 fe 01 00 00       	call   801042e5 <sleep>
801040e7:	83 c4 10             	add    $0x10,%esp
    havekids = 0;
801040ea:	e9 fd fe ff ff       	jmp    80103fec <wait+0x1e>
  }
}
801040ef:	c9                   	leave  
801040f0:	c3                   	ret    

801040f1 <scheduler>:
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
801040f1:	55                   	push   %ebp
801040f2:	89 e5                	mov    %esp,%ebp
801040f4:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  struct cpu *c = mycpu();
801040f7:	e8 bc f8 ff ff       	call   801039b8 <mycpu>
801040fc:	89 45 f0             	mov    %eax,-0x10(%ebp)
  c->proc = 0;
801040ff:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104102:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
80104109:	00 00 00 
  
  for(;;){
    // Enable interrupts on this processor.
    sti();
8010410c:	e8 67 f8 ff ff       	call   80103978 <sti>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
80104111:	83 ec 0c             	sub    $0xc,%esp
80104114:	68 00 42 19 80       	push   $0x80194200
80104119:	e8 eb 05 00 00       	call   80104709 <acquire>
8010411e:	83 c4 10             	add    $0x10,%esp
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104121:	c7 45 f4 34 42 19 80 	movl   $0x80194234,-0xc(%ebp)
80104128:	eb 64                	jmp    8010418e <scheduler+0x9d>
      if(p->state != RUNNABLE)
8010412a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010412d:	8b 40 0c             	mov    0xc(%eax),%eax
80104130:	83 f8 03             	cmp    $0x3,%eax
80104133:	75 51                	jne    80104186 <scheduler+0x95>
        continue;

      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      c->proc = p;
80104135:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104138:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010413b:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
      switchuvm(p);
80104141:	83 ec 0c             	sub    $0xc,%esp
80104144:	ff 75 f4             	push   -0xc(%ebp)
80104147:	e8 9a 33 00 00       	call   801074e6 <switchuvm>
8010414c:	83 c4 10             	add    $0x10,%esp
      p->state = RUNNING;
8010414f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104152:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)

      swtch(&(c->scheduler), p->context);
80104159:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010415c:	8b 40 1c             	mov    0x1c(%eax),%eax
8010415f:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104162:	83 c2 04             	add    $0x4,%edx
80104165:	83 ec 08             	sub    $0x8,%esp
80104168:	50                   	push   %eax
80104169:	52                   	push   %edx
8010416a:	e8 85 0a 00 00       	call   80104bf4 <swtch>
8010416f:	83 c4 10             	add    $0x10,%esp
      switchkvm();
80104172:	e8 56 33 00 00       	call   801074cd <switchkvm>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      c->proc = 0;
80104177:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010417a:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
80104181:	00 00 00 
80104184:	eb 01                	jmp    80104187 <scheduler+0x96>
        continue;
80104186:	90                   	nop
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104187:	81 45 f4 84 00 00 00 	addl   $0x84,-0xc(%ebp)
8010418e:	81 7d f4 34 63 19 80 	cmpl   $0x80196334,-0xc(%ebp)
80104195:	72 93                	jb     8010412a <scheduler+0x39>
    }
    release(&ptable.lock);
80104197:	83 ec 0c             	sub    $0xc,%esp
8010419a:	68 00 42 19 80       	push   $0x80194200
8010419f:	e8 d3 05 00 00       	call   80104777 <release>
801041a4:	83 c4 10             	add    $0x10,%esp
    sti();
801041a7:	e9 60 ff ff ff       	jmp    8010410c <scheduler+0x1b>

801041ac <sched>:
// be proc->intena and proc->ncli, but that would
// break in the few places where a lock is held but
// there's no process.
void
sched(void)
{
801041ac:	55                   	push   %ebp
801041ad:	89 e5                	mov    %esp,%ebp
801041af:	83 ec 18             	sub    $0x18,%esp
  int intena;
  struct proc *p = myproc();
801041b2:	e8 79 f8 ff ff       	call   80103a30 <myproc>
801041b7:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(!holding(&ptable.lock))
801041ba:	83 ec 0c             	sub    $0xc,%esp
801041bd:	68 00 42 19 80       	push   $0x80194200
801041c2:	e8 7d 06 00 00       	call   80104844 <holding>
801041c7:	83 c4 10             	add    $0x10,%esp
801041ca:	85 c0                	test   %eax,%eax
801041cc:	75 0d                	jne    801041db <sched+0x2f>
    panic("sched ptable.lock");
801041ce:	83 ec 0c             	sub    $0xc,%esp
801041d1:	68 eb a3 10 80       	push   $0x8010a3eb
801041d6:	e8 ce c3 ff ff       	call   801005a9 <panic>
  if(mycpu()->ncli != 1)
801041db:	e8 d8 f7 ff ff       	call   801039b8 <mycpu>
801041e0:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
801041e6:	83 f8 01             	cmp    $0x1,%eax
801041e9:	74 0d                	je     801041f8 <sched+0x4c>
    panic("sched locks");
801041eb:	83 ec 0c             	sub    $0xc,%esp
801041ee:	68 fd a3 10 80       	push   $0x8010a3fd
801041f3:	e8 b1 c3 ff ff       	call   801005a9 <panic>
  if(p->state == RUNNING)
801041f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041fb:	8b 40 0c             	mov    0xc(%eax),%eax
801041fe:	83 f8 04             	cmp    $0x4,%eax
80104201:	75 0d                	jne    80104210 <sched+0x64>
    panic("sched running");
80104203:	83 ec 0c             	sub    $0xc,%esp
80104206:	68 09 a4 10 80       	push   $0x8010a409
8010420b:	e8 99 c3 ff ff       	call   801005a9 <panic>
  if(readeflags()&FL_IF)
80104210:	e8 53 f7 ff ff       	call   80103968 <readeflags>
80104215:	25 00 02 00 00       	and    $0x200,%eax
8010421a:	85 c0                	test   %eax,%eax
8010421c:	74 0d                	je     8010422b <sched+0x7f>
    panic("sched interruptible");
8010421e:	83 ec 0c             	sub    $0xc,%esp
80104221:	68 17 a4 10 80       	push   $0x8010a417
80104226:	e8 7e c3 ff ff       	call   801005a9 <panic>
  intena = mycpu()->intena;
8010422b:	e8 88 f7 ff ff       	call   801039b8 <mycpu>
80104230:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
80104236:	89 45 f0             	mov    %eax,-0x10(%ebp)
  swtch(&p->context, mycpu()->scheduler);
80104239:	e8 7a f7 ff ff       	call   801039b8 <mycpu>
8010423e:	8b 40 04             	mov    0x4(%eax),%eax
80104241:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104244:	83 c2 1c             	add    $0x1c,%edx
80104247:	83 ec 08             	sub    $0x8,%esp
8010424a:	50                   	push   %eax
8010424b:	52                   	push   %edx
8010424c:	e8 a3 09 00 00       	call   80104bf4 <swtch>
80104251:	83 c4 10             	add    $0x10,%esp
  mycpu()->intena = intena;
80104254:	e8 5f f7 ff ff       	call   801039b8 <mycpu>
80104259:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010425c:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
}
80104262:	90                   	nop
80104263:	c9                   	leave  
80104264:	c3                   	ret    

80104265 <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
80104265:	55                   	push   %ebp
80104266:	89 e5                	mov    %esp,%ebp
80104268:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
8010426b:	83 ec 0c             	sub    $0xc,%esp
8010426e:	68 00 42 19 80       	push   $0x80194200
80104273:	e8 91 04 00 00       	call   80104709 <acquire>
80104278:	83 c4 10             	add    $0x10,%esp
  myproc()->state = RUNNABLE;
8010427b:	e8 b0 f7 ff ff       	call   80103a30 <myproc>
80104280:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
80104287:	e8 20 ff ff ff       	call   801041ac <sched>
  release(&ptable.lock);
8010428c:	83 ec 0c             	sub    $0xc,%esp
8010428f:	68 00 42 19 80       	push   $0x80194200
80104294:	e8 de 04 00 00       	call   80104777 <release>
80104299:	83 c4 10             	add    $0x10,%esp
}
8010429c:	90                   	nop
8010429d:	c9                   	leave  
8010429e:	c3                   	ret    

8010429f <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
8010429f:	55                   	push   %ebp
801042a0:	89 e5                	mov    %esp,%ebp
801042a2:	83 ec 08             	sub    $0x8,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
801042a5:	83 ec 0c             	sub    $0xc,%esp
801042a8:	68 00 42 19 80       	push   $0x80194200
801042ad:	e8 c5 04 00 00       	call   80104777 <release>
801042b2:	83 c4 10             	add    $0x10,%esp

  if (first) {
801042b5:	a1 04 f0 10 80       	mov    0x8010f004,%eax
801042ba:	85 c0                	test   %eax,%eax
801042bc:	74 24                	je     801042e2 <forkret+0x43>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot
    // be run from main().
    first = 0;
801042be:	c7 05 04 f0 10 80 00 	movl   $0x0,0x8010f004
801042c5:	00 00 00 
    iinit(ROOTDEV);
801042c8:	83 ec 0c             	sub    $0xc,%esp
801042cb:	6a 01                	push   $0x1
801042cd:	e8 a6 d3 ff ff       	call   80101678 <iinit>
801042d2:	83 c4 10             	add    $0x10,%esp
    initlog(ROOTDEV);
801042d5:	83 ec 0c             	sub    $0xc,%esp
801042d8:	6a 01                	push   $0x1
801042da:	e8 3e eb ff ff       	call   80102e1d <initlog>
801042df:	83 c4 10             	add    $0x10,%esp
  }

  // Return to "caller", actually trapret (see allocproc).
}
801042e2:	90                   	nop
801042e3:	c9                   	leave  
801042e4:	c3                   	ret    

801042e5 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
801042e5:	55                   	push   %ebp
801042e6:	89 e5                	mov    %esp,%ebp
801042e8:	83 ec 18             	sub    $0x18,%esp
  struct proc *p = myproc();
801042eb:	e8 40 f7 ff ff       	call   80103a30 <myproc>
801042f0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  if(p == 0)
801042f3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801042f7:	75 0d                	jne    80104306 <sleep+0x21>
    panic("sleep");
801042f9:	83 ec 0c             	sub    $0xc,%esp
801042fc:	68 2b a4 10 80       	push   $0x8010a42b
80104301:	e8 a3 c2 ff ff       	call   801005a9 <panic>

  if(lk == 0)
80104306:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
8010430a:	75 0d                	jne    80104319 <sleep+0x34>
    panic("sleep without lk");
8010430c:	83 ec 0c             	sub    $0xc,%esp
8010430f:	68 31 a4 10 80       	push   $0x8010a431
80104314:	e8 90 c2 ff ff       	call   801005a9 <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
80104319:	81 7d 0c 00 42 19 80 	cmpl   $0x80194200,0xc(%ebp)
80104320:	74 1e                	je     80104340 <sleep+0x5b>
    acquire(&ptable.lock);  //DOC: sleeplock1
80104322:	83 ec 0c             	sub    $0xc,%esp
80104325:	68 00 42 19 80       	push   $0x80194200
8010432a:	e8 da 03 00 00       	call   80104709 <acquire>
8010432f:	83 c4 10             	add    $0x10,%esp
    release(lk);
80104332:	83 ec 0c             	sub    $0xc,%esp
80104335:	ff 75 0c             	push   0xc(%ebp)
80104338:	e8 3a 04 00 00       	call   80104777 <release>
8010433d:	83 c4 10             	add    $0x10,%esp
  }
  // Go to sleep.
  p->chan = chan;
80104340:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104343:	8b 55 08             	mov    0x8(%ebp),%edx
80104346:	89 50 20             	mov    %edx,0x20(%eax)
  p->state = SLEEPING;
80104349:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010434c:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)

  sched();
80104353:	e8 54 fe ff ff       	call   801041ac <sched>

  // Tidy up.
  p->chan = 0;
80104358:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010435b:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
80104362:	81 7d 0c 00 42 19 80 	cmpl   $0x80194200,0xc(%ebp)
80104369:	74 1e                	je     80104389 <sleep+0xa4>
    release(&ptable.lock);
8010436b:	83 ec 0c             	sub    $0xc,%esp
8010436e:	68 00 42 19 80       	push   $0x80194200
80104373:	e8 ff 03 00 00       	call   80104777 <release>
80104378:	83 c4 10             	add    $0x10,%esp
    acquire(lk);
8010437b:	83 ec 0c             	sub    $0xc,%esp
8010437e:	ff 75 0c             	push   0xc(%ebp)
80104381:	e8 83 03 00 00       	call   80104709 <acquire>
80104386:	83 c4 10             	add    $0x10,%esp
  }
}
80104389:	90                   	nop
8010438a:	c9                   	leave  
8010438b:	c3                   	ret    

8010438c <wakeup1>:
//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
8010438c:	55                   	push   %ebp
8010438d:	89 e5                	mov    %esp,%ebp
8010438f:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104392:	c7 45 fc 34 42 19 80 	movl   $0x80194234,-0x4(%ebp)
80104399:	eb 27                	jmp    801043c2 <wakeup1+0x36>
    if(p->state == SLEEPING && p->chan == chan)
8010439b:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010439e:	8b 40 0c             	mov    0xc(%eax),%eax
801043a1:	83 f8 02             	cmp    $0x2,%eax
801043a4:	75 15                	jne    801043bb <wakeup1+0x2f>
801043a6:	8b 45 fc             	mov    -0x4(%ebp),%eax
801043a9:	8b 40 20             	mov    0x20(%eax),%eax
801043ac:	39 45 08             	cmp    %eax,0x8(%ebp)
801043af:	75 0a                	jne    801043bb <wakeup1+0x2f>
      p->state = RUNNABLE;
801043b1:	8b 45 fc             	mov    -0x4(%ebp),%eax
801043b4:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801043bb:	81 45 fc 84 00 00 00 	addl   $0x84,-0x4(%ebp)
801043c2:	81 7d fc 34 63 19 80 	cmpl   $0x80196334,-0x4(%ebp)
801043c9:	72 d0                	jb     8010439b <wakeup1+0xf>
}
801043cb:	90                   	nop
801043cc:	90                   	nop
801043cd:	c9                   	leave  
801043ce:	c3                   	ret    

801043cf <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
801043cf:	55                   	push   %ebp
801043d0:	89 e5                	mov    %esp,%ebp
801043d2:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);
801043d5:	83 ec 0c             	sub    $0xc,%esp
801043d8:	68 00 42 19 80       	push   $0x80194200
801043dd:	e8 27 03 00 00       	call   80104709 <acquire>
801043e2:	83 c4 10             	add    $0x10,%esp
  wakeup1(chan);
801043e5:	83 ec 0c             	sub    $0xc,%esp
801043e8:	ff 75 08             	push   0x8(%ebp)
801043eb:	e8 9c ff ff ff       	call   8010438c <wakeup1>
801043f0:	83 c4 10             	add    $0x10,%esp
  release(&ptable.lock);
801043f3:	83 ec 0c             	sub    $0xc,%esp
801043f6:	68 00 42 19 80       	push   $0x80194200
801043fb:	e8 77 03 00 00       	call   80104777 <release>
80104400:	83 c4 10             	add    $0x10,%esp
}
80104403:	90                   	nop
80104404:	c9                   	leave  
80104405:	c3                   	ret    

80104406 <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
80104406:	55                   	push   %ebp
80104407:	89 e5                	mov    %esp,%ebp
80104409:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;

  acquire(&ptable.lock);
8010440c:	83 ec 0c             	sub    $0xc,%esp
8010440f:	68 00 42 19 80       	push   $0x80194200
80104414:	e8 f0 02 00 00       	call   80104709 <acquire>
80104419:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010441c:	c7 45 f4 34 42 19 80 	movl   $0x80194234,-0xc(%ebp)
80104423:	eb 48                	jmp    8010446d <kill+0x67>
    if(p->pid == pid){
80104425:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104428:	8b 40 10             	mov    0x10(%eax),%eax
8010442b:	39 45 08             	cmp    %eax,0x8(%ebp)
8010442e:	75 36                	jne    80104466 <kill+0x60>
      p->killed = 1;
80104430:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104433:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
8010443a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010443d:	8b 40 0c             	mov    0xc(%eax),%eax
80104440:	83 f8 02             	cmp    $0x2,%eax
80104443:	75 0a                	jne    8010444f <kill+0x49>
        p->state = RUNNABLE;
80104445:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104448:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      release(&ptable.lock);
8010444f:	83 ec 0c             	sub    $0xc,%esp
80104452:	68 00 42 19 80       	push   $0x80194200
80104457:	e8 1b 03 00 00       	call   80104777 <release>
8010445c:	83 c4 10             	add    $0x10,%esp
      return 0;
8010445f:	b8 00 00 00 00       	mov    $0x0,%eax
80104464:	eb 25                	jmp    8010448b <kill+0x85>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104466:	81 45 f4 84 00 00 00 	addl   $0x84,-0xc(%ebp)
8010446d:	81 7d f4 34 63 19 80 	cmpl   $0x80196334,-0xc(%ebp)
80104474:	72 af                	jb     80104425 <kill+0x1f>
    }
  }
  release(&ptable.lock);
80104476:	83 ec 0c             	sub    $0xc,%esp
80104479:	68 00 42 19 80       	push   $0x80194200
8010447e:	e8 f4 02 00 00       	call   80104777 <release>
80104483:	83 c4 10             	add    $0x10,%esp
  return -1;
80104486:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010448b:	c9                   	leave  
8010448c:	c3                   	ret    

8010448d <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
8010448d:	55                   	push   %ebp
8010448e:	89 e5                	mov    %esp,%ebp
80104490:	83 ec 48             	sub    $0x48,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104493:	c7 45 f0 34 42 19 80 	movl   $0x80194234,-0x10(%ebp)
8010449a:	e9 da 00 00 00       	jmp    80104579 <procdump+0xec>
    if(p->state == UNUSED)
8010449f:	8b 45 f0             	mov    -0x10(%ebp),%eax
801044a2:	8b 40 0c             	mov    0xc(%eax),%eax
801044a5:	85 c0                	test   %eax,%eax
801044a7:	0f 84 c4 00 00 00    	je     80104571 <procdump+0xe4>
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
801044ad:	8b 45 f0             	mov    -0x10(%ebp),%eax
801044b0:	8b 40 0c             	mov    0xc(%eax),%eax
801044b3:	83 f8 05             	cmp    $0x5,%eax
801044b6:	77 23                	ja     801044db <procdump+0x4e>
801044b8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801044bb:	8b 40 0c             	mov    0xc(%eax),%eax
801044be:	8b 04 85 08 f0 10 80 	mov    -0x7fef0ff8(,%eax,4),%eax
801044c5:	85 c0                	test   %eax,%eax
801044c7:	74 12                	je     801044db <procdump+0x4e>
      state = states[p->state];
801044c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801044cc:	8b 40 0c             	mov    0xc(%eax),%eax
801044cf:	8b 04 85 08 f0 10 80 	mov    -0x7fef0ff8(,%eax,4),%eax
801044d6:	89 45 ec             	mov    %eax,-0x14(%ebp)
801044d9:	eb 07                	jmp    801044e2 <procdump+0x55>
    else
      state = "???";
801044db:	c7 45 ec 42 a4 10 80 	movl   $0x8010a442,-0x14(%ebp)
    cprintf("%d %s %s", p->pid, state, p->name);
801044e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801044e5:	8d 50 6c             	lea    0x6c(%eax),%edx
801044e8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801044eb:	8b 40 10             	mov    0x10(%eax),%eax
801044ee:	52                   	push   %edx
801044ef:	ff 75 ec             	push   -0x14(%ebp)
801044f2:	50                   	push   %eax
801044f3:	68 46 a4 10 80       	push   $0x8010a446
801044f8:	e8 f7 be ff ff       	call   801003f4 <cprintf>
801044fd:	83 c4 10             	add    $0x10,%esp
    if(p->state == SLEEPING){
80104500:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104503:	8b 40 0c             	mov    0xc(%eax),%eax
80104506:	83 f8 02             	cmp    $0x2,%eax
80104509:	75 54                	jne    8010455f <procdump+0xd2>
      getcallerpcs((uint*)p->context->ebp+2, pc);
8010450b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010450e:	8b 40 1c             	mov    0x1c(%eax),%eax
80104511:	8b 40 0c             	mov    0xc(%eax),%eax
80104514:	83 c0 08             	add    $0x8,%eax
80104517:	89 c2                	mov    %eax,%edx
80104519:	83 ec 08             	sub    $0x8,%esp
8010451c:	8d 45 c4             	lea    -0x3c(%ebp),%eax
8010451f:	50                   	push   %eax
80104520:	52                   	push   %edx
80104521:	e8 a3 02 00 00       	call   801047c9 <getcallerpcs>
80104526:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
80104529:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104530:	eb 1c                	jmp    8010454e <procdump+0xc1>
        cprintf(" %p", pc[i]);
80104532:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104535:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80104539:	83 ec 08             	sub    $0x8,%esp
8010453c:	50                   	push   %eax
8010453d:	68 4f a4 10 80       	push   $0x8010a44f
80104542:	e8 ad be ff ff       	call   801003f4 <cprintf>
80104547:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
8010454a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010454e:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
80104552:	7f 0b                	jg     8010455f <procdump+0xd2>
80104554:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104557:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
8010455b:	85 c0                	test   %eax,%eax
8010455d:	75 d3                	jne    80104532 <procdump+0xa5>
    }
    cprintf("\n");
8010455f:	83 ec 0c             	sub    $0xc,%esp
80104562:	68 53 a4 10 80       	push   $0x8010a453
80104567:	e8 88 be ff ff       	call   801003f4 <cprintf>
8010456c:	83 c4 10             	add    $0x10,%esp
8010456f:	eb 01                	jmp    80104572 <procdump+0xe5>
      continue;
80104571:	90                   	nop
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104572:	81 45 f0 84 00 00 00 	addl   $0x84,-0x10(%ebp)
80104579:	81 7d f0 34 63 19 80 	cmpl   $0x80196334,-0x10(%ebp)
80104580:	0f 82 19 ff ff ff    	jb     8010449f <procdump+0x12>
  }
}
80104586:	90                   	nop
80104587:	90                   	nop
80104588:	c9                   	leave  
80104589:	c3                   	ret    

8010458a <initsleeplock>:
#include "spinlock.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
8010458a:	55                   	push   %ebp
8010458b:	89 e5                	mov    %esp,%ebp
8010458d:	83 ec 08             	sub    $0x8,%esp
  initlock(&lk->lk, "sleep lock");
80104590:	8b 45 08             	mov    0x8(%ebp),%eax
80104593:	83 c0 04             	add    $0x4,%eax
80104596:	83 ec 08             	sub    $0x8,%esp
80104599:	68 7f a4 10 80       	push   $0x8010a47f
8010459e:	50                   	push   %eax
8010459f:	e8 43 01 00 00       	call   801046e7 <initlock>
801045a4:	83 c4 10             	add    $0x10,%esp
  lk->name = name;
801045a7:	8b 45 08             	mov    0x8(%ebp),%eax
801045aa:	8b 55 0c             	mov    0xc(%ebp),%edx
801045ad:	89 50 38             	mov    %edx,0x38(%eax)
  lk->locked = 0;
801045b0:	8b 45 08             	mov    0x8(%ebp),%eax
801045b3:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
801045b9:	8b 45 08             	mov    0x8(%ebp),%eax
801045bc:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
}
801045c3:	90                   	nop
801045c4:	c9                   	leave  
801045c5:	c3                   	ret    

801045c6 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
801045c6:	55                   	push   %ebp
801045c7:	89 e5                	mov    %esp,%ebp
801045c9:	83 ec 08             	sub    $0x8,%esp
  acquire(&lk->lk);
801045cc:	8b 45 08             	mov    0x8(%ebp),%eax
801045cf:	83 c0 04             	add    $0x4,%eax
801045d2:	83 ec 0c             	sub    $0xc,%esp
801045d5:	50                   	push   %eax
801045d6:	e8 2e 01 00 00       	call   80104709 <acquire>
801045db:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
801045de:	eb 15                	jmp    801045f5 <acquiresleep+0x2f>
    sleep(lk, &lk->lk);
801045e0:	8b 45 08             	mov    0x8(%ebp),%eax
801045e3:	83 c0 04             	add    $0x4,%eax
801045e6:	83 ec 08             	sub    $0x8,%esp
801045e9:	50                   	push   %eax
801045ea:	ff 75 08             	push   0x8(%ebp)
801045ed:	e8 f3 fc ff ff       	call   801042e5 <sleep>
801045f2:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
801045f5:	8b 45 08             	mov    0x8(%ebp),%eax
801045f8:	8b 00                	mov    (%eax),%eax
801045fa:	85 c0                	test   %eax,%eax
801045fc:	75 e2                	jne    801045e0 <acquiresleep+0x1a>
  }
  lk->locked = 1;
801045fe:	8b 45 08             	mov    0x8(%ebp),%eax
80104601:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  lk->pid = myproc()->pid;
80104607:	e8 24 f4 ff ff       	call   80103a30 <myproc>
8010460c:	8b 50 10             	mov    0x10(%eax),%edx
8010460f:	8b 45 08             	mov    0x8(%ebp),%eax
80104612:	89 50 3c             	mov    %edx,0x3c(%eax)
  release(&lk->lk);
80104615:	8b 45 08             	mov    0x8(%ebp),%eax
80104618:	83 c0 04             	add    $0x4,%eax
8010461b:	83 ec 0c             	sub    $0xc,%esp
8010461e:	50                   	push   %eax
8010461f:	e8 53 01 00 00       	call   80104777 <release>
80104624:	83 c4 10             	add    $0x10,%esp
}
80104627:	90                   	nop
80104628:	c9                   	leave  
80104629:	c3                   	ret    

8010462a <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
8010462a:	55                   	push   %ebp
8010462b:	89 e5                	mov    %esp,%ebp
8010462d:	83 ec 08             	sub    $0x8,%esp
  acquire(&lk->lk);
80104630:	8b 45 08             	mov    0x8(%ebp),%eax
80104633:	83 c0 04             	add    $0x4,%eax
80104636:	83 ec 0c             	sub    $0xc,%esp
80104639:	50                   	push   %eax
8010463a:	e8 ca 00 00 00       	call   80104709 <acquire>
8010463f:	83 c4 10             	add    $0x10,%esp
  lk->locked = 0;
80104642:	8b 45 08             	mov    0x8(%ebp),%eax
80104645:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
8010464b:	8b 45 08             	mov    0x8(%ebp),%eax
8010464e:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
  wakeup(lk);
80104655:	83 ec 0c             	sub    $0xc,%esp
80104658:	ff 75 08             	push   0x8(%ebp)
8010465b:	e8 6f fd ff ff       	call   801043cf <wakeup>
80104660:	83 c4 10             	add    $0x10,%esp
  release(&lk->lk);
80104663:	8b 45 08             	mov    0x8(%ebp),%eax
80104666:	83 c0 04             	add    $0x4,%eax
80104669:	83 ec 0c             	sub    $0xc,%esp
8010466c:	50                   	push   %eax
8010466d:	e8 05 01 00 00       	call   80104777 <release>
80104672:	83 c4 10             	add    $0x10,%esp
}
80104675:	90                   	nop
80104676:	c9                   	leave  
80104677:	c3                   	ret    

80104678 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
80104678:	55                   	push   %ebp
80104679:	89 e5                	mov    %esp,%ebp
8010467b:	83 ec 18             	sub    $0x18,%esp
  int r;
  
  acquire(&lk->lk);
8010467e:	8b 45 08             	mov    0x8(%ebp),%eax
80104681:	83 c0 04             	add    $0x4,%eax
80104684:	83 ec 0c             	sub    $0xc,%esp
80104687:	50                   	push   %eax
80104688:	e8 7c 00 00 00       	call   80104709 <acquire>
8010468d:	83 c4 10             	add    $0x10,%esp
  r = lk->locked;
80104690:	8b 45 08             	mov    0x8(%ebp),%eax
80104693:	8b 00                	mov    (%eax),%eax
80104695:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&lk->lk);
80104698:	8b 45 08             	mov    0x8(%ebp),%eax
8010469b:	83 c0 04             	add    $0x4,%eax
8010469e:	83 ec 0c             	sub    $0xc,%esp
801046a1:	50                   	push   %eax
801046a2:	e8 d0 00 00 00       	call   80104777 <release>
801046a7:	83 c4 10             	add    $0x10,%esp
  return r;
801046aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801046ad:	c9                   	leave  
801046ae:	c3                   	ret    

801046af <readeflags>:
{
801046af:	55                   	push   %ebp
801046b0:	89 e5                	mov    %esp,%ebp
801046b2:	83 ec 10             	sub    $0x10,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
801046b5:	9c                   	pushf  
801046b6:	58                   	pop    %eax
801046b7:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
801046ba:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801046bd:	c9                   	leave  
801046be:	c3                   	ret    

801046bf <cli>:
{
801046bf:	55                   	push   %ebp
801046c0:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
801046c2:	fa                   	cli    
}
801046c3:	90                   	nop
801046c4:	5d                   	pop    %ebp
801046c5:	c3                   	ret    

801046c6 <sti>:
{
801046c6:	55                   	push   %ebp
801046c7:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
801046c9:	fb                   	sti    
}
801046ca:	90                   	nop
801046cb:	5d                   	pop    %ebp
801046cc:	c3                   	ret    

801046cd <xchg>:
{
801046cd:	55                   	push   %ebp
801046ce:	89 e5                	mov    %esp,%ebp
801046d0:	83 ec 10             	sub    $0x10,%esp
  asm volatile("lock; xchgl %0, %1" :
801046d3:	8b 55 08             	mov    0x8(%ebp),%edx
801046d6:	8b 45 0c             	mov    0xc(%ebp),%eax
801046d9:	8b 4d 08             	mov    0x8(%ebp),%ecx
801046dc:	f0 87 02             	lock xchg %eax,(%edx)
801046df:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return result;
801046e2:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801046e5:	c9                   	leave  
801046e6:	c3                   	ret    

801046e7 <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
801046e7:	55                   	push   %ebp
801046e8:	89 e5                	mov    %esp,%ebp
  lk->name = name;
801046ea:	8b 45 08             	mov    0x8(%ebp),%eax
801046ed:	8b 55 0c             	mov    0xc(%ebp),%edx
801046f0:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
801046f3:	8b 45 08             	mov    0x8(%ebp),%eax
801046f6:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
801046fc:	8b 45 08             	mov    0x8(%ebp),%eax
801046ff:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
80104706:	90                   	nop
80104707:	5d                   	pop    %ebp
80104708:	c3                   	ret    

80104709 <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
80104709:	55                   	push   %ebp
8010470a:	89 e5                	mov    %esp,%ebp
8010470c:	53                   	push   %ebx
8010470d:	83 ec 04             	sub    $0x4,%esp
  pushcli(); // disable interrupts to avoid deadlock.
80104710:	e8 5f 01 00 00       	call   80104874 <pushcli>
  if(holding(lk)){
80104715:	8b 45 08             	mov    0x8(%ebp),%eax
80104718:	83 ec 0c             	sub    $0xc,%esp
8010471b:	50                   	push   %eax
8010471c:	e8 23 01 00 00       	call   80104844 <holding>
80104721:	83 c4 10             	add    $0x10,%esp
80104724:	85 c0                	test   %eax,%eax
80104726:	74 0d                	je     80104735 <acquire+0x2c>
    panic("acquire");
80104728:	83 ec 0c             	sub    $0xc,%esp
8010472b:	68 8a a4 10 80       	push   $0x8010a48a
80104730:	e8 74 be ff ff       	call   801005a9 <panic>
  }

  // The xchg is atomic.
  while(xchg(&lk->locked, 1) != 0)
80104735:	90                   	nop
80104736:	8b 45 08             	mov    0x8(%ebp),%eax
80104739:	83 ec 08             	sub    $0x8,%esp
8010473c:	6a 01                	push   $0x1
8010473e:	50                   	push   %eax
8010473f:	e8 89 ff ff ff       	call   801046cd <xchg>
80104744:	83 c4 10             	add    $0x10,%esp
80104747:	85 c0                	test   %eax,%eax
80104749:	75 eb                	jne    80104736 <acquire+0x2d>
    ;

  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that the critical section's memory
  // references happen after the lock is acquired.
  __sync_synchronize();
8010474b:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Record info about lock acquisition for debugging.
  lk->cpu = mycpu();
80104750:	8b 5d 08             	mov    0x8(%ebp),%ebx
80104753:	e8 60 f2 ff ff       	call   801039b8 <mycpu>
80104758:	89 43 08             	mov    %eax,0x8(%ebx)
  getcallerpcs(&lk, lk->pcs);
8010475b:	8b 45 08             	mov    0x8(%ebp),%eax
8010475e:	83 c0 0c             	add    $0xc,%eax
80104761:	83 ec 08             	sub    $0x8,%esp
80104764:	50                   	push   %eax
80104765:	8d 45 08             	lea    0x8(%ebp),%eax
80104768:	50                   	push   %eax
80104769:	e8 5b 00 00 00       	call   801047c9 <getcallerpcs>
8010476e:	83 c4 10             	add    $0x10,%esp
}
80104771:	90                   	nop
80104772:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104775:	c9                   	leave  
80104776:	c3                   	ret    

80104777 <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
80104777:	55                   	push   %ebp
80104778:	89 e5                	mov    %esp,%ebp
8010477a:	83 ec 08             	sub    $0x8,%esp
  if(!holding(lk))
8010477d:	83 ec 0c             	sub    $0xc,%esp
80104780:	ff 75 08             	push   0x8(%ebp)
80104783:	e8 bc 00 00 00       	call   80104844 <holding>
80104788:	83 c4 10             	add    $0x10,%esp
8010478b:	85 c0                	test   %eax,%eax
8010478d:	75 0d                	jne    8010479c <release+0x25>
    panic("release");
8010478f:	83 ec 0c             	sub    $0xc,%esp
80104792:	68 92 a4 10 80       	push   $0x8010a492
80104797:	e8 0d be ff ff       	call   801005a9 <panic>

  lk->pcs[0] = 0;
8010479c:	8b 45 08             	mov    0x8(%ebp),%eax
8010479f:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
801047a6:	8b 45 08             	mov    0x8(%ebp),%eax
801047a9:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that all the stores in the critical
  // section are visible to other cores before the lock is released.
  // Both the C compiler and the hardware may re-order loads and
  // stores; __sync_synchronize() tells them both not to.
  __sync_synchronize();
801047b0:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Release the lock, equivalent to lk->locked = 0.
  // This code can't use a C assignment, since it might
  // not be atomic. A real OS would use C atomics here.
  asm volatile("movl $0, %0" : "+m" (lk->locked) : );
801047b5:	8b 45 08             	mov    0x8(%ebp),%eax
801047b8:	8b 55 08             	mov    0x8(%ebp),%edx
801047bb:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  popcli();
801047c1:	e8 fb 00 00 00       	call   801048c1 <popcli>
}
801047c6:	90                   	nop
801047c7:	c9                   	leave  
801047c8:	c3                   	ret    

801047c9 <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
801047c9:	55                   	push   %ebp
801047ca:	89 e5                	mov    %esp,%ebp
801047cc:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
801047cf:	8b 45 08             	mov    0x8(%ebp),%eax
801047d2:	83 e8 08             	sub    $0x8,%eax
801047d5:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
801047d8:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
801047df:	eb 38                	jmp    80104819 <getcallerpcs+0x50>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
801047e1:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
801047e5:	74 53                	je     8010483a <getcallerpcs+0x71>
801047e7:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
801047ee:	76 4a                	jbe    8010483a <getcallerpcs+0x71>
801047f0:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
801047f4:	74 44                	je     8010483a <getcallerpcs+0x71>
      break;
    pcs[i] = ebp[1];     // saved %eip
801047f6:	8b 45 f8             	mov    -0x8(%ebp),%eax
801047f9:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80104800:	8b 45 0c             	mov    0xc(%ebp),%eax
80104803:	01 c2                	add    %eax,%edx
80104805:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104808:	8b 40 04             	mov    0x4(%eax),%eax
8010480b:	89 02                	mov    %eax,(%edx)
    ebp = (uint*)ebp[0]; // saved %ebp
8010480d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104810:	8b 00                	mov    (%eax),%eax
80104812:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
80104815:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80104819:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
8010481d:	7e c2                	jle    801047e1 <getcallerpcs+0x18>
  }
  for(; i < 10; i++)
8010481f:	eb 19                	jmp    8010483a <getcallerpcs+0x71>
    pcs[i] = 0;
80104821:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104824:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010482b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010482e:	01 d0                	add    %edx,%eax
80104830:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; i < 10; i++)
80104836:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
8010483a:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
8010483e:	7e e1                	jle    80104821 <getcallerpcs+0x58>
}
80104840:	90                   	nop
80104841:	90                   	nop
80104842:	c9                   	leave  
80104843:	c3                   	ret    

80104844 <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
80104844:	55                   	push   %ebp
80104845:	89 e5                	mov    %esp,%ebp
80104847:	53                   	push   %ebx
80104848:	83 ec 04             	sub    $0x4,%esp
  return lock->locked && lock->cpu == mycpu();
8010484b:	8b 45 08             	mov    0x8(%ebp),%eax
8010484e:	8b 00                	mov    (%eax),%eax
80104850:	85 c0                	test   %eax,%eax
80104852:	74 16                	je     8010486a <holding+0x26>
80104854:	8b 45 08             	mov    0x8(%ebp),%eax
80104857:	8b 58 08             	mov    0x8(%eax),%ebx
8010485a:	e8 59 f1 ff ff       	call   801039b8 <mycpu>
8010485f:	39 c3                	cmp    %eax,%ebx
80104861:	75 07                	jne    8010486a <holding+0x26>
80104863:	b8 01 00 00 00       	mov    $0x1,%eax
80104868:	eb 05                	jmp    8010486f <holding+0x2b>
8010486a:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010486f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104872:	c9                   	leave  
80104873:	c3                   	ret    

80104874 <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
80104874:	55                   	push   %ebp
80104875:	89 e5                	mov    %esp,%ebp
80104877:	83 ec 18             	sub    $0x18,%esp
  int eflags;

  eflags = readeflags();
8010487a:	e8 30 fe ff ff       	call   801046af <readeflags>
8010487f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  cli();
80104882:	e8 38 fe ff ff       	call   801046bf <cli>
  if(mycpu()->ncli == 0)
80104887:	e8 2c f1 ff ff       	call   801039b8 <mycpu>
8010488c:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104892:	85 c0                	test   %eax,%eax
80104894:	75 14                	jne    801048aa <pushcli+0x36>
    mycpu()->intena = eflags & FL_IF;
80104896:	e8 1d f1 ff ff       	call   801039b8 <mycpu>
8010489b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010489e:	81 e2 00 02 00 00    	and    $0x200,%edx
801048a4:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
  mycpu()->ncli += 1;
801048aa:	e8 09 f1 ff ff       	call   801039b8 <mycpu>
801048af:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
801048b5:	83 c2 01             	add    $0x1,%edx
801048b8:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
}
801048be:	90                   	nop
801048bf:	c9                   	leave  
801048c0:	c3                   	ret    

801048c1 <popcli>:

void
popcli(void)
{
801048c1:	55                   	push   %ebp
801048c2:	89 e5                	mov    %esp,%ebp
801048c4:	83 ec 08             	sub    $0x8,%esp
  if(readeflags()&FL_IF)
801048c7:	e8 e3 fd ff ff       	call   801046af <readeflags>
801048cc:	25 00 02 00 00       	and    $0x200,%eax
801048d1:	85 c0                	test   %eax,%eax
801048d3:	74 0d                	je     801048e2 <popcli+0x21>
    panic("popcli - interruptible");
801048d5:	83 ec 0c             	sub    $0xc,%esp
801048d8:	68 9a a4 10 80       	push   $0x8010a49a
801048dd:	e8 c7 bc ff ff       	call   801005a9 <panic>
  if(--mycpu()->ncli < 0)
801048e2:	e8 d1 f0 ff ff       	call   801039b8 <mycpu>
801048e7:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
801048ed:	83 ea 01             	sub    $0x1,%edx
801048f0:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
801048f6:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
801048fc:	85 c0                	test   %eax,%eax
801048fe:	79 0d                	jns    8010490d <popcli+0x4c>
    panic("popcli");
80104900:	83 ec 0c             	sub    $0xc,%esp
80104903:	68 b1 a4 10 80       	push   $0x8010a4b1
80104908:	e8 9c bc ff ff       	call   801005a9 <panic>
  if(mycpu()->ncli == 0 && mycpu()->intena)
8010490d:	e8 a6 f0 ff ff       	call   801039b8 <mycpu>
80104912:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104918:	85 c0                	test   %eax,%eax
8010491a:	75 14                	jne    80104930 <popcli+0x6f>
8010491c:	e8 97 f0 ff ff       	call   801039b8 <mycpu>
80104921:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
80104927:	85 c0                	test   %eax,%eax
80104929:	74 05                	je     80104930 <popcli+0x6f>
    sti();
8010492b:	e8 96 fd ff ff       	call   801046c6 <sti>
}
80104930:	90                   	nop
80104931:	c9                   	leave  
80104932:	c3                   	ret    

80104933 <stosb>:
{
80104933:	55                   	push   %ebp
80104934:	89 e5                	mov    %esp,%ebp
80104936:	57                   	push   %edi
80104937:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
80104938:	8b 4d 08             	mov    0x8(%ebp),%ecx
8010493b:	8b 55 10             	mov    0x10(%ebp),%edx
8010493e:	8b 45 0c             	mov    0xc(%ebp),%eax
80104941:	89 cb                	mov    %ecx,%ebx
80104943:	89 df                	mov    %ebx,%edi
80104945:	89 d1                	mov    %edx,%ecx
80104947:	fc                   	cld    
80104948:	f3 aa                	rep stos %al,%es:(%edi)
8010494a:	89 ca                	mov    %ecx,%edx
8010494c:	89 fb                	mov    %edi,%ebx
8010494e:	89 5d 08             	mov    %ebx,0x8(%ebp)
80104951:	89 55 10             	mov    %edx,0x10(%ebp)
}
80104954:	90                   	nop
80104955:	5b                   	pop    %ebx
80104956:	5f                   	pop    %edi
80104957:	5d                   	pop    %ebp
80104958:	c3                   	ret    

80104959 <stosl>:
{
80104959:	55                   	push   %ebp
8010495a:	89 e5                	mov    %esp,%ebp
8010495c:	57                   	push   %edi
8010495d:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
8010495e:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104961:	8b 55 10             	mov    0x10(%ebp),%edx
80104964:	8b 45 0c             	mov    0xc(%ebp),%eax
80104967:	89 cb                	mov    %ecx,%ebx
80104969:	89 df                	mov    %ebx,%edi
8010496b:	89 d1                	mov    %edx,%ecx
8010496d:	fc                   	cld    
8010496e:	f3 ab                	rep stos %eax,%es:(%edi)
80104970:	89 ca                	mov    %ecx,%edx
80104972:	89 fb                	mov    %edi,%ebx
80104974:	89 5d 08             	mov    %ebx,0x8(%ebp)
80104977:	89 55 10             	mov    %edx,0x10(%ebp)
}
8010497a:	90                   	nop
8010497b:	5b                   	pop    %ebx
8010497c:	5f                   	pop    %edi
8010497d:	5d                   	pop    %ebp
8010497e:	c3                   	ret    

8010497f <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
8010497f:	55                   	push   %ebp
80104980:	89 e5                	mov    %esp,%ebp
  if ((int)dst%4 == 0 && n%4 == 0){
80104982:	8b 45 08             	mov    0x8(%ebp),%eax
80104985:	83 e0 03             	and    $0x3,%eax
80104988:	85 c0                	test   %eax,%eax
8010498a:	75 43                	jne    801049cf <memset+0x50>
8010498c:	8b 45 10             	mov    0x10(%ebp),%eax
8010498f:	83 e0 03             	and    $0x3,%eax
80104992:	85 c0                	test   %eax,%eax
80104994:	75 39                	jne    801049cf <memset+0x50>
    c &= 0xFF;
80104996:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
8010499d:	8b 45 10             	mov    0x10(%ebp),%eax
801049a0:	c1 e8 02             	shr    $0x2,%eax
801049a3:	89 c2                	mov    %eax,%edx
801049a5:	8b 45 0c             	mov    0xc(%ebp),%eax
801049a8:	c1 e0 18             	shl    $0x18,%eax
801049ab:	89 c1                	mov    %eax,%ecx
801049ad:	8b 45 0c             	mov    0xc(%ebp),%eax
801049b0:	c1 e0 10             	shl    $0x10,%eax
801049b3:	09 c1                	or     %eax,%ecx
801049b5:	8b 45 0c             	mov    0xc(%ebp),%eax
801049b8:	c1 e0 08             	shl    $0x8,%eax
801049bb:	09 c8                	or     %ecx,%eax
801049bd:	0b 45 0c             	or     0xc(%ebp),%eax
801049c0:	52                   	push   %edx
801049c1:	50                   	push   %eax
801049c2:	ff 75 08             	push   0x8(%ebp)
801049c5:	e8 8f ff ff ff       	call   80104959 <stosl>
801049ca:	83 c4 0c             	add    $0xc,%esp
801049cd:	eb 12                	jmp    801049e1 <memset+0x62>
  } else
    stosb(dst, c, n);
801049cf:	8b 45 10             	mov    0x10(%ebp),%eax
801049d2:	50                   	push   %eax
801049d3:	ff 75 0c             	push   0xc(%ebp)
801049d6:	ff 75 08             	push   0x8(%ebp)
801049d9:	e8 55 ff ff ff       	call   80104933 <stosb>
801049de:	83 c4 0c             	add    $0xc,%esp
  return dst;
801049e1:	8b 45 08             	mov    0x8(%ebp),%eax
}
801049e4:	c9                   	leave  
801049e5:	c3                   	ret    

801049e6 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
801049e6:	55                   	push   %ebp
801049e7:	89 e5                	mov    %esp,%ebp
801049e9:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;

  s1 = v1;
801049ec:	8b 45 08             	mov    0x8(%ebp),%eax
801049ef:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
801049f2:	8b 45 0c             	mov    0xc(%ebp),%eax
801049f5:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
801049f8:	eb 30                	jmp    80104a2a <memcmp+0x44>
    if(*s1 != *s2)
801049fa:	8b 45 fc             	mov    -0x4(%ebp),%eax
801049fd:	0f b6 10             	movzbl (%eax),%edx
80104a00:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104a03:	0f b6 00             	movzbl (%eax),%eax
80104a06:	38 c2                	cmp    %al,%dl
80104a08:	74 18                	je     80104a22 <memcmp+0x3c>
      return *s1 - *s2;
80104a0a:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104a0d:	0f b6 00             	movzbl (%eax),%eax
80104a10:	0f b6 d0             	movzbl %al,%edx
80104a13:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104a16:	0f b6 00             	movzbl (%eax),%eax
80104a19:	0f b6 c8             	movzbl %al,%ecx
80104a1c:	89 d0                	mov    %edx,%eax
80104a1e:	29 c8                	sub    %ecx,%eax
80104a20:	eb 1a                	jmp    80104a3c <memcmp+0x56>
    s1++, s2++;
80104a22:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80104a26:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
  while(n-- > 0){
80104a2a:	8b 45 10             	mov    0x10(%ebp),%eax
80104a2d:	8d 50 ff             	lea    -0x1(%eax),%edx
80104a30:	89 55 10             	mov    %edx,0x10(%ebp)
80104a33:	85 c0                	test   %eax,%eax
80104a35:	75 c3                	jne    801049fa <memcmp+0x14>
  }

  return 0;
80104a37:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104a3c:	c9                   	leave  
80104a3d:	c3                   	ret    

80104a3e <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
80104a3e:	55                   	push   %ebp
80104a3f:	89 e5                	mov    %esp,%ebp
80104a41:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
80104a44:	8b 45 0c             	mov    0xc(%ebp),%eax
80104a47:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
80104a4a:	8b 45 08             	mov    0x8(%ebp),%eax
80104a4d:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
80104a50:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104a53:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80104a56:	73 54                	jae    80104aac <memmove+0x6e>
80104a58:	8b 55 fc             	mov    -0x4(%ebp),%edx
80104a5b:	8b 45 10             	mov    0x10(%ebp),%eax
80104a5e:	01 d0                	add    %edx,%eax
80104a60:	39 45 f8             	cmp    %eax,-0x8(%ebp)
80104a63:	73 47                	jae    80104aac <memmove+0x6e>
    s += n;
80104a65:	8b 45 10             	mov    0x10(%ebp),%eax
80104a68:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
80104a6b:	8b 45 10             	mov    0x10(%ebp),%eax
80104a6e:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
80104a71:	eb 13                	jmp    80104a86 <memmove+0x48>
      *--d = *--s;
80104a73:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
80104a77:	83 6d f8 01          	subl   $0x1,-0x8(%ebp)
80104a7b:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104a7e:	0f b6 10             	movzbl (%eax),%edx
80104a81:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104a84:	88 10                	mov    %dl,(%eax)
    while(n-- > 0)
80104a86:	8b 45 10             	mov    0x10(%ebp),%eax
80104a89:	8d 50 ff             	lea    -0x1(%eax),%edx
80104a8c:	89 55 10             	mov    %edx,0x10(%ebp)
80104a8f:	85 c0                	test   %eax,%eax
80104a91:	75 e0                	jne    80104a73 <memmove+0x35>
  if(s < d && s + n > d){
80104a93:	eb 24                	jmp    80104ab9 <memmove+0x7b>
  } else
    while(n-- > 0)
      *d++ = *s++;
80104a95:	8b 55 fc             	mov    -0x4(%ebp),%edx
80104a98:	8d 42 01             	lea    0x1(%edx),%eax
80104a9b:	89 45 fc             	mov    %eax,-0x4(%ebp)
80104a9e:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104aa1:	8d 48 01             	lea    0x1(%eax),%ecx
80104aa4:	89 4d f8             	mov    %ecx,-0x8(%ebp)
80104aa7:	0f b6 12             	movzbl (%edx),%edx
80104aaa:	88 10                	mov    %dl,(%eax)
    while(n-- > 0)
80104aac:	8b 45 10             	mov    0x10(%ebp),%eax
80104aaf:	8d 50 ff             	lea    -0x1(%eax),%edx
80104ab2:	89 55 10             	mov    %edx,0x10(%ebp)
80104ab5:	85 c0                	test   %eax,%eax
80104ab7:	75 dc                	jne    80104a95 <memmove+0x57>

  return dst;
80104ab9:	8b 45 08             	mov    0x8(%ebp),%eax
}
80104abc:	c9                   	leave  
80104abd:	c3                   	ret    

80104abe <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
80104abe:	55                   	push   %ebp
80104abf:	89 e5                	mov    %esp,%ebp
  return memmove(dst, src, n);
80104ac1:	ff 75 10             	push   0x10(%ebp)
80104ac4:	ff 75 0c             	push   0xc(%ebp)
80104ac7:	ff 75 08             	push   0x8(%ebp)
80104aca:	e8 6f ff ff ff       	call   80104a3e <memmove>
80104acf:	83 c4 0c             	add    $0xc,%esp
}
80104ad2:	c9                   	leave  
80104ad3:	c3                   	ret    

80104ad4 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
80104ad4:	55                   	push   %ebp
80104ad5:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
80104ad7:	eb 0c                	jmp    80104ae5 <strncmp+0x11>
    n--, p++, q++;
80104ad9:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80104add:	83 45 08 01          	addl   $0x1,0x8(%ebp)
80104ae1:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(n > 0 && *p && *p == *q)
80104ae5:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104ae9:	74 1a                	je     80104b05 <strncmp+0x31>
80104aeb:	8b 45 08             	mov    0x8(%ebp),%eax
80104aee:	0f b6 00             	movzbl (%eax),%eax
80104af1:	84 c0                	test   %al,%al
80104af3:	74 10                	je     80104b05 <strncmp+0x31>
80104af5:	8b 45 08             	mov    0x8(%ebp),%eax
80104af8:	0f b6 10             	movzbl (%eax),%edx
80104afb:	8b 45 0c             	mov    0xc(%ebp),%eax
80104afe:	0f b6 00             	movzbl (%eax),%eax
80104b01:	38 c2                	cmp    %al,%dl
80104b03:	74 d4                	je     80104ad9 <strncmp+0x5>
  if(n == 0)
80104b05:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104b09:	75 07                	jne    80104b12 <strncmp+0x3e>
    return 0;
80104b0b:	b8 00 00 00 00       	mov    $0x0,%eax
80104b10:	eb 16                	jmp    80104b28 <strncmp+0x54>
  return (uchar)*p - (uchar)*q;
80104b12:	8b 45 08             	mov    0x8(%ebp),%eax
80104b15:	0f b6 00             	movzbl (%eax),%eax
80104b18:	0f b6 d0             	movzbl %al,%edx
80104b1b:	8b 45 0c             	mov    0xc(%ebp),%eax
80104b1e:	0f b6 00             	movzbl (%eax),%eax
80104b21:	0f b6 c8             	movzbl %al,%ecx
80104b24:	89 d0                	mov    %edx,%eax
80104b26:	29 c8                	sub    %ecx,%eax
}
80104b28:	5d                   	pop    %ebp
80104b29:	c3                   	ret    

80104b2a <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
80104b2a:	55                   	push   %ebp
80104b2b:	89 e5                	mov    %esp,%ebp
80104b2d:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
80104b30:	8b 45 08             	mov    0x8(%ebp),%eax
80104b33:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
80104b36:	90                   	nop
80104b37:	8b 45 10             	mov    0x10(%ebp),%eax
80104b3a:	8d 50 ff             	lea    -0x1(%eax),%edx
80104b3d:	89 55 10             	mov    %edx,0x10(%ebp)
80104b40:	85 c0                	test   %eax,%eax
80104b42:	7e 2c                	jle    80104b70 <strncpy+0x46>
80104b44:	8b 55 0c             	mov    0xc(%ebp),%edx
80104b47:	8d 42 01             	lea    0x1(%edx),%eax
80104b4a:	89 45 0c             	mov    %eax,0xc(%ebp)
80104b4d:	8b 45 08             	mov    0x8(%ebp),%eax
80104b50:	8d 48 01             	lea    0x1(%eax),%ecx
80104b53:	89 4d 08             	mov    %ecx,0x8(%ebp)
80104b56:	0f b6 12             	movzbl (%edx),%edx
80104b59:	88 10                	mov    %dl,(%eax)
80104b5b:	0f b6 00             	movzbl (%eax),%eax
80104b5e:	84 c0                	test   %al,%al
80104b60:	75 d5                	jne    80104b37 <strncpy+0xd>
    ;
  while(n-- > 0)
80104b62:	eb 0c                	jmp    80104b70 <strncpy+0x46>
    *s++ = 0;
80104b64:	8b 45 08             	mov    0x8(%ebp),%eax
80104b67:	8d 50 01             	lea    0x1(%eax),%edx
80104b6a:	89 55 08             	mov    %edx,0x8(%ebp)
80104b6d:	c6 00 00             	movb   $0x0,(%eax)
  while(n-- > 0)
80104b70:	8b 45 10             	mov    0x10(%ebp),%eax
80104b73:	8d 50 ff             	lea    -0x1(%eax),%edx
80104b76:	89 55 10             	mov    %edx,0x10(%ebp)
80104b79:	85 c0                	test   %eax,%eax
80104b7b:	7f e7                	jg     80104b64 <strncpy+0x3a>
  return os;
80104b7d:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104b80:	c9                   	leave  
80104b81:	c3                   	ret    

80104b82 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
80104b82:	55                   	push   %ebp
80104b83:	89 e5                	mov    %esp,%ebp
80104b85:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
80104b88:	8b 45 08             	mov    0x8(%ebp),%eax
80104b8b:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
80104b8e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104b92:	7f 05                	jg     80104b99 <safestrcpy+0x17>
    return os;
80104b94:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104b97:	eb 32                	jmp    80104bcb <safestrcpy+0x49>
  while(--n > 0 && (*s++ = *t++) != 0)
80104b99:	90                   	nop
80104b9a:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80104b9e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104ba2:	7e 1e                	jle    80104bc2 <safestrcpy+0x40>
80104ba4:	8b 55 0c             	mov    0xc(%ebp),%edx
80104ba7:	8d 42 01             	lea    0x1(%edx),%eax
80104baa:	89 45 0c             	mov    %eax,0xc(%ebp)
80104bad:	8b 45 08             	mov    0x8(%ebp),%eax
80104bb0:	8d 48 01             	lea    0x1(%eax),%ecx
80104bb3:	89 4d 08             	mov    %ecx,0x8(%ebp)
80104bb6:	0f b6 12             	movzbl (%edx),%edx
80104bb9:	88 10                	mov    %dl,(%eax)
80104bbb:	0f b6 00             	movzbl (%eax),%eax
80104bbe:	84 c0                	test   %al,%al
80104bc0:	75 d8                	jne    80104b9a <safestrcpy+0x18>
    ;
  *s = 0;
80104bc2:	8b 45 08             	mov    0x8(%ebp),%eax
80104bc5:	c6 00 00             	movb   $0x0,(%eax)
  return os;
80104bc8:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104bcb:	c9                   	leave  
80104bcc:	c3                   	ret    

80104bcd <strlen>:

int
strlen(const char *s)
{
80104bcd:	55                   	push   %ebp
80104bce:	89 e5                	mov    %esp,%ebp
80104bd0:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
80104bd3:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80104bda:	eb 04                	jmp    80104be0 <strlen+0x13>
80104bdc:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80104be0:	8b 55 fc             	mov    -0x4(%ebp),%edx
80104be3:	8b 45 08             	mov    0x8(%ebp),%eax
80104be6:	01 d0                	add    %edx,%eax
80104be8:	0f b6 00             	movzbl (%eax),%eax
80104beb:	84 c0                	test   %al,%al
80104bed:	75 ed                	jne    80104bdc <strlen+0xf>
    ;
  return n;
80104bef:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104bf2:	c9                   	leave  
80104bf3:	c3                   	ret    

80104bf4 <swtch>:
# a struct context, and save its address in *old.
# Switch stacks to new and pop previously-saved registers.

.globl swtch
swtch:
  movl 4(%esp), %eax
80104bf4:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
80104bf8:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
80104bfc:	55                   	push   %ebp
  pushl %ebx
80104bfd:	53                   	push   %ebx
  pushl %esi
80104bfe:	56                   	push   %esi
  pushl %edi
80104bff:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
80104c00:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
80104c02:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
80104c04:	5f                   	pop    %edi
  popl %esi
80104c05:	5e                   	pop    %esi
  popl %ebx
80104c06:	5b                   	pop    %ebx
  popl %ebp
80104c07:	5d                   	pop    %ebp
  ret
80104c08:	c3                   	ret    

80104c09 <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
80104c09:	55                   	push   %ebp
80104c0a:	89 e5                	mov    %esp,%ebp
80104c0c:	83 ec 18             	sub    $0x18,%esp
  struct proc *curproc = myproc();
80104c0f:	e8 1c ee ff ff       	call   80103a30 <myproc>
80104c14:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(addr >= curproc->sz || addr+4 > curproc->sz)
80104c17:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c1a:	8b 00                	mov    (%eax),%eax
80104c1c:	39 45 08             	cmp    %eax,0x8(%ebp)
80104c1f:	73 0f                	jae    80104c30 <fetchint+0x27>
80104c21:	8b 45 08             	mov    0x8(%ebp),%eax
80104c24:	8d 50 04             	lea    0x4(%eax),%edx
80104c27:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c2a:	8b 00                	mov    (%eax),%eax
80104c2c:	39 c2                	cmp    %eax,%edx
80104c2e:	76 07                	jbe    80104c37 <fetchint+0x2e>
    return -1;
80104c30:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104c35:	eb 0f                	jmp    80104c46 <fetchint+0x3d>
  *ip = *(int*)(addr);
80104c37:	8b 45 08             	mov    0x8(%ebp),%eax
80104c3a:	8b 10                	mov    (%eax),%edx
80104c3c:	8b 45 0c             	mov    0xc(%ebp),%eax
80104c3f:	89 10                	mov    %edx,(%eax)
  return 0;
80104c41:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104c46:	c9                   	leave  
80104c47:	c3                   	ret    

80104c48 <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
80104c48:	55                   	push   %ebp
80104c49:	89 e5                	mov    %esp,%ebp
80104c4b:	83 ec 18             	sub    $0x18,%esp
  char *s, *ep;
  struct proc *curproc = myproc();
80104c4e:	e8 dd ed ff ff       	call   80103a30 <myproc>
80104c53:	89 45 f0             	mov    %eax,-0x10(%ebp)

  if(addr >= curproc->sz)
80104c56:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104c59:	8b 00                	mov    (%eax),%eax
80104c5b:	39 45 08             	cmp    %eax,0x8(%ebp)
80104c5e:	72 07                	jb     80104c67 <fetchstr+0x1f>
    return -1;
80104c60:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104c65:	eb 41                	jmp    80104ca8 <fetchstr+0x60>
  *pp = (char*)addr;
80104c67:	8b 55 08             	mov    0x8(%ebp),%edx
80104c6a:	8b 45 0c             	mov    0xc(%ebp),%eax
80104c6d:	89 10                	mov    %edx,(%eax)
  ep = (char*)curproc->sz;
80104c6f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104c72:	8b 00                	mov    (%eax),%eax
80104c74:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(s = *pp; s < ep; s++){
80104c77:	8b 45 0c             	mov    0xc(%ebp),%eax
80104c7a:	8b 00                	mov    (%eax),%eax
80104c7c:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104c7f:	eb 1a                	jmp    80104c9b <fetchstr+0x53>
    if(*s == 0)
80104c81:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c84:	0f b6 00             	movzbl (%eax),%eax
80104c87:	84 c0                	test   %al,%al
80104c89:	75 0c                	jne    80104c97 <fetchstr+0x4f>
      return s - *pp;
80104c8b:	8b 45 0c             	mov    0xc(%ebp),%eax
80104c8e:	8b 10                	mov    (%eax),%edx
80104c90:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c93:	29 d0                	sub    %edx,%eax
80104c95:	eb 11                	jmp    80104ca8 <fetchstr+0x60>
  for(s = *pp; s < ep; s++){
80104c97:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104c9b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c9e:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80104ca1:	72 de                	jb     80104c81 <fetchstr+0x39>
  }
  return -1;
80104ca3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104ca8:	c9                   	leave  
80104ca9:	c3                   	ret    

80104caa <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
80104caa:	55                   	push   %ebp
80104cab:	89 e5                	mov    %esp,%ebp
80104cad:	83 ec 08             	sub    $0x8,%esp
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
80104cb0:	e8 7b ed ff ff       	call   80103a30 <myproc>
80104cb5:	8b 40 18             	mov    0x18(%eax),%eax
80104cb8:	8b 50 44             	mov    0x44(%eax),%edx
80104cbb:	8b 45 08             	mov    0x8(%ebp),%eax
80104cbe:	c1 e0 02             	shl    $0x2,%eax
80104cc1:	01 d0                	add    %edx,%eax
80104cc3:	83 c0 04             	add    $0x4,%eax
80104cc6:	83 ec 08             	sub    $0x8,%esp
80104cc9:	ff 75 0c             	push   0xc(%ebp)
80104ccc:	50                   	push   %eax
80104ccd:	e8 37 ff ff ff       	call   80104c09 <fetchint>
80104cd2:	83 c4 10             	add    $0x10,%esp
}
80104cd5:	c9                   	leave  
80104cd6:	c3                   	ret    

80104cd7 <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
80104cd7:	55                   	push   %ebp
80104cd8:	89 e5                	mov    %esp,%ebp
80104cda:	83 ec 18             	sub    $0x18,%esp
  int i;
  struct proc *curproc = myproc();
80104cdd:	e8 4e ed ff ff       	call   80103a30 <myproc>
80104ce2:	89 45 f4             	mov    %eax,-0xc(%ebp)
 
  if(argint(n, &i) < 0)
80104ce5:	83 ec 08             	sub    $0x8,%esp
80104ce8:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104ceb:	50                   	push   %eax
80104cec:	ff 75 08             	push   0x8(%ebp)
80104cef:	e8 b6 ff ff ff       	call   80104caa <argint>
80104cf4:	83 c4 10             	add    $0x10,%esp
80104cf7:	85 c0                	test   %eax,%eax
80104cf9:	79 07                	jns    80104d02 <argptr+0x2b>
    return -1;
80104cfb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104d00:	eb 3b                	jmp    80104d3d <argptr+0x66>
  if(size < 0 || (uint)i >= curproc->sz || (uint)i+size > curproc->sz)
80104d02:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104d06:	78 1f                	js     80104d27 <argptr+0x50>
80104d08:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d0b:	8b 00                	mov    (%eax),%eax
80104d0d:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104d10:	39 d0                	cmp    %edx,%eax
80104d12:	76 13                	jbe    80104d27 <argptr+0x50>
80104d14:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104d17:	89 c2                	mov    %eax,%edx
80104d19:	8b 45 10             	mov    0x10(%ebp),%eax
80104d1c:	01 c2                	add    %eax,%edx
80104d1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d21:	8b 00                	mov    (%eax),%eax
80104d23:	39 c2                	cmp    %eax,%edx
80104d25:	76 07                	jbe    80104d2e <argptr+0x57>
    return -1;
80104d27:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104d2c:	eb 0f                	jmp    80104d3d <argptr+0x66>
  *pp = (char*)i;
80104d2e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104d31:	89 c2                	mov    %eax,%edx
80104d33:	8b 45 0c             	mov    0xc(%ebp),%eax
80104d36:	89 10                	mov    %edx,(%eax)
  return 0;
80104d38:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104d3d:	c9                   	leave  
80104d3e:	c3                   	ret    

80104d3f <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
80104d3f:	55                   	push   %ebp
80104d40:	89 e5                	mov    %esp,%ebp
80104d42:	83 ec 18             	sub    $0x18,%esp
  int addr;
  if(argint(n, &addr) < 0)
80104d45:	83 ec 08             	sub    $0x8,%esp
80104d48:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104d4b:	50                   	push   %eax
80104d4c:	ff 75 08             	push   0x8(%ebp)
80104d4f:	e8 56 ff ff ff       	call   80104caa <argint>
80104d54:	83 c4 10             	add    $0x10,%esp
80104d57:	85 c0                	test   %eax,%eax
80104d59:	79 07                	jns    80104d62 <argstr+0x23>
    return -1;
80104d5b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104d60:	eb 12                	jmp    80104d74 <argstr+0x35>
  return fetchstr(addr, pp);
80104d62:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d65:	83 ec 08             	sub    $0x8,%esp
80104d68:	ff 75 0c             	push   0xc(%ebp)
80104d6b:	50                   	push   %eax
80104d6c:	e8 d7 fe ff ff       	call   80104c48 <fetchstr>
80104d71:	83 c4 10             	add    $0x10,%esp
}
80104d74:	c9                   	leave  
80104d75:	c3                   	ret    

80104d76 <syscall>:
    [SYS_thread_num] sys_thread_num,
};

void
syscall(void)
{
80104d76:	55                   	push   %ebp
80104d77:	89 e5                	mov    %esp,%ebp
80104d79:	83 ec 18             	sub    $0x18,%esp
  int num;
  struct proc *curproc = myproc();
80104d7c:	e8 af ec ff ff       	call   80103a30 <myproc>
80104d81:	89 45 f4             	mov    %eax,-0xc(%ebp)

  num = curproc->tf->eax;
80104d84:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d87:	8b 40 18             	mov    0x18(%eax),%eax
80104d8a:	8b 40 1c             	mov    0x1c(%eax),%eax
80104d8d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
80104d90:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104d94:	7e 2f                	jle    80104dc5 <syscall+0x4f>
80104d96:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104d99:	83 f8 17             	cmp    $0x17,%eax
80104d9c:	77 27                	ja     80104dc5 <syscall+0x4f>
80104d9e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104da1:	8b 04 85 20 f0 10 80 	mov    -0x7fef0fe0(,%eax,4),%eax
80104da8:	85 c0                	test   %eax,%eax
80104daa:	74 19                	je     80104dc5 <syscall+0x4f>
    curproc->tf->eax = syscalls[num]();
80104dac:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104daf:	8b 04 85 20 f0 10 80 	mov    -0x7fef0fe0(,%eax,4),%eax
80104db6:	ff d0                	call   *%eax
80104db8:	89 c2                	mov    %eax,%edx
80104dba:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104dbd:	8b 40 18             	mov    0x18(%eax),%eax
80104dc0:	89 50 1c             	mov    %edx,0x1c(%eax)
80104dc3:	eb 2c                	jmp    80104df1 <syscall+0x7b>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            curproc->pid, curproc->name, num);
80104dc5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104dc8:	8d 50 6c             	lea    0x6c(%eax),%edx
    cprintf("%d %s: unknown sys call %d\n",
80104dcb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104dce:	8b 40 10             	mov    0x10(%eax),%eax
80104dd1:	ff 75 f0             	push   -0x10(%ebp)
80104dd4:	52                   	push   %edx
80104dd5:	50                   	push   %eax
80104dd6:	68 b8 a4 10 80       	push   $0x8010a4b8
80104ddb:	e8 14 b6 ff ff       	call   801003f4 <cprintf>
80104de0:	83 c4 10             	add    $0x10,%esp
    curproc->tf->eax = -1;
80104de3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104de6:	8b 40 18             	mov    0x18(%eax),%eax
80104de9:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
80104df0:	90                   	nop
80104df1:	90                   	nop
80104df2:	c9                   	leave  
80104df3:	c3                   	ret    

80104df4 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
80104df4:	55                   	push   %ebp
80104df5:	89 e5                	mov    %esp,%ebp
80104df7:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
80104dfa:	83 ec 08             	sub    $0x8,%esp
80104dfd:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104e00:	50                   	push   %eax
80104e01:	ff 75 08             	push   0x8(%ebp)
80104e04:	e8 a1 fe ff ff       	call   80104caa <argint>
80104e09:	83 c4 10             	add    $0x10,%esp
80104e0c:	85 c0                	test   %eax,%eax
80104e0e:	79 07                	jns    80104e17 <argfd+0x23>
    return -1;
80104e10:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104e15:	eb 4f                	jmp    80104e66 <argfd+0x72>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
80104e17:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104e1a:	85 c0                	test   %eax,%eax
80104e1c:	78 20                	js     80104e3e <argfd+0x4a>
80104e1e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104e21:	83 f8 0f             	cmp    $0xf,%eax
80104e24:	7f 18                	jg     80104e3e <argfd+0x4a>
80104e26:	e8 05 ec ff ff       	call   80103a30 <myproc>
80104e2b:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104e2e:	83 c2 08             	add    $0x8,%edx
80104e31:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104e35:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104e38:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104e3c:	75 07                	jne    80104e45 <argfd+0x51>
    return -1;
80104e3e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104e43:	eb 21                	jmp    80104e66 <argfd+0x72>
  if(pfd)
80104e45:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80104e49:	74 08                	je     80104e53 <argfd+0x5f>
    *pfd = fd;
80104e4b:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104e4e:	8b 45 0c             	mov    0xc(%ebp),%eax
80104e51:	89 10                	mov    %edx,(%eax)
  if(pf)
80104e53:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104e57:	74 08                	je     80104e61 <argfd+0x6d>
    *pf = f;
80104e59:	8b 45 10             	mov    0x10(%ebp),%eax
80104e5c:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104e5f:	89 10                	mov    %edx,(%eax)
  return 0;
80104e61:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104e66:	c9                   	leave  
80104e67:	c3                   	ret    

80104e68 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
80104e68:	55                   	push   %ebp
80104e69:	89 e5                	mov    %esp,%ebp
80104e6b:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct proc *curproc = myproc();
80104e6e:	e8 bd eb ff ff       	call   80103a30 <myproc>
80104e73:	89 45 f0             	mov    %eax,-0x10(%ebp)

  for(fd = 0; fd < NOFILE; fd++){
80104e76:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104e7d:	eb 2a                	jmp    80104ea9 <fdalloc+0x41>
    if(curproc->ofile[fd] == 0){
80104e7f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104e82:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104e85:	83 c2 08             	add    $0x8,%edx
80104e88:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104e8c:	85 c0                	test   %eax,%eax
80104e8e:	75 15                	jne    80104ea5 <fdalloc+0x3d>
      curproc->ofile[fd] = f;
80104e90:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104e93:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104e96:	8d 4a 08             	lea    0x8(%edx),%ecx
80104e99:	8b 55 08             	mov    0x8(%ebp),%edx
80104e9c:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
      return fd;
80104ea0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ea3:	eb 0f                	jmp    80104eb4 <fdalloc+0x4c>
  for(fd = 0; fd < NOFILE; fd++){
80104ea5:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104ea9:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
80104ead:	7e d0                	jle    80104e7f <fdalloc+0x17>
    }
  }
  return -1;
80104eaf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104eb4:	c9                   	leave  
80104eb5:	c3                   	ret    

80104eb6 <sys_dup>:

int
sys_dup(void)
{
80104eb6:	55                   	push   %ebp
80104eb7:	89 e5                	mov    %esp,%ebp
80104eb9:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int fd;

  if(argfd(0, 0, &f) < 0)
80104ebc:	83 ec 04             	sub    $0x4,%esp
80104ebf:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104ec2:	50                   	push   %eax
80104ec3:	6a 00                	push   $0x0
80104ec5:	6a 00                	push   $0x0
80104ec7:	e8 28 ff ff ff       	call   80104df4 <argfd>
80104ecc:	83 c4 10             	add    $0x10,%esp
80104ecf:	85 c0                	test   %eax,%eax
80104ed1:	79 07                	jns    80104eda <sys_dup+0x24>
    return -1;
80104ed3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104ed8:	eb 31                	jmp    80104f0b <sys_dup+0x55>
  if((fd=fdalloc(f)) < 0)
80104eda:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104edd:	83 ec 0c             	sub    $0xc,%esp
80104ee0:	50                   	push   %eax
80104ee1:	e8 82 ff ff ff       	call   80104e68 <fdalloc>
80104ee6:	83 c4 10             	add    $0x10,%esp
80104ee9:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104eec:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104ef0:	79 07                	jns    80104ef9 <sys_dup+0x43>
    return -1;
80104ef2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104ef7:	eb 12                	jmp    80104f0b <sys_dup+0x55>
  filedup(f);
80104ef9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104efc:	83 ec 0c             	sub    $0xc,%esp
80104eff:	50                   	push   %eax
80104f00:	e8 45 c1 ff ff       	call   8010104a <filedup>
80104f05:	83 c4 10             	add    $0x10,%esp
  return fd;
80104f08:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80104f0b:	c9                   	leave  
80104f0c:	c3                   	ret    

80104f0d <sys_read>:

int
sys_read(void)
{
80104f0d:	55                   	push   %ebp
80104f0e:	89 e5                	mov    %esp,%ebp
80104f10:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80104f13:	83 ec 04             	sub    $0x4,%esp
80104f16:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104f19:	50                   	push   %eax
80104f1a:	6a 00                	push   $0x0
80104f1c:	6a 00                	push   $0x0
80104f1e:	e8 d1 fe ff ff       	call   80104df4 <argfd>
80104f23:	83 c4 10             	add    $0x10,%esp
80104f26:	85 c0                	test   %eax,%eax
80104f28:	78 2e                	js     80104f58 <sys_read+0x4b>
80104f2a:	83 ec 08             	sub    $0x8,%esp
80104f2d:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104f30:	50                   	push   %eax
80104f31:	6a 02                	push   $0x2
80104f33:	e8 72 fd ff ff       	call   80104caa <argint>
80104f38:	83 c4 10             	add    $0x10,%esp
80104f3b:	85 c0                	test   %eax,%eax
80104f3d:	78 19                	js     80104f58 <sys_read+0x4b>
80104f3f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f42:	83 ec 04             	sub    $0x4,%esp
80104f45:	50                   	push   %eax
80104f46:	8d 45 ec             	lea    -0x14(%ebp),%eax
80104f49:	50                   	push   %eax
80104f4a:	6a 01                	push   $0x1
80104f4c:	e8 86 fd ff ff       	call   80104cd7 <argptr>
80104f51:	83 c4 10             	add    $0x10,%esp
80104f54:	85 c0                	test   %eax,%eax
80104f56:	79 07                	jns    80104f5f <sys_read+0x52>
    return -1;
80104f58:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104f5d:	eb 17                	jmp    80104f76 <sys_read+0x69>
  return fileread(f, p, n);
80104f5f:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80104f62:	8b 55 ec             	mov    -0x14(%ebp),%edx
80104f65:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f68:	83 ec 04             	sub    $0x4,%esp
80104f6b:	51                   	push   %ecx
80104f6c:	52                   	push   %edx
80104f6d:	50                   	push   %eax
80104f6e:	e8 67 c2 ff ff       	call   801011da <fileread>
80104f73:	83 c4 10             	add    $0x10,%esp
}
80104f76:	c9                   	leave  
80104f77:	c3                   	ret    

80104f78 <sys_write>:

int
sys_write(void)
{
80104f78:	55                   	push   %ebp
80104f79:	89 e5                	mov    %esp,%ebp
80104f7b:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80104f7e:	83 ec 04             	sub    $0x4,%esp
80104f81:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104f84:	50                   	push   %eax
80104f85:	6a 00                	push   $0x0
80104f87:	6a 00                	push   $0x0
80104f89:	e8 66 fe ff ff       	call   80104df4 <argfd>
80104f8e:	83 c4 10             	add    $0x10,%esp
80104f91:	85 c0                	test   %eax,%eax
80104f93:	78 2e                	js     80104fc3 <sys_write+0x4b>
80104f95:	83 ec 08             	sub    $0x8,%esp
80104f98:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104f9b:	50                   	push   %eax
80104f9c:	6a 02                	push   $0x2
80104f9e:	e8 07 fd ff ff       	call   80104caa <argint>
80104fa3:	83 c4 10             	add    $0x10,%esp
80104fa6:	85 c0                	test   %eax,%eax
80104fa8:	78 19                	js     80104fc3 <sys_write+0x4b>
80104faa:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104fad:	83 ec 04             	sub    $0x4,%esp
80104fb0:	50                   	push   %eax
80104fb1:	8d 45 ec             	lea    -0x14(%ebp),%eax
80104fb4:	50                   	push   %eax
80104fb5:	6a 01                	push   $0x1
80104fb7:	e8 1b fd ff ff       	call   80104cd7 <argptr>
80104fbc:	83 c4 10             	add    $0x10,%esp
80104fbf:	85 c0                	test   %eax,%eax
80104fc1:	79 07                	jns    80104fca <sys_write+0x52>
    return -1;
80104fc3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104fc8:	eb 17                	jmp    80104fe1 <sys_write+0x69>
  return filewrite(f, p, n);
80104fca:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80104fcd:	8b 55 ec             	mov    -0x14(%ebp),%edx
80104fd0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104fd3:	83 ec 04             	sub    $0x4,%esp
80104fd6:	51                   	push   %ecx
80104fd7:	52                   	push   %edx
80104fd8:	50                   	push   %eax
80104fd9:	e8 b4 c2 ff ff       	call   80101292 <filewrite>
80104fde:	83 c4 10             	add    $0x10,%esp
}
80104fe1:	c9                   	leave  
80104fe2:	c3                   	ret    

80104fe3 <sys_close>:

int
sys_close(void)
{
80104fe3:	55                   	push   %ebp
80104fe4:	89 e5                	mov    %esp,%ebp
80104fe6:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argfd(0, &fd, &f) < 0)
80104fe9:	83 ec 04             	sub    $0x4,%esp
80104fec:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104fef:	50                   	push   %eax
80104ff0:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104ff3:	50                   	push   %eax
80104ff4:	6a 00                	push   $0x0
80104ff6:	e8 f9 fd ff ff       	call   80104df4 <argfd>
80104ffb:	83 c4 10             	add    $0x10,%esp
80104ffe:	85 c0                	test   %eax,%eax
80105000:	79 07                	jns    80105009 <sys_close+0x26>
    return -1;
80105002:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105007:	eb 27                	jmp    80105030 <sys_close+0x4d>
  myproc()->ofile[fd] = 0;
80105009:	e8 22 ea ff ff       	call   80103a30 <myproc>
8010500e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105011:	83 c2 08             	add    $0x8,%edx
80105014:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
8010501b:	00 
  fileclose(f);
8010501c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010501f:	83 ec 0c             	sub    $0xc,%esp
80105022:	50                   	push   %eax
80105023:	e8 73 c0 ff ff       	call   8010109b <fileclose>
80105028:	83 c4 10             	add    $0x10,%esp
  return 0;
8010502b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105030:	c9                   	leave  
80105031:	c3                   	ret    

80105032 <sys_fstat>:

int
sys_fstat(void)
{
80105032:	55                   	push   %ebp
80105033:	89 e5                	mov    %esp,%ebp
80105035:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  struct stat *st;

  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
80105038:	83 ec 04             	sub    $0x4,%esp
8010503b:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010503e:	50                   	push   %eax
8010503f:	6a 00                	push   $0x0
80105041:	6a 00                	push   $0x0
80105043:	e8 ac fd ff ff       	call   80104df4 <argfd>
80105048:	83 c4 10             	add    $0x10,%esp
8010504b:	85 c0                	test   %eax,%eax
8010504d:	78 17                	js     80105066 <sys_fstat+0x34>
8010504f:	83 ec 04             	sub    $0x4,%esp
80105052:	6a 14                	push   $0x14
80105054:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105057:	50                   	push   %eax
80105058:	6a 01                	push   $0x1
8010505a:	e8 78 fc ff ff       	call   80104cd7 <argptr>
8010505f:	83 c4 10             	add    $0x10,%esp
80105062:	85 c0                	test   %eax,%eax
80105064:	79 07                	jns    8010506d <sys_fstat+0x3b>
    return -1;
80105066:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010506b:	eb 13                	jmp    80105080 <sys_fstat+0x4e>
  return filestat(f, st);
8010506d:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105070:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105073:	83 ec 08             	sub    $0x8,%esp
80105076:	52                   	push   %edx
80105077:	50                   	push   %eax
80105078:	e8 06 c1 ff ff       	call   80101183 <filestat>
8010507d:	83 c4 10             	add    $0x10,%esp
}
80105080:	c9                   	leave  
80105081:	c3                   	ret    

80105082 <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
80105082:	55                   	push   %ebp
80105083:	89 e5                	mov    %esp,%ebp
80105085:	83 ec 28             	sub    $0x28,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
80105088:	83 ec 08             	sub    $0x8,%esp
8010508b:	8d 45 d8             	lea    -0x28(%ebp),%eax
8010508e:	50                   	push   %eax
8010508f:	6a 00                	push   $0x0
80105091:	e8 a9 fc ff ff       	call   80104d3f <argstr>
80105096:	83 c4 10             	add    $0x10,%esp
80105099:	85 c0                	test   %eax,%eax
8010509b:	78 15                	js     801050b2 <sys_link+0x30>
8010509d:	83 ec 08             	sub    $0x8,%esp
801050a0:	8d 45 dc             	lea    -0x24(%ebp),%eax
801050a3:	50                   	push   %eax
801050a4:	6a 01                	push   $0x1
801050a6:	e8 94 fc ff ff       	call   80104d3f <argstr>
801050ab:	83 c4 10             	add    $0x10,%esp
801050ae:	85 c0                	test   %eax,%eax
801050b0:	79 0a                	jns    801050bc <sys_link+0x3a>
    return -1;
801050b2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801050b7:	e9 68 01 00 00       	jmp    80105224 <sys_link+0x1a2>

  begin_op();
801050bc:	e8 7b df ff ff       	call   8010303c <begin_op>
  if((ip = namei(old)) == 0){
801050c1:	8b 45 d8             	mov    -0x28(%ebp),%eax
801050c4:	83 ec 0c             	sub    $0xc,%esp
801050c7:	50                   	push   %eax
801050c8:	e8 50 d4 ff ff       	call   8010251d <namei>
801050cd:	83 c4 10             	add    $0x10,%esp
801050d0:	89 45 f4             	mov    %eax,-0xc(%ebp)
801050d3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801050d7:	75 0f                	jne    801050e8 <sys_link+0x66>
    end_op();
801050d9:	e8 ea df ff ff       	call   801030c8 <end_op>
    return -1;
801050de:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801050e3:	e9 3c 01 00 00       	jmp    80105224 <sys_link+0x1a2>
  }

  ilock(ip);
801050e8:	83 ec 0c             	sub    $0xc,%esp
801050eb:	ff 75 f4             	push   -0xc(%ebp)
801050ee:	e8 f7 c8 ff ff       	call   801019ea <ilock>
801050f3:	83 c4 10             	add    $0x10,%esp
  if(ip->type == T_DIR){
801050f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801050f9:	0f b7 40 50          	movzwl 0x50(%eax),%eax
801050fd:	66 83 f8 01          	cmp    $0x1,%ax
80105101:	75 1d                	jne    80105120 <sys_link+0x9e>
    iunlockput(ip);
80105103:	83 ec 0c             	sub    $0xc,%esp
80105106:	ff 75 f4             	push   -0xc(%ebp)
80105109:	e8 0d cb ff ff       	call   80101c1b <iunlockput>
8010510e:	83 c4 10             	add    $0x10,%esp
    end_op();
80105111:	e8 b2 df ff ff       	call   801030c8 <end_op>
    return -1;
80105116:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010511b:	e9 04 01 00 00       	jmp    80105224 <sys_link+0x1a2>
  }

  ip->nlink++;
80105120:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105123:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105127:	83 c0 01             	add    $0x1,%eax
8010512a:	89 c2                	mov    %eax,%edx
8010512c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010512f:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
80105133:	83 ec 0c             	sub    $0xc,%esp
80105136:	ff 75 f4             	push   -0xc(%ebp)
80105139:	e8 cf c6 ff ff       	call   8010180d <iupdate>
8010513e:	83 c4 10             	add    $0x10,%esp
  iunlock(ip);
80105141:	83 ec 0c             	sub    $0xc,%esp
80105144:	ff 75 f4             	push   -0xc(%ebp)
80105147:	e8 b1 c9 ff ff       	call   80101afd <iunlock>
8010514c:	83 c4 10             	add    $0x10,%esp

  if((dp = nameiparent(new, name)) == 0)
8010514f:	8b 45 dc             	mov    -0x24(%ebp),%eax
80105152:	83 ec 08             	sub    $0x8,%esp
80105155:	8d 55 e2             	lea    -0x1e(%ebp),%edx
80105158:	52                   	push   %edx
80105159:	50                   	push   %eax
8010515a:	e8 da d3 ff ff       	call   80102539 <nameiparent>
8010515f:	83 c4 10             	add    $0x10,%esp
80105162:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105165:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105169:	74 71                	je     801051dc <sys_link+0x15a>
    goto bad;
  ilock(dp);
8010516b:	83 ec 0c             	sub    $0xc,%esp
8010516e:	ff 75 f0             	push   -0x10(%ebp)
80105171:	e8 74 c8 ff ff       	call   801019ea <ilock>
80105176:	83 c4 10             	add    $0x10,%esp
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
80105179:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010517c:	8b 10                	mov    (%eax),%edx
8010517e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105181:	8b 00                	mov    (%eax),%eax
80105183:	39 c2                	cmp    %eax,%edx
80105185:	75 1d                	jne    801051a4 <sys_link+0x122>
80105187:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010518a:	8b 40 04             	mov    0x4(%eax),%eax
8010518d:	83 ec 04             	sub    $0x4,%esp
80105190:	50                   	push   %eax
80105191:	8d 45 e2             	lea    -0x1e(%ebp),%eax
80105194:	50                   	push   %eax
80105195:	ff 75 f0             	push   -0x10(%ebp)
80105198:	e8 e9 d0 ff ff       	call   80102286 <dirlink>
8010519d:	83 c4 10             	add    $0x10,%esp
801051a0:	85 c0                	test   %eax,%eax
801051a2:	79 10                	jns    801051b4 <sys_link+0x132>
    iunlockput(dp);
801051a4:	83 ec 0c             	sub    $0xc,%esp
801051a7:	ff 75 f0             	push   -0x10(%ebp)
801051aa:	e8 6c ca ff ff       	call   80101c1b <iunlockput>
801051af:	83 c4 10             	add    $0x10,%esp
    goto bad;
801051b2:	eb 29                	jmp    801051dd <sys_link+0x15b>
  }
  iunlockput(dp);
801051b4:	83 ec 0c             	sub    $0xc,%esp
801051b7:	ff 75 f0             	push   -0x10(%ebp)
801051ba:	e8 5c ca ff ff       	call   80101c1b <iunlockput>
801051bf:	83 c4 10             	add    $0x10,%esp
  iput(ip);
801051c2:	83 ec 0c             	sub    $0xc,%esp
801051c5:	ff 75 f4             	push   -0xc(%ebp)
801051c8:	e8 7e c9 ff ff       	call   80101b4b <iput>
801051cd:	83 c4 10             	add    $0x10,%esp

  end_op();
801051d0:	e8 f3 de ff ff       	call   801030c8 <end_op>

  return 0;
801051d5:	b8 00 00 00 00       	mov    $0x0,%eax
801051da:	eb 48                	jmp    80105224 <sys_link+0x1a2>
    goto bad;
801051dc:	90                   	nop

bad:
  ilock(ip);
801051dd:	83 ec 0c             	sub    $0xc,%esp
801051e0:	ff 75 f4             	push   -0xc(%ebp)
801051e3:	e8 02 c8 ff ff       	call   801019ea <ilock>
801051e8:	83 c4 10             	add    $0x10,%esp
  ip->nlink--;
801051eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801051ee:	0f b7 40 56          	movzwl 0x56(%eax),%eax
801051f2:	83 e8 01             	sub    $0x1,%eax
801051f5:	89 c2                	mov    %eax,%edx
801051f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801051fa:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
801051fe:	83 ec 0c             	sub    $0xc,%esp
80105201:	ff 75 f4             	push   -0xc(%ebp)
80105204:	e8 04 c6 ff ff       	call   8010180d <iupdate>
80105209:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
8010520c:	83 ec 0c             	sub    $0xc,%esp
8010520f:	ff 75 f4             	push   -0xc(%ebp)
80105212:	e8 04 ca ff ff       	call   80101c1b <iunlockput>
80105217:	83 c4 10             	add    $0x10,%esp
  end_op();
8010521a:	e8 a9 de ff ff       	call   801030c8 <end_op>
  return -1;
8010521f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105224:	c9                   	leave  
80105225:	c3                   	ret    

80105226 <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
80105226:	55                   	push   %ebp
80105227:	89 e5                	mov    %esp,%ebp
80105229:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
8010522c:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
80105233:	eb 40                	jmp    80105275 <isdirempty+0x4f>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105235:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105238:	6a 10                	push   $0x10
8010523a:	50                   	push   %eax
8010523b:	8d 45 e4             	lea    -0x1c(%ebp),%eax
8010523e:	50                   	push   %eax
8010523f:	ff 75 08             	push   0x8(%ebp)
80105242:	e8 8f cc ff ff       	call   80101ed6 <readi>
80105247:	83 c4 10             	add    $0x10,%esp
8010524a:	83 f8 10             	cmp    $0x10,%eax
8010524d:	74 0d                	je     8010525c <isdirempty+0x36>
      panic("isdirempty: readi");
8010524f:	83 ec 0c             	sub    $0xc,%esp
80105252:	68 d4 a4 10 80       	push   $0x8010a4d4
80105257:	e8 4d b3 ff ff       	call   801005a9 <panic>
    if(de.inum != 0)
8010525c:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
80105260:	66 85 c0             	test   %ax,%ax
80105263:	74 07                	je     8010526c <isdirempty+0x46>
      return 0;
80105265:	b8 00 00 00 00       	mov    $0x0,%eax
8010526a:	eb 1b                	jmp    80105287 <isdirempty+0x61>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
8010526c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010526f:	83 c0 10             	add    $0x10,%eax
80105272:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105275:	8b 45 08             	mov    0x8(%ebp),%eax
80105278:	8b 50 58             	mov    0x58(%eax),%edx
8010527b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010527e:	39 c2                	cmp    %eax,%edx
80105280:	77 b3                	ja     80105235 <isdirempty+0xf>
  }
  return 1;
80105282:	b8 01 00 00 00       	mov    $0x1,%eax
}
80105287:	c9                   	leave  
80105288:	c3                   	ret    

80105289 <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
80105289:	55                   	push   %ebp
8010528a:	89 e5                	mov    %esp,%ebp
8010528c:	83 ec 38             	sub    $0x38,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
8010528f:	83 ec 08             	sub    $0x8,%esp
80105292:	8d 45 cc             	lea    -0x34(%ebp),%eax
80105295:	50                   	push   %eax
80105296:	6a 00                	push   $0x0
80105298:	e8 a2 fa ff ff       	call   80104d3f <argstr>
8010529d:	83 c4 10             	add    $0x10,%esp
801052a0:	85 c0                	test   %eax,%eax
801052a2:	79 0a                	jns    801052ae <sys_unlink+0x25>
    return -1;
801052a4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801052a9:	e9 bf 01 00 00       	jmp    8010546d <sys_unlink+0x1e4>

  begin_op();
801052ae:	e8 89 dd ff ff       	call   8010303c <begin_op>
  if((dp = nameiparent(path, name)) == 0){
801052b3:	8b 45 cc             	mov    -0x34(%ebp),%eax
801052b6:	83 ec 08             	sub    $0x8,%esp
801052b9:	8d 55 d2             	lea    -0x2e(%ebp),%edx
801052bc:	52                   	push   %edx
801052bd:	50                   	push   %eax
801052be:	e8 76 d2 ff ff       	call   80102539 <nameiparent>
801052c3:	83 c4 10             	add    $0x10,%esp
801052c6:	89 45 f4             	mov    %eax,-0xc(%ebp)
801052c9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801052cd:	75 0f                	jne    801052de <sys_unlink+0x55>
    end_op();
801052cf:	e8 f4 dd ff ff       	call   801030c8 <end_op>
    return -1;
801052d4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801052d9:	e9 8f 01 00 00       	jmp    8010546d <sys_unlink+0x1e4>
  }

  ilock(dp);
801052de:	83 ec 0c             	sub    $0xc,%esp
801052e1:	ff 75 f4             	push   -0xc(%ebp)
801052e4:	e8 01 c7 ff ff       	call   801019ea <ilock>
801052e9:	83 c4 10             	add    $0x10,%esp

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
801052ec:	83 ec 08             	sub    $0x8,%esp
801052ef:	68 e6 a4 10 80       	push   $0x8010a4e6
801052f4:	8d 45 d2             	lea    -0x2e(%ebp),%eax
801052f7:	50                   	push   %eax
801052f8:	e8 b4 ce ff ff       	call   801021b1 <namecmp>
801052fd:	83 c4 10             	add    $0x10,%esp
80105300:	85 c0                	test   %eax,%eax
80105302:	0f 84 49 01 00 00    	je     80105451 <sys_unlink+0x1c8>
80105308:	83 ec 08             	sub    $0x8,%esp
8010530b:	68 e8 a4 10 80       	push   $0x8010a4e8
80105310:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105313:	50                   	push   %eax
80105314:	e8 98 ce ff ff       	call   801021b1 <namecmp>
80105319:	83 c4 10             	add    $0x10,%esp
8010531c:	85 c0                	test   %eax,%eax
8010531e:	0f 84 2d 01 00 00    	je     80105451 <sys_unlink+0x1c8>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
80105324:	83 ec 04             	sub    $0x4,%esp
80105327:	8d 45 c8             	lea    -0x38(%ebp),%eax
8010532a:	50                   	push   %eax
8010532b:	8d 45 d2             	lea    -0x2e(%ebp),%eax
8010532e:	50                   	push   %eax
8010532f:	ff 75 f4             	push   -0xc(%ebp)
80105332:	e8 95 ce ff ff       	call   801021cc <dirlookup>
80105337:	83 c4 10             	add    $0x10,%esp
8010533a:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010533d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105341:	0f 84 0d 01 00 00    	je     80105454 <sys_unlink+0x1cb>
    goto bad;
  ilock(ip);
80105347:	83 ec 0c             	sub    $0xc,%esp
8010534a:	ff 75 f0             	push   -0x10(%ebp)
8010534d:	e8 98 c6 ff ff       	call   801019ea <ilock>
80105352:	83 c4 10             	add    $0x10,%esp

  if(ip->nlink < 1)
80105355:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105358:	0f b7 40 56          	movzwl 0x56(%eax),%eax
8010535c:	66 85 c0             	test   %ax,%ax
8010535f:	7f 0d                	jg     8010536e <sys_unlink+0xe5>
    panic("unlink: nlink < 1");
80105361:	83 ec 0c             	sub    $0xc,%esp
80105364:	68 eb a4 10 80       	push   $0x8010a4eb
80105369:	e8 3b b2 ff ff       	call   801005a9 <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
8010536e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105371:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105375:	66 83 f8 01          	cmp    $0x1,%ax
80105379:	75 25                	jne    801053a0 <sys_unlink+0x117>
8010537b:	83 ec 0c             	sub    $0xc,%esp
8010537e:	ff 75 f0             	push   -0x10(%ebp)
80105381:	e8 a0 fe ff ff       	call   80105226 <isdirempty>
80105386:	83 c4 10             	add    $0x10,%esp
80105389:	85 c0                	test   %eax,%eax
8010538b:	75 13                	jne    801053a0 <sys_unlink+0x117>
    iunlockput(ip);
8010538d:	83 ec 0c             	sub    $0xc,%esp
80105390:	ff 75 f0             	push   -0x10(%ebp)
80105393:	e8 83 c8 ff ff       	call   80101c1b <iunlockput>
80105398:	83 c4 10             	add    $0x10,%esp
    goto bad;
8010539b:	e9 b5 00 00 00       	jmp    80105455 <sys_unlink+0x1cc>
  }

  memset(&de, 0, sizeof(de));
801053a0:	83 ec 04             	sub    $0x4,%esp
801053a3:	6a 10                	push   $0x10
801053a5:	6a 00                	push   $0x0
801053a7:	8d 45 e0             	lea    -0x20(%ebp),%eax
801053aa:	50                   	push   %eax
801053ab:	e8 cf f5 ff ff       	call   8010497f <memset>
801053b0:	83 c4 10             	add    $0x10,%esp
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801053b3:	8b 45 c8             	mov    -0x38(%ebp),%eax
801053b6:	6a 10                	push   $0x10
801053b8:	50                   	push   %eax
801053b9:	8d 45 e0             	lea    -0x20(%ebp),%eax
801053bc:	50                   	push   %eax
801053bd:	ff 75 f4             	push   -0xc(%ebp)
801053c0:	e8 66 cc ff ff       	call   8010202b <writei>
801053c5:	83 c4 10             	add    $0x10,%esp
801053c8:	83 f8 10             	cmp    $0x10,%eax
801053cb:	74 0d                	je     801053da <sys_unlink+0x151>
    panic("unlink: writei");
801053cd:	83 ec 0c             	sub    $0xc,%esp
801053d0:	68 fd a4 10 80       	push   $0x8010a4fd
801053d5:	e8 cf b1 ff ff       	call   801005a9 <panic>
  if(ip->type == T_DIR){
801053da:	8b 45 f0             	mov    -0x10(%ebp),%eax
801053dd:	0f b7 40 50          	movzwl 0x50(%eax),%eax
801053e1:	66 83 f8 01          	cmp    $0x1,%ax
801053e5:	75 21                	jne    80105408 <sys_unlink+0x17f>
    dp->nlink--;
801053e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801053ea:	0f b7 40 56          	movzwl 0x56(%eax),%eax
801053ee:	83 e8 01             	sub    $0x1,%eax
801053f1:	89 c2                	mov    %eax,%edx
801053f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801053f6:	66 89 50 56          	mov    %dx,0x56(%eax)
    iupdate(dp);
801053fa:	83 ec 0c             	sub    $0xc,%esp
801053fd:	ff 75 f4             	push   -0xc(%ebp)
80105400:	e8 08 c4 ff ff       	call   8010180d <iupdate>
80105405:	83 c4 10             	add    $0x10,%esp
  }
  iunlockput(dp);
80105408:	83 ec 0c             	sub    $0xc,%esp
8010540b:	ff 75 f4             	push   -0xc(%ebp)
8010540e:	e8 08 c8 ff ff       	call   80101c1b <iunlockput>
80105413:	83 c4 10             	add    $0x10,%esp

  ip->nlink--;
80105416:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105419:	0f b7 40 56          	movzwl 0x56(%eax),%eax
8010541d:	83 e8 01             	sub    $0x1,%eax
80105420:	89 c2                	mov    %eax,%edx
80105422:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105425:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
80105429:	83 ec 0c             	sub    $0xc,%esp
8010542c:	ff 75 f0             	push   -0x10(%ebp)
8010542f:	e8 d9 c3 ff ff       	call   8010180d <iupdate>
80105434:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
80105437:	83 ec 0c             	sub    $0xc,%esp
8010543a:	ff 75 f0             	push   -0x10(%ebp)
8010543d:	e8 d9 c7 ff ff       	call   80101c1b <iunlockput>
80105442:	83 c4 10             	add    $0x10,%esp

  end_op();
80105445:	e8 7e dc ff ff       	call   801030c8 <end_op>

  return 0;
8010544a:	b8 00 00 00 00       	mov    $0x0,%eax
8010544f:	eb 1c                	jmp    8010546d <sys_unlink+0x1e4>
    goto bad;
80105451:	90                   	nop
80105452:	eb 01                	jmp    80105455 <sys_unlink+0x1cc>
    goto bad;
80105454:	90                   	nop

bad:
  iunlockput(dp);
80105455:	83 ec 0c             	sub    $0xc,%esp
80105458:	ff 75 f4             	push   -0xc(%ebp)
8010545b:	e8 bb c7 ff ff       	call   80101c1b <iunlockput>
80105460:	83 c4 10             	add    $0x10,%esp
  end_op();
80105463:	e8 60 dc ff ff       	call   801030c8 <end_op>
  return -1;
80105468:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010546d:	c9                   	leave  
8010546e:	c3                   	ret    

8010546f <create>:

static struct inode*
create(char *path, short type, short major, short minor)
{
8010546f:	55                   	push   %ebp
80105470:	89 e5                	mov    %esp,%ebp
80105472:	83 ec 38             	sub    $0x38,%esp
80105475:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80105478:	8b 55 10             	mov    0x10(%ebp),%edx
8010547b:	8b 45 14             	mov    0x14(%ebp),%eax
8010547e:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
80105482:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
80105486:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
8010548a:	83 ec 08             	sub    $0x8,%esp
8010548d:	8d 45 de             	lea    -0x22(%ebp),%eax
80105490:	50                   	push   %eax
80105491:	ff 75 08             	push   0x8(%ebp)
80105494:	e8 a0 d0 ff ff       	call   80102539 <nameiparent>
80105499:	83 c4 10             	add    $0x10,%esp
8010549c:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010549f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801054a3:	75 0a                	jne    801054af <create+0x40>
    return 0;
801054a5:	b8 00 00 00 00       	mov    $0x0,%eax
801054aa:	e9 90 01 00 00       	jmp    8010563f <create+0x1d0>
  ilock(dp);
801054af:	83 ec 0c             	sub    $0xc,%esp
801054b2:	ff 75 f4             	push   -0xc(%ebp)
801054b5:	e8 30 c5 ff ff       	call   801019ea <ilock>
801054ba:	83 c4 10             	add    $0x10,%esp

  if((ip = dirlookup(dp, name, &off)) != 0){
801054bd:	83 ec 04             	sub    $0x4,%esp
801054c0:	8d 45 ec             	lea    -0x14(%ebp),%eax
801054c3:	50                   	push   %eax
801054c4:	8d 45 de             	lea    -0x22(%ebp),%eax
801054c7:	50                   	push   %eax
801054c8:	ff 75 f4             	push   -0xc(%ebp)
801054cb:	e8 fc cc ff ff       	call   801021cc <dirlookup>
801054d0:	83 c4 10             	add    $0x10,%esp
801054d3:	89 45 f0             	mov    %eax,-0x10(%ebp)
801054d6:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801054da:	74 50                	je     8010552c <create+0xbd>
    iunlockput(dp);
801054dc:	83 ec 0c             	sub    $0xc,%esp
801054df:	ff 75 f4             	push   -0xc(%ebp)
801054e2:	e8 34 c7 ff ff       	call   80101c1b <iunlockput>
801054e7:	83 c4 10             	add    $0x10,%esp
    ilock(ip);
801054ea:	83 ec 0c             	sub    $0xc,%esp
801054ed:	ff 75 f0             	push   -0x10(%ebp)
801054f0:	e8 f5 c4 ff ff       	call   801019ea <ilock>
801054f5:	83 c4 10             	add    $0x10,%esp
    if(type == T_FILE && ip->type == T_FILE)
801054f8:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
801054fd:	75 15                	jne    80105514 <create+0xa5>
801054ff:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105502:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105506:	66 83 f8 02          	cmp    $0x2,%ax
8010550a:	75 08                	jne    80105514 <create+0xa5>
      return ip;
8010550c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010550f:	e9 2b 01 00 00       	jmp    8010563f <create+0x1d0>
    iunlockput(ip);
80105514:	83 ec 0c             	sub    $0xc,%esp
80105517:	ff 75 f0             	push   -0x10(%ebp)
8010551a:	e8 fc c6 ff ff       	call   80101c1b <iunlockput>
8010551f:	83 c4 10             	add    $0x10,%esp
    return 0;
80105522:	b8 00 00 00 00       	mov    $0x0,%eax
80105527:	e9 13 01 00 00       	jmp    8010563f <create+0x1d0>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
8010552c:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
80105530:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105533:	8b 00                	mov    (%eax),%eax
80105535:	83 ec 08             	sub    $0x8,%esp
80105538:	52                   	push   %edx
80105539:	50                   	push   %eax
8010553a:	e8 f7 c1 ff ff       	call   80101736 <ialloc>
8010553f:	83 c4 10             	add    $0x10,%esp
80105542:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105545:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105549:	75 0d                	jne    80105558 <create+0xe9>
    panic("create: ialloc");
8010554b:	83 ec 0c             	sub    $0xc,%esp
8010554e:	68 0c a5 10 80       	push   $0x8010a50c
80105553:	e8 51 b0 ff ff       	call   801005a9 <panic>

  ilock(ip);
80105558:	83 ec 0c             	sub    $0xc,%esp
8010555b:	ff 75 f0             	push   -0x10(%ebp)
8010555e:	e8 87 c4 ff ff       	call   801019ea <ilock>
80105563:	83 c4 10             	add    $0x10,%esp
  ip->major = major;
80105566:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105569:	0f b7 55 d0          	movzwl -0x30(%ebp),%edx
8010556d:	66 89 50 52          	mov    %dx,0x52(%eax)
  ip->minor = minor;
80105571:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105574:	0f b7 55 cc          	movzwl -0x34(%ebp),%edx
80105578:	66 89 50 54          	mov    %dx,0x54(%eax)
  ip->nlink = 1;
8010557c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010557f:	66 c7 40 56 01 00    	movw   $0x1,0x56(%eax)
  iupdate(ip);
80105585:	83 ec 0c             	sub    $0xc,%esp
80105588:	ff 75 f0             	push   -0x10(%ebp)
8010558b:	e8 7d c2 ff ff       	call   8010180d <iupdate>
80105590:	83 c4 10             	add    $0x10,%esp

  if(type == T_DIR){  // Create . and .. entries.
80105593:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
80105598:	75 6a                	jne    80105604 <create+0x195>
    dp->nlink++;  // for ".."
8010559a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010559d:	0f b7 40 56          	movzwl 0x56(%eax),%eax
801055a1:	83 c0 01             	add    $0x1,%eax
801055a4:	89 c2                	mov    %eax,%edx
801055a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055a9:	66 89 50 56          	mov    %dx,0x56(%eax)
    iupdate(dp);
801055ad:	83 ec 0c             	sub    $0xc,%esp
801055b0:	ff 75 f4             	push   -0xc(%ebp)
801055b3:	e8 55 c2 ff ff       	call   8010180d <iupdate>
801055b8:	83 c4 10             	add    $0x10,%esp
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
801055bb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801055be:	8b 40 04             	mov    0x4(%eax),%eax
801055c1:	83 ec 04             	sub    $0x4,%esp
801055c4:	50                   	push   %eax
801055c5:	68 e6 a4 10 80       	push   $0x8010a4e6
801055ca:	ff 75 f0             	push   -0x10(%ebp)
801055cd:	e8 b4 cc ff ff       	call   80102286 <dirlink>
801055d2:	83 c4 10             	add    $0x10,%esp
801055d5:	85 c0                	test   %eax,%eax
801055d7:	78 1e                	js     801055f7 <create+0x188>
801055d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055dc:	8b 40 04             	mov    0x4(%eax),%eax
801055df:	83 ec 04             	sub    $0x4,%esp
801055e2:	50                   	push   %eax
801055e3:	68 e8 a4 10 80       	push   $0x8010a4e8
801055e8:	ff 75 f0             	push   -0x10(%ebp)
801055eb:	e8 96 cc ff ff       	call   80102286 <dirlink>
801055f0:	83 c4 10             	add    $0x10,%esp
801055f3:	85 c0                	test   %eax,%eax
801055f5:	79 0d                	jns    80105604 <create+0x195>
      panic("create dots");
801055f7:	83 ec 0c             	sub    $0xc,%esp
801055fa:	68 1b a5 10 80       	push   $0x8010a51b
801055ff:	e8 a5 af ff ff       	call   801005a9 <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
80105604:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105607:	8b 40 04             	mov    0x4(%eax),%eax
8010560a:	83 ec 04             	sub    $0x4,%esp
8010560d:	50                   	push   %eax
8010560e:	8d 45 de             	lea    -0x22(%ebp),%eax
80105611:	50                   	push   %eax
80105612:	ff 75 f4             	push   -0xc(%ebp)
80105615:	e8 6c cc ff ff       	call   80102286 <dirlink>
8010561a:	83 c4 10             	add    $0x10,%esp
8010561d:	85 c0                	test   %eax,%eax
8010561f:	79 0d                	jns    8010562e <create+0x1bf>
    panic("create: dirlink");
80105621:	83 ec 0c             	sub    $0xc,%esp
80105624:	68 27 a5 10 80       	push   $0x8010a527
80105629:	e8 7b af ff ff       	call   801005a9 <panic>

  iunlockput(dp);
8010562e:	83 ec 0c             	sub    $0xc,%esp
80105631:	ff 75 f4             	push   -0xc(%ebp)
80105634:	e8 e2 c5 ff ff       	call   80101c1b <iunlockput>
80105639:	83 c4 10             	add    $0x10,%esp

  return ip;
8010563c:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
8010563f:	c9                   	leave  
80105640:	c3                   	ret    

80105641 <sys_open>:

int
sys_open(void)
{
80105641:	55                   	push   %ebp
80105642:	89 e5                	mov    %esp,%ebp
80105644:	83 ec 28             	sub    $0x28,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
80105647:	83 ec 08             	sub    $0x8,%esp
8010564a:	8d 45 e8             	lea    -0x18(%ebp),%eax
8010564d:	50                   	push   %eax
8010564e:	6a 00                	push   $0x0
80105650:	e8 ea f6 ff ff       	call   80104d3f <argstr>
80105655:	83 c4 10             	add    $0x10,%esp
80105658:	85 c0                	test   %eax,%eax
8010565a:	78 15                	js     80105671 <sys_open+0x30>
8010565c:	83 ec 08             	sub    $0x8,%esp
8010565f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105662:	50                   	push   %eax
80105663:	6a 01                	push   $0x1
80105665:	e8 40 f6 ff ff       	call   80104caa <argint>
8010566a:	83 c4 10             	add    $0x10,%esp
8010566d:	85 c0                	test   %eax,%eax
8010566f:	79 0a                	jns    8010567b <sys_open+0x3a>
    return -1;
80105671:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105676:	e9 61 01 00 00       	jmp    801057dc <sys_open+0x19b>

  begin_op();
8010567b:	e8 bc d9 ff ff       	call   8010303c <begin_op>

  if(omode & O_CREATE){
80105680:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105683:	25 00 02 00 00       	and    $0x200,%eax
80105688:	85 c0                	test   %eax,%eax
8010568a:	74 2a                	je     801056b6 <sys_open+0x75>
    ip = create(path, T_FILE, 0, 0);
8010568c:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010568f:	6a 00                	push   $0x0
80105691:	6a 00                	push   $0x0
80105693:	6a 02                	push   $0x2
80105695:	50                   	push   %eax
80105696:	e8 d4 fd ff ff       	call   8010546f <create>
8010569b:	83 c4 10             	add    $0x10,%esp
8010569e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ip == 0){
801056a1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801056a5:	75 75                	jne    8010571c <sys_open+0xdb>
      end_op();
801056a7:	e8 1c da ff ff       	call   801030c8 <end_op>
      return -1;
801056ac:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801056b1:	e9 26 01 00 00       	jmp    801057dc <sys_open+0x19b>
    }
  } else {
    if((ip = namei(path)) == 0){
801056b6:	8b 45 e8             	mov    -0x18(%ebp),%eax
801056b9:	83 ec 0c             	sub    $0xc,%esp
801056bc:	50                   	push   %eax
801056bd:	e8 5b ce ff ff       	call   8010251d <namei>
801056c2:	83 c4 10             	add    $0x10,%esp
801056c5:	89 45 f4             	mov    %eax,-0xc(%ebp)
801056c8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801056cc:	75 0f                	jne    801056dd <sys_open+0x9c>
      end_op();
801056ce:	e8 f5 d9 ff ff       	call   801030c8 <end_op>
      return -1;
801056d3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801056d8:	e9 ff 00 00 00       	jmp    801057dc <sys_open+0x19b>
    }
    ilock(ip);
801056dd:	83 ec 0c             	sub    $0xc,%esp
801056e0:	ff 75 f4             	push   -0xc(%ebp)
801056e3:	e8 02 c3 ff ff       	call   801019ea <ilock>
801056e8:	83 c4 10             	add    $0x10,%esp
    if(ip->type == T_DIR && omode != O_RDONLY){
801056eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801056ee:	0f b7 40 50          	movzwl 0x50(%eax),%eax
801056f2:	66 83 f8 01          	cmp    $0x1,%ax
801056f6:	75 24                	jne    8010571c <sys_open+0xdb>
801056f8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801056fb:	85 c0                	test   %eax,%eax
801056fd:	74 1d                	je     8010571c <sys_open+0xdb>
      iunlockput(ip);
801056ff:	83 ec 0c             	sub    $0xc,%esp
80105702:	ff 75 f4             	push   -0xc(%ebp)
80105705:	e8 11 c5 ff ff       	call   80101c1b <iunlockput>
8010570a:	83 c4 10             	add    $0x10,%esp
      end_op();
8010570d:	e8 b6 d9 ff ff       	call   801030c8 <end_op>
      return -1;
80105712:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105717:	e9 c0 00 00 00       	jmp    801057dc <sys_open+0x19b>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
8010571c:	e8 bc b8 ff ff       	call   80100fdd <filealloc>
80105721:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105724:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105728:	74 17                	je     80105741 <sys_open+0x100>
8010572a:	83 ec 0c             	sub    $0xc,%esp
8010572d:	ff 75 f0             	push   -0x10(%ebp)
80105730:	e8 33 f7 ff ff       	call   80104e68 <fdalloc>
80105735:	83 c4 10             	add    $0x10,%esp
80105738:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010573b:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010573f:	79 2e                	jns    8010576f <sys_open+0x12e>
    if(f)
80105741:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105745:	74 0e                	je     80105755 <sys_open+0x114>
      fileclose(f);
80105747:	83 ec 0c             	sub    $0xc,%esp
8010574a:	ff 75 f0             	push   -0x10(%ebp)
8010574d:	e8 49 b9 ff ff       	call   8010109b <fileclose>
80105752:	83 c4 10             	add    $0x10,%esp
    iunlockput(ip);
80105755:	83 ec 0c             	sub    $0xc,%esp
80105758:	ff 75 f4             	push   -0xc(%ebp)
8010575b:	e8 bb c4 ff ff       	call   80101c1b <iunlockput>
80105760:	83 c4 10             	add    $0x10,%esp
    end_op();
80105763:	e8 60 d9 ff ff       	call   801030c8 <end_op>
    return -1;
80105768:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010576d:	eb 6d                	jmp    801057dc <sys_open+0x19b>
  }
  iunlock(ip);
8010576f:	83 ec 0c             	sub    $0xc,%esp
80105772:	ff 75 f4             	push   -0xc(%ebp)
80105775:	e8 83 c3 ff ff       	call   80101afd <iunlock>
8010577a:	83 c4 10             	add    $0x10,%esp
  end_op();
8010577d:	e8 46 d9 ff ff       	call   801030c8 <end_op>

  f->type = FD_INODE;
80105782:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105785:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
8010578b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010578e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105791:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
80105794:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105797:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
8010579e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801057a1:	83 e0 01             	and    $0x1,%eax
801057a4:	85 c0                	test   %eax,%eax
801057a6:	0f 94 c0             	sete   %al
801057a9:	89 c2                	mov    %eax,%edx
801057ab:	8b 45 f0             	mov    -0x10(%ebp),%eax
801057ae:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
801057b1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801057b4:	83 e0 01             	and    $0x1,%eax
801057b7:	85 c0                	test   %eax,%eax
801057b9:	75 0a                	jne    801057c5 <sys_open+0x184>
801057bb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801057be:	83 e0 02             	and    $0x2,%eax
801057c1:	85 c0                	test   %eax,%eax
801057c3:	74 07                	je     801057cc <sys_open+0x18b>
801057c5:	b8 01 00 00 00       	mov    $0x1,%eax
801057ca:	eb 05                	jmp    801057d1 <sys_open+0x190>
801057cc:	b8 00 00 00 00       	mov    $0x0,%eax
801057d1:	89 c2                	mov    %eax,%edx
801057d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801057d6:	88 50 09             	mov    %dl,0x9(%eax)
  return fd;
801057d9:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
801057dc:	c9                   	leave  
801057dd:	c3                   	ret    

801057de <sys_mkdir>:

int
sys_mkdir(void)
{
801057de:	55                   	push   %ebp
801057df:	89 e5                	mov    %esp,%ebp
801057e1:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
801057e4:	e8 53 d8 ff ff       	call   8010303c <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
801057e9:	83 ec 08             	sub    $0x8,%esp
801057ec:	8d 45 f0             	lea    -0x10(%ebp),%eax
801057ef:	50                   	push   %eax
801057f0:	6a 00                	push   $0x0
801057f2:	e8 48 f5 ff ff       	call   80104d3f <argstr>
801057f7:	83 c4 10             	add    $0x10,%esp
801057fa:	85 c0                	test   %eax,%eax
801057fc:	78 1b                	js     80105819 <sys_mkdir+0x3b>
801057fe:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105801:	6a 00                	push   $0x0
80105803:	6a 00                	push   $0x0
80105805:	6a 01                	push   $0x1
80105807:	50                   	push   %eax
80105808:	e8 62 fc ff ff       	call   8010546f <create>
8010580d:	83 c4 10             	add    $0x10,%esp
80105810:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105813:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105817:	75 0c                	jne    80105825 <sys_mkdir+0x47>
    end_op();
80105819:	e8 aa d8 ff ff       	call   801030c8 <end_op>
    return -1;
8010581e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105823:	eb 18                	jmp    8010583d <sys_mkdir+0x5f>
  }
  iunlockput(ip);
80105825:	83 ec 0c             	sub    $0xc,%esp
80105828:	ff 75 f4             	push   -0xc(%ebp)
8010582b:	e8 eb c3 ff ff       	call   80101c1b <iunlockput>
80105830:	83 c4 10             	add    $0x10,%esp
  end_op();
80105833:	e8 90 d8 ff ff       	call   801030c8 <end_op>
  return 0;
80105838:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010583d:	c9                   	leave  
8010583e:	c3                   	ret    

8010583f <sys_mknod>:

int
sys_mknod(void)
{
8010583f:	55                   	push   %ebp
80105840:	89 e5                	mov    %esp,%ebp
80105842:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
80105845:	e8 f2 d7 ff ff       	call   8010303c <begin_op>
  if((argstr(0, &path)) < 0 ||
8010584a:	83 ec 08             	sub    $0x8,%esp
8010584d:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105850:	50                   	push   %eax
80105851:	6a 00                	push   $0x0
80105853:	e8 e7 f4 ff ff       	call   80104d3f <argstr>
80105858:	83 c4 10             	add    $0x10,%esp
8010585b:	85 c0                	test   %eax,%eax
8010585d:	78 4f                	js     801058ae <sys_mknod+0x6f>
     argint(1, &major) < 0 ||
8010585f:	83 ec 08             	sub    $0x8,%esp
80105862:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105865:	50                   	push   %eax
80105866:	6a 01                	push   $0x1
80105868:	e8 3d f4 ff ff       	call   80104caa <argint>
8010586d:	83 c4 10             	add    $0x10,%esp
  if((argstr(0, &path)) < 0 ||
80105870:	85 c0                	test   %eax,%eax
80105872:	78 3a                	js     801058ae <sys_mknod+0x6f>
     argint(2, &minor) < 0 ||
80105874:	83 ec 08             	sub    $0x8,%esp
80105877:	8d 45 e8             	lea    -0x18(%ebp),%eax
8010587a:	50                   	push   %eax
8010587b:	6a 02                	push   $0x2
8010587d:	e8 28 f4 ff ff       	call   80104caa <argint>
80105882:	83 c4 10             	add    $0x10,%esp
     argint(1, &major) < 0 ||
80105885:	85 c0                	test   %eax,%eax
80105887:	78 25                	js     801058ae <sys_mknod+0x6f>
     (ip = create(path, T_DEV, major, minor)) == 0){
80105889:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010588c:	0f bf c8             	movswl %ax,%ecx
8010588f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105892:	0f bf d0             	movswl %ax,%edx
80105895:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105898:	51                   	push   %ecx
80105899:	52                   	push   %edx
8010589a:	6a 03                	push   $0x3
8010589c:	50                   	push   %eax
8010589d:	e8 cd fb ff ff       	call   8010546f <create>
801058a2:	83 c4 10             	add    $0x10,%esp
801058a5:	89 45 f4             	mov    %eax,-0xc(%ebp)
     argint(2, &minor) < 0 ||
801058a8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801058ac:	75 0c                	jne    801058ba <sys_mknod+0x7b>
    end_op();
801058ae:	e8 15 d8 ff ff       	call   801030c8 <end_op>
    return -1;
801058b3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801058b8:	eb 18                	jmp    801058d2 <sys_mknod+0x93>
  }
  iunlockput(ip);
801058ba:	83 ec 0c             	sub    $0xc,%esp
801058bd:	ff 75 f4             	push   -0xc(%ebp)
801058c0:	e8 56 c3 ff ff       	call   80101c1b <iunlockput>
801058c5:	83 c4 10             	add    $0x10,%esp
  end_op();
801058c8:	e8 fb d7 ff ff       	call   801030c8 <end_op>
  return 0;
801058cd:	b8 00 00 00 00       	mov    $0x0,%eax
}
801058d2:	c9                   	leave  
801058d3:	c3                   	ret    

801058d4 <sys_chdir>:

int
sys_chdir(void)
{
801058d4:	55                   	push   %ebp
801058d5:	89 e5                	mov    %esp,%ebp
801058d7:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;
  struct proc *curproc = myproc();
801058da:	e8 51 e1 ff ff       	call   80103a30 <myproc>
801058df:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  begin_op();
801058e2:	e8 55 d7 ff ff       	call   8010303c <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
801058e7:	83 ec 08             	sub    $0x8,%esp
801058ea:	8d 45 ec             	lea    -0x14(%ebp),%eax
801058ed:	50                   	push   %eax
801058ee:	6a 00                	push   $0x0
801058f0:	e8 4a f4 ff ff       	call   80104d3f <argstr>
801058f5:	83 c4 10             	add    $0x10,%esp
801058f8:	85 c0                	test   %eax,%eax
801058fa:	78 18                	js     80105914 <sys_chdir+0x40>
801058fc:	8b 45 ec             	mov    -0x14(%ebp),%eax
801058ff:	83 ec 0c             	sub    $0xc,%esp
80105902:	50                   	push   %eax
80105903:	e8 15 cc ff ff       	call   8010251d <namei>
80105908:	83 c4 10             	add    $0x10,%esp
8010590b:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010590e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105912:	75 0c                	jne    80105920 <sys_chdir+0x4c>
    end_op();
80105914:	e8 af d7 ff ff       	call   801030c8 <end_op>
    return -1;
80105919:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010591e:	eb 68                	jmp    80105988 <sys_chdir+0xb4>
  }
  ilock(ip);
80105920:	83 ec 0c             	sub    $0xc,%esp
80105923:	ff 75 f0             	push   -0x10(%ebp)
80105926:	e8 bf c0 ff ff       	call   801019ea <ilock>
8010592b:	83 c4 10             	add    $0x10,%esp
  if(ip->type != T_DIR){
8010592e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105931:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105935:	66 83 f8 01          	cmp    $0x1,%ax
80105939:	74 1a                	je     80105955 <sys_chdir+0x81>
    iunlockput(ip);
8010593b:	83 ec 0c             	sub    $0xc,%esp
8010593e:	ff 75 f0             	push   -0x10(%ebp)
80105941:	e8 d5 c2 ff ff       	call   80101c1b <iunlockput>
80105946:	83 c4 10             	add    $0x10,%esp
    end_op();
80105949:	e8 7a d7 ff ff       	call   801030c8 <end_op>
    return -1;
8010594e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105953:	eb 33                	jmp    80105988 <sys_chdir+0xb4>
  }
  iunlock(ip);
80105955:	83 ec 0c             	sub    $0xc,%esp
80105958:	ff 75 f0             	push   -0x10(%ebp)
8010595b:	e8 9d c1 ff ff       	call   80101afd <iunlock>
80105960:	83 c4 10             	add    $0x10,%esp
  iput(curproc->cwd);
80105963:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105966:	8b 40 68             	mov    0x68(%eax),%eax
80105969:	83 ec 0c             	sub    $0xc,%esp
8010596c:	50                   	push   %eax
8010596d:	e8 d9 c1 ff ff       	call   80101b4b <iput>
80105972:	83 c4 10             	add    $0x10,%esp
  end_op();
80105975:	e8 4e d7 ff ff       	call   801030c8 <end_op>
  curproc->cwd = ip;
8010597a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010597d:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105980:	89 50 68             	mov    %edx,0x68(%eax)
  return 0;
80105983:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105988:	c9                   	leave  
80105989:	c3                   	ret    

8010598a <sys_exec>:

int
sys_exec(void)
{
8010598a:	55                   	push   %ebp
8010598b:	89 e5                	mov    %esp,%ebp
8010598d:	81 ec 98 00 00 00    	sub    $0x98,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
80105993:	83 ec 08             	sub    $0x8,%esp
80105996:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105999:	50                   	push   %eax
8010599a:	6a 00                	push   $0x0
8010599c:	e8 9e f3 ff ff       	call   80104d3f <argstr>
801059a1:	83 c4 10             	add    $0x10,%esp
801059a4:	85 c0                	test   %eax,%eax
801059a6:	78 18                	js     801059c0 <sys_exec+0x36>
801059a8:	83 ec 08             	sub    $0x8,%esp
801059ab:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
801059b1:	50                   	push   %eax
801059b2:	6a 01                	push   $0x1
801059b4:	e8 f1 f2 ff ff       	call   80104caa <argint>
801059b9:	83 c4 10             	add    $0x10,%esp
801059bc:	85 c0                	test   %eax,%eax
801059be:	79 0a                	jns    801059ca <sys_exec+0x40>
    return -1;
801059c0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801059c5:	e9 c6 00 00 00       	jmp    80105a90 <sys_exec+0x106>
  }
  memset(argv, 0, sizeof(argv));
801059ca:	83 ec 04             	sub    $0x4,%esp
801059cd:	68 80 00 00 00       	push   $0x80
801059d2:	6a 00                	push   $0x0
801059d4:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
801059da:	50                   	push   %eax
801059db:	e8 9f ef ff ff       	call   8010497f <memset>
801059e0:	83 c4 10             	add    $0x10,%esp
  for(i=0;; i++){
801059e3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
801059ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059ed:	83 f8 1f             	cmp    $0x1f,%eax
801059f0:	76 0a                	jbe    801059fc <sys_exec+0x72>
      return -1;
801059f2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801059f7:	e9 94 00 00 00       	jmp    80105a90 <sys_exec+0x106>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
801059fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059ff:	c1 e0 02             	shl    $0x2,%eax
80105a02:	89 c2                	mov    %eax,%edx
80105a04:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
80105a0a:	01 c2                	add    %eax,%edx
80105a0c:	83 ec 08             	sub    $0x8,%esp
80105a0f:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
80105a15:	50                   	push   %eax
80105a16:	52                   	push   %edx
80105a17:	e8 ed f1 ff ff       	call   80104c09 <fetchint>
80105a1c:	83 c4 10             	add    $0x10,%esp
80105a1f:	85 c0                	test   %eax,%eax
80105a21:	79 07                	jns    80105a2a <sys_exec+0xa0>
      return -1;
80105a23:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a28:	eb 66                	jmp    80105a90 <sys_exec+0x106>
    if(uarg == 0){
80105a2a:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80105a30:	85 c0                	test   %eax,%eax
80105a32:	75 27                	jne    80105a5b <sys_exec+0xd1>
      argv[i] = 0;
80105a34:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a37:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
80105a3e:	00 00 00 00 
      break;
80105a42:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
80105a43:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a46:	83 ec 08             	sub    $0x8,%esp
80105a49:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
80105a4f:	52                   	push   %edx
80105a50:	50                   	push   %eax
80105a51:	e8 2a b1 ff ff       	call   80100b80 <exec>
80105a56:	83 c4 10             	add    $0x10,%esp
80105a59:	eb 35                	jmp    80105a90 <sys_exec+0x106>
    if(fetchstr(uarg, &argv[i]) < 0)
80105a5b:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
80105a61:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a64:	c1 e0 02             	shl    $0x2,%eax
80105a67:	01 c2                	add    %eax,%edx
80105a69:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80105a6f:	83 ec 08             	sub    $0x8,%esp
80105a72:	52                   	push   %edx
80105a73:	50                   	push   %eax
80105a74:	e8 cf f1 ff ff       	call   80104c48 <fetchstr>
80105a79:	83 c4 10             	add    $0x10,%esp
80105a7c:	85 c0                	test   %eax,%eax
80105a7e:	79 07                	jns    80105a87 <sys_exec+0xfd>
      return -1;
80105a80:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a85:	eb 09                	jmp    80105a90 <sys_exec+0x106>
  for(i=0;; i++){
80105a87:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(i >= NELEM(argv))
80105a8b:	e9 5a ff ff ff       	jmp    801059ea <sys_exec+0x60>
}
80105a90:	c9                   	leave  
80105a91:	c3                   	ret    

80105a92 <sys_pipe>:

int
sys_pipe(void)
{
80105a92:	55                   	push   %ebp
80105a93:	89 e5                	mov    %esp,%ebp
80105a95:	83 ec 28             	sub    $0x28,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
80105a98:	83 ec 04             	sub    $0x4,%esp
80105a9b:	6a 08                	push   $0x8
80105a9d:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105aa0:	50                   	push   %eax
80105aa1:	6a 00                	push   $0x0
80105aa3:	e8 2f f2 ff ff       	call   80104cd7 <argptr>
80105aa8:	83 c4 10             	add    $0x10,%esp
80105aab:	85 c0                	test   %eax,%eax
80105aad:	79 0a                	jns    80105ab9 <sys_pipe+0x27>
    return -1;
80105aaf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ab4:	e9 ae 00 00 00       	jmp    80105b67 <sys_pipe+0xd5>
  if(pipealloc(&rf, &wf) < 0)
80105ab9:	83 ec 08             	sub    $0x8,%esp
80105abc:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105abf:	50                   	push   %eax
80105ac0:	8d 45 e8             	lea    -0x18(%ebp),%eax
80105ac3:	50                   	push   %eax
80105ac4:	e8 a4 da ff ff       	call   8010356d <pipealloc>
80105ac9:	83 c4 10             	add    $0x10,%esp
80105acc:	85 c0                	test   %eax,%eax
80105ace:	79 0a                	jns    80105ada <sys_pipe+0x48>
    return -1;
80105ad0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ad5:	e9 8d 00 00 00       	jmp    80105b67 <sys_pipe+0xd5>
  fd0 = -1;
80105ada:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
80105ae1:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105ae4:	83 ec 0c             	sub    $0xc,%esp
80105ae7:	50                   	push   %eax
80105ae8:	e8 7b f3 ff ff       	call   80104e68 <fdalloc>
80105aed:	83 c4 10             	add    $0x10,%esp
80105af0:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105af3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105af7:	78 18                	js     80105b11 <sys_pipe+0x7f>
80105af9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105afc:	83 ec 0c             	sub    $0xc,%esp
80105aff:	50                   	push   %eax
80105b00:	e8 63 f3 ff ff       	call   80104e68 <fdalloc>
80105b05:	83 c4 10             	add    $0x10,%esp
80105b08:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105b0b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105b0f:	79 3e                	jns    80105b4f <sys_pipe+0xbd>
    if(fd0 >= 0)
80105b11:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105b15:	78 13                	js     80105b2a <sys_pipe+0x98>
      myproc()->ofile[fd0] = 0;
80105b17:	e8 14 df ff ff       	call   80103a30 <myproc>
80105b1c:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105b1f:	83 c2 08             	add    $0x8,%edx
80105b22:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80105b29:	00 
    fileclose(rf);
80105b2a:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105b2d:	83 ec 0c             	sub    $0xc,%esp
80105b30:	50                   	push   %eax
80105b31:	e8 65 b5 ff ff       	call   8010109b <fileclose>
80105b36:	83 c4 10             	add    $0x10,%esp
    fileclose(wf);
80105b39:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105b3c:	83 ec 0c             	sub    $0xc,%esp
80105b3f:	50                   	push   %eax
80105b40:	e8 56 b5 ff ff       	call   8010109b <fileclose>
80105b45:	83 c4 10             	add    $0x10,%esp
    return -1;
80105b48:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b4d:	eb 18                	jmp    80105b67 <sys_pipe+0xd5>
  }
  fd[0] = fd0;
80105b4f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105b52:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105b55:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
80105b57:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105b5a:	8d 50 04             	lea    0x4(%eax),%edx
80105b5d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b60:	89 02                	mov    %eax,(%edx)
  return 0;
80105b62:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105b67:	c9                   	leave  
80105b68:	c3                   	ret    

80105b69 <sys_fork>:
#include "mmu.h"
#include "proc.h"

int
sys_fork(void)
{
80105b69:	55                   	push   %ebp
80105b6a:	89 e5                	mov    %esp,%ebp
80105b6c:	83 ec 08             	sub    $0x8,%esp
  return fork();
80105b6f:	e8 be e1 ff ff       	call   80103d32 <fork>
}
80105b74:	c9                   	leave  
80105b75:	c3                   	ret    

80105b76 <sys_exit>:

int
sys_exit(void)
{
80105b76:	55                   	push   %ebp
80105b77:	89 e5                	mov    %esp,%ebp
80105b79:	83 ec 08             	sub    $0x8,%esp
  exit();
80105b7c:	e8 2a e3 ff ff       	call   80103eab <exit>
  return 0;  // not reached
80105b81:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105b86:	c9                   	leave  
80105b87:	c3                   	ret    

80105b88 <sys_wait>:

int
sys_wait(void)
{
80105b88:	55                   	push   %ebp
80105b89:	89 e5                	mov    %esp,%ebp
80105b8b:	83 ec 08             	sub    $0x8,%esp
  return wait();
80105b8e:	e8 3b e4 ff ff       	call   80103fce <wait>
}
80105b93:	c9                   	leave  
80105b94:	c3                   	ret    

80105b95 <sys_kill>:

int
sys_kill(void)
{
80105b95:	55                   	push   %ebp
80105b96:	89 e5                	mov    %esp,%ebp
80105b98:	83 ec 18             	sub    $0x18,%esp
  int pid;

  if(argint(0, &pid) < 0)
80105b9b:	83 ec 08             	sub    $0x8,%esp
80105b9e:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105ba1:	50                   	push   %eax
80105ba2:	6a 00                	push   $0x0
80105ba4:	e8 01 f1 ff ff       	call   80104caa <argint>
80105ba9:	83 c4 10             	add    $0x10,%esp
80105bac:	85 c0                	test   %eax,%eax
80105bae:	79 07                	jns    80105bb7 <sys_kill+0x22>
    return -1;
80105bb0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105bb5:	eb 0f                	jmp    80105bc6 <sys_kill+0x31>
  return kill(pid);
80105bb7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105bba:	83 ec 0c             	sub    $0xc,%esp
80105bbd:	50                   	push   %eax
80105bbe:	e8 43 e8 ff ff       	call   80104406 <kill>
80105bc3:	83 c4 10             	add    $0x10,%esp
}
80105bc6:	c9                   	leave  
80105bc7:	c3                   	ret    

80105bc8 <sys_getpid>:

int
sys_getpid(void)
{
80105bc8:	55                   	push   %ebp
80105bc9:	89 e5                	mov    %esp,%ebp
80105bcb:	83 ec 08             	sub    $0x8,%esp
  return myproc()->pid;
80105bce:	e8 5d de ff ff       	call   80103a30 <myproc>
80105bd3:	8b 40 10             	mov    0x10(%eax),%eax
}
80105bd6:	c9                   	leave  
80105bd7:	c3                   	ret    

80105bd8 <sys_sbrk>:

int
sys_sbrk(void)
{
80105bd8:	55                   	push   %ebp
80105bd9:	89 e5                	mov    %esp,%ebp
80105bdb:	83 ec 18             	sub    $0x18,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
80105bde:	83 ec 08             	sub    $0x8,%esp
80105be1:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105be4:	50                   	push   %eax
80105be5:	6a 00                	push   $0x0
80105be7:	e8 be f0 ff ff       	call   80104caa <argint>
80105bec:	83 c4 10             	add    $0x10,%esp
80105bef:	85 c0                	test   %eax,%eax
80105bf1:	79 07                	jns    80105bfa <sys_sbrk+0x22>
    return -1;
80105bf3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105bf8:	eb 27                	jmp    80105c21 <sys_sbrk+0x49>
  addr = myproc()->sz;
80105bfa:	e8 31 de ff ff       	call   80103a30 <myproc>
80105bff:	8b 00                	mov    (%eax),%eax
80105c01:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
80105c04:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c07:	83 ec 0c             	sub    $0xc,%esp
80105c0a:	50                   	push   %eax
80105c0b:	e8 87 e0 ff ff       	call   80103c97 <growproc>
80105c10:	83 c4 10             	add    $0x10,%esp
80105c13:	85 c0                	test   %eax,%eax
80105c15:	79 07                	jns    80105c1e <sys_sbrk+0x46>
    return -1;
80105c17:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c1c:	eb 03                	jmp    80105c21 <sys_sbrk+0x49>
  return addr;
80105c1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80105c21:	c9                   	leave  
80105c22:	c3                   	ret    

80105c23 <sys_sleep>:

int
sys_sleep(void)
{
80105c23:	55                   	push   %ebp
80105c24:	89 e5                	mov    %esp,%ebp
80105c26:	83 ec 18             	sub    $0x18,%esp
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
80105c29:	83 ec 08             	sub    $0x8,%esp
80105c2c:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105c2f:	50                   	push   %eax
80105c30:	6a 00                	push   $0x0
80105c32:	e8 73 f0 ff ff       	call   80104caa <argint>
80105c37:	83 c4 10             	add    $0x10,%esp
80105c3a:	85 c0                	test   %eax,%eax
80105c3c:	79 07                	jns    80105c45 <sys_sleep+0x22>
    return -1;
80105c3e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c43:	eb 76                	jmp    80105cbb <sys_sleep+0x98>
  acquire(&tickslock);
80105c45:	83 ec 0c             	sub    $0xc,%esp
80105c48:	68 40 6b 19 80       	push   $0x80196b40
80105c4d:	e8 b7 ea ff ff       	call   80104709 <acquire>
80105c52:	83 c4 10             	add    $0x10,%esp
  ticks0 = ticks;
80105c55:	a1 74 6b 19 80       	mov    0x80196b74,%eax
80105c5a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
80105c5d:	eb 38                	jmp    80105c97 <sys_sleep+0x74>
    if(myproc()->killed){
80105c5f:	e8 cc dd ff ff       	call   80103a30 <myproc>
80105c64:	8b 40 24             	mov    0x24(%eax),%eax
80105c67:	85 c0                	test   %eax,%eax
80105c69:	74 17                	je     80105c82 <sys_sleep+0x5f>
      release(&tickslock);
80105c6b:	83 ec 0c             	sub    $0xc,%esp
80105c6e:	68 40 6b 19 80       	push   $0x80196b40
80105c73:	e8 ff ea ff ff       	call   80104777 <release>
80105c78:	83 c4 10             	add    $0x10,%esp
      return -1;
80105c7b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c80:	eb 39                	jmp    80105cbb <sys_sleep+0x98>
    }
    sleep(&ticks, &tickslock);
80105c82:	83 ec 08             	sub    $0x8,%esp
80105c85:	68 40 6b 19 80       	push   $0x80196b40
80105c8a:	68 74 6b 19 80       	push   $0x80196b74
80105c8f:	e8 51 e6 ff ff       	call   801042e5 <sleep>
80105c94:	83 c4 10             	add    $0x10,%esp
  while(ticks - ticks0 < n){
80105c97:	a1 74 6b 19 80       	mov    0x80196b74,%eax
80105c9c:	2b 45 f4             	sub    -0xc(%ebp),%eax
80105c9f:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105ca2:	39 d0                	cmp    %edx,%eax
80105ca4:	72 b9                	jb     80105c5f <sys_sleep+0x3c>
  }
  release(&tickslock);
80105ca6:	83 ec 0c             	sub    $0xc,%esp
80105ca9:	68 40 6b 19 80       	push   $0x80196b40
80105cae:	e8 c4 ea ff ff       	call   80104777 <release>
80105cb3:	83 c4 10             	add    $0x10,%esp
  return 0;
80105cb6:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105cbb:	c9                   	leave  
80105cbc:	c3                   	ret    

80105cbd <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
80105cbd:	55                   	push   %ebp
80105cbe:	89 e5                	mov    %esp,%ebp
80105cc0:	83 ec 18             	sub    $0x18,%esp
  uint xticks;

  acquire(&tickslock);
80105cc3:	83 ec 0c             	sub    $0xc,%esp
80105cc6:	68 40 6b 19 80       	push   $0x80196b40
80105ccb:	e8 39 ea ff ff       	call   80104709 <acquire>
80105cd0:	83 c4 10             	add    $0x10,%esp
  xticks = ticks;
80105cd3:	a1 74 6b 19 80       	mov    0x80196b74,%eax
80105cd8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
80105cdb:	83 ec 0c             	sub    $0xc,%esp
80105cde:	68 40 6b 19 80       	push   $0x80196b40
80105ce3:	e8 8f ea ff ff       	call   80104777 <release>
80105ce8:	83 c4 10             	add    $0x10,%esp
  return xticks;
80105ceb:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80105cee:	c9                   	leave  
80105cef:	c3                   	ret    

80105cf0 <sys_uthread_init>:

int
sys_uthread_init(void) // syscall 실행은 됨
{
80105cf0:	55                   	push   %ebp
80105cf1:	89 e5                	mov    %esp,%ebp
80105cf3:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int func;

  if(argint(0, &func) < 0)
80105cf6:	83 ec 08             	sub    $0x8,%esp
80105cf9:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105cfc:	50                   	push   %eax
80105cfd:	6a 00                	push   $0x0
80105cff:	e8 a6 ef ff ff       	call   80104caa <argint>
80105d04:	83 c4 10             	add    $0x10,%esp
80105d07:	85 c0                	test   %eax,%eax
80105d09:	79 07                	jns    80105d12 <sys_uthread_init+0x22>
    return -1;
80105d0b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d10:	eb 22                	jmp    80105d34 <sys_uthread_init+0x44>
  p = myproc();
80105d12:	e8 19 dd ff ff       	call   80103a30 <myproc>
80105d17:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p->scheduler == 0)
80105d1a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d1d:	8b 40 7c             	mov    0x7c(%eax),%eax
80105d20:	85 c0                	test   %eax,%eax
80105d22:	75 0b                	jne    80105d2f <sys_uthread_init+0x3f>
    p->scheduler = (uint)func;
80105d24:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d27:	89 c2                	mov    %eax,%edx
80105d29:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d2c:	89 50 7c             	mov    %edx,0x7c(%eax)
  
  return 0;
80105d2f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105d34:	c9                   	leave  
80105d35:	c3                   	ret    

80105d36 <sys_thread_num>:

int
sys_thread_num(void)
{
80105d36:	55                   	push   %ebp
80105d37:	89 e5                	mov    %esp,%ebp
80105d39:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int thread;

  if (argint(0, &thread) < 0)
80105d3c:	83 ec 08             	sub    $0x8,%esp
80105d3f:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105d42:	50                   	push   %eax
80105d43:	6a 00                	push   $0x0
80105d45:	e8 60 ef ff ff       	call   80104caa <argint>
80105d4a:	83 c4 10             	add    $0x10,%esp
80105d4d:	85 c0                	test   %eax,%eax
80105d4f:	79 07                	jns    80105d58 <sys_thread_num+0x22>
    return -1;
80105d51:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d56:	eb 19                	jmp    80105d71 <sys_thread_num+0x3b>
  p = myproc();
80105d58:	e8 d3 dc ff ff       	call   80103a30 <myproc>
80105d5d:	89 45 f4             	mov    %eax,-0xc(%ebp)
    p->thread = thread;
80105d60:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105d63:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d66:	89 90 80 00 00 00    	mov    %edx,0x80(%eax)

  return 0;
80105d6c:	b8 00 00 00 00       	mov    $0x0,%eax
80105d71:	c9                   	leave  
80105d72:	c3                   	ret    

80105d73 <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
80105d73:	1e                   	push   %ds
  pushl %es
80105d74:	06                   	push   %es
  pushl %fs
80105d75:	0f a0                	push   %fs
  pushl %gs
80105d77:	0f a8                	push   %gs
  pushal
80105d79:	60                   	pusha  
  
  # Set up data segments.
  movw $(SEG_KDATA<<3), %ax
80105d7a:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
80105d7e:	8e d8                	mov    %eax,%ds
  movw %ax, %es
80105d80:	8e c0                	mov    %eax,%es

  # Call trap(tf), where tf=%esp
  pushl %esp
80105d82:	54                   	push   %esp
  call trap
80105d83:	e8 d7 01 00 00       	call   80105f5f <trap>
  addl $4, %esp
80105d88:	83 c4 04             	add    $0x4,%esp

80105d8b <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
80105d8b:	61                   	popa   
  popl %gs
80105d8c:	0f a9                	pop    %gs
  popl %fs
80105d8e:	0f a1                	pop    %fs
  popl %es
80105d90:	07                   	pop    %es
  popl %ds
80105d91:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
80105d92:	83 c4 08             	add    $0x8,%esp
  iret
80105d95:	cf                   	iret   

80105d96 <lidt>:
{
80105d96:	55                   	push   %ebp
80105d97:	89 e5                	mov    %esp,%ebp
80105d99:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
80105d9c:	8b 45 0c             	mov    0xc(%ebp),%eax
80105d9f:	83 e8 01             	sub    $0x1,%eax
80105da2:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80105da6:	8b 45 08             	mov    0x8(%ebp),%eax
80105da9:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80105dad:	8b 45 08             	mov    0x8(%ebp),%eax
80105db0:	c1 e8 10             	shr    $0x10,%eax
80105db3:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lidt (%0)" : : "r" (pd));
80105db7:	8d 45 fa             	lea    -0x6(%ebp),%eax
80105dba:	0f 01 18             	lidtl  (%eax)
}
80105dbd:	90                   	nop
80105dbe:	c9                   	leave  
80105dbf:	c3                   	ret    

80105dc0 <rcr2>:

static inline uint
rcr2(void)
{
80105dc0:	55                   	push   %ebp
80105dc1:	89 e5                	mov    %esp,%ebp
80105dc3:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
80105dc6:	0f 20 d0             	mov    %cr2,%eax
80105dc9:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return val;
80105dcc:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105dcf:	c9                   	leave  
80105dd0:	c3                   	ret    

80105dd1 <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
80105dd1:	55                   	push   %ebp
80105dd2:	89 e5                	mov    %esp,%ebp
80105dd4:	83 ec 18             	sub    $0x18,%esp
  int i;

  for(i = 0; i < 256; i++)
80105dd7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80105dde:	e9 c3 00 00 00       	jmp    80105ea6 <tvinit+0xd5>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
80105de3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105de6:	8b 04 85 80 f0 10 80 	mov    -0x7fef0f80(,%eax,4),%eax
80105ded:	89 c2                	mov    %eax,%edx
80105def:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105df2:	66 89 14 c5 40 63 19 	mov    %dx,-0x7fe69cc0(,%eax,8)
80105df9:	80 
80105dfa:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105dfd:	66 c7 04 c5 42 63 19 	movw   $0x8,-0x7fe69cbe(,%eax,8)
80105e04:	80 08 00 
80105e07:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e0a:	0f b6 14 c5 44 63 19 	movzbl -0x7fe69cbc(,%eax,8),%edx
80105e11:	80 
80105e12:	83 e2 e0             	and    $0xffffffe0,%edx
80105e15:	88 14 c5 44 63 19 80 	mov    %dl,-0x7fe69cbc(,%eax,8)
80105e1c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e1f:	0f b6 14 c5 44 63 19 	movzbl -0x7fe69cbc(,%eax,8),%edx
80105e26:	80 
80105e27:	83 e2 1f             	and    $0x1f,%edx
80105e2a:	88 14 c5 44 63 19 80 	mov    %dl,-0x7fe69cbc(,%eax,8)
80105e31:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e34:	0f b6 14 c5 45 63 19 	movzbl -0x7fe69cbb(,%eax,8),%edx
80105e3b:	80 
80105e3c:	83 e2 f0             	and    $0xfffffff0,%edx
80105e3f:	83 ca 0e             	or     $0xe,%edx
80105e42:	88 14 c5 45 63 19 80 	mov    %dl,-0x7fe69cbb(,%eax,8)
80105e49:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e4c:	0f b6 14 c5 45 63 19 	movzbl -0x7fe69cbb(,%eax,8),%edx
80105e53:	80 
80105e54:	83 e2 ef             	and    $0xffffffef,%edx
80105e57:	88 14 c5 45 63 19 80 	mov    %dl,-0x7fe69cbb(,%eax,8)
80105e5e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e61:	0f b6 14 c5 45 63 19 	movzbl -0x7fe69cbb(,%eax,8),%edx
80105e68:	80 
80105e69:	83 e2 9f             	and    $0xffffff9f,%edx
80105e6c:	88 14 c5 45 63 19 80 	mov    %dl,-0x7fe69cbb(,%eax,8)
80105e73:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e76:	0f b6 14 c5 45 63 19 	movzbl -0x7fe69cbb(,%eax,8),%edx
80105e7d:	80 
80105e7e:	83 ca 80             	or     $0xffffff80,%edx
80105e81:	88 14 c5 45 63 19 80 	mov    %dl,-0x7fe69cbb(,%eax,8)
80105e88:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e8b:	8b 04 85 80 f0 10 80 	mov    -0x7fef0f80(,%eax,4),%eax
80105e92:	c1 e8 10             	shr    $0x10,%eax
80105e95:	89 c2                	mov    %eax,%edx
80105e97:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e9a:	66 89 14 c5 46 63 19 	mov    %dx,-0x7fe69cba(,%eax,8)
80105ea1:	80 
  for(i = 0; i < 256; i++)
80105ea2:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80105ea6:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80105ead:	0f 8e 30 ff ff ff    	jle    80105de3 <tvinit+0x12>
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
80105eb3:	a1 80 f1 10 80       	mov    0x8010f180,%eax
80105eb8:	66 a3 40 65 19 80    	mov    %ax,0x80196540
80105ebe:	66 c7 05 42 65 19 80 	movw   $0x8,0x80196542
80105ec5:	08 00 
80105ec7:	0f b6 05 44 65 19 80 	movzbl 0x80196544,%eax
80105ece:	83 e0 e0             	and    $0xffffffe0,%eax
80105ed1:	a2 44 65 19 80       	mov    %al,0x80196544
80105ed6:	0f b6 05 44 65 19 80 	movzbl 0x80196544,%eax
80105edd:	83 e0 1f             	and    $0x1f,%eax
80105ee0:	a2 44 65 19 80       	mov    %al,0x80196544
80105ee5:	0f b6 05 45 65 19 80 	movzbl 0x80196545,%eax
80105eec:	83 c8 0f             	or     $0xf,%eax
80105eef:	a2 45 65 19 80       	mov    %al,0x80196545
80105ef4:	0f b6 05 45 65 19 80 	movzbl 0x80196545,%eax
80105efb:	83 e0 ef             	and    $0xffffffef,%eax
80105efe:	a2 45 65 19 80       	mov    %al,0x80196545
80105f03:	0f b6 05 45 65 19 80 	movzbl 0x80196545,%eax
80105f0a:	83 c8 60             	or     $0x60,%eax
80105f0d:	a2 45 65 19 80       	mov    %al,0x80196545
80105f12:	0f b6 05 45 65 19 80 	movzbl 0x80196545,%eax
80105f19:	83 c8 80             	or     $0xffffff80,%eax
80105f1c:	a2 45 65 19 80       	mov    %al,0x80196545
80105f21:	a1 80 f1 10 80       	mov    0x8010f180,%eax
80105f26:	c1 e8 10             	shr    $0x10,%eax
80105f29:	66 a3 46 65 19 80    	mov    %ax,0x80196546

  initlock(&tickslock, "time");
80105f2f:	83 ec 08             	sub    $0x8,%esp
80105f32:	68 38 a5 10 80       	push   $0x8010a538
80105f37:	68 40 6b 19 80       	push   $0x80196b40
80105f3c:	e8 a6 e7 ff ff       	call   801046e7 <initlock>
80105f41:	83 c4 10             	add    $0x10,%esp
}
80105f44:	90                   	nop
80105f45:	c9                   	leave  
80105f46:	c3                   	ret    

80105f47 <idtinit>:

void
idtinit(void)
{
80105f47:	55                   	push   %ebp
80105f48:	89 e5                	mov    %esp,%ebp
  lidt(idt, sizeof(idt));
80105f4a:	68 00 08 00 00       	push   $0x800
80105f4f:	68 40 63 19 80       	push   $0x80196340
80105f54:	e8 3d fe ff ff       	call   80105d96 <lidt>
80105f59:	83 c4 08             	add    $0x8,%esp
}
80105f5c:	90                   	nop
80105f5d:	c9                   	leave  
80105f5e:	c3                   	ret    

80105f5f <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
80105f5f:	55                   	push   %ebp
80105f60:	89 e5                	mov    %esp,%ebp
80105f62:	57                   	push   %edi
80105f63:	56                   	push   %esi
80105f64:	53                   	push   %ebx
80105f65:	83 ec 2c             	sub    $0x2c,%esp
  if(tf->trapno == T_SYSCALL){
80105f68:	8b 45 08             	mov    0x8(%ebp),%eax
80105f6b:	8b 40 30             	mov    0x30(%eax),%eax
80105f6e:	83 f8 40             	cmp    $0x40,%eax
80105f71:	75 3b                	jne    80105fae <trap+0x4f>
    if(myproc()->killed)
80105f73:	e8 b8 da ff ff       	call   80103a30 <myproc>
80105f78:	8b 40 24             	mov    0x24(%eax),%eax
80105f7b:	85 c0                	test   %eax,%eax
80105f7d:	74 05                	je     80105f84 <trap+0x25>
      exit();
80105f7f:	e8 27 df ff ff       	call   80103eab <exit>
    myproc()->tf = tf;
80105f84:	e8 a7 da ff ff       	call   80103a30 <myproc>
80105f89:	8b 55 08             	mov    0x8(%ebp),%edx
80105f8c:	89 50 18             	mov    %edx,0x18(%eax)
    syscall();
80105f8f:	e8 e2 ed ff ff       	call   80104d76 <syscall>
    if(myproc()->killed)
80105f94:	e8 97 da ff ff       	call   80103a30 <myproc>
80105f99:	8b 40 24             	mov    0x24(%eax),%eax
80105f9c:	85 c0                	test   %eax,%eax
80105f9e:	0f 84 fb 02 00 00    	je     8010629f <trap+0x340>
      exit();
80105fa4:	e8 02 df ff ff       	call   80103eab <exit>
    return;
80105fa9:	e9 f1 02 00 00       	jmp    8010629f <trap+0x340>
  }

  switch(tf->trapno){
80105fae:	8b 45 08             	mov    0x8(%ebp),%eax
80105fb1:	8b 40 30             	mov    0x30(%eax),%eax
80105fb4:	83 e8 20             	sub    $0x20,%eax
80105fb7:	83 f8 1f             	cmp    $0x1f,%eax
80105fba:	0f 87 a7 01 00 00    	ja     80106167 <trap+0x208>
80105fc0:	8b 04 85 fc a5 10 80 	mov    -0x7fef5a04(,%eax,4),%eax
80105fc7:	ff e0                	jmp    *%eax
  case T_IRQ0 + IRQ_TIMER:
    if(cpuid() == 0){
80105fc9:	e8 cf d9 ff ff       	call   8010399d <cpuid>
80105fce:	85 c0                	test   %eax,%eax
80105fd0:	75 3d                	jne    8010600f <trap+0xb0>
      acquire(&tickslock);
80105fd2:	83 ec 0c             	sub    $0xc,%esp
80105fd5:	68 40 6b 19 80       	push   $0x80196b40
80105fda:	e8 2a e7 ff ff       	call   80104709 <acquire>
80105fdf:	83 c4 10             	add    $0x10,%esp
      ticks++;
80105fe2:	a1 74 6b 19 80       	mov    0x80196b74,%eax
80105fe7:	83 c0 01             	add    $0x1,%eax
80105fea:	a3 74 6b 19 80       	mov    %eax,0x80196b74
      wakeup(&ticks);
80105fef:	83 ec 0c             	sub    $0xc,%esp
80105ff2:	68 74 6b 19 80       	push   $0x80196b74
80105ff7:	e8 d3 e3 ff ff       	call   801043cf <wakeup>
80105ffc:	83 c4 10             	add    $0x10,%esp
      release(&tickslock);
80105fff:	83 ec 0c             	sub    $0xc,%esp
80106002:	68 40 6b 19 80       	push   $0x80196b40
80106007:	e8 6b e7 ff ff       	call   80104777 <release>
8010600c:	83 c4 10             	add    $0x10,%esp
    }
    lapiceoi();
8010600f:	e8 08 cb ff ff       	call   80102b1c <lapiceoi>
    if(myproc())
80106014:	e8 17 da ff ff       	call   80103a30 <myproc>
80106019:	85 c0                	test   %eax,%eax
8010601b:	0f 84 fd 01 00 00    	je     8010621e <trap+0x2bf>
    {
      cprintf("thread : %d", myproc()->scheduler);
80106021:	e8 0a da ff ff       	call   80103a30 <myproc>
80106026:	8b 40 7c             	mov    0x7c(%eax),%eax
80106029:	83 ec 08             	sub    $0x8,%esp
8010602c:	50                   	push   %eax
8010602d:	68 3d a5 10 80       	push   $0x8010a53d
80106032:	e8 bd a3 ff ff       	call   801003f4 <cprintf>
80106037:	83 c4 10             	add    $0x10,%esp
      if(ticks % 1000 == 0)
8010603a:	8b 0d 74 6b 19 80    	mov    0x80196b74,%ecx
80106040:	ba d3 4d 62 10       	mov    $0x10624dd3,%edx
80106045:	89 c8                	mov    %ecx,%eax
80106047:	f7 e2                	mul    %edx
80106049:	89 d0                	mov    %edx,%eax
8010604b:	c1 e8 06             	shr    $0x6,%eax
8010604e:	69 d0 e8 03 00 00    	imul   $0x3e8,%eax,%edx
80106054:	89 c8                	mov    %ecx,%eax
80106056:	29 d0                	sub    %edx,%eax
80106058:	85 c0                	test   %eax,%eax
8010605a:	75 16                	jne    80106072 <trap+0x113>
        cprintf("tick : %d", ticks);
8010605c:	a1 74 6b 19 80       	mov    0x80196b74,%eax
80106061:	83 ec 08             	sub    $0x8,%esp
80106064:	50                   	push   %eax
80106065:	68 49 a5 10 80       	push   $0x8010a549
8010606a:	e8 85 a3 ff ff       	call   801003f4 <cprintf>
8010606f:	83 c4 10             	add    $0x10,%esp
      if(myproc()->scheduler != 0 && myproc()->thread >= 1 && ticks % 1000 == 0)
80106072:	e8 b9 d9 ff ff       	call   80103a30 <myproc>
80106077:	8b 40 7c             	mov    0x7c(%eax),%eax
8010607a:	85 c0                	test   %eax,%eax
8010607c:	0f 84 9c 01 00 00    	je     8010621e <trap+0x2bf>
80106082:	e8 a9 d9 ff ff       	call   80103a30 <myproc>
80106087:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
8010608d:	85 c0                	test   %eax,%eax
8010608f:	0f 8e 89 01 00 00    	jle    8010621e <trap+0x2bf>
80106095:	8b 0d 74 6b 19 80    	mov    0x80196b74,%ecx
8010609b:	ba d3 4d 62 10       	mov    $0x10624dd3,%edx
801060a0:	89 c8                	mov    %ecx,%eax
801060a2:	f7 e2                	mul    %edx
801060a4:	89 d0                	mov    %edx,%eax
801060a6:	c1 e8 06             	shr    $0x6,%eax
801060a9:	69 d0 e8 03 00 00    	imul   $0x3e8,%eax,%edx
801060af:	89 c8                	mov    %ecx,%eax
801060b1:	29 d0                	sub    %edx,%eax
801060b3:	85 c0                	test   %eax,%eax
801060b5:	0f 85 63 01 00 00    	jne    8010621e <trap+0x2bf>
      {
        cprintf("thread : %d", myproc()->thread);
801060bb:	e8 70 d9 ff ff       	call   80103a30 <myproc>
801060c0:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
801060c6:	83 ec 08             	sub    $0x8,%esp
801060c9:	50                   	push   %eax
801060ca:	68 3d a5 10 80       	push   $0x8010a53d
801060cf:	e8 20 a3 ff ff       	call   801003f4 <cprintf>
801060d4:	83 c4 10             	add    $0x10,%esp
        void (*scheduler_ptr)(void) = (void (*)(void))(myproc()->scheduler);
801060d7:	e8 54 d9 ff ff       	call   80103a30 <myproc>
801060dc:	8b 40 7c             	mov    0x7c(%eax),%eax
801060df:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        scheduler_ptr();
801060e2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801060e5:	ff d0                	call   *%eax
        cprintf("start\n");
801060e7:	83 ec 0c             	sub    $0xc,%esp
801060ea:	68 53 a5 10 80       	push   $0x8010a553
801060ef:	e8 00 a3 ff ff       	call   801003f4 <cprintf>
801060f4:	83 c4 10             	add    $0x10,%esp
      }
    }
    break;
801060f7:	e9 22 01 00 00       	jmp    8010621e <trap+0x2bf>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
801060fc:	e8 f8 3e 00 00       	call   80109ff9 <ideintr>
    lapiceoi();
80106101:	e8 16 ca ff ff       	call   80102b1c <lapiceoi>
    break;
80106106:	e9 14 01 00 00       	jmp    8010621f <trap+0x2c0>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
8010610b:	e8 51 c8 ff ff       	call   80102961 <kbdintr>
    lapiceoi();
80106110:	e8 07 ca ff ff       	call   80102b1c <lapiceoi>
    break;
80106115:	e9 05 01 00 00       	jmp    8010621f <trap+0x2c0>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
8010611a:	e8 56 03 00 00       	call   80106475 <uartintr>
    lapiceoi();
8010611f:	e8 f8 c9 ff ff       	call   80102b1c <lapiceoi>
    break;
80106124:	e9 f6 00 00 00       	jmp    8010621f <trap+0x2c0>
  case T_IRQ0 + 0xB:
    i8254_intr();
80106129:	e8 7e 2b 00 00       	call   80108cac <i8254_intr>
    lapiceoi();
8010612e:	e8 e9 c9 ff ff       	call   80102b1c <lapiceoi>
    break;
80106133:	e9 e7 00 00 00       	jmp    8010621f <trap+0x2c0>
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106138:	8b 45 08             	mov    0x8(%ebp),%eax
8010613b:	8b 70 38             	mov    0x38(%eax),%esi
            cpuid(), tf->cs, tf->eip);
8010613e:	8b 45 08             	mov    0x8(%ebp),%eax
80106141:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106145:	0f b7 d8             	movzwl %ax,%ebx
80106148:	e8 50 d8 ff ff       	call   8010399d <cpuid>
8010614d:	56                   	push   %esi
8010614e:	53                   	push   %ebx
8010614f:	50                   	push   %eax
80106150:	68 5c a5 10 80       	push   $0x8010a55c
80106155:	e8 9a a2 ff ff       	call   801003f4 <cprintf>
8010615a:	83 c4 10             	add    $0x10,%esp
    lapiceoi();
8010615d:	e8 ba c9 ff ff       	call   80102b1c <lapiceoi>
    break;
80106162:	e9 b8 00 00 00       	jmp    8010621f <trap+0x2c0>

  //PAGEBREAK: 13
  default:
    if(myproc() == 0 || (tf->cs&3) == 0){
80106167:	e8 c4 d8 ff ff       	call   80103a30 <myproc>
8010616c:	85 c0                	test   %eax,%eax
8010616e:	74 11                	je     80106181 <trap+0x222>
80106170:	8b 45 08             	mov    0x8(%ebp),%eax
80106173:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106177:	0f b7 c0             	movzwl %ax,%eax
8010617a:	83 e0 03             	and    $0x3,%eax
8010617d:	85 c0                	test   %eax,%eax
8010617f:	75 39                	jne    801061ba <trap+0x25b>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80106181:	e8 3a fc ff ff       	call   80105dc0 <rcr2>
80106186:	89 c3                	mov    %eax,%ebx
80106188:	8b 45 08             	mov    0x8(%ebp),%eax
8010618b:	8b 70 38             	mov    0x38(%eax),%esi
8010618e:	e8 0a d8 ff ff       	call   8010399d <cpuid>
80106193:	8b 55 08             	mov    0x8(%ebp),%edx
80106196:	8b 52 30             	mov    0x30(%edx),%edx
80106199:	83 ec 0c             	sub    $0xc,%esp
8010619c:	53                   	push   %ebx
8010619d:	56                   	push   %esi
8010619e:	50                   	push   %eax
8010619f:	52                   	push   %edx
801061a0:	68 80 a5 10 80       	push   $0x8010a580
801061a5:	e8 4a a2 ff ff       	call   801003f4 <cprintf>
801061aa:	83 c4 20             	add    $0x20,%esp
              tf->trapno, cpuid(), tf->eip, rcr2());
      panic("trap");
801061ad:	83 ec 0c             	sub    $0xc,%esp
801061b0:	68 b2 a5 10 80       	push   $0x8010a5b2
801061b5:	e8 ef a3 ff ff       	call   801005a9 <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
801061ba:	e8 01 fc ff ff       	call   80105dc0 <rcr2>
801061bf:	89 c6                	mov    %eax,%esi
801061c1:	8b 45 08             	mov    0x8(%ebp),%eax
801061c4:	8b 40 38             	mov    0x38(%eax),%eax
801061c7:	89 45 d4             	mov    %eax,-0x2c(%ebp)
801061ca:	e8 ce d7 ff ff       	call   8010399d <cpuid>
801061cf:	89 c3                	mov    %eax,%ebx
801061d1:	8b 45 08             	mov    0x8(%ebp),%eax
801061d4:	8b 78 34             	mov    0x34(%eax),%edi
801061d7:	89 7d d0             	mov    %edi,-0x30(%ebp)
801061da:	8b 45 08             	mov    0x8(%ebp),%eax
801061dd:	8b 78 30             	mov    0x30(%eax),%edi
            "eip 0x%x addr 0x%x--kill proc\n",
            myproc()->pid, myproc()->name, tf->trapno,
801061e0:	e8 4b d8 ff ff       	call   80103a30 <myproc>
801061e5:	8d 48 6c             	lea    0x6c(%eax),%ecx
801061e8:	89 4d cc             	mov    %ecx,-0x34(%ebp)
801061eb:	e8 40 d8 ff ff       	call   80103a30 <myproc>
    cprintf("pid %d %s: trap %d err %d on cpu %d "
801061f0:	8b 40 10             	mov    0x10(%eax),%eax
801061f3:	56                   	push   %esi
801061f4:	ff 75 d4             	push   -0x2c(%ebp)
801061f7:	53                   	push   %ebx
801061f8:	ff 75 d0             	push   -0x30(%ebp)
801061fb:	57                   	push   %edi
801061fc:	ff 75 cc             	push   -0x34(%ebp)
801061ff:	50                   	push   %eax
80106200:	68 b8 a5 10 80       	push   $0x8010a5b8
80106205:	e8 ea a1 ff ff       	call   801003f4 <cprintf>
8010620a:	83 c4 20             	add    $0x20,%esp
            tf->err, cpuid(), tf->eip, rcr2());
    myproc()->killed = 1;
8010620d:	e8 1e d8 ff ff       	call   80103a30 <myproc>
80106212:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
80106219:	eb 04                	jmp    8010621f <trap+0x2c0>
    break;
8010621b:	90                   	nop
8010621c:	eb 01                	jmp    8010621f <trap+0x2c0>
    break;
8010621e:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running
  // until it gets to the regular system call return.)
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
8010621f:	e8 0c d8 ff ff       	call   80103a30 <myproc>
80106224:	85 c0                	test   %eax,%eax
80106226:	74 23                	je     8010624b <trap+0x2ec>
80106228:	e8 03 d8 ff ff       	call   80103a30 <myproc>
8010622d:	8b 40 24             	mov    0x24(%eax),%eax
80106230:	85 c0                	test   %eax,%eax
80106232:	74 17                	je     8010624b <trap+0x2ec>
80106234:	8b 45 08             	mov    0x8(%ebp),%eax
80106237:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
8010623b:	0f b7 c0             	movzwl %ax,%eax
8010623e:	83 e0 03             	and    $0x3,%eax
80106241:	83 f8 03             	cmp    $0x3,%eax
80106244:	75 05                	jne    8010624b <trap+0x2ec>
    exit();
80106246:	e8 60 dc ff ff       	call   80103eab <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(myproc() && myproc()->state == RUNNING &&
8010624b:	e8 e0 d7 ff ff       	call   80103a30 <myproc>
80106250:	85 c0                	test   %eax,%eax
80106252:	74 1d                	je     80106271 <trap+0x312>
80106254:	e8 d7 d7 ff ff       	call   80103a30 <myproc>
80106259:	8b 40 0c             	mov    0xc(%eax),%eax
8010625c:	83 f8 04             	cmp    $0x4,%eax
8010625f:	75 10                	jne    80106271 <trap+0x312>
     tf->trapno == T_IRQ0+IRQ_TIMER)
80106261:	8b 45 08             	mov    0x8(%ebp),%eax
80106264:	8b 40 30             	mov    0x30(%eax),%eax
  if(myproc() && myproc()->state == RUNNING &&
80106267:	83 f8 20             	cmp    $0x20,%eax
8010626a:	75 05                	jne    80106271 <trap+0x312>
    yield();
8010626c:	e8 f4 df ff ff       	call   80104265 <yield>

  // Check if the process has been killed since we yielded
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80106271:	e8 ba d7 ff ff       	call   80103a30 <myproc>
80106276:	85 c0                	test   %eax,%eax
80106278:	74 26                	je     801062a0 <trap+0x341>
8010627a:	e8 b1 d7 ff ff       	call   80103a30 <myproc>
8010627f:	8b 40 24             	mov    0x24(%eax),%eax
80106282:	85 c0                	test   %eax,%eax
80106284:	74 1a                	je     801062a0 <trap+0x341>
80106286:	8b 45 08             	mov    0x8(%ebp),%eax
80106289:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
8010628d:	0f b7 c0             	movzwl %ax,%eax
80106290:	83 e0 03             	and    $0x3,%eax
80106293:	83 f8 03             	cmp    $0x3,%eax
80106296:	75 08                	jne    801062a0 <trap+0x341>
    exit();
80106298:	e8 0e dc ff ff       	call   80103eab <exit>
8010629d:	eb 01                	jmp    801062a0 <trap+0x341>
    return;
8010629f:	90                   	nop
}
801062a0:	8d 65 f4             	lea    -0xc(%ebp),%esp
801062a3:	5b                   	pop    %ebx
801062a4:	5e                   	pop    %esi
801062a5:	5f                   	pop    %edi
801062a6:	5d                   	pop    %ebp
801062a7:	c3                   	ret    

801062a8 <inb>:
{
801062a8:	55                   	push   %ebp
801062a9:	89 e5                	mov    %esp,%ebp
801062ab:	83 ec 14             	sub    $0x14,%esp
801062ae:	8b 45 08             	mov    0x8(%ebp),%eax
801062b1:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801062b5:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
801062b9:	89 c2                	mov    %eax,%edx
801062bb:	ec                   	in     (%dx),%al
801062bc:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
801062bf:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
801062c3:	c9                   	leave  
801062c4:	c3                   	ret    

801062c5 <outb>:
{
801062c5:	55                   	push   %ebp
801062c6:	89 e5                	mov    %esp,%ebp
801062c8:	83 ec 08             	sub    $0x8,%esp
801062cb:	8b 45 08             	mov    0x8(%ebp),%eax
801062ce:	8b 55 0c             	mov    0xc(%ebp),%edx
801062d1:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
801062d5:	89 d0                	mov    %edx,%eax
801062d7:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801062da:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801062de:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801062e2:	ee                   	out    %al,(%dx)
}
801062e3:	90                   	nop
801062e4:	c9                   	leave  
801062e5:	c3                   	ret    

801062e6 <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
801062e6:	55                   	push   %ebp
801062e7:	89 e5                	mov    %esp,%ebp
801062e9:	83 ec 18             	sub    $0x18,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
801062ec:	6a 00                	push   $0x0
801062ee:	68 fa 03 00 00       	push   $0x3fa
801062f3:	e8 cd ff ff ff       	call   801062c5 <outb>
801062f8:	83 c4 08             	add    $0x8,%esp

  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
801062fb:	68 80 00 00 00       	push   $0x80
80106300:	68 fb 03 00 00       	push   $0x3fb
80106305:	e8 bb ff ff ff       	call   801062c5 <outb>
8010630a:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
8010630d:	6a 0c                	push   $0xc
8010630f:	68 f8 03 00 00       	push   $0x3f8
80106314:	e8 ac ff ff ff       	call   801062c5 <outb>
80106319:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
8010631c:	6a 00                	push   $0x0
8010631e:	68 f9 03 00 00       	push   $0x3f9
80106323:	e8 9d ff ff ff       	call   801062c5 <outb>
80106328:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
8010632b:	6a 03                	push   $0x3
8010632d:	68 fb 03 00 00       	push   $0x3fb
80106332:	e8 8e ff ff ff       	call   801062c5 <outb>
80106337:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
8010633a:	6a 00                	push   $0x0
8010633c:	68 fc 03 00 00       	push   $0x3fc
80106341:	e8 7f ff ff ff       	call   801062c5 <outb>
80106346:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0x01);    // Enable receive interrupts.
80106349:	6a 01                	push   $0x1
8010634b:	68 f9 03 00 00       	push   $0x3f9
80106350:	e8 70 ff ff ff       	call   801062c5 <outb>
80106355:	83 c4 08             	add    $0x8,%esp

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
80106358:	68 fd 03 00 00       	push   $0x3fd
8010635d:	e8 46 ff ff ff       	call   801062a8 <inb>
80106362:	83 c4 04             	add    $0x4,%esp
80106365:	3c ff                	cmp    $0xff,%al
80106367:	74 61                	je     801063ca <uartinit+0xe4>
    return;
  uart = 1;
80106369:	c7 05 78 6b 19 80 01 	movl   $0x1,0x80196b78
80106370:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
80106373:	68 fa 03 00 00       	push   $0x3fa
80106378:	e8 2b ff ff ff       	call   801062a8 <inb>
8010637d:	83 c4 04             	add    $0x4,%esp
  inb(COM1+0);
80106380:	68 f8 03 00 00       	push   $0x3f8
80106385:	e8 1e ff ff ff       	call   801062a8 <inb>
8010638a:	83 c4 04             	add    $0x4,%esp
  ioapicenable(IRQ_COM1, 0);
8010638d:	83 ec 08             	sub    $0x8,%esp
80106390:	6a 00                	push   $0x0
80106392:	6a 04                	push   $0x4
80106394:	e8 95 c2 ff ff       	call   8010262e <ioapicenable>
80106399:	83 c4 10             	add    $0x10,%esp

  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
8010639c:	c7 45 f4 7c a6 10 80 	movl   $0x8010a67c,-0xc(%ebp)
801063a3:	eb 19                	jmp    801063be <uartinit+0xd8>
    uartputc(*p);
801063a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801063a8:	0f b6 00             	movzbl (%eax),%eax
801063ab:	0f be c0             	movsbl %al,%eax
801063ae:	83 ec 0c             	sub    $0xc,%esp
801063b1:	50                   	push   %eax
801063b2:	e8 16 00 00 00       	call   801063cd <uartputc>
801063b7:	83 c4 10             	add    $0x10,%esp
  for(p="xv6...\n"; *p; p++)
801063ba:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801063be:	8b 45 f4             	mov    -0xc(%ebp),%eax
801063c1:	0f b6 00             	movzbl (%eax),%eax
801063c4:	84 c0                	test   %al,%al
801063c6:	75 dd                	jne    801063a5 <uartinit+0xbf>
801063c8:	eb 01                	jmp    801063cb <uartinit+0xe5>
    return;
801063ca:	90                   	nop
}
801063cb:	c9                   	leave  
801063cc:	c3                   	ret    

801063cd <uartputc>:

void
uartputc(int c)
{
801063cd:	55                   	push   %ebp
801063ce:	89 e5                	mov    %esp,%ebp
801063d0:	83 ec 18             	sub    $0x18,%esp
  int i;

  if(!uart)
801063d3:	a1 78 6b 19 80       	mov    0x80196b78,%eax
801063d8:	85 c0                	test   %eax,%eax
801063da:	74 53                	je     8010642f <uartputc+0x62>
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
801063dc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801063e3:	eb 11                	jmp    801063f6 <uartputc+0x29>
    microdelay(10);
801063e5:	83 ec 0c             	sub    $0xc,%esp
801063e8:	6a 0a                	push   $0xa
801063ea:	e8 48 c7 ff ff       	call   80102b37 <microdelay>
801063ef:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
801063f2:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801063f6:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
801063fa:	7f 1a                	jg     80106416 <uartputc+0x49>
801063fc:	83 ec 0c             	sub    $0xc,%esp
801063ff:	68 fd 03 00 00       	push   $0x3fd
80106404:	e8 9f fe ff ff       	call   801062a8 <inb>
80106409:	83 c4 10             	add    $0x10,%esp
8010640c:	0f b6 c0             	movzbl %al,%eax
8010640f:	83 e0 20             	and    $0x20,%eax
80106412:	85 c0                	test   %eax,%eax
80106414:	74 cf                	je     801063e5 <uartputc+0x18>
  outb(COM1+0, c);
80106416:	8b 45 08             	mov    0x8(%ebp),%eax
80106419:	0f b6 c0             	movzbl %al,%eax
8010641c:	83 ec 08             	sub    $0x8,%esp
8010641f:	50                   	push   %eax
80106420:	68 f8 03 00 00       	push   $0x3f8
80106425:	e8 9b fe ff ff       	call   801062c5 <outb>
8010642a:	83 c4 10             	add    $0x10,%esp
8010642d:	eb 01                	jmp    80106430 <uartputc+0x63>
    return;
8010642f:	90                   	nop
}
80106430:	c9                   	leave  
80106431:	c3                   	ret    

80106432 <uartgetc>:

static int
uartgetc(void)
{
80106432:	55                   	push   %ebp
80106433:	89 e5                	mov    %esp,%ebp
  if(!uart)
80106435:	a1 78 6b 19 80       	mov    0x80196b78,%eax
8010643a:	85 c0                	test   %eax,%eax
8010643c:	75 07                	jne    80106445 <uartgetc+0x13>
    return -1;
8010643e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106443:	eb 2e                	jmp    80106473 <uartgetc+0x41>
  if(!(inb(COM1+5) & 0x01))
80106445:	68 fd 03 00 00       	push   $0x3fd
8010644a:	e8 59 fe ff ff       	call   801062a8 <inb>
8010644f:	83 c4 04             	add    $0x4,%esp
80106452:	0f b6 c0             	movzbl %al,%eax
80106455:	83 e0 01             	and    $0x1,%eax
80106458:	85 c0                	test   %eax,%eax
8010645a:	75 07                	jne    80106463 <uartgetc+0x31>
    return -1;
8010645c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106461:	eb 10                	jmp    80106473 <uartgetc+0x41>
  return inb(COM1+0);
80106463:	68 f8 03 00 00       	push   $0x3f8
80106468:	e8 3b fe ff ff       	call   801062a8 <inb>
8010646d:	83 c4 04             	add    $0x4,%esp
80106470:	0f b6 c0             	movzbl %al,%eax
}
80106473:	c9                   	leave  
80106474:	c3                   	ret    

80106475 <uartintr>:

void
uartintr(void)
{
80106475:	55                   	push   %ebp
80106476:	89 e5                	mov    %esp,%ebp
80106478:	83 ec 08             	sub    $0x8,%esp
  consoleintr(uartgetc);
8010647b:	83 ec 0c             	sub    $0xc,%esp
8010647e:	68 32 64 10 80       	push   $0x80106432
80106483:	e8 4e a3 ff ff       	call   801007d6 <consoleintr>
80106488:	83 c4 10             	add    $0x10,%esp
}
8010648b:	90                   	nop
8010648c:	c9                   	leave  
8010648d:	c3                   	ret    

8010648e <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
8010648e:	6a 00                	push   $0x0
  pushl $0
80106490:	6a 00                	push   $0x0
  jmp alltraps
80106492:	e9 dc f8 ff ff       	jmp    80105d73 <alltraps>

80106497 <vector1>:
.globl vector1
vector1:
  pushl $0
80106497:	6a 00                	push   $0x0
  pushl $1
80106499:	6a 01                	push   $0x1
  jmp alltraps
8010649b:	e9 d3 f8 ff ff       	jmp    80105d73 <alltraps>

801064a0 <vector2>:
.globl vector2
vector2:
  pushl $0
801064a0:	6a 00                	push   $0x0
  pushl $2
801064a2:	6a 02                	push   $0x2
  jmp alltraps
801064a4:	e9 ca f8 ff ff       	jmp    80105d73 <alltraps>

801064a9 <vector3>:
.globl vector3
vector3:
  pushl $0
801064a9:	6a 00                	push   $0x0
  pushl $3
801064ab:	6a 03                	push   $0x3
  jmp alltraps
801064ad:	e9 c1 f8 ff ff       	jmp    80105d73 <alltraps>

801064b2 <vector4>:
.globl vector4
vector4:
  pushl $0
801064b2:	6a 00                	push   $0x0
  pushl $4
801064b4:	6a 04                	push   $0x4
  jmp alltraps
801064b6:	e9 b8 f8 ff ff       	jmp    80105d73 <alltraps>

801064bb <vector5>:
.globl vector5
vector5:
  pushl $0
801064bb:	6a 00                	push   $0x0
  pushl $5
801064bd:	6a 05                	push   $0x5
  jmp alltraps
801064bf:	e9 af f8 ff ff       	jmp    80105d73 <alltraps>

801064c4 <vector6>:
.globl vector6
vector6:
  pushl $0
801064c4:	6a 00                	push   $0x0
  pushl $6
801064c6:	6a 06                	push   $0x6
  jmp alltraps
801064c8:	e9 a6 f8 ff ff       	jmp    80105d73 <alltraps>

801064cd <vector7>:
.globl vector7
vector7:
  pushl $0
801064cd:	6a 00                	push   $0x0
  pushl $7
801064cf:	6a 07                	push   $0x7
  jmp alltraps
801064d1:	e9 9d f8 ff ff       	jmp    80105d73 <alltraps>

801064d6 <vector8>:
.globl vector8
vector8:
  pushl $8
801064d6:	6a 08                	push   $0x8
  jmp alltraps
801064d8:	e9 96 f8 ff ff       	jmp    80105d73 <alltraps>

801064dd <vector9>:
.globl vector9
vector9:
  pushl $0
801064dd:	6a 00                	push   $0x0
  pushl $9
801064df:	6a 09                	push   $0x9
  jmp alltraps
801064e1:	e9 8d f8 ff ff       	jmp    80105d73 <alltraps>

801064e6 <vector10>:
.globl vector10
vector10:
  pushl $10
801064e6:	6a 0a                	push   $0xa
  jmp alltraps
801064e8:	e9 86 f8 ff ff       	jmp    80105d73 <alltraps>

801064ed <vector11>:
.globl vector11
vector11:
  pushl $11
801064ed:	6a 0b                	push   $0xb
  jmp alltraps
801064ef:	e9 7f f8 ff ff       	jmp    80105d73 <alltraps>

801064f4 <vector12>:
.globl vector12
vector12:
  pushl $12
801064f4:	6a 0c                	push   $0xc
  jmp alltraps
801064f6:	e9 78 f8 ff ff       	jmp    80105d73 <alltraps>

801064fb <vector13>:
.globl vector13
vector13:
  pushl $13
801064fb:	6a 0d                	push   $0xd
  jmp alltraps
801064fd:	e9 71 f8 ff ff       	jmp    80105d73 <alltraps>

80106502 <vector14>:
.globl vector14
vector14:
  pushl $14
80106502:	6a 0e                	push   $0xe
  jmp alltraps
80106504:	e9 6a f8 ff ff       	jmp    80105d73 <alltraps>

80106509 <vector15>:
.globl vector15
vector15:
  pushl $0
80106509:	6a 00                	push   $0x0
  pushl $15
8010650b:	6a 0f                	push   $0xf
  jmp alltraps
8010650d:	e9 61 f8 ff ff       	jmp    80105d73 <alltraps>

80106512 <vector16>:
.globl vector16
vector16:
  pushl $0
80106512:	6a 00                	push   $0x0
  pushl $16
80106514:	6a 10                	push   $0x10
  jmp alltraps
80106516:	e9 58 f8 ff ff       	jmp    80105d73 <alltraps>

8010651b <vector17>:
.globl vector17
vector17:
  pushl $17
8010651b:	6a 11                	push   $0x11
  jmp alltraps
8010651d:	e9 51 f8 ff ff       	jmp    80105d73 <alltraps>

80106522 <vector18>:
.globl vector18
vector18:
  pushl $0
80106522:	6a 00                	push   $0x0
  pushl $18
80106524:	6a 12                	push   $0x12
  jmp alltraps
80106526:	e9 48 f8 ff ff       	jmp    80105d73 <alltraps>

8010652b <vector19>:
.globl vector19
vector19:
  pushl $0
8010652b:	6a 00                	push   $0x0
  pushl $19
8010652d:	6a 13                	push   $0x13
  jmp alltraps
8010652f:	e9 3f f8 ff ff       	jmp    80105d73 <alltraps>

80106534 <vector20>:
.globl vector20
vector20:
  pushl $0
80106534:	6a 00                	push   $0x0
  pushl $20
80106536:	6a 14                	push   $0x14
  jmp alltraps
80106538:	e9 36 f8 ff ff       	jmp    80105d73 <alltraps>

8010653d <vector21>:
.globl vector21
vector21:
  pushl $0
8010653d:	6a 00                	push   $0x0
  pushl $21
8010653f:	6a 15                	push   $0x15
  jmp alltraps
80106541:	e9 2d f8 ff ff       	jmp    80105d73 <alltraps>

80106546 <vector22>:
.globl vector22
vector22:
  pushl $0
80106546:	6a 00                	push   $0x0
  pushl $22
80106548:	6a 16                	push   $0x16
  jmp alltraps
8010654a:	e9 24 f8 ff ff       	jmp    80105d73 <alltraps>

8010654f <vector23>:
.globl vector23
vector23:
  pushl $0
8010654f:	6a 00                	push   $0x0
  pushl $23
80106551:	6a 17                	push   $0x17
  jmp alltraps
80106553:	e9 1b f8 ff ff       	jmp    80105d73 <alltraps>

80106558 <vector24>:
.globl vector24
vector24:
  pushl $0
80106558:	6a 00                	push   $0x0
  pushl $24
8010655a:	6a 18                	push   $0x18
  jmp alltraps
8010655c:	e9 12 f8 ff ff       	jmp    80105d73 <alltraps>

80106561 <vector25>:
.globl vector25
vector25:
  pushl $0
80106561:	6a 00                	push   $0x0
  pushl $25
80106563:	6a 19                	push   $0x19
  jmp alltraps
80106565:	e9 09 f8 ff ff       	jmp    80105d73 <alltraps>

8010656a <vector26>:
.globl vector26
vector26:
  pushl $0
8010656a:	6a 00                	push   $0x0
  pushl $26
8010656c:	6a 1a                	push   $0x1a
  jmp alltraps
8010656e:	e9 00 f8 ff ff       	jmp    80105d73 <alltraps>

80106573 <vector27>:
.globl vector27
vector27:
  pushl $0
80106573:	6a 00                	push   $0x0
  pushl $27
80106575:	6a 1b                	push   $0x1b
  jmp alltraps
80106577:	e9 f7 f7 ff ff       	jmp    80105d73 <alltraps>

8010657c <vector28>:
.globl vector28
vector28:
  pushl $0
8010657c:	6a 00                	push   $0x0
  pushl $28
8010657e:	6a 1c                	push   $0x1c
  jmp alltraps
80106580:	e9 ee f7 ff ff       	jmp    80105d73 <alltraps>

80106585 <vector29>:
.globl vector29
vector29:
  pushl $0
80106585:	6a 00                	push   $0x0
  pushl $29
80106587:	6a 1d                	push   $0x1d
  jmp alltraps
80106589:	e9 e5 f7 ff ff       	jmp    80105d73 <alltraps>

8010658e <vector30>:
.globl vector30
vector30:
  pushl $0
8010658e:	6a 00                	push   $0x0
  pushl $30
80106590:	6a 1e                	push   $0x1e
  jmp alltraps
80106592:	e9 dc f7 ff ff       	jmp    80105d73 <alltraps>

80106597 <vector31>:
.globl vector31
vector31:
  pushl $0
80106597:	6a 00                	push   $0x0
  pushl $31
80106599:	6a 1f                	push   $0x1f
  jmp alltraps
8010659b:	e9 d3 f7 ff ff       	jmp    80105d73 <alltraps>

801065a0 <vector32>:
.globl vector32
vector32:
  pushl $0
801065a0:	6a 00                	push   $0x0
  pushl $32
801065a2:	6a 20                	push   $0x20
  jmp alltraps
801065a4:	e9 ca f7 ff ff       	jmp    80105d73 <alltraps>

801065a9 <vector33>:
.globl vector33
vector33:
  pushl $0
801065a9:	6a 00                	push   $0x0
  pushl $33
801065ab:	6a 21                	push   $0x21
  jmp alltraps
801065ad:	e9 c1 f7 ff ff       	jmp    80105d73 <alltraps>

801065b2 <vector34>:
.globl vector34
vector34:
  pushl $0
801065b2:	6a 00                	push   $0x0
  pushl $34
801065b4:	6a 22                	push   $0x22
  jmp alltraps
801065b6:	e9 b8 f7 ff ff       	jmp    80105d73 <alltraps>

801065bb <vector35>:
.globl vector35
vector35:
  pushl $0
801065bb:	6a 00                	push   $0x0
  pushl $35
801065bd:	6a 23                	push   $0x23
  jmp alltraps
801065bf:	e9 af f7 ff ff       	jmp    80105d73 <alltraps>

801065c4 <vector36>:
.globl vector36
vector36:
  pushl $0
801065c4:	6a 00                	push   $0x0
  pushl $36
801065c6:	6a 24                	push   $0x24
  jmp alltraps
801065c8:	e9 a6 f7 ff ff       	jmp    80105d73 <alltraps>

801065cd <vector37>:
.globl vector37
vector37:
  pushl $0
801065cd:	6a 00                	push   $0x0
  pushl $37
801065cf:	6a 25                	push   $0x25
  jmp alltraps
801065d1:	e9 9d f7 ff ff       	jmp    80105d73 <alltraps>

801065d6 <vector38>:
.globl vector38
vector38:
  pushl $0
801065d6:	6a 00                	push   $0x0
  pushl $38
801065d8:	6a 26                	push   $0x26
  jmp alltraps
801065da:	e9 94 f7 ff ff       	jmp    80105d73 <alltraps>

801065df <vector39>:
.globl vector39
vector39:
  pushl $0
801065df:	6a 00                	push   $0x0
  pushl $39
801065e1:	6a 27                	push   $0x27
  jmp alltraps
801065e3:	e9 8b f7 ff ff       	jmp    80105d73 <alltraps>

801065e8 <vector40>:
.globl vector40
vector40:
  pushl $0
801065e8:	6a 00                	push   $0x0
  pushl $40
801065ea:	6a 28                	push   $0x28
  jmp alltraps
801065ec:	e9 82 f7 ff ff       	jmp    80105d73 <alltraps>

801065f1 <vector41>:
.globl vector41
vector41:
  pushl $0
801065f1:	6a 00                	push   $0x0
  pushl $41
801065f3:	6a 29                	push   $0x29
  jmp alltraps
801065f5:	e9 79 f7 ff ff       	jmp    80105d73 <alltraps>

801065fa <vector42>:
.globl vector42
vector42:
  pushl $0
801065fa:	6a 00                	push   $0x0
  pushl $42
801065fc:	6a 2a                	push   $0x2a
  jmp alltraps
801065fe:	e9 70 f7 ff ff       	jmp    80105d73 <alltraps>

80106603 <vector43>:
.globl vector43
vector43:
  pushl $0
80106603:	6a 00                	push   $0x0
  pushl $43
80106605:	6a 2b                	push   $0x2b
  jmp alltraps
80106607:	e9 67 f7 ff ff       	jmp    80105d73 <alltraps>

8010660c <vector44>:
.globl vector44
vector44:
  pushl $0
8010660c:	6a 00                	push   $0x0
  pushl $44
8010660e:	6a 2c                	push   $0x2c
  jmp alltraps
80106610:	e9 5e f7 ff ff       	jmp    80105d73 <alltraps>

80106615 <vector45>:
.globl vector45
vector45:
  pushl $0
80106615:	6a 00                	push   $0x0
  pushl $45
80106617:	6a 2d                	push   $0x2d
  jmp alltraps
80106619:	e9 55 f7 ff ff       	jmp    80105d73 <alltraps>

8010661e <vector46>:
.globl vector46
vector46:
  pushl $0
8010661e:	6a 00                	push   $0x0
  pushl $46
80106620:	6a 2e                	push   $0x2e
  jmp alltraps
80106622:	e9 4c f7 ff ff       	jmp    80105d73 <alltraps>

80106627 <vector47>:
.globl vector47
vector47:
  pushl $0
80106627:	6a 00                	push   $0x0
  pushl $47
80106629:	6a 2f                	push   $0x2f
  jmp alltraps
8010662b:	e9 43 f7 ff ff       	jmp    80105d73 <alltraps>

80106630 <vector48>:
.globl vector48
vector48:
  pushl $0
80106630:	6a 00                	push   $0x0
  pushl $48
80106632:	6a 30                	push   $0x30
  jmp alltraps
80106634:	e9 3a f7 ff ff       	jmp    80105d73 <alltraps>

80106639 <vector49>:
.globl vector49
vector49:
  pushl $0
80106639:	6a 00                	push   $0x0
  pushl $49
8010663b:	6a 31                	push   $0x31
  jmp alltraps
8010663d:	e9 31 f7 ff ff       	jmp    80105d73 <alltraps>

80106642 <vector50>:
.globl vector50
vector50:
  pushl $0
80106642:	6a 00                	push   $0x0
  pushl $50
80106644:	6a 32                	push   $0x32
  jmp alltraps
80106646:	e9 28 f7 ff ff       	jmp    80105d73 <alltraps>

8010664b <vector51>:
.globl vector51
vector51:
  pushl $0
8010664b:	6a 00                	push   $0x0
  pushl $51
8010664d:	6a 33                	push   $0x33
  jmp alltraps
8010664f:	e9 1f f7 ff ff       	jmp    80105d73 <alltraps>

80106654 <vector52>:
.globl vector52
vector52:
  pushl $0
80106654:	6a 00                	push   $0x0
  pushl $52
80106656:	6a 34                	push   $0x34
  jmp alltraps
80106658:	e9 16 f7 ff ff       	jmp    80105d73 <alltraps>

8010665d <vector53>:
.globl vector53
vector53:
  pushl $0
8010665d:	6a 00                	push   $0x0
  pushl $53
8010665f:	6a 35                	push   $0x35
  jmp alltraps
80106661:	e9 0d f7 ff ff       	jmp    80105d73 <alltraps>

80106666 <vector54>:
.globl vector54
vector54:
  pushl $0
80106666:	6a 00                	push   $0x0
  pushl $54
80106668:	6a 36                	push   $0x36
  jmp alltraps
8010666a:	e9 04 f7 ff ff       	jmp    80105d73 <alltraps>

8010666f <vector55>:
.globl vector55
vector55:
  pushl $0
8010666f:	6a 00                	push   $0x0
  pushl $55
80106671:	6a 37                	push   $0x37
  jmp alltraps
80106673:	e9 fb f6 ff ff       	jmp    80105d73 <alltraps>

80106678 <vector56>:
.globl vector56
vector56:
  pushl $0
80106678:	6a 00                	push   $0x0
  pushl $56
8010667a:	6a 38                	push   $0x38
  jmp alltraps
8010667c:	e9 f2 f6 ff ff       	jmp    80105d73 <alltraps>

80106681 <vector57>:
.globl vector57
vector57:
  pushl $0
80106681:	6a 00                	push   $0x0
  pushl $57
80106683:	6a 39                	push   $0x39
  jmp alltraps
80106685:	e9 e9 f6 ff ff       	jmp    80105d73 <alltraps>

8010668a <vector58>:
.globl vector58
vector58:
  pushl $0
8010668a:	6a 00                	push   $0x0
  pushl $58
8010668c:	6a 3a                	push   $0x3a
  jmp alltraps
8010668e:	e9 e0 f6 ff ff       	jmp    80105d73 <alltraps>

80106693 <vector59>:
.globl vector59
vector59:
  pushl $0
80106693:	6a 00                	push   $0x0
  pushl $59
80106695:	6a 3b                	push   $0x3b
  jmp alltraps
80106697:	e9 d7 f6 ff ff       	jmp    80105d73 <alltraps>

8010669c <vector60>:
.globl vector60
vector60:
  pushl $0
8010669c:	6a 00                	push   $0x0
  pushl $60
8010669e:	6a 3c                	push   $0x3c
  jmp alltraps
801066a0:	e9 ce f6 ff ff       	jmp    80105d73 <alltraps>

801066a5 <vector61>:
.globl vector61
vector61:
  pushl $0
801066a5:	6a 00                	push   $0x0
  pushl $61
801066a7:	6a 3d                	push   $0x3d
  jmp alltraps
801066a9:	e9 c5 f6 ff ff       	jmp    80105d73 <alltraps>

801066ae <vector62>:
.globl vector62
vector62:
  pushl $0
801066ae:	6a 00                	push   $0x0
  pushl $62
801066b0:	6a 3e                	push   $0x3e
  jmp alltraps
801066b2:	e9 bc f6 ff ff       	jmp    80105d73 <alltraps>

801066b7 <vector63>:
.globl vector63
vector63:
  pushl $0
801066b7:	6a 00                	push   $0x0
  pushl $63
801066b9:	6a 3f                	push   $0x3f
  jmp alltraps
801066bb:	e9 b3 f6 ff ff       	jmp    80105d73 <alltraps>

801066c0 <vector64>:
.globl vector64
vector64:
  pushl $0
801066c0:	6a 00                	push   $0x0
  pushl $64
801066c2:	6a 40                	push   $0x40
  jmp alltraps
801066c4:	e9 aa f6 ff ff       	jmp    80105d73 <alltraps>

801066c9 <vector65>:
.globl vector65
vector65:
  pushl $0
801066c9:	6a 00                	push   $0x0
  pushl $65
801066cb:	6a 41                	push   $0x41
  jmp alltraps
801066cd:	e9 a1 f6 ff ff       	jmp    80105d73 <alltraps>

801066d2 <vector66>:
.globl vector66
vector66:
  pushl $0
801066d2:	6a 00                	push   $0x0
  pushl $66
801066d4:	6a 42                	push   $0x42
  jmp alltraps
801066d6:	e9 98 f6 ff ff       	jmp    80105d73 <alltraps>

801066db <vector67>:
.globl vector67
vector67:
  pushl $0
801066db:	6a 00                	push   $0x0
  pushl $67
801066dd:	6a 43                	push   $0x43
  jmp alltraps
801066df:	e9 8f f6 ff ff       	jmp    80105d73 <alltraps>

801066e4 <vector68>:
.globl vector68
vector68:
  pushl $0
801066e4:	6a 00                	push   $0x0
  pushl $68
801066e6:	6a 44                	push   $0x44
  jmp alltraps
801066e8:	e9 86 f6 ff ff       	jmp    80105d73 <alltraps>

801066ed <vector69>:
.globl vector69
vector69:
  pushl $0
801066ed:	6a 00                	push   $0x0
  pushl $69
801066ef:	6a 45                	push   $0x45
  jmp alltraps
801066f1:	e9 7d f6 ff ff       	jmp    80105d73 <alltraps>

801066f6 <vector70>:
.globl vector70
vector70:
  pushl $0
801066f6:	6a 00                	push   $0x0
  pushl $70
801066f8:	6a 46                	push   $0x46
  jmp alltraps
801066fa:	e9 74 f6 ff ff       	jmp    80105d73 <alltraps>

801066ff <vector71>:
.globl vector71
vector71:
  pushl $0
801066ff:	6a 00                	push   $0x0
  pushl $71
80106701:	6a 47                	push   $0x47
  jmp alltraps
80106703:	e9 6b f6 ff ff       	jmp    80105d73 <alltraps>

80106708 <vector72>:
.globl vector72
vector72:
  pushl $0
80106708:	6a 00                	push   $0x0
  pushl $72
8010670a:	6a 48                	push   $0x48
  jmp alltraps
8010670c:	e9 62 f6 ff ff       	jmp    80105d73 <alltraps>

80106711 <vector73>:
.globl vector73
vector73:
  pushl $0
80106711:	6a 00                	push   $0x0
  pushl $73
80106713:	6a 49                	push   $0x49
  jmp alltraps
80106715:	e9 59 f6 ff ff       	jmp    80105d73 <alltraps>

8010671a <vector74>:
.globl vector74
vector74:
  pushl $0
8010671a:	6a 00                	push   $0x0
  pushl $74
8010671c:	6a 4a                	push   $0x4a
  jmp alltraps
8010671e:	e9 50 f6 ff ff       	jmp    80105d73 <alltraps>

80106723 <vector75>:
.globl vector75
vector75:
  pushl $0
80106723:	6a 00                	push   $0x0
  pushl $75
80106725:	6a 4b                	push   $0x4b
  jmp alltraps
80106727:	e9 47 f6 ff ff       	jmp    80105d73 <alltraps>

8010672c <vector76>:
.globl vector76
vector76:
  pushl $0
8010672c:	6a 00                	push   $0x0
  pushl $76
8010672e:	6a 4c                	push   $0x4c
  jmp alltraps
80106730:	e9 3e f6 ff ff       	jmp    80105d73 <alltraps>

80106735 <vector77>:
.globl vector77
vector77:
  pushl $0
80106735:	6a 00                	push   $0x0
  pushl $77
80106737:	6a 4d                	push   $0x4d
  jmp alltraps
80106739:	e9 35 f6 ff ff       	jmp    80105d73 <alltraps>

8010673e <vector78>:
.globl vector78
vector78:
  pushl $0
8010673e:	6a 00                	push   $0x0
  pushl $78
80106740:	6a 4e                	push   $0x4e
  jmp alltraps
80106742:	e9 2c f6 ff ff       	jmp    80105d73 <alltraps>

80106747 <vector79>:
.globl vector79
vector79:
  pushl $0
80106747:	6a 00                	push   $0x0
  pushl $79
80106749:	6a 4f                	push   $0x4f
  jmp alltraps
8010674b:	e9 23 f6 ff ff       	jmp    80105d73 <alltraps>

80106750 <vector80>:
.globl vector80
vector80:
  pushl $0
80106750:	6a 00                	push   $0x0
  pushl $80
80106752:	6a 50                	push   $0x50
  jmp alltraps
80106754:	e9 1a f6 ff ff       	jmp    80105d73 <alltraps>

80106759 <vector81>:
.globl vector81
vector81:
  pushl $0
80106759:	6a 00                	push   $0x0
  pushl $81
8010675b:	6a 51                	push   $0x51
  jmp alltraps
8010675d:	e9 11 f6 ff ff       	jmp    80105d73 <alltraps>

80106762 <vector82>:
.globl vector82
vector82:
  pushl $0
80106762:	6a 00                	push   $0x0
  pushl $82
80106764:	6a 52                	push   $0x52
  jmp alltraps
80106766:	e9 08 f6 ff ff       	jmp    80105d73 <alltraps>

8010676b <vector83>:
.globl vector83
vector83:
  pushl $0
8010676b:	6a 00                	push   $0x0
  pushl $83
8010676d:	6a 53                	push   $0x53
  jmp alltraps
8010676f:	e9 ff f5 ff ff       	jmp    80105d73 <alltraps>

80106774 <vector84>:
.globl vector84
vector84:
  pushl $0
80106774:	6a 00                	push   $0x0
  pushl $84
80106776:	6a 54                	push   $0x54
  jmp alltraps
80106778:	e9 f6 f5 ff ff       	jmp    80105d73 <alltraps>

8010677d <vector85>:
.globl vector85
vector85:
  pushl $0
8010677d:	6a 00                	push   $0x0
  pushl $85
8010677f:	6a 55                	push   $0x55
  jmp alltraps
80106781:	e9 ed f5 ff ff       	jmp    80105d73 <alltraps>

80106786 <vector86>:
.globl vector86
vector86:
  pushl $0
80106786:	6a 00                	push   $0x0
  pushl $86
80106788:	6a 56                	push   $0x56
  jmp alltraps
8010678a:	e9 e4 f5 ff ff       	jmp    80105d73 <alltraps>

8010678f <vector87>:
.globl vector87
vector87:
  pushl $0
8010678f:	6a 00                	push   $0x0
  pushl $87
80106791:	6a 57                	push   $0x57
  jmp alltraps
80106793:	e9 db f5 ff ff       	jmp    80105d73 <alltraps>

80106798 <vector88>:
.globl vector88
vector88:
  pushl $0
80106798:	6a 00                	push   $0x0
  pushl $88
8010679a:	6a 58                	push   $0x58
  jmp alltraps
8010679c:	e9 d2 f5 ff ff       	jmp    80105d73 <alltraps>

801067a1 <vector89>:
.globl vector89
vector89:
  pushl $0
801067a1:	6a 00                	push   $0x0
  pushl $89
801067a3:	6a 59                	push   $0x59
  jmp alltraps
801067a5:	e9 c9 f5 ff ff       	jmp    80105d73 <alltraps>

801067aa <vector90>:
.globl vector90
vector90:
  pushl $0
801067aa:	6a 00                	push   $0x0
  pushl $90
801067ac:	6a 5a                	push   $0x5a
  jmp alltraps
801067ae:	e9 c0 f5 ff ff       	jmp    80105d73 <alltraps>

801067b3 <vector91>:
.globl vector91
vector91:
  pushl $0
801067b3:	6a 00                	push   $0x0
  pushl $91
801067b5:	6a 5b                	push   $0x5b
  jmp alltraps
801067b7:	e9 b7 f5 ff ff       	jmp    80105d73 <alltraps>

801067bc <vector92>:
.globl vector92
vector92:
  pushl $0
801067bc:	6a 00                	push   $0x0
  pushl $92
801067be:	6a 5c                	push   $0x5c
  jmp alltraps
801067c0:	e9 ae f5 ff ff       	jmp    80105d73 <alltraps>

801067c5 <vector93>:
.globl vector93
vector93:
  pushl $0
801067c5:	6a 00                	push   $0x0
  pushl $93
801067c7:	6a 5d                	push   $0x5d
  jmp alltraps
801067c9:	e9 a5 f5 ff ff       	jmp    80105d73 <alltraps>

801067ce <vector94>:
.globl vector94
vector94:
  pushl $0
801067ce:	6a 00                	push   $0x0
  pushl $94
801067d0:	6a 5e                	push   $0x5e
  jmp alltraps
801067d2:	e9 9c f5 ff ff       	jmp    80105d73 <alltraps>

801067d7 <vector95>:
.globl vector95
vector95:
  pushl $0
801067d7:	6a 00                	push   $0x0
  pushl $95
801067d9:	6a 5f                	push   $0x5f
  jmp alltraps
801067db:	e9 93 f5 ff ff       	jmp    80105d73 <alltraps>

801067e0 <vector96>:
.globl vector96
vector96:
  pushl $0
801067e0:	6a 00                	push   $0x0
  pushl $96
801067e2:	6a 60                	push   $0x60
  jmp alltraps
801067e4:	e9 8a f5 ff ff       	jmp    80105d73 <alltraps>

801067e9 <vector97>:
.globl vector97
vector97:
  pushl $0
801067e9:	6a 00                	push   $0x0
  pushl $97
801067eb:	6a 61                	push   $0x61
  jmp alltraps
801067ed:	e9 81 f5 ff ff       	jmp    80105d73 <alltraps>

801067f2 <vector98>:
.globl vector98
vector98:
  pushl $0
801067f2:	6a 00                	push   $0x0
  pushl $98
801067f4:	6a 62                	push   $0x62
  jmp alltraps
801067f6:	e9 78 f5 ff ff       	jmp    80105d73 <alltraps>

801067fb <vector99>:
.globl vector99
vector99:
  pushl $0
801067fb:	6a 00                	push   $0x0
  pushl $99
801067fd:	6a 63                	push   $0x63
  jmp alltraps
801067ff:	e9 6f f5 ff ff       	jmp    80105d73 <alltraps>

80106804 <vector100>:
.globl vector100
vector100:
  pushl $0
80106804:	6a 00                	push   $0x0
  pushl $100
80106806:	6a 64                	push   $0x64
  jmp alltraps
80106808:	e9 66 f5 ff ff       	jmp    80105d73 <alltraps>

8010680d <vector101>:
.globl vector101
vector101:
  pushl $0
8010680d:	6a 00                	push   $0x0
  pushl $101
8010680f:	6a 65                	push   $0x65
  jmp alltraps
80106811:	e9 5d f5 ff ff       	jmp    80105d73 <alltraps>

80106816 <vector102>:
.globl vector102
vector102:
  pushl $0
80106816:	6a 00                	push   $0x0
  pushl $102
80106818:	6a 66                	push   $0x66
  jmp alltraps
8010681a:	e9 54 f5 ff ff       	jmp    80105d73 <alltraps>

8010681f <vector103>:
.globl vector103
vector103:
  pushl $0
8010681f:	6a 00                	push   $0x0
  pushl $103
80106821:	6a 67                	push   $0x67
  jmp alltraps
80106823:	e9 4b f5 ff ff       	jmp    80105d73 <alltraps>

80106828 <vector104>:
.globl vector104
vector104:
  pushl $0
80106828:	6a 00                	push   $0x0
  pushl $104
8010682a:	6a 68                	push   $0x68
  jmp alltraps
8010682c:	e9 42 f5 ff ff       	jmp    80105d73 <alltraps>

80106831 <vector105>:
.globl vector105
vector105:
  pushl $0
80106831:	6a 00                	push   $0x0
  pushl $105
80106833:	6a 69                	push   $0x69
  jmp alltraps
80106835:	e9 39 f5 ff ff       	jmp    80105d73 <alltraps>

8010683a <vector106>:
.globl vector106
vector106:
  pushl $0
8010683a:	6a 00                	push   $0x0
  pushl $106
8010683c:	6a 6a                	push   $0x6a
  jmp alltraps
8010683e:	e9 30 f5 ff ff       	jmp    80105d73 <alltraps>

80106843 <vector107>:
.globl vector107
vector107:
  pushl $0
80106843:	6a 00                	push   $0x0
  pushl $107
80106845:	6a 6b                	push   $0x6b
  jmp alltraps
80106847:	e9 27 f5 ff ff       	jmp    80105d73 <alltraps>

8010684c <vector108>:
.globl vector108
vector108:
  pushl $0
8010684c:	6a 00                	push   $0x0
  pushl $108
8010684e:	6a 6c                	push   $0x6c
  jmp alltraps
80106850:	e9 1e f5 ff ff       	jmp    80105d73 <alltraps>

80106855 <vector109>:
.globl vector109
vector109:
  pushl $0
80106855:	6a 00                	push   $0x0
  pushl $109
80106857:	6a 6d                	push   $0x6d
  jmp alltraps
80106859:	e9 15 f5 ff ff       	jmp    80105d73 <alltraps>

8010685e <vector110>:
.globl vector110
vector110:
  pushl $0
8010685e:	6a 00                	push   $0x0
  pushl $110
80106860:	6a 6e                	push   $0x6e
  jmp alltraps
80106862:	e9 0c f5 ff ff       	jmp    80105d73 <alltraps>

80106867 <vector111>:
.globl vector111
vector111:
  pushl $0
80106867:	6a 00                	push   $0x0
  pushl $111
80106869:	6a 6f                	push   $0x6f
  jmp alltraps
8010686b:	e9 03 f5 ff ff       	jmp    80105d73 <alltraps>

80106870 <vector112>:
.globl vector112
vector112:
  pushl $0
80106870:	6a 00                	push   $0x0
  pushl $112
80106872:	6a 70                	push   $0x70
  jmp alltraps
80106874:	e9 fa f4 ff ff       	jmp    80105d73 <alltraps>

80106879 <vector113>:
.globl vector113
vector113:
  pushl $0
80106879:	6a 00                	push   $0x0
  pushl $113
8010687b:	6a 71                	push   $0x71
  jmp alltraps
8010687d:	e9 f1 f4 ff ff       	jmp    80105d73 <alltraps>

80106882 <vector114>:
.globl vector114
vector114:
  pushl $0
80106882:	6a 00                	push   $0x0
  pushl $114
80106884:	6a 72                	push   $0x72
  jmp alltraps
80106886:	e9 e8 f4 ff ff       	jmp    80105d73 <alltraps>

8010688b <vector115>:
.globl vector115
vector115:
  pushl $0
8010688b:	6a 00                	push   $0x0
  pushl $115
8010688d:	6a 73                	push   $0x73
  jmp alltraps
8010688f:	e9 df f4 ff ff       	jmp    80105d73 <alltraps>

80106894 <vector116>:
.globl vector116
vector116:
  pushl $0
80106894:	6a 00                	push   $0x0
  pushl $116
80106896:	6a 74                	push   $0x74
  jmp alltraps
80106898:	e9 d6 f4 ff ff       	jmp    80105d73 <alltraps>

8010689d <vector117>:
.globl vector117
vector117:
  pushl $0
8010689d:	6a 00                	push   $0x0
  pushl $117
8010689f:	6a 75                	push   $0x75
  jmp alltraps
801068a1:	e9 cd f4 ff ff       	jmp    80105d73 <alltraps>

801068a6 <vector118>:
.globl vector118
vector118:
  pushl $0
801068a6:	6a 00                	push   $0x0
  pushl $118
801068a8:	6a 76                	push   $0x76
  jmp alltraps
801068aa:	e9 c4 f4 ff ff       	jmp    80105d73 <alltraps>

801068af <vector119>:
.globl vector119
vector119:
  pushl $0
801068af:	6a 00                	push   $0x0
  pushl $119
801068b1:	6a 77                	push   $0x77
  jmp alltraps
801068b3:	e9 bb f4 ff ff       	jmp    80105d73 <alltraps>

801068b8 <vector120>:
.globl vector120
vector120:
  pushl $0
801068b8:	6a 00                	push   $0x0
  pushl $120
801068ba:	6a 78                	push   $0x78
  jmp alltraps
801068bc:	e9 b2 f4 ff ff       	jmp    80105d73 <alltraps>

801068c1 <vector121>:
.globl vector121
vector121:
  pushl $0
801068c1:	6a 00                	push   $0x0
  pushl $121
801068c3:	6a 79                	push   $0x79
  jmp alltraps
801068c5:	e9 a9 f4 ff ff       	jmp    80105d73 <alltraps>

801068ca <vector122>:
.globl vector122
vector122:
  pushl $0
801068ca:	6a 00                	push   $0x0
  pushl $122
801068cc:	6a 7a                	push   $0x7a
  jmp alltraps
801068ce:	e9 a0 f4 ff ff       	jmp    80105d73 <alltraps>

801068d3 <vector123>:
.globl vector123
vector123:
  pushl $0
801068d3:	6a 00                	push   $0x0
  pushl $123
801068d5:	6a 7b                	push   $0x7b
  jmp alltraps
801068d7:	e9 97 f4 ff ff       	jmp    80105d73 <alltraps>

801068dc <vector124>:
.globl vector124
vector124:
  pushl $0
801068dc:	6a 00                	push   $0x0
  pushl $124
801068de:	6a 7c                	push   $0x7c
  jmp alltraps
801068e0:	e9 8e f4 ff ff       	jmp    80105d73 <alltraps>

801068e5 <vector125>:
.globl vector125
vector125:
  pushl $0
801068e5:	6a 00                	push   $0x0
  pushl $125
801068e7:	6a 7d                	push   $0x7d
  jmp alltraps
801068e9:	e9 85 f4 ff ff       	jmp    80105d73 <alltraps>

801068ee <vector126>:
.globl vector126
vector126:
  pushl $0
801068ee:	6a 00                	push   $0x0
  pushl $126
801068f0:	6a 7e                	push   $0x7e
  jmp alltraps
801068f2:	e9 7c f4 ff ff       	jmp    80105d73 <alltraps>

801068f7 <vector127>:
.globl vector127
vector127:
  pushl $0
801068f7:	6a 00                	push   $0x0
  pushl $127
801068f9:	6a 7f                	push   $0x7f
  jmp alltraps
801068fb:	e9 73 f4 ff ff       	jmp    80105d73 <alltraps>

80106900 <vector128>:
.globl vector128
vector128:
  pushl $0
80106900:	6a 00                	push   $0x0
  pushl $128
80106902:	68 80 00 00 00       	push   $0x80
  jmp alltraps
80106907:	e9 67 f4 ff ff       	jmp    80105d73 <alltraps>

8010690c <vector129>:
.globl vector129
vector129:
  pushl $0
8010690c:	6a 00                	push   $0x0
  pushl $129
8010690e:	68 81 00 00 00       	push   $0x81
  jmp alltraps
80106913:	e9 5b f4 ff ff       	jmp    80105d73 <alltraps>

80106918 <vector130>:
.globl vector130
vector130:
  pushl $0
80106918:	6a 00                	push   $0x0
  pushl $130
8010691a:	68 82 00 00 00       	push   $0x82
  jmp alltraps
8010691f:	e9 4f f4 ff ff       	jmp    80105d73 <alltraps>

80106924 <vector131>:
.globl vector131
vector131:
  pushl $0
80106924:	6a 00                	push   $0x0
  pushl $131
80106926:	68 83 00 00 00       	push   $0x83
  jmp alltraps
8010692b:	e9 43 f4 ff ff       	jmp    80105d73 <alltraps>

80106930 <vector132>:
.globl vector132
vector132:
  pushl $0
80106930:	6a 00                	push   $0x0
  pushl $132
80106932:	68 84 00 00 00       	push   $0x84
  jmp alltraps
80106937:	e9 37 f4 ff ff       	jmp    80105d73 <alltraps>

8010693c <vector133>:
.globl vector133
vector133:
  pushl $0
8010693c:	6a 00                	push   $0x0
  pushl $133
8010693e:	68 85 00 00 00       	push   $0x85
  jmp alltraps
80106943:	e9 2b f4 ff ff       	jmp    80105d73 <alltraps>

80106948 <vector134>:
.globl vector134
vector134:
  pushl $0
80106948:	6a 00                	push   $0x0
  pushl $134
8010694a:	68 86 00 00 00       	push   $0x86
  jmp alltraps
8010694f:	e9 1f f4 ff ff       	jmp    80105d73 <alltraps>

80106954 <vector135>:
.globl vector135
vector135:
  pushl $0
80106954:	6a 00                	push   $0x0
  pushl $135
80106956:	68 87 00 00 00       	push   $0x87
  jmp alltraps
8010695b:	e9 13 f4 ff ff       	jmp    80105d73 <alltraps>

80106960 <vector136>:
.globl vector136
vector136:
  pushl $0
80106960:	6a 00                	push   $0x0
  pushl $136
80106962:	68 88 00 00 00       	push   $0x88
  jmp alltraps
80106967:	e9 07 f4 ff ff       	jmp    80105d73 <alltraps>

8010696c <vector137>:
.globl vector137
vector137:
  pushl $0
8010696c:	6a 00                	push   $0x0
  pushl $137
8010696e:	68 89 00 00 00       	push   $0x89
  jmp alltraps
80106973:	e9 fb f3 ff ff       	jmp    80105d73 <alltraps>

80106978 <vector138>:
.globl vector138
vector138:
  pushl $0
80106978:	6a 00                	push   $0x0
  pushl $138
8010697a:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
8010697f:	e9 ef f3 ff ff       	jmp    80105d73 <alltraps>

80106984 <vector139>:
.globl vector139
vector139:
  pushl $0
80106984:	6a 00                	push   $0x0
  pushl $139
80106986:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
8010698b:	e9 e3 f3 ff ff       	jmp    80105d73 <alltraps>

80106990 <vector140>:
.globl vector140
vector140:
  pushl $0
80106990:	6a 00                	push   $0x0
  pushl $140
80106992:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
80106997:	e9 d7 f3 ff ff       	jmp    80105d73 <alltraps>

8010699c <vector141>:
.globl vector141
vector141:
  pushl $0
8010699c:	6a 00                	push   $0x0
  pushl $141
8010699e:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
801069a3:	e9 cb f3 ff ff       	jmp    80105d73 <alltraps>

801069a8 <vector142>:
.globl vector142
vector142:
  pushl $0
801069a8:	6a 00                	push   $0x0
  pushl $142
801069aa:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
801069af:	e9 bf f3 ff ff       	jmp    80105d73 <alltraps>

801069b4 <vector143>:
.globl vector143
vector143:
  pushl $0
801069b4:	6a 00                	push   $0x0
  pushl $143
801069b6:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
801069bb:	e9 b3 f3 ff ff       	jmp    80105d73 <alltraps>

801069c0 <vector144>:
.globl vector144
vector144:
  pushl $0
801069c0:	6a 00                	push   $0x0
  pushl $144
801069c2:	68 90 00 00 00       	push   $0x90
  jmp alltraps
801069c7:	e9 a7 f3 ff ff       	jmp    80105d73 <alltraps>

801069cc <vector145>:
.globl vector145
vector145:
  pushl $0
801069cc:	6a 00                	push   $0x0
  pushl $145
801069ce:	68 91 00 00 00       	push   $0x91
  jmp alltraps
801069d3:	e9 9b f3 ff ff       	jmp    80105d73 <alltraps>

801069d8 <vector146>:
.globl vector146
vector146:
  pushl $0
801069d8:	6a 00                	push   $0x0
  pushl $146
801069da:	68 92 00 00 00       	push   $0x92
  jmp alltraps
801069df:	e9 8f f3 ff ff       	jmp    80105d73 <alltraps>

801069e4 <vector147>:
.globl vector147
vector147:
  pushl $0
801069e4:	6a 00                	push   $0x0
  pushl $147
801069e6:	68 93 00 00 00       	push   $0x93
  jmp alltraps
801069eb:	e9 83 f3 ff ff       	jmp    80105d73 <alltraps>

801069f0 <vector148>:
.globl vector148
vector148:
  pushl $0
801069f0:	6a 00                	push   $0x0
  pushl $148
801069f2:	68 94 00 00 00       	push   $0x94
  jmp alltraps
801069f7:	e9 77 f3 ff ff       	jmp    80105d73 <alltraps>

801069fc <vector149>:
.globl vector149
vector149:
  pushl $0
801069fc:	6a 00                	push   $0x0
  pushl $149
801069fe:	68 95 00 00 00       	push   $0x95
  jmp alltraps
80106a03:	e9 6b f3 ff ff       	jmp    80105d73 <alltraps>

80106a08 <vector150>:
.globl vector150
vector150:
  pushl $0
80106a08:	6a 00                	push   $0x0
  pushl $150
80106a0a:	68 96 00 00 00       	push   $0x96
  jmp alltraps
80106a0f:	e9 5f f3 ff ff       	jmp    80105d73 <alltraps>

80106a14 <vector151>:
.globl vector151
vector151:
  pushl $0
80106a14:	6a 00                	push   $0x0
  pushl $151
80106a16:	68 97 00 00 00       	push   $0x97
  jmp alltraps
80106a1b:	e9 53 f3 ff ff       	jmp    80105d73 <alltraps>

80106a20 <vector152>:
.globl vector152
vector152:
  pushl $0
80106a20:	6a 00                	push   $0x0
  pushl $152
80106a22:	68 98 00 00 00       	push   $0x98
  jmp alltraps
80106a27:	e9 47 f3 ff ff       	jmp    80105d73 <alltraps>

80106a2c <vector153>:
.globl vector153
vector153:
  pushl $0
80106a2c:	6a 00                	push   $0x0
  pushl $153
80106a2e:	68 99 00 00 00       	push   $0x99
  jmp alltraps
80106a33:	e9 3b f3 ff ff       	jmp    80105d73 <alltraps>

80106a38 <vector154>:
.globl vector154
vector154:
  pushl $0
80106a38:	6a 00                	push   $0x0
  pushl $154
80106a3a:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
80106a3f:	e9 2f f3 ff ff       	jmp    80105d73 <alltraps>

80106a44 <vector155>:
.globl vector155
vector155:
  pushl $0
80106a44:	6a 00                	push   $0x0
  pushl $155
80106a46:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
80106a4b:	e9 23 f3 ff ff       	jmp    80105d73 <alltraps>

80106a50 <vector156>:
.globl vector156
vector156:
  pushl $0
80106a50:	6a 00                	push   $0x0
  pushl $156
80106a52:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
80106a57:	e9 17 f3 ff ff       	jmp    80105d73 <alltraps>

80106a5c <vector157>:
.globl vector157
vector157:
  pushl $0
80106a5c:	6a 00                	push   $0x0
  pushl $157
80106a5e:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
80106a63:	e9 0b f3 ff ff       	jmp    80105d73 <alltraps>

80106a68 <vector158>:
.globl vector158
vector158:
  pushl $0
80106a68:	6a 00                	push   $0x0
  pushl $158
80106a6a:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
80106a6f:	e9 ff f2 ff ff       	jmp    80105d73 <alltraps>

80106a74 <vector159>:
.globl vector159
vector159:
  pushl $0
80106a74:	6a 00                	push   $0x0
  pushl $159
80106a76:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
80106a7b:	e9 f3 f2 ff ff       	jmp    80105d73 <alltraps>

80106a80 <vector160>:
.globl vector160
vector160:
  pushl $0
80106a80:	6a 00                	push   $0x0
  pushl $160
80106a82:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
80106a87:	e9 e7 f2 ff ff       	jmp    80105d73 <alltraps>

80106a8c <vector161>:
.globl vector161
vector161:
  pushl $0
80106a8c:	6a 00                	push   $0x0
  pushl $161
80106a8e:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
80106a93:	e9 db f2 ff ff       	jmp    80105d73 <alltraps>

80106a98 <vector162>:
.globl vector162
vector162:
  pushl $0
80106a98:	6a 00                	push   $0x0
  pushl $162
80106a9a:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
80106a9f:	e9 cf f2 ff ff       	jmp    80105d73 <alltraps>

80106aa4 <vector163>:
.globl vector163
vector163:
  pushl $0
80106aa4:	6a 00                	push   $0x0
  pushl $163
80106aa6:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
80106aab:	e9 c3 f2 ff ff       	jmp    80105d73 <alltraps>

80106ab0 <vector164>:
.globl vector164
vector164:
  pushl $0
80106ab0:	6a 00                	push   $0x0
  pushl $164
80106ab2:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
80106ab7:	e9 b7 f2 ff ff       	jmp    80105d73 <alltraps>

80106abc <vector165>:
.globl vector165
vector165:
  pushl $0
80106abc:	6a 00                	push   $0x0
  pushl $165
80106abe:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
80106ac3:	e9 ab f2 ff ff       	jmp    80105d73 <alltraps>

80106ac8 <vector166>:
.globl vector166
vector166:
  pushl $0
80106ac8:	6a 00                	push   $0x0
  pushl $166
80106aca:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
80106acf:	e9 9f f2 ff ff       	jmp    80105d73 <alltraps>

80106ad4 <vector167>:
.globl vector167
vector167:
  pushl $0
80106ad4:	6a 00                	push   $0x0
  pushl $167
80106ad6:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
80106adb:	e9 93 f2 ff ff       	jmp    80105d73 <alltraps>

80106ae0 <vector168>:
.globl vector168
vector168:
  pushl $0
80106ae0:	6a 00                	push   $0x0
  pushl $168
80106ae2:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
80106ae7:	e9 87 f2 ff ff       	jmp    80105d73 <alltraps>

80106aec <vector169>:
.globl vector169
vector169:
  pushl $0
80106aec:	6a 00                	push   $0x0
  pushl $169
80106aee:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
80106af3:	e9 7b f2 ff ff       	jmp    80105d73 <alltraps>

80106af8 <vector170>:
.globl vector170
vector170:
  pushl $0
80106af8:	6a 00                	push   $0x0
  pushl $170
80106afa:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
80106aff:	e9 6f f2 ff ff       	jmp    80105d73 <alltraps>

80106b04 <vector171>:
.globl vector171
vector171:
  pushl $0
80106b04:	6a 00                	push   $0x0
  pushl $171
80106b06:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
80106b0b:	e9 63 f2 ff ff       	jmp    80105d73 <alltraps>

80106b10 <vector172>:
.globl vector172
vector172:
  pushl $0
80106b10:	6a 00                	push   $0x0
  pushl $172
80106b12:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
80106b17:	e9 57 f2 ff ff       	jmp    80105d73 <alltraps>

80106b1c <vector173>:
.globl vector173
vector173:
  pushl $0
80106b1c:	6a 00                	push   $0x0
  pushl $173
80106b1e:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
80106b23:	e9 4b f2 ff ff       	jmp    80105d73 <alltraps>

80106b28 <vector174>:
.globl vector174
vector174:
  pushl $0
80106b28:	6a 00                	push   $0x0
  pushl $174
80106b2a:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
80106b2f:	e9 3f f2 ff ff       	jmp    80105d73 <alltraps>

80106b34 <vector175>:
.globl vector175
vector175:
  pushl $0
80106b34:	6a 00                	push   $0x0
  pushl $175
80106b36:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
80106b3b:	e9 33 f2 ff ff       	jmp    80105d73 <alltraps>

80106b40 <vector176>:
.globl vector176
vector176:
  pushl $0
80106b40:	6a 00                	push   $0x0
  pushl $176
80106b42:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
80106b47:	e9 27 f2 ff ff       	jmp    80105d73 <alltraps>

80106b4c <vector177>:
.globl vector177
vector177:
  pushl $0
80106b4c:	6a 00                	push   $0x0
  pushl $177
80106b4e:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
80106b53:	e9 1b f2 ff ff       	jmp    80105d73 <alltraps>

80106b58 <vector178>:
.globl vector178
vector178:
  pushl $0
80106b58:	6a 00                	push   $0x0
  pushl $178
80106b5a:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
80106b5f:	e9 0f f2 ff ff       	jmp    80105d73 <alltraps>

80106b64 <vector179>:
.globl vector179
vector179:
  pushl $0
80106b64:	6a 00                	push   $0x0
  pushl $179
80106b66:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
80106b6b:	e9 03 f2 ff ff       	jmp    80105d73 <alltraps>

80106b70 <vector180>:
.globl vector180
vector180:
  pushl $0
80106b70:	6a 00                	push   $0x0
  pushl $180
80106b72:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
80106b77:	e9 f7 f1 ff ff       	jmp    80105d73 <alltraps>

80106b7c <vector181>:
.globl vector181
vector181:
  pushl $0
80106b7c:	6a 00                	push   $0x0
  pushl $181
80106b7e:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
80106b83:	e9 eb f1 ff ff       	jmp    80105d73 <alltraps>

80106b88 <vector182>:
.globl vector182
vector182:
  pushl $0
80106b88:	6a 00                	push   $0x0
  pushl $182
80106b8a:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
80106b8f:	e9 df f1 ff ff       	jmp    80105d73 <alltraps>

80106b94 <vector183>:
.globl vector183
vector183:
  pushl $0
80106b94:	6a 00                	push   $0x0
  pushl $183
80106b96:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
80106b9b:	e9 d3 f1 ff ff       	jmp    80105d73 <alltraps>

80106ba0 <vector184>:
.globl vector184
vector184:
  pushl $0
80106ba0:	6a 00                	push   $0x0
  pushl $184
80106ba2:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
80106ba7:	e9 c7 f1 ff ff       	jmp    80105d73 <alltraps>

80106bac <vector185>:
.globl vector185
vector185:
  pushl $0
80106bac:	6a 00                	push   $0x0
  pushl $185
80106bae:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
80106bb3:	e9 bb f1 ff ff       	jmp    80105d73 <alltraps>

80106bb8 <vector186>:
.globl vector186
vector186:
  pushl $0
80106bb8:	6a 00                	push   $0x0
  pushl $186
80106bba:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
80106bbf:	e9 af f1 ff ff       	jmp    80105d73 <alltraps>

80106bc4 <vector187>:
.globl vector187
vector187:
  pushl $0
80106bc4:	6a 00                	push   $0x0
  pushl $187
80106bc6:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
80106bcb:	e9 a3 f1 ff ff       	jmp    80105d73 <alltraps>

80106bd0 <vector188>:
.globl vector188
vector188:
  pushl $0
80106bd0:	6a 00                	push   $0x0
  pushl $188
80106bd2:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
80106bd7:	e9 97 f1 ff ff       	jmp    80105d73 <alltraps>

80106bdc <vector189>:
.globl vector189
vector189:
  pushl $0
80106bdc:	6a 00                	push   $0x0
  pushl $189
80106bde:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
80106be3:	e9 8b f1 ff ff       	jmp    80105d73 <alltraps>

80106be8 <vector190>:
.globl vector190
vector190:
  pushl $0
80106be8:	6a 00                	push   $0x0
  pushl $190
80106bea:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
80106bef:	e9 7f f1 ff ff       	jmp    80105d73 <alltraps>

80106bf4 <vector191>:
.globl vector191
vector191:
  pushl $0
80106bf4:	6a 00                	push   $0x0
  pushl $191
80106bf6:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
80106bfb:	e9 73 f1 ff ff       	jmp    80105d73 <alltraps>

80106c00 <vector192>:
.globl vector192
vector192:
  pushl $0
80106c00:	6a 00                	push   $0x0
  pushl $192
80106c02:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
80106c07:	e9 67 f1 ff ff       	jmp    80105d73 <alltraps>

80106c0c <vector193>:
.globl vector193
vector193:
  pushl $0
80106c0c:	6a 00                	push   $0x0
  pushl $193
80106c0e:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
80106c13:	e9 5b f1 ff ff       	jmp    80105d73 <alltraps>

80106c18 <vector194>:
.globl vector194
vector194:
  pushl $0
80106c18:	6a 00                	push   $0x0
  pushl $194
80106c1a:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
80106c1f:	e9 4f f1 ff ff       	jmp    80105d73 <alltraps>

80106c24 <vector195>:
.globl vector195
vector195:
  pushl $0
80106c24:	6a 00                	push   $0x0
  pushl $195
80106c26:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
80106c2b:	e9 43 f1 ff ff       	jmp    80105d73 <alltraps>

80106c30 <vector196>:
.globl vector196
vector196:
  pushl $0
80106c30:	6a 00                	push   $0x0
  pushl $196
80106c32:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
80106c37:	e9 37 f1 ff ff       	jmp    80105d73 <alltraps>

80106c3c <vector197>:
.globl vector197
vector197:
  pushl $0
80106c3c:	6a 00                	push   $0x0
  pushl $197
80106c3e:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
80106c43:	e9 2b f1 ff ff       	jmp    80105d73 <alltraps>

80106c48 <vector198>:
.globl vector198
vector198:
  pushl $0
80106c48:	6a 00                	push   $0x0
  pushl $198
80106c4a:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
80106c4f:	e9 1f f1 ff ff       	jmp    80105d73 <alltraps>

80106c54 <vector199>:
.globl vector199
vector199:
  pushl $0
80106c54:	6a 00                	push   $0x0
  pushl $199
80106c56:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
80106c5b:	e9 13 f1 ff ff       	jmp    80105d73 <alltraps>

80106c60 <vector200>:
.globl vector200
vector200:
  pushl $0
80106c60:	6a 00                	push   $0x0
  pushl $200
80106c62:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
80106c67:	e9 07 f1 ff ff       	jmp    80105d73 <alltraps>

80106c6c <vector201>:
.globl vector201
vector201:
  pushl $0
80106c6c:	6a 00                	push   $0x0
  pushl $201
80106c6e:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
80106c73:	e9 fb f0 ff ff       	jmp    80105d73 <alltraps>

80106c78 <vector202>:
.globl vector202
vector202:
  pushl $0
80106c78:	6a 00                	push   $0x0
  pushl $202
80106c7a:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
80106c7f:	e9 ef f0 ff ff       	jmp    80105d73 <alltraps>

80106c84 <vector203>:
.globl vector203
vector203:
  pushl $0
80106c84:	6a 00                	push   $0x0
  pushl $203
80106c86:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
80106c8b:	e9 e3 f0 ff ff       	jmp    80105d73 <alltraps>

80106c90 <vector204>:
.globl vector204
vector204:
  pushl $0
80106c90:	6a 00                	push   $0x0
  pushl $204
80106c92:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
80106c97:	e9 d7 f0 ff ff       	jmp    80105d73 <alltraps>

80106c9c <vector205>:
.globl vector205
vector205:
  pushl $0
80106c9c:	6a 00                	push   $0x0
  pushl $205
80106c9e:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
80106ca3:	e9 cb f0 ff ff       	jmp    80105d73 <alltraps>

80106ca8 <vector206>:
.globl vector206
vector206:
  pushl $0
80106ca8:	6a 00                	push   $0x0
  pushl $206
80106caa:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
80106caf:	e9 bf f0 ff ff       	jmp    80105d73 <alltraps>

80106cb4 <vector207>:
.globl vector207
vector207:
  pushl $0
80106cb4:	6a 00                	push   $0x0
  pushl $207
80106cb6:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
80106cbb:	e9 b3 f0 ff ff       	jmp    80105d73 <alltraps>

80106cc0 <vector208>:
.globl vector208
vector208:
  pushl $0
80106cc0:	6a 00                	push   $0x0
  pushl $208
80106cc2:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
80106cc7:	e9 a7 f0 ff ff       	jmp    80105d73 <alltraps>

80106ccc <vector209>:
.globl vector209
vector209:
  pushl $0
80106ccc:	6a 00                	push   $0x0
  pushl $209
80106cce:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
80106cd3:	e9 9b f0 ff ff       	jmp    80105d73 <alltraps>

80106cd8 <vector210>:
.globl vector210
vector210:
  pushl $0
80106cd8:	6a 00                	push   $0x0
  pushl $210
80106cda:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
80106cdf:	e9 8f f0 ff ff       	jmp    80105d73 <alltraps>

80106ce4 <vector211>:
.globl vector211
vector211:
  pushl $0
80106ce4:	6a 00                	push   $0x0
  pushl $211
80106ce6:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
80106ceb:	e9 83 f0 ff ff       	jmp    80105d73 <alltraps>

80106cf0 <vector212>:
.globl vector212
vector212:
  pushl $0
80106cf0:	6a 00                	push   $0x0
  pushl $212
80106cf2:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
80106cf7:	e9 77 f0 ff ff       	jmp    80105d73 <alltraps>

80106cfc <vector213>:
.globl vector213
vector213:
  pushl $0
80106cfc:	6a 00                	push   $0x0
  pushl $213
80106cfe:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
80106d03:	e9 6b f0 ff ff       	jmp    80105d73 <alltraps>

80106d08 <vector214>:
.globl vector214
vector214:
  pushl $0
80106d08:	6a 00                	push   $0x0
  pushl $214
80106d0a:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
80106d0f:	e9 5f f0 ff ff       	jmp    80105d73 <alltraps>

80106d14 <vector215>:
.globl vector215
vector215:
  pushl $0
80106d14:	6a 00                	push   $0x0
  pushl $215
80106d16:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
80106d1b:	e9 53 f0 ff ff       	jmp    80105d73 <alltraps>

80106d20 <vector216>:
.globl vector216
vector216:
  pushl $0
80106d20:	6a 00                	push   $0x0
  pushl $216
80106d22:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
80106d27:	e9 47 f0 ff ff       	jmp    80105d73 <alltraps>

80106d2c <vector217>:
.globl vector217
vector217:
  pushl $0
80106d2c:	6a 00                	push   $0x0
  pushl $217
80106d2e:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
80106d33:	e9 3b f0 ff ff       	jmp    80105d73 <alltraps>

80106d38 <vector218>:
.globl vector218
vector218:
  pushl $0
80106d38:	6a 00                	push   $0x0
  pushl $218
80106d3a:	68 da 00 00 00       	push   $0xda
  jmp alltraps
80106d3f:	e9 2f f0 ff ff       	jmp    80105d73 <alltraps>

80106d44 <vector219>:
.globl vector219
vector219:
  pushl $0
80106d44:	6a 00                	push   $0x0
  pushl $219
80106d46:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
80106d4b:	e9 23 f0 ff ff       	jmp    80105d73 <alltraps>

80106d50 <vector220>:
.globl vector220
vector220:
  pushl $0
80106d50:	6a 00                	push   $0x0
  pushl $220
80106d52:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
80106d57:	e9 17 f0 ff ff       	jmp    80105d73 <alltraps>

80106d5c <vector221>:
.globl vector221
vector221:
  pushl $0
80106d5c:	6a 00                	push   $0x0
  pushl $221
80106d5e:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
80106d63:	e9 0b f0 ff ff       	jmp    80105d73 <alltraps>

80106d68 <vector222>:
.globl vector222
vector222:
  pushl $0
80106d68:	6a 00                	push   $0x0
  pushl $222
80106d6a:	68 de 00 00 00       	push   $0xde
  jmp alltraps
80106d6f:	e9 ff ef ff ff       	jmp    80105d73 <alltraps>

80106d74 <vector223>:
.globl vector223
vector223:
  pushl $0
80106d74:	6a 00                	push   $0x0
  pushl $223
80106d76:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
80106d7b:	e9 f3 ef ff ff       	jmp    80105d73 <alltraps>

80106d80 <vector224>:
.globl vector224
vector224:
  pushl $0
80106d80:	6a 00                	push   $0x0
  pushl $224
80106d82:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
80106d87:	e9 e7 ef ff ff       	jmp    80105d73 <alltraps>

80106d8c <vector225>:
.globl vector225
vector225:
  pushl $0
80106d8c:	6a 00                	push   $0x0
  pushl $225
80106d8e:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
80106d93:	e9 db ef ff ff       	jmp    80105d73 <alltraps>

80106d98 <vector226>:
.globl vector226
vector226:
  pushl $0
80106d98:	6a 00                	push   $0x0
  pushl $226
80106d9a:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
80106d9f:	e9 cf ef ff ff       	jmp    80105d73 <alltraps>

80106da4 <vector227>:
.globl vector227
vector227:
  pushl $0
80106da4:	6a 00                	push   $0x0
  pushl $227
80106da6:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
80106dab:	e9 c3 ef ff ff       	jmp    80105d73 <alltraps>

80106db0 <vector228>:
.globl vector228
vector228:
  pushl $0
80106db0:	6a 00                	push   $0x0
  pushl $228
80106db2:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
80106db7:	e9 b7 ef ff ff       	jmp    80105d73 <alltraps>

80106dbc <vector229>:
.globl vector229
vector229:
  pushl $0
80106dbc:	6a 00                	push   $0x0
  pushl $229
80106dbe:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
80106dc3:	e9 ab ef ff ff       	jmp    80105d73 <alltraps>

80106dc8 <vector230>:
.globl vector230
vector230:
  pushl $0
80106dc8:	6a 00                	push   $0x0
  pushl $230
80106dca:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
80106dcf:	e9 9f ef ff ff       	jmp    80105d73 <alltraps>

80106dd4 <vector231>:
.globl vector231
vector231:
  pushl $0
80106dd4:	6a 00                	push   $0x0
  pushl $231
80106dd6:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
80106ddb:	e9 93 ef ff ff       	jmp    80105d73 <alltraps>

80106de0 <vector232>:
.globl vector232
vector232:
  pushl $0
80106de0:	6a 00                	push   $0x0
  pushl $232
80106de2:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
80106de7:	e9 87 ef ff ff       	jmp    80105d73 <alltraps>

80106dec <vector233>:
.globl vector233
vector233:
  pushl $0
80106dec:	6a 00                	push   $0x0
  pushl $233
80106dee:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
80106df3:	e9 7b ef ff ff       	jmp    80105d73 <alltraps>

80106df8 <vector234>:
.globl vector234
vector234:
  pushl $0
80106df8:	6a 00                	push   $0x0
  pushl $234
80106dfa:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
80106dff:	e9 6f ef ff ff       	jmp    80105d73 <alltraps>

80106e04 <vector235>:
.globl vector235
vector235:
  pushl $0
80106e04:	6a 00                	push   $0x0
  pushl $235
80106e06:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
80106e0b:	e9 63 ef ff ff       	jmp    80105d73 <alltraps>

80106e10 <vector236>:
.globl vector236
vector236:
  pushl $0
80106e10:	6a 00                	push   $0x0
  pushl $236
80106e12:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
80106e17:	e9 57 ef ff ff       	jmp    80105d73 <alltraps>

80106e1c <vector237>:
.globl vector237
vector237:
  pushl $0
80106e1c:	6a 00                	push   $0x0
  pushl $237
80106e1e:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
80106e23:	e9 4b ef ff ff       	jmp    80105d73 <alltraps>

80106e28 <vector238>:
.globl vector238
vector238:
  pushl $0
80106e28:	6a 00                	push   $0x0
  pushl $238
80106e2a:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
80106e2f:	e9 3f ef ff ff       	jmp    80105d73 <alltraps>

80106e34 <vector239>:
.globl vector239
vector239:
  pushl $0
80106e34:	6a 00                	push   $0x0
  pushl $239
80106e36:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
80106e3b:	e9 33 ef ff ff       	jmp    80105d73 <alltraps>

80106e40 <vector240>:
.globl vector240
vector240:
  pushl $0
80106e40:	6a 00                	push   $0x0
  pushl $240
80106e42:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
80106e47:	e9 27 ef ff ff       	jmp    80105d73 <alltraps>

80106e4c <vector241>:
.globl vector241
vector241:
  pushl $0
80106e4c:	6a 00                	push   $0x0
  pushl $241
80106e4e:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
80106e53:	e9 1b ef ff ff       	jmp    80105d73 <alltraps>

80106e58 <vector242>:
.globl vector242
vector242:
  pushl $0
80106e58:	6a 00                	push   $0x0
  pushl $242
80106e5a:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
80106e5f:	e9 0f ef ff ff       	jmp    80105d73 <alltraps>

80106e64 <vector243>:
.globl vector243
vector243:
  pushl $0
80106e64:	6a 00                	push   $0x0
  pushl $243
80106e66:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
80106e6b:	e9 03 ef ff ff       	jmp    80105d73 <alltraps>

80106e70 <vector244>:
.globl vector244
vector244:
  pushl $0
80106e70:	6a 00                	push   $0x0
  pushl $244
80106e72:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
80106e77:	e9 f7 ee ff ff       	jmp    80105d73 <alltraps>

80106e7c <vector245>:
.globl vector245
vector245:
  pushl $0
80106e7c:	6a 00                	push   $0x0
  pushl $245
80106e7e:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
80106e83:	e9 eb ee ff ff       	jmp    80105d73 <alltraps>

80106e88 <vector246>:
.globl vector246
vector246:
  pushl $0
80106e88:	6a 00                	push   $0x0
  pushl $246
80106e8a:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
80106e8f:	e9 df ee ff ff       	jmp    80105d73 <alltraps>

80106e94 <vector247>:
.globl vector247
vector247:
  pushl $0
80106e94:	6a 00                	push   $0x0
  pushl $247
80106e96:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
80106e9b:	e9 d3 ee ff ff       	jmp    80105d73 <alltraps>

80106ea0 <vector248>:
.globl vector248
vector248:
  pushl $0
80106ea0:	6a 00                	push   $0x0
  pushl $248
80106ea2:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
80106ea7:	e9 c7 ee ff ff       	jmp    80105d73 <alltraps>

80106eac <vector249>:
.globl vector249
vector249:
  pushl $0
80106eac:	6a 00                	push   $0x0
  pushl $249
80106eae:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
80106eb3:	e9 bb ee ff ff       	jmp    80105d73 <alltraps>

80106eb8 <vector250>:
.globl vector250
vector250:
  pushl $0
80106eb8:	6a 00                	push   $0x0
  pushl $250
80106eba:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
80106ebf:	e9 af ee ff ff       	jmp    80105d73 <alltraps>

80106ec4 <vector251>:
.globl vector251
vector251:
  pushl $0
80106ec4:	6a 00                	push   $0x0
  pushl $251
80106ec6:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
80106ecb:	e9 a3 ee ff ff       	jmp    80105d73 <alltraps>

80106ed0 <vector252>:
.globl vector252
vector252:
  pushl $0
80106ed0:	6a 00                	push   $0x0
  pushl $252
80106ed2:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
80106ed7:	e9 97 ee ff ff       	jmp    80105d73 <alltraps>

80106edc <vector253>:
.globl vector253
vector253:
  pushl $0
80106edc:	6a 00                	push   $0x0
  pushl $253
80106ede:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
80106ee3:	e9 8b ee ff ff       	jmp    80105d73 <alltraps>

80106ee8 <vector254>:
.globl vector254
vector254:
  pushl $0
80106ee8:	6a 00                	push   $0x0
  pushl $254
80106eea:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
80106eef:	e9 7f ee ff ff       	jmp    80105d73 <alltraps>

80106ef4 <vector255>:
.globl vector255
vector255:
  pushl $0
80106ef4:	6a 00                	push   $0x0
  pushl $255
80106ef6:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
80106efb:	e9 73 ee ff ff       	jmp    80105d73 <alltraps>

80106f00 <lgdt>:
{
80106f00:	55                   	push   %ebp
80106f01:	89 e5                	mov    %esp,%ebp
80106f03:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
80106f06:	8b 45 0c             	mov    0xc(%ebp),%eax
80106f09:	83 e8 01             	sub    $0x1,%eax
80106f0c:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80106f10:	8b 45 08             	mov    0x8(%ebp),%eax
80106f13:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80106f17:	8b 45 08             	mov    0x8(%ebp),%eax
80106f1a:	c1 e8 10             	shr    $0x10,%eax
80106f1d:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lgdt (%0)" : : "r" (pd));
80106f21:	8d 45 fa             	lea    -0x6(%ebp),%eax
80106f24:	0f 01 10             	lgdtl  (%eax)
}
80106f27:	90                   	nop
80106f28:	c9                   	leave  
80106f29:	c3                   	ret    

80106f2a <ltr>:
{
80106f2a:	55                   	push   %ebp
80106f2b:	89 e5                	mov    %esp,%ebp
80106f2d:	83 ec 04             	sub    $0x4,%esp
80106f30:	8b 45 08             	mov    0x8(%ebp),%eax
80106f33:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
80106f37:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80106f3b:	0f 00 d8             	ltr    %ax
}
80106f3e:	90                   	nop
80106f3f:	c9                   	leave  
80106f40:	c3                   	ret    

80106f41 <lcr3>:

static inline void
lcr3(uint val)
{
80106f41:	55                   	push   %ebp
80106f42:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
80106f44:	8b 45 08             	mov    0x8(%ebp),%eax
80106f47:	0f 22 d8             	mov    %eax,%cr3
}
80106f4a:	90                   	nop
80106f4b:	5d                   	pop    %ebp
80106f4c:	c3                   	ret    

80106f4d <seginit>:
extern struct gpu gpu;
// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
80106f4d:	55                   	push   %ebp
80106f4e:	89 e5                	mov    %esp,%ebp
80106f50:	83 ec 18             	sub    $0x18,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpuid()];
80106f53:	e8 45 ca ff ff       	call   8010399d <cpuid>
80106f58:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
80106f5e:	05 80 6b 19 80       	add    $0x80196b80,%eax
80106f63:	89 45 f4             	mov    %eax,-0xc(%ebp)

  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
80106f66:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106f69:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
80106f6f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106f72:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
80106f78:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106f7b:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
80106f7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106f82:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80106f86:	83 e2 f0             	and    $0xfffffff0,%edx
80106f89:	83 ca 0a             	or     $0xa,%edx
80106f8c:	88 50 7d             	mov    %dl,0x7d(%eax)
80106f8f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106f92:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80106f96:	83 ca 10             	or     $0x10,%edx
80106f99:	88 50 7d             	mov    %dl,0x7d(%eax)
80106f9c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106f9f:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80106fa3:	83 e2 9f             	and    $0xffffff9f,%edx
80106fa6:	88 50 7d             	mov    %dl,0x7d(%eax)
80106fa9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106fac:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80106fb0:	83 ca 80             	or     $0xffffff80,%edx
80106fb3:	88 50 7d             	mov    %dl,0x7d(%eax)
80106fb6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106fb9:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80106fbd:	83 ca 0f             	or     $0xf,%edx
80106fc0:	88 50 7e             	mov    %dl,0x7e(%eax)
80106fc3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106fc6:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80106fca:	83 e2 ef             	and    $0xffffffef,%edx
80106fcd:	88 50 7e             	mov    %dl,0x7e(%eax)
80106fd0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106fd3:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80106fd7:	83 e2 df             	and    $0xffffffdf,%edx
80106fda:	88 50 7e             	mov    %dl,0x7e(%eax)
80106fdd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106fe0:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80106fe4:	83 ca 40             	or     $0x40,%edx
80106fe7:	88 50 7e             	mov    %dl,0x7e(%eax)
80106fea:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106fed:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80106ff1:	83 ca 80             	or     $0xffffff80,%edx
80106ff4:	88 50 7e             	mov    %dl,0x7e(%eax)
80106ff7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ffa:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
80106ffe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107001:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
80107008:	ff ff 
8010700a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010700d:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
80107014:	00 00 
80107016:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107019:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
80107020:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107023:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
8010702a:	83 e2 f0             	and    $0xfffffff0,%edx
8010702d:	83 ca 02             	or     $0x2,%edx
80107030:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107036:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107039:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107040:	83 ca 10             	or     $0x10,%edx
80107043:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107049:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010704c:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107053:	83 e2 9f             	and    $0xffffff9f,%edx
80107056:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
8010705c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010705f:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107066:	83 ca 80             	or     $0xffffff80,%edx
80107069:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
8010706f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107072:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107079:	83 ca 0f             	or     $0xf,%edx
8010707c:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107082:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107085:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
8010708c:	83 e2 ef             	and    $0xffffffef,%edx
8010708f:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107095:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107098:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
8010709f:	83 e2 df             	and    $0xffffffdf,%edx
801070a2:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801070a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801070ab:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801070b2:	83 ca 40             	or     $0x40,%edx
801070b5:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801070bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801070be:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801070c5:	83 ca 80             	or     $0xffffff80,%edx
801070c8:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801070ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
801070d1:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
801070d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801070db:	66 c7 80 88 00 00 00 	movw   $0xffff,0x88(%eax)
801070e2:	ff ff 
801070e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801070e7:	66 c7 80 8a 00 00 00 	movw   $0x0,0x8a(%eax)
801070ee:	00 00 
801070f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801070f3:	c6 80 8c 00 00 00 00 	movb   $0x0,0x8c(%eax)
801070fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801070fd:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107104:	83 e2 f0             	and    $0xfffffff0,%edx
80107107:	83 ca 0a             	or     $0xa,%edx
8010710a:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107110:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107113:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
8010711a:	83 ca 10             	or     $0x10,%edx
8010711d:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107123:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107126:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
8010712d:	83 ca 60             	or     $0x60,%edx
80107130:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107136:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107139:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107140:	83 ca 80             	or     $0xffffff80,%edx
80107143:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107149:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010714c:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107153:	83 ca 0f             	or     $0xf,%edx
80107156:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
8010715c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010715f:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107166:	83 e2 ef             	and    $0xffffffef,%edx
80107169:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
8010716f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107172:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107179:	83 e2 df             	and    $0xffffffdf,%edx
8010717c:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107182:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107185:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
8010718c:	83 ca 40             	or     $0x40,%edx
8010718f:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107195:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107198:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
8010719f:	83 ca 80             	or     $0xffffff80,%edx
801071a2:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
801071a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801071ab:	c6 80 8f 00 00 00 00 	movb   $0x0,0x8f(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
801071b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801071b5:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
801071bc:	ff ff 
801071be:	8b 45 f4             	mov    -0xc(%ebp),%eax
801071c1:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
801071c8:	00 00 
801071ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
801071cd:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
801071d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801071d7:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
801071de:	83 e2 f0             	and    $0xfffffff0,%edx
801071e1:	83 ca 02             	or     $0x2,%edx
801071e4:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801071ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
801071ed:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
801071f4:	83 ca 10             	or     $0x10,%edx
801071f7:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801071fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107200:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107207:	83 ca 60             	or     $0x60,%edx
8010720a:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107210:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107213:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
8010721a:	83 ca 80             	or     $0xffffff80,%edx
8010721d:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107223:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107226:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
8010722d:	83 ca 0f             	or     $0xf,%edx
80107230:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107236:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107239:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107240:	83 e2 ef             	and    $0xffffffef,%edx
80107243:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107249:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010724c:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107253:	83 e2 df             	and    $0xffffffdf,%edx
80107256:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
8010725c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010725f:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107266:	83 ca 40             	or     $0x40,%edx
80107269:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
8010726f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107272:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107279:	83 ca 80             	or     $0xffffff80,%edx
8010727c:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107282:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107285:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  lgdt(c->gdt, sizeof(c->gdt));
8010728c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010728f:	83 c0 70             	add    $0x70,%eax
80107292:	83 ec 08             	sub    $0x8,%esp
80107295:	6a 30                	push   $0x30
80107297:	50                   	push   %eax
80107298:	e8 63 fc ff ff       	call   80106f00 <lgdt>
8010729d:	83 c4 10             	add    $0x10,%esp
}
801072a0:	90                   	nop
801072a1:	c9                   	leave  
801072a2:	c3                   	ret    

801072a3 <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
801072a3:	55                   	push   %ebp
801072a4:	89 e5                	mov    %esp,%ebp
801072a6:	83 ec 18             	sub    $0x18,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
801072a9:	8b 45 0c             	mov    0xc(%ebp),%eax
801072ac:	c1 e8 16             	shr    $0x16,%eax
801072af:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801072b6:	8b 45 08             	mov    0x8(%ebp),%eax
801072b9:	01 d0                	add    %edx,%eax
801072bb:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
801072be:	8b 45 f0             	mov    -0x10(%ebp),%eax
801072c1:	8b 00                	mov    (%eax),%eax
801072c3:	83 e0 01             	and    $0x1,%eax
801072c6:	85 c0                	test   %eax,%eax
801072c8:	74 14                	je     801072de <walkpgdir+0x3b>
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
801072ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
801072cd:	8b 00                	mov    (%eax),%eax
801072cf:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801072d4:	05 00 00 00 80       	add    $0x80000000,%eax
801072d9:	89 45 f4             	mov    %eax,-0xc(%ebp)
801072dc:	eb 42                	jmp    80107320 <walkpgdir+0x7d>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
801072de:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801072e2:	74 0e                	je     801072f2 <walkpgdir+0x4f>
801072e4:	e8 b7 b4 ff ff       	call   801027a0 <kalloc>
801072e9:	89 45 f4             	mov    %eax,-0xc(%ebp)
801072ec:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801072f0:	75 07                	jne    801072f9 <walkpgdir+0x56>
      return 0;
801072f2:	b8 00 00 00 00       	mov    $0x0,%eax
801072f7:	eb 3e                	jmp    80107337 <walkpgdir+0x94>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
801072f9:	83 ec 04             	sub    $0x4,%esp
801072fc:	68 00 10 00 00       	push   $0x1000
80107301:	6a 00                	push   $0x0
80107303:	ff 75 f4             	push   -0xc(%ebp)
80107306:	e8 74 d6 ff ff       	call   8010497f <memset>
8010730b:	83 c4 10             	add    $0x10,%esp
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table
    // entries, if necessary.
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
8010730e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107311:	05 00 00 00 80       	add    $0x80000000,%eax
80107316:	83 c8 07             	or     $0x7,%eax
80107319:	89 c2                	mov    %eax,%edx
8010731b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010731e:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
80107320:	8b 45 0c             	mov    0xc(%ebp),%eax
80107323:	c1 e8 0c             	shr    $0xc,%eax
80107326:	25 ff 03 00 00       	and    $0x3ff,%eax
8010732b:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107332:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107335:	01 d0                	add    %edx,%eax
}
80107337:	c9                   	leave  
80107338:	c3                   	ret    

80107339 <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
80107339:	55                   	push   %ebp
8010733a:	89 e5                	mov    %esp,%ebp
8010733c:	83 ec 18             	sub    $0x18,%esp
  char *a, *last;
  pte_t *pte;

  a = (char*)PGROUNDDOWN((uint)va);
8010733f:	8b 45 0c             	mov    0xc(%ebp),%eax
80107342:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107347:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
8010734a:	8b 55 0c             	mov    0xc(%ebp),%edx
8010734d:	8b 45 10             	mov    0x10(%ebp),%eax
80107350:	01 d0                	add    %edx,%eax
80107352:	83 e8 01             	sub    $0x1,%eax
80107355:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010735a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
8010735d:	83 ec 04             	sub    $0x4,%esp
80107360:	6a 01                	push   $0x1
80107362:	ff 75 f4             	push   -0xc(%ebp)
80107365:	ff 75 08             	push   0x8(%ebp)
80107368:	e8 36 ff ff ff       	call   801072a3 <walkpgdir>
8010736d:	83 c4 10             	add    $0x10,%esp
80107370:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107373:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107377:	75 07                	jne    80107380 <mappages+0x47>
      return -1;
80107379:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010737e:	eb 47                	jmp    801073c7 <mappages+0x8e>
    if(*pte & PTE_P)
80107380:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107383:	8b 00                	mov    (%eax),%eax
80107385:	83 e0 01             	and    $0x1,%eax
80107388:	85 c0                	test   %eax,%eax
8010738a:	74 0d                	je     80107399 <mappages+0x60>
      panic("remap");
8010738c:	83 ec 0c             	sub    $0xc,%esp
8010738f:	68 84 a6 10 80       	push   $0x8010a684
80107394:	e8 10 92 ff ff       	call   801005a9 <panic>
    *pte = pa | perm | PTE_P;
80107399:	8b 45 18             	mov    0x18(%ebp),%eax
8010739c:	0b 45 14             	or     0x14(%ebp),%eax
8010739f:	83 c8 01             	or     $0x1,%eax
801073a2:	89 c2                	mov    %eax,%edx
801073a4:	8b 45 ec             	mov    -0x14(%ebp),%eax
801073a7:	89 10                	mov    %edx,(%eax)
    if(a == last)
801073a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073ac:	3b 45 f0             	cmp    -0x10(%ebp),%eax
801073af:	74 10                	je     801073c1 <mappages+0x88>
      break;
    a += PGSIZE;
801073b1:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
801073b8:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
801073bf:	eb 9c                	jmp    8010735d <mappages+0x24>
      break;
801073c1:	90                   	nop
  }
  return 0;
801073c2:	b8 00 00 00 00       	mov    $0x0,%eax
}
801073c7:	c9                   	leave  
801073c8:	c3                   	ret    

801073c9 <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
801073c9:	55                   	push   %ebp
801073ca:	89 e5                	mov    %esp,%ebp
801073cc:	53                   	push   %ebx
801073cd:	83 ec 24             	sub    $0x24,%esp
  pde_t *pgdir;
  struct kmap *k;
  k = kmap;
801073d0:	c7 45 f4 80 f4 10 80 	movl   $0x8010f480,-0xc(%ebp)
  struct kmap vram = { (void*)(DEVSPACE - gpu.vram_size),gpu.pvram_addr,gpu.pvram_addr+gpu.vram_size, PTE_W};
801073d7:	8b 15 50 6e 19 80    	mov    0x80196e50,%edx
801073dd:	b8 00 00 00 fe       	mov    $0xfe000000,%eax
801073e2:	29 d0                	sub    %edx,%eax
801073e4:	89 45 e0             	mov    %eax,-0x20(%ebp)
801073e7:	a1 48 6e 19 80       	mov    0x80196e48,%eax
801073ec:	89 45 e4             	mov    %eax,-0x1c(%ebp)
801073ef:	8b 15 48 6e 19 80    	mov    0x80196e48,%edx
801073f5:	a1 50 6e 19 80       	mov    0x80196e50,%eax
801073fa:	01 d0                	add    %edx,%eax
801073fc:	89 45 e8             	mov    %eax,-0x18(%ebp)
801073ff:	c7 45 ec 02 00 00 00 	movl   $0x2,-0x14(%ebp)
  k[3] = vram;
80107406:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107409:	83 c0 30             	add    $0x30,%eax
8010740c:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010740f:	89 10                	mov    %edx,(%eax)
80107411:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80107414:	89 50 04             	mov    %edx,0x4(%eax)
80107417:	8b 55 e8             	mov    -0x18(%ebp),%edx
8010741a:	89 50 08             	mov    %edx,0x8(%eax)
8010741d:	8b 55 ec             	mov    -0x14(%ebp),%edx
80107420:	89 50 0c             	mov    %edx,0xc(%eax)
  if((pgdir = (pde_t*)kalloc()) == 0){
80107423:	e8 78 b3 ff ff       	call   801027a0 <kalloc>
80107428:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010742b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010742f:	75 07                	jne    80107438 <setupkvm+0x6f>
    return 0;
80107431:	b8 00 00 00 00       	mov    $0x0,%eax
80107436:	eb 78                	jmp    801074b0 <setupkvm+0xe7>
  }
  memset(pgdir, 0, PGSIZE);
80107438:	83 ec 04             	sub    $0x4,%esp
8010743b:	68 00 10 00 00       	push   $0x1000
80107440:	6a 00                	push   $0x0
80107442:	ff 75 f0             	push   -0x10(%ebp)
80107445:	e8 35 d5 ff ff       	call   8010497f <memset>
8010744a:	83 c4 10             	add    $0x10,%esp
  if (P2V(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
8010744d:	c7 45 f4 80 f4 10 80 	movl   $0x8010f480,-0xc(%ebp)
80107454:	eb 4e                	jmp    801074a4 <setupkvm+0xdb>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
80107456:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107459:	8b 48 0c             	mov    0xc(%eax),%ecx
                (uint)k->phys_start, k->perm) < 0) {
8010745c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010745f:	8b 50 04             	mov    0x4(%eax),%edx
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
80107462:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107465:	8b 58 08             	mov    0x8(%eax),%ebx
80107468:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010746b:	8b 40 04             	mov    0x4(%eax),%eax
8010746e:	29 c3                	sub    %eax,%ebx
80107470:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107473:	8b 00                	mov    (%eax),%eax
80107475:	83 ec 0c             	sub    $0xc,%esp
80107478:	51                   	push   %ecx
80107479:	52                   	push   %edx
8010747a:	53                   	push   %ebx
8010747b:	50                   	push   %eax
8010747c:	ff 75 f0             	push   -0x10(%ebp)
8010747f:	e8 b5 fe ff ff       	call   80107339 <mappages>
80107484:	83 c4 20             	add    $0x20,%esp
80107487:	85 c0                	test   %eax,%eax
80107489:	79 15                	jns    801074a0 <setupkvm+0xd7>
      freevm(pgdir);
8010748b:	83 ec 0c             	sub    $0xc,%esp
8010748e:	ff 75 f0             	push   -0x10(%ebp)
80107491:	e8 f5 04 00 00       	call   8010798b <freevm>
80107496:	83 c4 10             	add    $0x10,%esp
      return 0;
80107499:	b8 00 00 00 00       	mov    $0x0,%eax
8010749e:	eb 10                	jmp    801074b0 <setupkvm+0xe7>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
801074a0:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
801074a4:	81 7d f4 e0 f4 10 80 	cmpl   $0x8010f4e0,-0xc(%ebp)
801074ab:	72 a9                	jb     80107456 <setupkvm+0x8d>
    }
  return pgdir;
801074ad:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
801074b0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801074b3:	c9                   	leave  
801074b4:	c3                   	ret    

801074b5 <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
801074b5:	55                   	push   %ebp
801074b6:	89 e5                	mov    %esp,%ebp
801074b8:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
801074bb:	e8 09 ff ff ff       	call   801073c9 <setupkvm>
801074c0:	a3 7c 6b 19 80       	mov    %eax,0x80196b7c
  switchkvm();
801074c5:	e8 03 00 00 00       	call   801074cd <switchkvm>
}
801074ca:	90                   	nop
801074cb:	c9                   	leave  
801074cc:	c3                   	ret    

801074cd <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
801074cd:	55                   	push   %ebp
801074ce:	89 e5                	mov    %esp,%ebp
  lcr3(V2P(kpgdir));   // switch to the kernel page table
801074d0:	a1 7c 6b 19 80       	mov    0x80196b7c,%eax
801074d5:	05 00 00 00 80       	add    $0x80000000,%eax
801074da:	50                   	push   %eax
801074db:	e8 61 fa ff ff       	call   80106f41 <lcr3>
801074e0:	83 c4 04             	add    $0x4,%esp
}
801074e3:	90                   	nop
801074e4:	c9                   	leave  
801074e5:	c3                   	ret    

801074e6 <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
801074e6:	55                   	push   %ebp
801074e7:	89 e5                	mov    %esp,%ebp
801074e9:	56                   	push   %esi
801074ea:	53                   	push   %ebx
801074eb:	83 ec 10             	sub    $0x10,%esp
  if(p == 0)
801074ee:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801074f2:	75 0d                	jne    80107501 <switchuvm+0x1b>
    panic("switchuvm: no process");
801074f4:	83 ec 0c             	sub    $0xc,%esp
801074f7:	68 8a a6 10 80       	push   $0x8010a68a
801074fc:	e8 a8 90 ff ff       	call   801005a9 <panic>
  if(p->kstack == 0)
80107501:	8b 45 08             	mov    0x8(%ebp),%eax
80107504:	8b 40 08             	mov    0x8(%eax),%eax
80107507:	85 c0                	test   %eax,%eax
80107509:	75 0d                	jne    80107518 <switchuvm+0x32>
    panic("switchuvm: no kstack");
8010750b:	83 ec 0c             	sub    $0xc,%esp
8010750e:	68 a0 a6 10 80       	push   $0x8010a6a0
80107513:	e8 91 90 ff ff       	call   801005a9 <panic>
  if(p->pgdir == 0)
80107518:	8b 45 08             	mov    0x8(%ebp),%eax
8010751b:	8b 40 04             	mov    0x4(%eax),%eax
8010751e:	85 c0                	test   %eax,%eax
80107520:	75 0d                	jne    8010752f <switchuvm+0x49>
    panic("switchuvm: no pgdir");
80107522:	83 ec 0c             	sub    $0xc,%esp
80107525:	68 b5 a6 10 80       	push   $0x8010a6b5
8010752a:	e8 7a 90 ff ff       	call   801005a9 <panic>

  pushcli();
8010752f:	e8 40 d3 ff ff       	call   80104874 <pushcli>
  mycpu()->gdt[SEG_TSS] = SEG16(STS_T32A, &mycpu()->ts,
80107534:	e8 7f c4 ff ff       	call   801039b8 <mycpu>
80107539:	89 c3                	mov    %eax,%ebx
8010753b:	e8 78 c4 ff ff       	call   801039b8 <mycpu>
80107540:	83 c0 08             	add    $0x8,%eax
80107543:	89 c6                	mov    %eax,%esi
80107545:	e8 6e c4 ff ff       	call   801039b8 <mycpu>
8010754a:	83 c0 08             	add    $0x8,%eax
8010754d:	c1 e8 10             	shr    $0x10,%eax
80107550:	88 45 f7             	mov    %al,-0x9(%ebp)
80107553:	e8 60 c4 ff ff       	call   801039b8 <mycpu>
80107558:	83 c0 08             	add    $0x8,%eax
8010755b:	c1 e8 18             	shr    $0x18,%eax
8010755e:	89 c2                	mov    %eax,%edx
80107560:	66 c7 83 98 00 00 00 	movw   $0x67,0x98(%ebx)
80107567:	67 00 
80107569:	66 89 b3 9a 00 00 00 	mov    %si,0x9a(%ebx)
80107570:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
80107574:	88 83 9c 00 00 00    	mov    %al,0x9c(%ebx)
8010757a:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80107581:	83 e0 f0             	and    $0xfffffff0,%eax
80107584:	83 c8 09             	or     $0x9,%eax
80107587:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
8010758d:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80107594:	83 c8 10             	or     $0x10,%eax
80107597:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
8010759d:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
801075a4:	83 e0 9f             	and    $0xffffff9f,%eax
801075a7:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
801075ad:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
801075b4:	83 c8 80             	or     $0xffffff80,%eax
801075b7:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
801075bd:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
801075c4:	83 e0 f0             	and    $0xfffffff0,%eax
801075c7:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
801075cd:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
801075d4:	83 e0 ef             	and    $0xffffffef,%eax
801075d7:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
801075dd:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
801075e4:	83 e0 df             	and    $0xffffffdf,%eax
801075e7:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
801075ed:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
801075f4:	83 c8 40             	or     $0x40,%eax
801075f7:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
801075fd:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107604:	83 e0 7f             	and    $0x7f,%eax
80107607:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
8010760d:	88 93 9f 00 00 00    	mov    %dl,0x9f(%ebx)
                                sizeof(mycpu()->ts)-1, 0);
  mycpu()->gdt[SEG_TSS].s = 0;
80107613:	e8 a0 c3 ff ff       	call   801039b8 <mycpu>
80107618:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
8010761f:	83 e2 ef             	and    $0xffffffef,%edx
80107622:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
  mycpu()->ts.ss0 = SEG_KDATA << 3;
80107628:	e8 8b c3 ff ff       	call   801039b8 <mycpu>
8010762d:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  mycpu()->ts.esp0 = (uint)p->kstack + KSTACKSIZE;
80107633:	8b 45 08             	mov    0x8(%ebp),%eax
80107636:	8b 40 08             	mov    0x8(%eax),%eax
80107639:	89 c3                	mov    %eax,%ebx
8010763b:	e8 78 c3 ff ff       	call   801039b8 <mycpu>
80107640:	8d 93 00 10 00 00    	lea    0x1000(%ebx),%edx
80107646:	89 50 0c             	mov    %edx,0xc(%eax)
  // setting IOPL=0 in eflags *and* iomb beyond the tss segment limit
  // forbids I/O instructions (e.g., inb and outb) from user space
  mycpu()->ts.iomb = (ushort) 0xFFFF;
80107649:	e8 6a c3 ff ff       	call   801039b8 <mycpu>
8010764e:	66 c7 40 6e ff ff    	movw   $0xffff,0x6e(%eax)
  ltr(SEG_TSS << 3);
80107654:	83 ec 0c             	sub    $0xc,%esp
80107657:	6a 28                	push   $0x28
80107659:	e8 cc f8 ff ff       	call   80106f2a <ltr>
8010765e:	83 c4 10             	add    $0x10,%esp
  lcr3(V2P(p->pgdir));  // switch to process's address space
80107661:	8b 45 08             	mov    0x8(%ebp),%eax
80107664:	8b 40 04             	mov    0x4(%eax),%eax
80107667:	05 00 00 00 80       	add    $0x80000000,%eax
8010766c:	83 ec 0c             	sub    $0xc,%esp
8010766f:	50                   	push   %eax
80107670:	e8 cc f8 ff ff       	call   80106f41 <lcr3>
80107675:	83 c4 10             	add    $0x10,%esp
  popcli();
80107678:	e8 44 d2 ff ff       	call   801048c1 <popcli>
}
8010767d:	90                   	nop
8010767e:	8d 65 f8             	lea    -0x8(%ebp),%esp
80107681:	5b                   	pop    %ebx
80107682:	5e                   	pop    %esi
80107683:	5d                   	pop    %ebp
80107684:	c3                   	ret    

80107685 <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
80107685:	55                   	push   %ebp
80107686:	89 e5                	mov    %esp,%ebp
80107688:	83 ec 18             	sub    $0x18,%esp
  char *mem;

  if(sz >= PGSIZE)
8010768b:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
80107692:	76 0d                	jbe    801076a1 <inituvm+0x1c>
    panic("inituvm: more than a page");
80107694:	83 ec 0c             	sub    $0xc,%esp
80107697:	68 c9 a6 10 80       	push   $0x8010a6c9
8010769c:	e8 08 8f ff ff       	call   801005a9 <panic>
  mem = kalloc();
801076a1:	e8 fa b0 ff ff       	call   801027a0 <kalloc>
801076a6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
801076a9:	83 ec 04             	sub    $0x4,%esp
801076ac:	68 00 10 00 00       	push   $0x1000
801076b1:	6a 00                	push   $0x0
801076b3:	ff 75 f4             	push   -0xc(%ebp)
801076b6:	e8 c4 d2 ff ff       	call   8010497f <memset>
801076bb:	83 c4 10             	add    $0x10,%esp
  mappages(pgdir, 0, PGSIZE, V2P(mem), PTE_W|PTE_U);
801076be:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076c1:	05 00 00 00 80       	add    $0x80000000,%eax
801076c6:	83 ec 0c             	sub    $0xc,%esp
801076c9:	6a 06                	push   $0x6
801076cb:	50                   	push   %eax
801076cc:	68 00 10 00 00       	push   $0x1000
801076d1:	6a 00                	push   $0x0
801076d3:	ff 75 08             	push   0x8(%ebp)
801076d6:	e8 5e fc ff ff       	call   80107339 <mappages>
801076db:	83 c4 20             	add    $0x20,%esp
  memmove(mem, init, sz);
801076de:	83 ec 04             	sub    $0x4,%esp
801076e1:	ff 75 10             	push   0x10(%ebp)
801076e4:	ff 75 0c             	push   0xc(%ebp)
801076e7:	ff 75 f4             	push   -0xc(%ebp)
801076ea:	e8 4f d3 ff ff       	call   80104a3e <memmove>
801076ef:	83 c4 10             	add    $0x10,%esp
}
801076f2:	90                   	nop
801076f3:	c9                   	leave  
801076f4:	c3                   	ret    

801076f5 <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
801076f5:	55                   	push   %ebp
801076f6:	89 e5                	mov    %esp,%ebp
801076f8:	83 ec 18             	sub    $0x18,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
801076fb:	8b 45 0c             	mov    0xc(%ebp),%eax
801076fe:	25 ff 0f 00 00       	and    $0xfff,%eax
80107703:	85 c0                	test   %eax,%eax
80107705:	74 0d                	je     80107714 <loaduvm+0x1f>
    panic("loaduvm: addr must be page aligned");
80107707:	83 ec 0c             	sub    $0xc,%esp
8010770a:	68 e4 a6 10 80       	push   $0x8010a6e4
8010770f:	e8 95 8e ff ff       	call   801005a9 <panic>
  for(i = 0; i < sz; i += PGSIZE){
80107714:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010771b:	e9 8f 00 00 00       	jmp    801077af <loaduvm+0xba>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
80107720:	8b 55 0c             	mov    0xc(%ebp),%edx
80107723:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107726:	01 d0                	add    %edx,%eax
80107728:	83 ec 04             	sub    $0x4,%esp
8010772b:	6a 00                	push   $0x0
8010772d:	50                   	push   %eax
8010772e:	ff 75 08             	push   0x8(%ebp)
80107731:	e8 6d fb ff ff       	call   801072a3 <walkpgdir>
80107736:	83 c4 10             	add    $0x10,%esp
80107739:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010773c:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107740:	75 0d                	jne    8010774f <loaduvm+0x5a>
      panic("loaduvm: address should exist");
80107742:	83 ec 0c             	sub    $0xc,%esp
80107745:	68 07 a7 10 80       	push   $0x8010a707
8010774a:	e8 5a 8e ff ff       	call   801005a9 <panic>
    pa = PTE_ADDR(*pte);
8010774f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107752:	8b 00                	mov    (%eax),%eax
80107754:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107759:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
8010775c:	8b 45 18             	mov    0x18(%ebp),%eax
8010775f:	2b 45 f4             	sub    -0xc(%ebp),%eax
80107762:	3d ff 0f 00 00       	cmp    $0xfff,%eax
80107767:	77 0b                	ja     80107774 <loaduvm+0x7f>
      n = sz - i;
80107769:	8b 45 18             	mov    0x18(%ebp),%eax
8010776c:	2b 45 f4             	sub    -0xc(%ebp),%eax
8010776f:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107772:	eb 07                	jmp    8010777b <loaduvm+0x86>
    else
      n = PGSIZE;
80107774:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, P2V(pa), offset+i, n) != n)
8010777b:	8b 55 14             	mov    0x14(%ebp),%edx
8010777e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107781:	01 d0                	add    %edx,%eax
80107783:	8b 55 e8             	mov    -0x18(%ebp),%edx
80107786:	81 c2 00 00 00 80    	add    $0x80000000,%edx
8010778c:	ff 75 f0             	push   -0x10(%ebp)
8010778f:	50                   	push   %eax
80107790:	52                   	push   %edx
80107791:	ff 75 10             	push   0x10(%ebp)
80107794:	e8 3d a7 ff ff       	call   80101ed6 <readi>
80107799:	83 c4 10             	add    $0x10,%esp
8010779c:	39 45 f0             	cmp    %eax,-0x10(%ebp)
8010779f:	74 07                	je     801077a8 <loaduvm+0xb3>
      return -1;
801077a1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801077a6:	eb 18                	jmp    801077c0 <loaduvm+0xcb>
  for(i = 0; i < sz; i += PGSIZE){
801077a8:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801077af:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077b2:	3b 45 18             	cmp    0x18(%ebp),%eax
801077b5:	0f 82 65 ff ff ff    	jb     80107720 <loaduvm+0x2b>
  }
  return 0;
801077bb:	b8 00 00 00 00       	mov    $0x0,%eax
}
801077c0:	c9                   	leave  
801077c1:	c3                   	ret    

801077c2 <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
801077c2:	55                   	push   %ebp
801077c3:	89 e5                	mov    %esp,%ebp
801077c5:	83 ec 18             	sub    $0x18,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
801077c8:	8b 45 10             	mov    0x10(%ebp),%eax
801077cb:	85 c0                	test   %eax,%eax
801077cd:	79 0a                	jns    801077d9 <allocuvm+0x17>
    return 0;
801077cf:	b8 00 00 00 00       	mov    $0x0,%eax
801077d4:	e9 ec 00 00 00       	jmp    801078c5 <allocuvm+0x103>
  if(newsz < oldsz)
801077d9:	8b 45 10             	mov    0x10(%ebp),%eax
801077dc:	3b 45 0c             	cmp    0xc(%ebp),%eax
801077df:	73 08                	jae    801077e9 <allocuvm+0x27>
    return oldsz;
801077e1:	8b 45 0c             	mov    0xc(%ebp),%eax
801077e4:	e9 dc 00 00 00       	jmp    801078c5 <allocuvm+0x103>

  a = PGROUNDUP(oldsz);
801077e9:	8b 45 0c             	mov    0xc(%ebp),%eax
801077ec:	05 ff 0f 00 00       	add    $0xfff,%eax
801077f1:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801077f6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
801077f9:	e9 b8 00 00 00       	jmp    801078b6 <allocuvm+0xf4>
    mem = kalloc();
801077fe:	e8 9d af ff ff       	call   801027a0 <kalloc>
80107803:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
80107806:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010780a:	75 2e                	jne    8010783a <allocuvm+0x78>
      cprintf("allocuvm out of memory\n");
8010780c:	83 ec 0c             	sub    $0xc,%esp
8010780f:	68 25 a7 10 80       	push   $0x8010a725
80107814:	e8 db 8b ff ff       	call   801003f4 <cprintf>
80107819:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
8010781c:	83 ec 04             	sub    $0x4,%esp
8010781f:	ff 75 0c             	push   0xc(%ebp)
80107822:	ff 75 10             	push   0x10(%ebp)
80107825:	ff 75 08             	push   0x8(%ebp)
80107828:	e8 9a 00 00 00       	call   801078c7 <deallocuvm>
8010782d:	83 c4 10             	add    $0x10,%esp
      return 0;
80107830:	b8 00 00 00 00       	mov    $0x0,%eax
80107835:	e9 8b 00 00 00       	jmp    801078c5 <allocuvm+0x103>
    }
    memset(mem, 0, PGSIZE);
8010783a:	83 ec 04             	sub    $0x4,%esp
8010783d:	68 00 10 00 00       	push   $0x1000
80107842:	6a 00                	push   $0x0
80107844:	ff 75 f0             	push   -0x10(%ebp)
80107847:	e8 33 d1 ff ff       	call   8010497f <memset>
8010784c:	83 c4 10             	add    $0x10,%esp
    if(mappages(pgdir, (char*)a, PGSIZE, V2P(mem), PTE_W|PTE_U) < 0){
8010784f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107852:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80107858:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010785b:	83 ec 0c             	sub    $0xc,%esp
8010785e:	6a 06                	push   $0x6
80107860:	52                   	push   %edx
80107861:	68 00 10 00 00       	push   $0x1000
80107866:	50                   	push   %eax
80107867:	ff 75 08             	push   0x8(%ebp)
8010786a:	e8 ca fa ff ff       	call   80107339 <mappages>
8010786f:	83 c4 20             	add    $0x20,%esp
80107872:	85 c0                	test   %eax,%eax
80107874:	79 39                	jns    801078af <allocuvm+0xed>
      cprintf("allocuvm out of memory (2)\n");
80107876:	83 ec 0c             	sub    $0xc,%esp
80107879:	68 3d a7 10 80       	push   $0x8010a73d
8010787e:	e8 71 8b ff ff       	call   801003f4 <cprintf>
80107883:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
80107886:	83 ec 04             	sub    $0x4,%esp
80107889:	ff 75 0c             	push   0xc(%ebp)
8010788c:	ff 75 10             	push   0x10(%ebp)
8010788f:	ff 75 08             	push   0x8(%ebp)
80107892:	e8 30 00 00 00       	call   801078c7 <deallocuvm>
80107897:	83 c4 10             	add    $0x10,%esp
      kfree(mem);
8010789a:	83 ec 0c             	sub    $0xc,%esp
8010789d:	ff 75 f0             	push   -0x10(%ebp)
801078a0:	e8 61 ae ff ff       	call   80102706 <kfree>
801078a5:	83 c4 10             	add    $0x10,%esp
      return 0;
801078a8:	b8 00 00 00 00       	mov    $0x0,%eax
801078ad:	eb 16                	jmp    801078c5 <allocuvm+0x103>
  for(; a < newsz; a += PGSIZE){
801078af:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801078b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078b9:	3b 45 10             	cmp    0x10(%ebp),%eax
801078bc:	0f 82 3c ff ff ff    	jb     801077fe <allocuvm+0x3c>
    }
  }
  return newsz;
801078c2:	8b 45 10             	mov    0x10(%ebp),%eax
}
801078c5:	c9                   	leave  
801078c6:	c3                   	ret    

801078c7 <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
801078c7:	55                   	push   %ebp
801078c8:	89 e5                	mov    %esp,%ebp
801078ca:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
801078cd:	8b 45 10             	mov    0x10(%ebp),%eax
801078d0:	3b 45 0c             	cmp    0xc(%ebp),%eax
801078d3:	72 08                	jb     801078dd <deallocuvm+0x16>
    return oldsz;
801078d5:	8b 45 0c             	mov    0xc(%ebp),%eax
801078d8:	e9 ac 00 00 00       	jmp    80107989 <deallocuvm+0xc2>

  a = PGROUNDUP(newsz);
801078dd:	8b 45 10             	mov    0x10(%ebp),%eax
801078e0:	05 ff 0f 00 00       	add    $0xfff,%eax
801078e5:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801078ea:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
801078ed:	e9 88 00 00 00       	jmp    8010797a <deallocuvm+0xb3>
    pte = walkpgdir(pgdir, (char*)a, 0);
801078f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078f5:	83 ec 04             	sub    $0x4,%esp
801078f8:	6a 00                	push   $0x0
801078fa:	50                   	push   %eax
801078fb:	ff 75 08             	push   0x8(%ebp)
801078fe:	e8 a0 f9 ff ff       	call   801072a3 <walkpgdir>
80107903:	83 c4 10             	add    $0x10,%esp
80107906:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
80107909:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010790d:	75 16                	jne    80107925 <deallocuvm+0x5e>
      a = PGADDR(PDX(a) + 1, 0, 0) - PGSIZE;
8010790f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107912:	c1 e8 16             	shr    $0x16,%eax
80107915:	83 c0 01             	add    $0x1,%eax
80107918:	c1 e0 16             	shl    $0x16,%eax
8010791b:	2d 00 10 00 00       	sub    $0x1000,%eax
80107920:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107923:	eb 4e                	jmp    80107973 <deallocuvm+0xac>
    else if((*pte & PTE_P) != 0){
80107925:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107928:	8b 00                	mov    (%eax),%eax
8010792a:	83 e0 01             	and    $0x1,%eax
8010792d:	85 c0                	test   %eax,%eax
8010792f:	74 42                	je     80107973 <deallocuvm+0xac>
      pa = PTE_ADDR(*pte);
80107931:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107934:	8b 00                	mov    (%eax),%eax
80107936:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010793b:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
8010793e:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107942:	75 0d                	jne    80107951 <deallocuvm+0x8a>
        panic("kfree");
80107944:	83 ec 0c             	sub    $0xc,%esp
80107947:	68 59 a7 10 80       	push   $0x8010a759
8010794c:	e8 58 8c ff ff       	call   801005a9 <panic>
      char *v = P2V(pa);
80107951:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107954:	05 00 00 00 80       	add    $0x80000000,%eax
80107959:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
8010795c:	83 ec 0c             	sub    $0xc,%esp
8010795f:	ff 75 e8             	push   -0x18(%ebp)
80107962:	e8 9f ad ff ff       	call   80102706 <kfree>
80107967:	83 c4 10             	add    $0x10,%esp
      *pte = 0;
8010796a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010796d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; a  < oldsz; a += PGSIZE){
80107973:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
8010797a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010797d:	3b 45 0c             	cmp    0xc(%ebp),%eax
80107980:	0f 82 6c ff ff ff    	jb     801078f2 <deallocuvm+0x2b>
    }
  }
  return newsz;
80107986:	8b 45 10             	mov    0x10(%ebp),%eax
}
80107989:	c9                   	leave  
8010798a:	c3                   	ret    

8010798b <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
8010798b:	55                   	push   %ebp
8010798c:	89 e5                	mov    %esp,%ebp
8010798e:	83 ec 18             	sub    $0x18,%esp
  uint i;

  if(pgdir == 0)
80107991:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80107995:	75 0d                	jne    801079a4 <freevm+0x19>
    panic("freevm: no pgdir");
80107997:	83 ec 0c             	sub    $0xc,%esp
8010799a:	68 5f a7 10 80       	push   $0x8010a75f
8010799f:	e8 05 8c ff ff       	call   801005a9 <panic>
  deallocuvm(pgdir, KERNBASE, 0);
801079a4:	83 ec 04             	sub    $0x4,%esp
801079a7:	6a 00                	push   $0x0
801079a9:	68 00 00 00 80       	push   $0x80000000
801079ae:	ff 75 08             	push   0x8(%ebp)
801079b1:	e8 11 ff ff ff       	call   801078c7 <deallocuvm>
801079b6:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
801079b9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801079c0:	eb 48                	jmp    80107a0a <freevm+0x7f>
    if(pgdir[i] & PTE_P){
801079c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079c5:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801079cc:	8b 45 08             	mov    0x8(%ebp),%eax
801079cf:	01 d0                	add    %edx,%eax
801079d1:	8b 00                	mov    (%eax),%eax
801079d3:	83 e0 01             	and    $0x1,%eax
801079d6:	85 c0                	test   %eax,%eax
801079d8:	74 2c                	je     80107a06 <freevm+0x7b>
      char * v = P2V(PTE_ADDR(pgdir[i]));
801079da:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079dd:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801079e4:	8b 45 08             	mov    0x8(%ebp),%eax
801079e7:	01 d0                	add    %edx,%eax
801079e9:	8b 00                	mov    (%eax),%eax
801079eb:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801079f0:	05 00 00 00 80       	add    $0x80000000,%eax
801079f5:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
801079f8:	83 ec 0c             	sub    $0xc,%esp
801079fb:	ff 75 f0             	push   -0x10(%ebp)
801079fe:	e8 03 ad ff ff       	call   80102706 <kfree>
80107a03:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
80107a06:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80107a0a:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
80107a11:	76 af                	jbe    801079c2 <freevm+0x37>
    }
  }
  kfree((char*)pgdir);
80107a13:	83 ec 0c             	sub    $0xc,%esp
80107a16:	ff 75 08             	push   0x8(%ebp)
80107a19:	e8 e8 ac ff ff       	call   80102706 <kfree>
80107a1e:	83 c4 10             	add    $0x10,%esp
}
80107a21:	90                   	nop
80107a22:	c9                   	leave  
80107a23:	c3                   	ret    

80107a24 <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
80107a24:	55                   	push   %ebp
80107a25:	89 e5                	mov    %esp,%ebp
80107a27:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80107a2a:	83 ec 04             	sub    $0x4,%esp
80107a2d:	6a 00                	push   $0x0
80107a2f:	ff 75 0c             	push   0xc(%ebp)
80107a32:	ff 75 08             	push   0x8(%ebp)
80107a35:	e8 69 f8 ff ff       	call   801072a3 <walkpgdir>
80107a3a:	83 c4 10             	add    $0x10,%esp
80107a3d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
80107a40:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107a44:	75 0d                	jne    80107a53 <clearpteu+0x2f>
    panic("clearpteu");
80107a46:	83 ec 0c             	sub    $0xc,%esp
80107a49:	68 70 a7 10 80       	push   $0x8010a770
80107a4e:	e8 56 8b ff ff       	call   801005a9 <panic>
  *pte &= ~PTE_U;
80107a53:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a56:	8b 00                	mov    (%eax),%eax
80107a58:	83 e0 fb             	and    $0xfffffffb,%eax
80107a5b:	89 c2                	mov    %eax,%edx
80107a5d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a60:	89 10                	mov    %edx,(%eax)
}
80107a62:	90                   	nop
80107a63:	c9                   	leave  
80107a64:	c3                   	ret    

80107a65 <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
80107a65:	55                   	push   %ebp
80107a66:	89 e5                	mov    %esp,%ebp
80107a68:	83 ec 28             	sub    $0x28,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
80107a6b:	e8 59 f9 ff ff       	call   801073c9 <setupkvm>
80107a70:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107a73:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107a77:	75 0a                	jne    80107a83 <copyuvm+0x1e>
    return 0;
80107a79:	b8 00 00 00 00       	mov    $0x0,%eax
80107a7e:	e9 eb 00 00 00       	jmp    80107b6e <copyuvm+0x109>
  for(i = 0; i < sz; i += PGSIZE){
80107a83:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107a8a:	e9 b7 00 00 00       	jmp    80107b46 <copyuvm+0xe1>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
80107a8f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a92:	83 ec 04             	sub    $0x4,%esp
80107a95:	6a 00                	push   $0x0
80107a97:	50                   	push   %eax
80107a98:	ff 75 08             	push   0x8(%ebp)
80107a9b:	e8 03 f8 ff ff       	call   801072a3 <walkpgdir>
80107aa0:	83 c4 10             	add    $0x10,%esp
80107aa3:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107aa6:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107aaa:	75 0d                	jne    80107ab9 <copyuvm+0x54>
      panic("copyuvm: pte should exist");
80107aac:	83 ec 0c             	sub    $0xc,%esp
80107aaf:	68 7a a7 10 80       	push   $0x8010a77a
80107ab4:	e8 f0 8a ff ff       	call   801005a9 <panic>
    if(!(*pte & PTE_P))
80107ab9:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107abc:	8b 00                	mov    (%eax),%eax
80107abe:	83 e0 01             	and    $0x1,%eax
80107ac1:	85 c0                	test   %eax,%eax
80107ac3:	75 0d                	jne    80107ad2 <copyuvm+0x6d>
      panic("copyuvm: page not present");
80107ac5:	83 ec 0c             	sub    $0xc,%esp
80107ac8:	68 94 a7 10 80       	push   $0x8010a794
80107acd:	e8 d7 8a ff ff       	call   801005a9 <panic>
    pa = PTE_ADDR(*pte);
80107ad2:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107ad5:	8b 00                	mov    (%eax),%eax
80107ad7:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107adc:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
80107adf:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107ae2:	8b 00                	mov    (%eax),%eax
80107ae4:	25 ff 0f 00 00       	and    $0xfff,%eax
80107ae9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if((mem = kalloc()) == 0)
80107aec:	e8 af ac ff ff       	call   801027a0 <kalloc>
80107af1:	89 45 e0             	mov    %eax,-0x20(%ebp)
80107af4:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80107af8:	74 5d                	je     80107b57 <copyuvm+0xf2>
      goto bad;
    memmove(mem, (char*)P2V(pa), PGSIZE);
80107afa:	8b 45 e8             	mov    -0x18(%ebp),%eax
80107afd:	05 00 00 00 80       	add    $0x80000000,%eax
80107b02:	83 ec 04             	sub    $0x4,%esp
80107b05:	68 00 10 00 00       	push   $0x1000
80107b0a:	50                   	push   %eax
80107b0b:	ff 75 e0             	push   -0x20(%ebp)
80107b0e:	e8 2b cf ff ff       	call   80104a3e <memmove>
80107b13:	83 c4 10             	add    $0x10,%esp
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0)
80107b16:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80107b19:	8b 45 e0             	mov    -0x20(%ebp),%eax
80107b1c:	8d 88 00 00 00 80    	lea    -0x80000000(%eax),%ecx
80107b22:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b25:	83 ec 0c             	sub    $0xc,%esp
80107b28:	52                   	push   %edx
80107b29:	51                   	push   %ecx
80107b2a:	68 00 10 00 00       	push   $0x1000
80107b2f:	50                   	push   %eax
80107b30:	ff 75 f0             	push   -0x10(%ebp)
80107b33:	e8 01 f8 ff ff       	call   80107339 <mappages>
80107b38:	83 c4 20             	add    $0x20,%esp
80107b3b:	85 c0                	test   %eax,%eax
80107b3d:	78 1b                	js     80107b5a <copyuvm+0xf5>
  for(i = 0; i < sz; i += PGSIZE){
80107b3f:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80107b46:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b49:	3b 45 0c             	cmp    0xc(%ebp),%eax
80107b4c:	0f 82 3d ff ff ff    	jb     80107a8f <copyuvm+0x2a>
      goto bad;
  }
  return d;
80107b52:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107b55:	eb 17                	jmp    80107b6e <copyuvm+0x109>
      goto bad;
80107b57:	90                   	nop
80107b58:	eb 01                	jmp    80107b5b <copyuvm+0xf6>
      goto bad;
80107b5a:	90                   	nop

bad:
  freevm(d);
80107b5b:	83 ec 0c             	sub    $0xc,%esp
80107b5e:	ff 75 f0             	push   -0x10(%ebp)
80107b61:	e8 25 fe ff ff       	call   8010798b <freevm>
80107b66:	83 c4 10             	add    $0x10,%esp
  return 0;
80107b69:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107b6e:	c9                   	leave  
80107b6f:	c3                   	ret    

80107b70 <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
80107b70:	55                   	push   %ebp
80107b71:	89 e5                	mov    %esp,%ebp
80107b73:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80107b76:	83 ec 04             	sub    $0x4,%esp
80107b79:	6a 00                	push   $0x0
80107b7b:	ff 75 0c             	push   0xc(%ebp)
80107b7e:	ff 75 08             	push   0x8(%ebp)
80107b81:	e8 1d f7 ff ff       	call   801072a3 <walkpgdir>
80107b86:	83 c4 10             	add    $0x10,%esp
80107b89:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
80107b8c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b8f:	8b 00                	mov    (%eax),%eax
80107b91:	83 e0 01             	and    $0x1,%eax
80107b94:	85 c0                	test   %eax,%eax
80107b96:	75 07                	jne    80107b9f <uva2ka+0x2f>
    return 0;
80107b98:	b8 00 00 00 00       	mov    $0x0,%eax
80107b9d:	eb 22                	jmp    80107bc1 <uva2ka+0x51>
  if((*pte & PTE_U) == 0)
80107b9f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ba2:	8b 00                	mov    (%eax),%eax
80107ba4:	83 e0 04             	and    $0x4,%eax
80107ba7:	85 c0                	test   %eax,%eax
80107ba9:	75 07                	jne    80107bb2 <uva2ka+0x42>
    return 0;
80107bab:	b8 00 00 00 00       	mov    $0x0,%eax
80107bb0:	eb 0f                	jmp    80107bc1 <uva2ka+0x51>
  return (char*)P2V(PTE_ADDR(*pte));
80107bb2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bb5:	8b 00                	mov    (%eax),%eax
80107bb7:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107bbc:	05 00 00 00 80       	add    $0x80000000,%eax
}
80107bc1:	c9                   	leave  
80107bc2:	c3                   	ret    

80107bc3 <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
80107bc3:	55                   	push   %ebp
80107bc4:	89 e5                	mov    %esp,%ebp
80107bc6:	83 ec 18             	sub    $0x18,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
80107bc9:	8b 45 10             	mov    0x10(%ebp),%eax
80107bcc:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
80107bcf:	eb 7f                	jmp    80107c50 <copyout+0x8d>
    va0 = (uint)PGROUNDDOWN(va);
80107bd1:	8b 45 0c             	mov    0xc(%ebp),%eax
80107bd4:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107bd9:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
80107bdc:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107bdf:	83 ec 08             	sub    $0x8,%esp
80107be2:	50                   	push   %eax
80107be3:	ff 75 08             	push   0x8(%ebp)
80107be6:	e8 85 ff ff ff       	call   80107b70 <uva2ka>
80107beb:	83 c4 10             	add    $0x10,%esp
80107bee:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
80107bf1:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80107bf5:	75 07                	jne    80107bfe <copyout+0x3b>
      return -1;
80107bf7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107bfc:	eb 61                	jmp    80107c5f <copyout+0x9c>
    n = PGSIZE - (va - va0);
80107bfe:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107c01:	2b 45 0c             	sub    0xc(%ebp),%eax
80107c04:	05 00 10 00 00       	add    $0x1000,%eax
80107c09:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
80107c0c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107c0f:	3b 45 14             	cmp    0x14(%ebp),%eax
80107c12:	76 06                	jbe    80107c1a <copyout+0x57>
      n = len;
80107c14:	8b 45 14             	mov    0x14(%ebp),%eax
80107c17:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
80107c1a:	8b 45 0c             	mov    0xc(%ebp),%eax
80107c1d:	2b 45 ec             	sub    -0x14(%ebp),%eax
80107c20:	89 c2                	mov    %eax,%edx
80107c22:	8b 45 e8             	mov    -0x18(%ebp),%eax
80107c25:	01 d0                	add    %edx,%eax
80107c27:	83 ec 04             	sub    $0x4,%esp
80107c2a:	ff 75 f0             	push   -0x10(%ebp)
80107c2d:	ff 75 f4             	push   -0xc(%ebp)
80107c30:	50                   	push   %eax
80107c31:	e8 08 ce ff ff       	call   80104a3e <memmove>
80107c36:	83 c4 10             	add    $0x10,%esp
    len -= n;
80107c39:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107c3c:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
80107c3f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107c42:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
80107c45:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107c48:	05 00 10 00 00       	add    $0x1000,%eax
80107c4d:	89 45 0c             	mov    %eax,0xc(%ebp)
  while(len > 0){
80107c50:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80107c54:	0f 85 77 ff ff ff    	jne    80107bd1 <copyout+0xe>
  }
  return 0;
80107c5a:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107c5f:	c9                   	leave  
80107c60:	c3                   	ret    

80107c61 <mpinit_uefi>:

struct cpu cpus[NCPU];
int ncpu;
uchar ioapicid;
void mpinit_uefi(void)
{
80107c61:	55                   	push   %ebp
80107c62:	89 e5                	mov    %esp,%ebp
80107c64:	83 ec 20             	sub    $0x20,%esp
  struct boot_param *boot_param = (struct boot_param *)P2V_WO(BOOTPARAM);
80107c67:	c7 45 f8 00 00 05 80 	movl   $0x80050000,-0x8(%ebp)
  struct uefi_madt *madt = (struct uefi_madt*)(P2V_WO(boot_param->madt_addr));
80107c6e:	8b 45 f8             	mov    -0x8(%ebp),%eax
80107c71:	8b 40 08             	mov    0x8(%eax),%eax
80107c74:	05 00 00 00 80       	add    $0x80000000,%eax
80107c79:	89 45 f4             	mov    %eax,-0xc(%ebp)

  uint i=sizeof(struct uefi_madt);
80107c7c:	c7 45 fc 2c 00 00 00 	movl   $0x2c,-0x4(%ebp)
  struct uefi_lapic *lapic_entry;
  struct uefi_ioapic *ioapic;
  struct uefi_iso *iso;
  struct uefi_non_maskable_intr *non_mask_intr; 
  
  lapic = (uint *)(madt->lapic_addr);
80107c83:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c86:	8b 40 24             	mov    0x24(%eax),%eax
80107c89:	a3 00 41 19 80       	mov    %eax,0x80194100
  ncpu = 0;
80107c8e:	c7 05 40 6e 19 80 00 	movl   $0x0,0x80196e40
80107c95:	00 00 00 

  while(i<madt->len){
80107c98:	90                   	nop
80107c99:	e9 bd 00 00 00       	jmp    80107d5b <mpinit_uefi+0xfa>
    uchar *entry_type = ((uchar *)madt)+i;
80107c9e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80107ca1:	8b 45 fc             	mov    -0x4(%ebp),%eax
80107ca4:	01 d0                	add    %edx,%eax
80107ca6:	89 45 f0             	mov    %eax,-0x10(%ebp)
    switch(*entry_type){
80107ca9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107cac:	0f b6 00             	movzbl (%eax),%eax
80107caf:	0f b6 c0             	movzbl %al,%eax
80107cb2:	83 f8 05             	cmp    $0x5,%eax
80107cb5:	0f 87 a0 00 00 00    	ja     80107d5b <mpinit_uefi+0xfa>
80107cbb:	8b 04 85 b0 a7 10 80 	mov    -0x7fef5850(,%eax,4),%eax
80107cc2:	ff e0                	jmp    *%eax
      case 0:
        lapic_entry = (struct uefi_lapic *)entry_type;
80107cc4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107cc7:	89 45 e0             	mov    %eax,-0x20(%ebp)
        if(ncpu < NCPU) {
80107cca:	a1 40 6e 19 80       	mov    0x80196e40,%eax
80107ccf:	83 f8 03             	cmp    $0x3,%eax
80107cd2:	7f 28                	jg     80107cfc <mpinit_uefi+0x9b>
          cpus[ncpu].apicid = lapic_entry->lapic_id;
80107cd4:	8b 15 40 6e 19 80    	mov    0x80196e40,%edx
80107cda:	8b 45 e0             	mov    -0x20(%ebp),%eax
80107cdd:	0f b6 40 03          	movzbl 0x3(%eax),%eax
80107ce1:	69 d2 b0 00 00 00    	imul   $0xb0,%edx,%edx
80107ce7:	81 c2 80 6b 19 80    	add    $0x80196b80,%edx
80107ced:	88 02                	mov    %al,(%edx)
          ncpu++;
80107cef:	a1 40 6e 19 80       	mov    0x80196e40,%eax
80107cf4:	83 c0 01             	add    $0x1,%eax
80107cf7:	a3 40 6e 19 80       	mov    %eax,0x80196e40
        }
        i += lapic_entry->record_len;
80107cfc:	8b 45 e0             	mov    -0x20(%ebp),%eax
80107cff:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80107d03:	0f b6 c0             	movzbl %al,%eax
80107d06:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
80107d09:	eb 50                	jmp    80107d5b <mpinit_uefi+0xfa>

      case 1:
        ioapic = (struct uefi_ioapic *)entry_type;
80107d0b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107d0e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        ioapicid = ioapic->ioapic_id;
80107d11:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80107d14:	0f b6 40 02          	movzbl 0x2(%eax),%eax
80107d18:	a2 44 6e 19 80       	mov    %al,0x80196e44
        i += ioapic->record_len;
80107d1d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80107d20:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80107d24:	0f b6 c0             	movzbl %al,%eax
80107d27:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
80107d2a:	eb 2f                	jmp    80107d5b <mpinit_uefi+0xfa>

      case 2:
        iso = (struct uefi_iso *)entry_type;
80107d2c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107d2f:	89 45 e8             	mov    %eax,-0x18(%ebp)
        i += iso->record_len;
80107d32:	8b 45 e8             	mov    -0x18(%ebp),%eax
80107d35:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80107d39:	0f b6 c0             	movzbl %al,%eax
80107d3c:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
80107d3f:	eb 1a                	jmp    80107d5b <mpinit_uefi+0xfa>

      case 4:
        non_mask_intr = (struct uefi_non_maskable_intr *)entry_type;
80107d41:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107d44:	89 45 ec             	mov    %eax,-0x14(%ebp)
        i += non_mask_intr->record_len;
80107d47:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107d4a:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80107d4e:	0f b6 c0             	movzbl %al,%eax
80107d51:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
80107d54:	eb 05                	jmp    80107d5b <mpinit_uefi+0xfa>

      case 5:
        i = i + 0xC;
80107d56:	83 45 fc 0c          	addl   $0xc,-0x4(%ebp)
        break;
80107d5a:	90                   	nop
  while(i<madt->len){
80107d5b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d5e:	8b 40 04             	mov    0x4(%eax),%eax
80107d61:	39 45 fc             	cmp    %eax,-0x4(%ebp)
80107d64:	0f 82 34 ff ff ff    	jb     80107c9e <mpinit_uefi+0x3d>
    }
  }

}
80107d6a:	90                   	nop
80107d6b:	90                   	nop
80107d6c:	c9                   	leave  
80107d6d:	c3                   	ret    

80107d6e <inb>:
{
80107d6e:	55                   	push   %ebp
80107d6f:	89 e5                	mov    %esp,%ebp
80107d71:	83 ec 14             	sub    $0x14,%esp
80107d74:	8b 45 08             	mov    0x8(%ebp),%eax
80107d77:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80107d7b:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80107d7f:	89 c2                	mov    %eax,%edx
80107d81:	ec                   	in     (%dx),%al
80107d82:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80107d85:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80107d89:	c9                   	leave  
80107d8a:	c3                   	ret    

80107d8b <outb>:
{
80107d8b:	55                   	push   %ebp
80107d8c:	89 e5                	mov    %esp,%ebp
80107d8e:	83 ec 08             	sub    $0x8,%esp
80107d91:	8b 45 08             	mov    0x8(%ebp),%eax
80107d94:	8b 55 0c             	mov    0xc(%ebp),%edx
80107d97:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80107d9b:	89 d0                	mov    %edx,%eax
80107d9d:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80107da0:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80107da4:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80107da8:	ee                   	out    %al,(%dx)
}
80107da9:	90                   	nop
80107daa:	c9                   	leave  
80107dab:	c3                   	ret    

80107dac <uart_debug>:
#include "proc.h"
#include "x86.h"

#define COM1    0x3f8

void uart_debug(char p){
80107dac:	55                   	push   %ebp
80107dad:	89 e5                	mov    %esp,%ebp
80107daf:	83 ec 28             	sub    $0x28,%esp
80107db2:	8b 45 08             	mov    0x8(%ebp),%eax
80107db5:	88 45 e4             	mov    %al,-0x1c(%ebp)
    // Turn off the FIFO
  outb(COM1+2, 0);
80107db8:	6a 00                	push   $0x0
80107dba:	68 fa 03 00 00       	push   $0x3fa
80107dbf:	e8 c7 ff ff ff       	call   80107d8b <outb>
80107dc4:	83 c4 08             	add    $0x8,%esp

  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
80107dc7:	68 80 00 00 00       	push   $0x80
80107dcc:	68 fb 03 00 00       	push   $0x3fb
80107dd1:	e8 b5 ff ff ff       	call   80107d8b <outb>
80107dd6:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
80107dd9:	6a 0c                	push   $0xc
80107ddb:	68 f8 03 00 00       	push   $0x3f8
80107de0:	e8 a6 ff ff ff       	call   80107d8b <outb>
80107de5:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
80107de8:	6a 00                	push   $0x0
80107dea:	68 f9 03 00 00       	push   $0x3f9
80107def:	e8 97 ff ff ff       	call   80107d8b <outb>
80107df4:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
80107df7:	6a 03                	push   $0x3
80107df9:	68 fb 03 00 00       	push   $0x3fb
80107dfe:	e8 88 ff ff ff       	call   80107d8b <outb>
80107e03:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
80107e06:	6a 00                	push   $0x0
80107e08:	68 fc 03 00 00       	push   $0x3fc
80107e0d:	e8 79 ff ff ff       	call   80107d8b <outb>
80107e12:	83 c4 08             	add    $0x8,%esp

  for(int i=0;i<128 && !(inb(COM1+5) & 0x20); i++) microdelay(10);
80107e15:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107e1c:	eb 11                	jmp    80107e2f <uart_debug+0x83>
80107e1e:	83 ec 0c             	sub    $0xc,%esp
80107e21:	6a 0a                	push   $0xa
80107e23:	e8 0f ad ff ff       	call   80102b37 <microdelay>
80107e28:	83 c4 10             	add    $0x10,%esp
80107e2b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80107e2f:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
80107e33:	7f 1a                	jg     80107e4f <uart_debug+0xa3>
80107e35:	83 ec 0c             	sub    $0xc,%esp
80107e38:	68 fd 03 00 00       	push   $0x3fd
80107e3d:	e8 2c ff ff ff       	call   80107d6e <inb>
80107e42:	83 c4 10             	add    $0x10,%esp
80107e45:	0f b6 c0             	movzbl %al,%eax
80107e48:	83 e0 20             	and    $0x20,%eax
80107e4b:	85 c0                	test   %eax,%eax
80107e4d:	74 cf                	je     80107e1e <uart_debug+0x72>
  outb(COM1+0, p);
80107e4f:	0f b6 45 e4          	movzbl -0x1c(%ebp),%eax
80107e53:	0f b6 c0             	movzbl %al,%eax
80107e56:	83 ec 08             	sub    $0x8,%esp
80107e59:	50                   	push   %eax
80107e5a:	68 f8 03 00 00       	push   $0x3f8
80107e5f:	e8 27 ff ff ff       	call   80107d8b <outb>
80107e64:	83 c4 10             	add    $0x10,%esp
}
80107e67:	90                   	nop
80107e68:	c9                   	leave  
80107e69:	c3                   	ret    

80107e6a <uart_debugs>:

void uart_debugs(char *p){
80107e6a:	55                   	push   %ebp
80107e6b:	89 e5                	mov    %esp,%ebp
80107e6d:	83 ec 08             	sub    $0x8,%esp
  while(*p){
80107e70:	eb 1b                	jmp    80107e8d <uart_debugs+0x23>
    uart_debug(*p++);
80107e72:	8b 45 08             	mov    0x8(%ebp),%eax
80107e75:	8d 50 01             	lea    0x1(%eax),%edx
80107e78:	89 55 08             	mov    %edx,0x8(%ebp)
80107e7b:	0f b6 00             	movzbl (%eax),%eax
80107e7e:	0f be c0             	movsbl %al,%eax
80107e81:	83 ec 0c             	sub    $0xc,%esp
80107e84:	50                   	push   %eax
80107e85:	e8 22 ff ff ff       	call   80107dac <uart_debug>
80107e8a:	83 c4 10             	add    $0x10,%esp
  while(*p){
80107e8d:	8b 45 08             	mov    0x8(%ebp),%eax
80107e90:	0f b6 00             	movzbl (%eax),%eax
80107e93:	84 c0                	test   %al,%al
80107e95:	75 db                	jne    80107e72 <uart_debugs+0x8>
  }
}
80107e97:	90                   	nop
80107e98:	90                   	nop
80107e99:	c9                   	leave  
80107e9a:	c3                   	ret    

80107e9b <graphic_init>:
 * i%4 = 2 : red
 * i%4 = 3 : black
 */

struct gpu gpu;
void graphic_init(){
80107e9b:	55                   	push   %ebp
80107e9c:	89 e5                	mov    %esp,%ebp
80107e9e:	83 ec 10             	sub    $0x10,%esp
  struct boot_param *boot_param = (struct boot_param *)P2V_WO(BOOTPARAM);
80107ea1:	c7 45 fc 00 00 05 80 	movl   $0x80050000,-0x4(%ebp)
  gpu.pvram_addr = boot_param->graphic_config.frame_base;
80107ea8:	8b 45 fc             	mov    -0x4(%ebp),%eax
80107eab:	8b 50 14             	mov    0x14(%eax),%edx
80107eae:	8b 40 10             	mov    0x10(%eax),%eax
80107eb1:	a3 48 6e 19 80       	mov    %eax,0x80196e48
  gpu.vram_size = boot_param->graphic_config.frame_size;
80107eb6:	8b 45 fc             	mov    -0x4(%ebp),%eax
80107eb9:	8b 50 1c             	mov    0x1c(%eax),%edx
80107ebc:	8b 40 18             	mov    0x18(%eax),%eax
80107ebf:	a3 50 6e 19 80       	mov    %eax,0x80196e50
  gpu.vvram_addr = DEVSPACE - gpu.vram_size;
80107ec4:	8b 15 50 6e 19 80    	mov    0x80196e50,%edx
80107eca:	b8 00 00 00 fe       	mov    $0xfe000000,%eax
80107ecf:	29 d0                	sub    %edx,%eax
80107ed1:	a3 4c 6e 19 80       	mov    %eax,0x80196e4c
  gpu.horizontal_resolution = (uint)(boot_param->graphic_config.horizontal_resolution & 0xFFFFFFFF);
80107ed6:	8b 45 fc             	mov    -0x4(%ebp),%eax
80107ed9:	8b 50 24             	mov    0x24(%eax),%edx
80107edc:	8b 40 20             	mov    0x20(%eax),%eax
80107edf:	a3 54 6e 19 80       	mov    %eax,0x80196e54
  gpu.vertical_resolution = (uint)(boot_param->graphic_config.vertical_resolution & 0xFFFFFFFF);
80107ee4:	8b 45 fc             	mov    -0x4(%ebp),%eax
80107ee7:	8b 50 2c             	mov    0x2c(%eax),%edx
80107eea:	8b 40 28             	mov    0x28(%eax),%eax
80107eed:	a3 58 6e 19 80       	mov    %eax,0x80196e58
  gpu.pixels_per_line = (uint)(boot_param->graphic_config.pixels_per_line & 0xFFFFFFFF);
80107ef2:	8b 45 fc             	mov    -0x4(%ebp),%eax
80107ef5:	8b 50 34             	mov    0x34(%eax),%edx
80107ef8:	8b 40 30             	mov    0x30(%eax),%eax
80107efb:	a3 5c 6e 19 80       	mov    %eax,0x80196e5c
}
80107f00:	90                   	nop
80107f01:	c9                   	leave  
80107f02:	c3                   	ret    

80107f03 <graphic_draw_pixel>:

void graphic_draw_pixel(int x,int y,struct graphic_pixel * buffer){
80107f03:	55                   	push   %ebp
80107f04:	89 e5                	mov    %esp,%ebp
80107f06:	83 ec 10             	sub    $0x10,%esp
  int pixel_addr = (sizeof(struct graphic_pixel))*(y*gpu.pixels_per_line + x);
80107f09:	8b 15 5c 6e 19 80    	mov    0x80196e5c,%edx
80107f0f:	8b 45 0c             	mov    0xc(%ebp),%eax
80107f12:	0f af d0             	imul   %eax,%edx
80107f15:	8b 45 08             	mov    0x8(%ebp),%eax
80107f18:	01 d0                	add    %edx,%eax
80107f1a:	c1 e0 02             	shl    $0x2,%eax
80107f1d:	89 45 fc             	mov    %eax,-0x4(%ebp)
  struct graphic_pixel *pixel = (struct graphic_pixel *)(gpu.vvram_addr + pixel_addr);
80107f20:	8b 15 4c 6e 19 80    	mov    0x80196e4c,%edx
80107f26:	8b 45 fc             	mov    -0x4(%ebp),%eax
80107f29:	01 d0                	add    %edx,%eax
80107f2b:	89 45 f8             	mov    %eax,-0x8(%ebp)
  pixel->blue = buffer->blue;
80107f2e:	8b 45 10             	mov    0x10(%ebp),%eax
80107f31:	0f b6 10             	movzbl (%eax),%edx
80107f34:	8b 45 f8             	mov    -0x8(%ebp),%eax
80107f37:	88 10                	mov    %dl,(%eax)
  pixel->green = buffer->green;
80107f39:	8b 45 10             	mov    0x10(%ebp),%eax
80107f3c:	0f b6 50 01          	movzbl 0x1(%eax),%edx
80107f40:	8b 45 f8             	mov    -0x8(%ebp),%eax
80107f43:	88 50 01             	mov    %dl,0x1(%eax)
  pixel->red = buffer->red;
80107f46:	8b 45 10             	mov    0x10(%ebp),%eax
80107f49:	0f b6 50 02          	movzbl 0x2(%eax),%edx
80107f4d:	8b 45 f8             	mov    -0x8(%ebp),%eax
80107f50:	88 50 02             	mov    %dl,0x2(%eax)
}
80107f53:	90                   	nop
80107f54:	c9                   	leave  
80107f55:	c3                   	ret    

80107f56 <graphic_scroll_up>:

void graphic_scroll_up(int height){
80107f56:	55                   	push   %ebp
80107f57:	89 e5                	mov    %esp,%ebp
80107f59:	83 ec 18             	sub    $0x18,%esp
  int addr_diff = (sizeof(struct graphic_pixel))*gpu.pixels_per_line*height;
80107f5c:	8b 15 5c 6e 19 80    	mov    0x80196e5c,%edx
80107f62:	8b 45 08             	mov    0x8(%ebp),%eax
80107f65:	0f af c2             	imul   %edx,%eax
80107f68:	c1 e0 02             	shl    $0x2,%eax
80107f6b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove((unsigned int *)gpu.vvram_addr,(unsigned int *)(gpu.vvram_addr + addr_diff),gpu.vram_size - addr_diff);
80107f6e:	a1 50 6e 19 80       	mov    0x80196e50,%eax
80107f73:	8b 55 f4             	mov    -0xc(%ebp),%edx
80107f76:	29 d0                	sub    %edx,%eax
80107f78:	8b 0d 4c 6e 19 80    	mov    0x80196e4c,%ecx
80107f7e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80107f81:	01 ca                	add    %ecx,%edx
80107f83:	89 d1                	mov    %edx,%ecx
80107f85:	8b 15 4c 6e 19 80    	mov    0x80196e4c,%edx
80107f8b:	83 ec 04             	sub    $0x4,%esp
80107f8e:	50                   	push   %eax
80107f8f:	51                   	push   %ecx
80107f90:	52                   	push   %edx
80107f91:	e8 a8 ca ff ff       	call   80104a3e <memmove>
80107f96:	83 c4 10             	add    $0x10,%esp
  memset((unsigned int *)(gpu.vvram_addr + gpu.vram_size - addr_diff),0,addr_diff);
80107f99:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f9c:	8b 0d 4c 6e 19 80    	mov    0x80196e4c,%ecx
80107fa2:	8b 15 50 6e 19 80    	mov    0x80196e50,%edx
80107fa8:	01 ca                	add    %ecx,%edx
80107faa:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80107fad:	29 ca                	sub    %ecx,%edx
80107faf:	83 ec 04             	sub    $0x4,%esp
80107fb2:	50                   	push   %eax
80107fb3:	6a 00                	push   $0x0
80107fb5:	52                   	push   %edx
80107fb6:	e8 c4 c9 ff ff       	call   8010497f <memset>
80107fbb:	83 c4 10             	add    $0x10,%esp
}
80107fbe:	90                   	nop
80107fbf:	c9                   	leave  
80107fc0:	c3                   	ret    

80107fc1 <font_render>:
#include "font.h"


struct graphic_pixel black_pixel = {0x0,0x0,0x0,0x0};
struct graphic_pixel white_pixel = {0xFF,0xFF,0xFF,0x0};
void font_render(int x,int y,int index){
80107fc1:	55                   	push   %ebp
80107fc2:	89 e5                	mov    %esp,%ebp
80107fc4:	53                   	push   %ebx
80107fc5:	83 ec 14             	sub    $0x14,%esp
  int bin;
  for(int i=0;i<30;i++){
80107fc8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107fcf:	e9 b1 00 00 00       	jmp    80108085 <font_render+0xc4>
    for(int j=14;j>-1;j--){
80107fd4:	c7 45 f0 0e 00 00 00 	movl   $0xe,-0x10(%ebp)
80107fdb:	e9 97 00 00 00       	jmp    80108077 <font_render+0xb6>
      bin = (font_bin[index-0x20][i])&(1 << j);
80107fe0:	8b 45 10             	mov    0x10(%ebp),%eax
80107fe3:	83 e8 20             	sub    $0x20,%eax
80107fe6:	6b d0 1e             	imul   $0x1e,%eax,%edx
80107fe9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fec:	01 d0                	add    %edx,%eax
80107fee:	0f b7 84 00 e0 a7 10 	movzwl -0x7fef5820(%eax,%eax,1),%eax
80107ff5:	80 
80107ff6:	0f b7 d0             	movzwl %ax,%edx
80107ff9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107ffc:	bb 01 00 00 00       	mov    $0x1,%ebx
80108001:	89 c1                	mov    %eax,%ecx
80108003:	d3 e3                	shl    %cl,%ebx
80108005:	89 d8                	mov    %ebx,%eax
80108007:	21 d0                	and    %edx,%eax
80108009:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(bin == (1 << j)){
8010800c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010800f:	ba 01 00 00 00       	mov    $0x1,%edx
80108014:	89 c1                	mov    %eax,%ecx
80108016:	d3 e2                	shl    %cl,%edx
80108018:	89 d0                	mov    %edx,%eax
8010801a:	39 45 ec             	cmp    %eax,-0x14(%ebp)
8010801d:	75 2b                	jne    8010804a <font_render+0x89>
        graphic_draw_pixel(x+(14-j),y+i,&white_pixel);
8010801f:	8b 55 0c             	mov    0xc(%ebp),%edx
80108022:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108025:	01 c2                	add    %eax,%edx
80108027:	b8 0e 00 00 00       	mov    $0xe,%eax
8010802c:	2b 45 f0             	sub    -0x10(%ebp),%eax
8010802f:	89 c1                	mov    %eax,%ecx
80108031:	8b 45 08             	mov    0x8(%ebp),%eax
80108034:	01 c8                	add    %ecx,%eax
80108036:	83 ec 04             	sub    $0x4,%esp
80108039:	68 e0 f4 10 80       	push   $0x8010f4e0
8010803e:	52                   	push   %edx
8010803f:	50                   	push   %eax
80108040:	e8 be fe ff ff       	call   80107f03 <graphic_draw_pixel>
80108045:	83 c4 10             	add    $0x10,%esp
80108048:	eb 29                	jmp    80108073 <font_render+0xb2>
      } else {
        graphic_draw_pixel(x+(14-j),y+i,&black_pixel);
8010804a:	8b 55 0c             	mov    0xc(%ebp),%edx
8010804d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108050:	01 c2                	add    %eax,%edx
80108052:	b8 0e 00 00 00       	mov    $0xe,%eax
80108057:	2b 45 f0             	sub    -0x10(%ebp),%eax
8010805a:	89 c1                	mov    %eax,%ecx
8010805c:	8b 45 08             	mov    0x8(%ebp),%eax
8010805f:	01 c8                	add    %ecx,%eax
80108061:	83 ec 04             	sub    $0x4,%esp
80108064:	68 60 6e 19 80       	push   $0x80196e60
80108069:	52                   	push   %edx
8010806a:	50                   	push   %eax
8010806b:	e8 93 fe ff ff       	call   80107f03 <graphic_draw_pixel>
80108070:	83 c4 10             	add    $0x10,%esp
    for(int j=14;j>-1;j--){
80108073:	83 6d f0 01          	subl   $0x1,-0x10(%ebp)
80108077:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010807b:	0f 89 5f ff ff ff    	jns    80107fe0 <font_render+0x1f>
  for(int i=0;i<30;i++){
80108081:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108085:	83 7d f4 1d          	cmpl   $0x1d,-0xc(%ebp)
80108089:	0f 8e 45 ff ff ff    	jle    80107fd4 <font_render+0x13>
      }
    }
  }
}
8010808f:	90                   	nop
80108090:	90                   	nop
80108091:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108094:	c9                   	leave  
80108095:	c3                   	ret    

80108096 <font_render_string>:

void font_render_string(char *string,int row){
80108096:	55                   	push   %ebp
80108097:	89 e5                	mov    %esp,%ebp
80108099:	53                   	push   %ebx
8010809a:	83 ec 14             	sub    $0x14,%esp
  int i = 0;
8010809d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  while(string[i] && i < 52){
801080a4:	eb 33                	jmp    801080d9 <font_render_string+0x43>
    font_render(i*15+2,row*30,string[i]);
801080a6:	8b 55 f4             	mov    -0xc(%ebp),%edx
801080a9:	8b 45 08             	mov    0x8(%ebp),%eax
801080ac:	01 d0                	add    %edx,%eax
801080ae:	0f b6 00             	movzbl (%eax),%eax
801080b1:	0f be c8             	movsbl %al,%ecx
801080b4:	8b 45 0c             	mov    0xc(%ebp),%eax
801080b7:	6b d0 1e             	imul   $0x1e,%eax,%edx
801080ba:	8b 5d f4             	mov    -0xc(%ebp),%ebx
801080bd:	89 d8                	mov    %ebx,%eax
801080bf:	c1 e0 04             	shl    $0x4,%eax
801080c2:	29 d8                	sub    %ebx,%eax
801080c4:	83 c0 02             	add    $0x2,%eax
801080c7:	83 ec 04             	sub    $0x4,%esp
801080ca:	51                   	push   %ecx
801080cb:	52                   	push   %edx
801080cc:	50                   	push   %eax
801080cd:	e8 ef fe ff ff       	call   80107fc1 <font_render>
801080d2:	83 c4 10             	add    $0x10,%esp
    i++;
801080d5:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  while(string[i] && i < 52){
801080d9:	8b 55 f4             	mov    -0xc(%ebp),%edx
801080dc:	8b 45 08             	mov    0x8(%ebp),%eax
801080df:	01 d0                	add    %edx,%eax
801080e1:	0f b6 00             	movzbl (%eax),%eax
801080e4:	84 c0                	test   %al,%al
801080e6:	74 06                	je     801080ee <font_render_string+0x58>
801080e8:	83 7d f4 33          	cmpl   $0x33,-0xc(%ebp)
801080ec:	7e b8                	jle    801080a6 <font_render_string+0x10>
  }
}
801080ee:	90                   	nop
801080ef:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801080f2:	c9                   	leave  
801080f3:	c3                   	ret    

801080f4 <pci_init>:
#include "pci.h"
#include "defs.h"
#include "types.h"
#include "i8254.h"

void pci_init(){
801080f4:	55                   	push   %ebp
801080f5:	89 e5                	mov    %esp,%ebp
801080f7:	53                   	push   %ebx
801080f8:	83 ec 14             	sub    $0x14,%esp
  uint data;
  for(int i=0;i<256;i++){
801080fb:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108102:	eb 6b                	jmp    8010816f <pci_init+0x7b>
    for(int j=0;j<32;j++){
80108104:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
8010810b:	eb 58                	jmp    80108165 <pci_init+0x71>
      for(int k=0;k<8;k++){
8010810d:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80108114:	eb 45                	jmp    8010815b <pci_init+0x67>
      pci_access_config(i,j,k,0,&data);
80108116:	8b 4d ec             	mov    -0x14(%ebp),%ecx
80108119:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010811c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010811f:	83 ec 0c             	sub    $0xc,%esp
80108122:	8d 5d e8             	lea    -0x18(%ebp),%ebx
80108125:	53                   	push   %ebx
80108126:	6a 00                	push   $0x0
80108128:	51                   	push   %ecx
80108129:	52                   	push   %edx
8010812a:	50                   	push   %eax
8010812b:	e8 b0 00 00 00       	call   801081e0 <pci_access_config>
80108130:	83 c4 20             	add    $0x20,%esp
      if((data&0xFFFF) != 0xFFFF){
80108133:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108136:	0f b7 c0             	movzwl %ax,%eax
80108139:	3d ff ff 00 00       	cmp    $0xffff,%eax
8010813e:	74 17                	je     80108157 <pci_init+0x63>
        pci_init_device(i,j,k);
80108140:	8b 4d ec             	mov    -0x14(%ebp),%ecx
80108143:	8b 55 f0             	mov    -0x10(%ebp),%edx
80108146:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108149:	83 ec 04             	sub    $0x4,%esp
8010814c:	51                   	push   %ecx
8010814d:	52                   	push   %edx
8010814e:	50                   	push   %eax
8010814f:	e8 37 01 00 00       	call   8010828b <pci_init_device>
80108154:	83 c4 10             	add    $0x10,%esp
      for(int k=0;k<8;k++){
80108157:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
8010815b:	83 7d ec 07          	cmpl   $0x7,-0x14(%ebp)
8010815f:	7e b5                	jle    80108116 <pci_init+0x22>
    for(int j=0;j<32;j++){
80108161:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80108165:	83 7d f0 1f          	cmpl   $0x1f,-0x10(%ebp)
80108169:	7e a2                	jle    8010810d <pci_init+0x19>
  for(int i=0;i<256;i++){
8010816b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010816f:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80108176:	7e 8c                	jle    80108104 <pci_init+0x10>
      }
      }
    }
  }
}
80108178:	90                   	nop
80108179:	90                   	nop
8010817a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010817d:	c9                   	leave  
8010817e:	c3                   	ret    

8010817f <pci_write_config>:

void pci_write_config(uint config){
8010817f:	55                   	push   %ebp
80108180:	89 e5                	mov    %esp,%ebp
  asm("mov $0xCF8,%%edx\n\t"
80108182:	8b 45 08             	mov    0x8(%ebp),%eax
80108185:	ba f8 0c 00 00       	mov    $0xcf8,%edx
8010818a:	89 c0                	mov    %eax,%eax
8010818c:	ef                   	out    %eax,(%dx)
      "mov %0,%%eax\n\t"
      "out %%eax,%%dx\n\t"
      : :"r"(config));
}
8010818d:	90                   	nop
8010818e:	5d                   	pop    %ebp
8010818f:	c3                   	ret    

80108190 <pci_write_data>:

void pci_write_data(uint config){
80108190:	55                   	push   %ebp
80108191:	89 e5                	mov    %esp,%ebp
  asm("mov $0xCFC,%%edx\n\t"
80108193:	8b 45 08             	mov    0x8(%ebp),%eax
80108196:	ba fc 0c 00 00       	mov    $0xcfc,%edx
8010819b:	89 c0                	mov    %eax,%eax
8010819d:	ef                   	out    %eax,(%dx)
      "mov %0,%%eax\n\t"
      "out %%eax,%%dx\n\t"
      : :"r"(config));
}
8010819e:	90                   	nop
8010819f:	5d                   	pop    %ebp
801081a0:	c3                   	ret    

801081a1 <pci_read_config>:
uint pci_read_config(){
801081a1:	55                   	push   %ebp
801081a2:	89 e5                	mov    %esp,%ebp
801081a4:	83 ec 18             	sub    $0x18,%esp
  uint data;
  asm("mov $0xCFC,%%edx\n\t"
801081a7:	ba fc 0c 00 00       	mov    $0xcfc,%edx
801081ac:	ed                   	in     (%dx),%eax
801081ad:	89 45 f4             	mov    %eax,-0xc(%ebp)
      "in %%dx,%%eax\n\t"
      "mov %%eax,%0"
      :"=m"(data):);
  microdelay(200);
801081b0:	83 ec 0c             	sub    $0xc,%esp
801081b3:	68 c8 00 00 00       	push   $0xc8
801081b8:	e8 7a a9 ff ff       	call   80102b37 <microdelay>
801081bd:	83 c4 10             	add    $0x10,%esp
  return data;
801081c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801081c3:	c9                   	leave  
801081c4:	c3                   	ret    

801081c5 <pci_test>:


void pci_test(){
801081c5:	55                   	push   %ebp
801081c6:	89 e5                	mov    %esp,%ebp
801081c8:	83 ec 10             	sub    $0x10,%esp
  uint data = 0x80001804;
801081cb:	c7 45 fc 04 18 00 80 	movl   $0x80001804,-0x4(%ebp)
  pci_write_config(data);
801081d2:	ff 75 fc             	push   -0x4(%ebp)
801081d5:	e8 a5 ff ff ff       	call   8010817f <pci_write_config>
801081da:	83 c4 04             	add    $0x4,%esp
}
801081dd:	90                   	nop
801081de:	c9                   	leave  
801081df:	c3                   	ret    

801081e0 <pci_access_config>:

void pci_access_config(uint bus_num,uint device_num,uint function_num,uint reg_addr,uint *data){
801081e0:	55                   	push   %ebp
801081e1:	89 e5                	mov    %esp,%ebp
801081e3:	83 ec 18             	sub    $0x18,%esp
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
801081e6:	8b 45 08             	mov    0x8(%ebp),%eax
801081e9:	c1 e0 10             	shl    $0x10,%eax
801081ec:	25 00 00 ff 00       	and    $0xff0000,%eax
801081f1:	89 c2                	mov    %eax,%edx
801081f3:	8b 45 0c             	mov    0xc(%ebp),%eax
801081f6:	c1 e0 0b             	shl    $0xb,%eax
801081f9:	0f b7 c0             	movzwl %ax,%eax
801081fc:	09 c2                	or     %eax,%edx
801081fe:	8b 45 10             	mov    0x10(%ebp),%eax
80108201:	c1 e0 08             	shl    $0x8,%eax
80108204:	25 00 07 00 00       	and    $0x700,%eax
80108209:	09 c2                	or     %eax,%edx
    (reg_addr & 0xFC) | 0x80000000;
8010820b:	8b 45 14             	mov    0x14(%ebp),%eax
8010820e:	25 fc 00 00 00       	and    $0xfc,%eax
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
80108213:	09 d0                	or     %edx,%eax
80108215:	0d 00 00 00 80       	or     $0x80000000,%eax
8010821a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  pci_write_config(config_addr);
8010821d:	ff 75 f4             	push   -0xc(%ebp)
80108220:	e8 5a ff ff ff       	call   8010817f <pci_write_config>
80108225:	83 c4 04             	add    $0x4,%esp
  *data = pci_read_config();
80108228:	e8 74 ff ff ff       	call   801081a1 <pci_read_config>
8010822d:	8b 55 18             	mov    0x18(%ebp),%edx
80108230:	89 02                	mov    %eax,(%edx)
}
80108232:	90                   	nop
80108233:	c9                   	leave  
80108234:	c3                   	ret    

80108235 <pci_write_config_register>:

void pci_write_config_register(uint bus_num,uint device_num,uint function_num,uint reg_addr,uint data){
80108235:	55                   	push   %ebp
80108236:	89 e5                	mov    %esp,%ebp
80108238:	83 ec 10             	sub    $0x10,%esp
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
8010823b:	8b 45 08             	mov    0x8(%ebp),%eax
8010823e:	c1 e0 10             	shl    $0x10,%eax
80108241:	25 00 00 ff 00       	and    $0xff0000,%eax
80108246:	89 c2                	mov    %eax,%edx
80108248:	8b 45 0c             	mov    0xc(%ebp),%eax
8010824b:	c1 e0 0b             	shl    $0xb,%eax
8010824e:	0f b7 c0             	movzwl %ax,%eax
80108251:	09 c2                	or     %eax,%edx
80108253:	8b 45 10             	mov    0x10(%ebp),%eax
80108256:	c1 e0 08             	shl    $0x8,%eax
80108259:	25 00 07 00 00       	and    $0x700,%eax
8010825e:	09 c2                	or     %eax,%edx
    (reg_addr & 0xFC) | 0x80000000;
80108260:	8b 45 14             	mov    0x14(%ebp),%eax
80108263:	25 fc 00 00 00       	and    $0xfc,%eax
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
80108268:	09 d0                	or     %edx,%eax
8010826a:	0d 00 00 00 80       	or     $0x80000000,%eax
8010826f:	89 45 fc             	mov    %eax,-0x4(%ebp)
  pci_write_config(config_addr);
80108272:	ff 75 fc             	push   -0x4(%ebp)
80108275:	e8 05 ff ff ff       	call   8010817f <pci_write_config>
8010827a:	83 c4 04             	add    $0x4,%esp
  pci_write_data(data);
8010827d:	ff 75 18             	push   0x18(%ebp)
80108280:	e8 0b ff ff ff       	call   80108190 <pci_write_data>
80108285:	83 c4 04             	add    $0x4,%esp
}
80108288:	90                   	nop
80108289:	c9                   	leave  
8010828a:	c3                   	ret    

8010828b <pci_init_device>:

struct pci_dev dev;
void pci_init_device(uint bus_num,uint device_num,uint function_num){
8010828b:	55                   	push   %ebp
8010828c:	89 e5                	mov    %esp,%ebp
8010828e:	53                   	push   %ebx
8010828f:	83 ec 14             	sub    $0x14,%esp
  uint data;
  dev.bus_num = bus_num;
80108292:	8b 45 08             	mov    0x8(%ebp),%eax
80108295:	a2 64 6e 19 80       	mov    %al,0x80196e64
  dev.device_num = device_num;
8010829a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010829d:	a2 65 6e 19 80       	mov    %al,0x80196e65
  dev.function_num = function_num;
801082a2:	8b 45 10             	mov    0x10(%ebp),%eax
801082a5:	a2 66 6e 19 80       	mov    %al,0x80196e66
  cprintf("PCI Device Found Bus:0x%x Device:0x%x Function:%x\n",bus_num,device_num,function_num);
801082aa:	ff 75 10             	push   0x10(%ebp)
801082ad:	ff 75 0c             	push   0xc(%ebp)
801082b0:	ff 75 08             	push   0x8(%ebp)
801082b3:	68 24 be 10 80       	push   $0x8010be24
801082b8:	e8 37 81 ff ff       	call   801003f4 <cprintf>
801082bd:	83 c4 10             	add    $0x10,%esp
  
  pci_access_config(bus_num,device_num,function_num,0,&data);
801082c0:	83 ec 0c             	sub    $0xc,%esp
801082c3:	8d 45 ec             	lea    -0x14(%ebp),%eax
801082c6:	50                   	push   %eax
801082c7:	6a 00                	push   $0x0
801082c9:	ff 75 10             	push   0x10(%ebp)
801082cc:	ff 75 0c             	push   0xc(%ebp)
801082cf:	ff 75 08             	push   0x8(%ebp)
801082d2:	e8 09 ff ff ff       	call   801081e0 <pci_access_config>
801082d7:	83 c4 20             	add    $0x20,%esp
  uint device_id = data>>16;
801082da:	8b 45 ec             	mov    -0x14(%ebp),%eax
801082dd:	c1 e8 10             	shr    $0x10,%eax
801082e0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint vendor_id = data&0xFFFF;
801082e3:	8b 45 ec             	mov    -0x14(%ebp),%eax
801082e6:	25 ff ff 00 00       	and    $0xffff,%eax
801082eb:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dev.device_id = device_id;
801082ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082f1:	a3 68 6e 19 80       	mov    %eax,0x80196e68
  dev.vendor_id = vendor_id;
801082f6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801082f9:	a3 6c 6e 19 80       	mov    %eax,0x80196e6c
  cprintf("  Device ID:0x%x  Vendor ID:0x%x\n",device_id,vendor_id);
801082fe:	83 ec 04             	sub    $0x4,%esp
80108301:	ff 75 f0             	push   -0x10(%ebp)
80108304:	ff 75 f4             	push   -0xc(%ebp)
80108307:	68 58 be 10 80       	push   $0x8010be58
8010830c:	e8 e3 80 ff ff       	call   801003f4 <cprintf>
80108311:	83 c4 10             	add    $0x10,%esp
  
  pci_access_config(bus_num,device_num,function_num,0x8,&data);
80108314:	83 ec 0c             	sub    $0xc,%esp
80108317:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010831a:	50                   	push   %eax
8010831b:	6a 08                	push   $0x8
8010831d:	ff 75 10             	push   0x10(%ebp)
80108320:	ff 75 0c             	push   0xc(%ebp)
80108323:	ff 75 08             	push   0x8(%ebp)
80108326:	e8 b5 fe ff ff       	call   801081e0 <pci_access_config>
8010832b:	83 c4 20             	add    $0x20,%esp
  cprintf("  Base Class:0x%x  Sub Class:0x%x  Interface:0x%x  Revision ID:0x%x\n",
8010832e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108331:	0f b6 c8             	movzbl %al,%ecx
      data>>24,(data>>16)&0xFF,(data>>8)&0xFF,data&0xFF);
80108334:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108337:	c1 e8 08             	shr    $0x8,%eax
  cprintf("  Base Class:0x%x  Sub Class:0x%x  Interface:0x%x  Revision ID:0x%x\n",
8010833a:	0f b6 d0             	movzbl %al,%edx
      data>>24,(data>>16)&0xFF,(data>>8)&0xFF,data&0xFF);
8010833d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108340:	c1 e8 10             	shr    $0x10,%eax
  cprintf("  Base Class:0x%x  Sub Class:0x%x  Interface:0x%x  Revision ID:0x%x\n",
80108343:	0f b6 c0             	movzbl %al,%eax
80108346:	8b 5d ec             	mov    -0x14(%ebp),%ebx
80108349:	c1 eb 18             	shr    $0x18,%ebx
8010834c:	83 ec 0c             	sub    $0xc,%esp
8010834f:	51                   	push   %ecx
80108350:	52                   	push   %edx
80108351:	50                   	push   %eax
80108352:	53                   	push   %ebx
80108353:	68 7c be 10 80       	push   $0x8010be7c
80108358:	e8 97 80 ff ff       	call   801003f4 <cprintf>
8010835d:	83 c4 20             	add    $0x20,%esp
  dev.base_class = data>>24;
80108360:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108363:	c1 e8 18             	shr    $0x18,%eax
80108366:	a2 70 6e 19 80       	mov    %al,0x80196e70
  dev.sub_class = (data>>16)&0xFF;
8010836b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010836e:	c1 e8 10             	shr    $0x10,%eax
80108371:	a2 71 6e 19 80       	mov    %al,0x80196e71
  dev.interface = (data>>8)&0xFF;
80108376:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108379:	c1 e8 08             	shr    $0x8,%eax
8010837c:	a2 72 6e 19 80       	mov    %al,0x80196e72
  dev.revision_id = data&0xFF;
80108381:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108384:	a2 73 6e 19 80       	mov    %al,0x80196e73
  
  pci_access_config(bus_num,device_num,function_num,0x10,&data);
80108389:	83 ec 0c             	sub    $0xc,%esp
8010838c:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010838f:	50                   	push   %eax
80108390:	6a 10                	push   $0x10
80108392:	ff 75 10             	push   0x10(%ebp)
80108395:	ff 75 0c             	push   0xc(%ebp)
80108398:	ff 75 08             	push   0x8(%ebp)
8010839b:	e8 40 fe ff ff       	call   801081e0 <pci_access_config>
801083a0:	83 c4 20             	add    $0x20,%esp
  dev.bar0 = data;
801083a3:	8b 45 ec             	mov    -0x14(%ebp),%eax
801083a6:	a3 74 6e 19 80       	mov    %eax,0x80196e74
  pci_access_config(bus_num,device_num,function_num,0x14,&data);
801083ab:	83 ec 0c             	sub    $0xc,%esp
801083ae:	8d 45 ec             	lea    -0x14(%ebp),%eax
801083b1:	50                   	push   %eax
801083b2:	6a 14                	push   $0x14
801083b4:	ff 75 10             	push   0x10(%ebp)
801083b7:	ff 75 0c             	push   0xc(%ebp)
801083ba:	ff 75 08             	push   0x8(%ebp)
801083bd:	e8 1e fe ff ff       	call   801081e0 <pci_access_config>
801083c2:	83 c4 20             	add    $0x20,%esp
  dev.bar1 = data;
801083c5:	8b 45 ec             	mov    -0x14(%ebp),%eax
801083c8:	a3 78 6e 19 80       	mov    %eax,0x80196e78
  if(device_id == I8254_DEVICE_ID && vendor_id == I8254_VENDOR_ID){
801083cd:	81 7d f4 0e 10 00 00 	cmpl   $0x100e,-0xc(%ebp)
801083d4:	75 5a                	jne    80108430 <pci_init_device+0x1a5>
801083d6:	81 7d f0 86 80 00 00 	cmpl   $0x8086,-0x10(%ebp)
801083dd:	75 51                	jne    80108430 <pci_init_device+0x1a5>
    cprintf("E1000 Ethernet NIC Found\n");
801083df:	83 ec 0c             	sub    $0xc,%esp
801083e2:	68 c1 be 10 80       	push   $0x8010bec1
801083e7:	e8 08 80 ff ff       	call   801003f4 <cprintf>
801083ec:	83 c4 10             	add    $0x10,%esp
    pci_access_config(bus_num,device_num,function_num,0xF0,&data);
801083ef:	83 ec 0c             	sub    $0xc,%esp
801083f2:	8d 45 ec             	lea    -0x14(%ebp),%eax
801083f5:	50                   	push   %eax
801083f6:	68 f0 00 00 00       	push   $0xf0
801083fb:	ff 75 10             	push   0x10(%ebp)
801083fe:	ff 75 0c             	push   0xc(%ebp)
80108401:	ff 75 08             	push   0x8(%ebp)
80108404:	e8 d7 fd ff ff       	call   801081e0 <pci_access_config>
80108409:	83 c4 20             	add    $0x20,%esp
    cprintf("Message Control:%x\n",data);
8010840c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010840f:	83 ec 08             	sub    $0x8,%esp
80108412:	50                   	push   %eax
80108413:	68 db be 10 80       	push   $0x8010bedb
80108418:	e8 d7 7f ff ff       	call   801003f4 <cprintf>
8010841d:	83 c4 10             	add    $0x10,%esp
    i8254_init(&dev);
80108420:	83 ec 0c             	sub    $0xc,%esp
80108423:	68 64 6e 19 80       	push   $0x80196e64
80108428:	e8 09 00 00 00       	call   80108436 <i8254_init>
8010842d:	83 c4 10             	add    $0x10,%esp
  }
}
80108430:	90                   	nop
80108431:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108434:	c9                   	leave  
80108435:	c3                   	ret    

80108436 <i8254_init>:

uint base_addr;
uchar mac_addr[6] = {0};
uchar my_ip[4] = {10,0,1,10}; 
uint *intr_addr;
void i8254_init(struct pci_dev *dev){
80108436:	55                   	push   %ebp
80108437:	89 e5                	mov    %esp,%ebp
80108439:	53                   	push   %ebx
8010843a:	83 ec 14             	sub    $0x14,%esp
  uint cmd_reg;
  //Enable Bus Master
  pci_access_config(dev->bus_num,dev->device_num,dev->function_num,0x04,&cmd_reg);
8010843d:	8b 45 08             	mov    0x8(%ebp),%eax
80108440:	0f b6 40 02          	movzbl 0x2(%eax),%eax
80108444:	0f b6 c8             	movzbl %al,%ecx
80108447:	8b 45 08             	mov    0x8(%ebp),%eax
8010844a:	0f b6 40 01          	movzbl 0x1(%eax),%eax
8010844e:	0f b6 d0             	movzbl %al,%edx
80108451:	8b 45 08             	mov    0x8(%ebp),%eax
80108454:	0f b6 00             	movzbl (%eax),%eax
80108457:	0f b6 c0             	movzbl %al,%eax
8010845a:	83 ec 0c             	sub    $0xc,%esp
8010845d:	8d 5d ec             	lea    -0x14(%ebp),%ebx
80108460:	53                   	push   %ebx
80108461:	6a 04                	push   $0x4
80108463:	51                   	push   %ecx
80108464:	52                   	push   %edx
80108465:	50                   	push   %eax
80108466:	e8 75 fd ff ff       	call   801081e0 <pci_access_config>
8010846b:	83 c4 20             	add    $0x20,%esp
  cmd_reg = cmd_reg | PCI_CMD_BUS_MASTER;
8010846e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108471:	83 c8 04             	or     $0x4,%eax
80108474:	89 45 ec             	mov    %eax,-0x14(%ebp)
  pci_write_config_register(dev->bus_num,dev->device_num,dev->function_num,0x04,cmd_reg);
80108477:	8b 5d ec             	mov    -0x14(%ebp),%ebx
8010847a:	8b 45 08             	mov    0x8(%ebp),%eax
8010847d:	0f b6 40 02          	movzbl 0x2(%eax),%eax
80108481:	0f b6 c8             	movzbl %al,%ecx
80108484:	8b 45 08             	mov    0x8(%ebp),%eax
80108487:	0f b6 40 01          	movzbl 0x1(%eax),%eax
8010848b:	0f b6 d0             	movzbl %al,%edx
8010848e:	8b 45 08             	mov    0x8(%ebp),%eax
80108491:	0f b6 00             	movzbl (%eax),%eax
80108494:	0f b6 c0             	movzbl %al,%eax
80108497:	83 ec 0c             	sub    $0xc,%esp
8010849a:	53                   	push   %ebx
8010849b:	6a 04                	push   $0x4
8010849d:	51                   	push   %ecx
8010849e:	52                   	push   %edx
8010849f:	50                   	push   %eax
801084a0:	e8 90 fd ff ff       	call   80108235 <pci_write_config_register>
801084a5:	83 c4 20             	add    $0x20,%esp
  
  base_addr = PCI_P2V(dev->bar0);
801084a8:	8b 45 08             	mov    0x8(%ebp),%eax
801084ab:	8b 40 10             	mov    0x10(%eax),%eax
801084ae:	05 00 00 00 40       	add    $0x40000000,%eax
801084b3:	a3 7c 6e 19 80       	mov    %eax,0x80196e7c
  uint *ctrl = (uint *)base_addr;
801084b8:	a1 7c 6e 19 80       	mov    0x80196e7c,%eax
801084bd:	89 45 f4             	mov    %eax,-0xc(%ebp)
  //Disable Interrupts
  uint *imc = (uint *)(base_addr+0xD8);
801084c0:	a1 7c 6e 19 80       	mov    0x80196e7c,%eax
801084c5:	05 d8 00 00 00       	add    $0xd8,%eax
801084ca:	89 45 f0             	mov    %eax,-0x10(%ebp)
  *imc = 0xFFFFFFFF;
801084cd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801084d0:	c7 00 ff ff ff ff    	movl   $0xffffffff,(%eax)
  
  //Reset NIC
  *ctrl = *ctrl | I8254_CTRL_RST;
801084d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084d9:	8b 00                	mov    (%eax),%eax
801084db:	0d 00 00 00 04       	or     $0x4000000,%eax
801084e0:	89 c2                	mov    %eax,%edx
801084e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084e5:	89 10                	mov    %edx,(%eax)

  //Enable Interrupts
  *imc = 0xFFFFFFFF;
801084e7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801084ea:	c7 00 ff ff ff ff    	movl   $0xffffffff,(%eax)

  //Enable Link
  *ctrl |= I8254_CTRL_SLU;
801084f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084f3:	8b 00                	mov    (%eax),%eax
801084f5:	83 c8 40             	or     $0x40,%eax
801084f8:	89 c2                	mov    %eax,%edx
801084fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084fd:	89 10                	mov    %edx,(%eax)
  
  //General Configuration
  *ctrl &= (~I8254_CTRL_PHY_RST | ~I8254_CTRL_VME | ~I8254_CTRL_ILOS);
801084ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108502:	8b 10                	mov    (%eax),%edx
80108504:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108507:	89 10                	mov    %edx,(%eax)
  cprintf("E1000 General Configuration Done\n");
80108509:	83 ec 0c             	sub    $0xc,%esp
8010850c:	68 f0 be 10 80       	push   $0x8010bef0
80108511:	e8 de 7e ff ff       	call   801003f4 <cprintf>
80108516:	83 c4 10             	add    $0x10,%esp
  intr_addr = (uint *)kalloc();
80108519:	e8 82 a2 ff ff       	call   801027a0 <kalloc>
8010851e:	a3 88 6e 19 80       	mov    %eax,0x80196e88
  *intr_addr = 0;
80108523:	a1 88 6e 19 80       	mov    0x80196e88,%eax
80108528:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  cprintf("INTR_ADDR:%x\n",intr_addr);
8010852e:	a1 88 6e 19 80       	mov    0x80196e88,%eax
80108533:	83 ec 08             	sub    $0x8,%esp
80108536:	50                   	push   %eax
80108537:	68 12 bf 10 80       	push   $0x8010bf12
8010853c:	e8 b3 7e ff ff       	call   801003f4 <cprintf>
80108541:	83 c4 10             	add    $0x10,%esp
  i8254_init_recv();
80108544:	e8 50 00 00 00       	call   80108599 <i8254_init_recv>
  i8254_init_send();
80108549:	e8 69 03 00 00       	call   801088b7 <i8254_init_send>
  cprintf("IP Address %d.%d.%d.%d\n",
      my_ip[0],
      my_ip[1],
      my_ip[2],
      my_ip[3]);
8010854e:	0f b6 05 e7 f4 10 80 	movzbl 0x8010f4e7,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
80108555:	0f b6 d8             	movzbl %al,%ebx
      my_ip[2],
80108558:	0f b6 05 e6 f4 10 80 	movzbl 0x8010f4e6,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
8010855f:	0f b6 c8             	movzbl %al,%ecx
      my_ip[1],
80108562:	0f b6 05 e5 f4 10 80 	movzbl 0x8010f4e5,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
80108569:	0f b6 d0             	movzbl %al,%edx
      my_ip[0],
8010856c:	0f b6 05 e4 f4 10 80 	movzbl 0x8010f4e4,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
80108573:	0f b6 c0             	movzbl %al,%eax
80108576:	83 ec 0c             	sub    $0xc,%esp
80108579:	53                   	push   %ebx
8010857a:	51                   	push   %ecx
8010857b:	52                   	push   %edx
8010857c:	50                   	push   %eax
8010857d:	68 20 bf 10 80       	push   $0x8010bf20
80108582:	e8 6d 7e ff ff       	call   801003f4 <cprintf>
80108587:	83 c4 20             	add    $0x20,%esp
  *imc = 0x0;
8010858a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010858d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
}
80108593:	90                   	nop
80108594:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108597:	c9                   	leave  
80108598:	c3                   	ret    

80108599 <i8254_init_recv>:

void i8254_init_recv(){
80108599:	55                   	push   %ebp
8010859a:	89 e5                	mov    %esp,%ebp
8010859c:	57                   	push   %edi
8010859d:	56                   	push   %esi
8010859e:	53                   	push   %ebx
8010859f:	83 ec 6c             	sub    $0x6c,%esp
  
  uint data_l = i8254_read_eeprom(0x0);
801085a2:	83 ec 0c             	sub    $0xc,%esp
801085a5:	6a 00                	push   $0x0
801085a7:	e8 e8 04 00 00       	call   80108a94 <i8254_read_eeprom>
801085ac:	83 c4 10             	add    $0x10,%esp
801085af:	89 45 d8             	mov    %eax,-0x28(%ebp)
  mac_addr[0] = data_l&0xFF;
801085b2:	8b 45 d8             	mov    -0x28(%ebp),%eax
801085b5:	a2 80 6e 19 80       	mov    %al,0x80196e80
  mac_addr[1] = data_l>>8;
801085ba:	8b 45 d8             	mov    -0x28(%ebp),%eax
801085bd:	c1 e8 08             	shr    $0x8,%eax
801085c0:	a2 81 6e 19 80       	mov    %al,0x80196e81
  uint data_m = i8254_read_eeprom(0x1);
801085c5:	83 ec 0c             	sub    $0xc,%esp
801085c8:	6a 01                	push   $0x1
801085ca:	e8 c5 04 00 00       	call   80108a94 <i8254_read_eeprom>
801085cf:	83 c4 10             	add    $0x10,%esp
801085d2:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  mac_addr[2] = data_m&0xFF;
801085d5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
801085d8:	a2 82 6e 19 80       	mov    %al,0x80196e82
  mac_addr[3] = data_m>>8;
801085dd:	8b 45 d4             	mov    -0x2c(%ebp),%eax
801085e0:	c1 e8 08             	shr    $0x8,%eax
801085e3:	a2 83 6e 19 80       	mov    %al,0x80196e83
  uint data_h = i8254_read_eeprom(0x2);
801085e8:	83 ec 0c             	sub    $0xc,%esp
801085eb:	6a 02                	push   $0x2
801085ed:	e8 a2 04 00 00       	call   80108a94 <i8254_read_eeprom>
801085f2:	83 c4 10             	add    $0x10,%esp
801085f5:	89 45 d0             	mov    %eax,-0x30(%ebp)
  mac_addr[4] = data_h&0xFF;
801085f8:	8b 45 d0             	mov    -0x30(%ebp),%eax
801085fb:	a2 84 6e 19 80       	mov    %al,0x80196e84
  mac_addr[5] = data_h>>8;
80108600:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108603:	c1 e8 08             	shr    $0x8,%eax
80108606:	a2 85 6e 19 80       	mov    %al,0x80196e85
      mac_addr[0],
      mac_addr[1],
      mac_addr[2],
      mac_addr[3],
      mac_addr[4],
      mac_addr[5]);
8010860b:	0f b6 05 85 6e 19 80 	movzbl 0x80196e85,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108612:	0f b6 f8             	movzbl %al,%edi
      mac_addr[4],
80108615:	0f b6 05 84 6e 19 80 	movzbl 0x80196e84,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
8010861c:	0f b6 f0             	movzbl %al,%esi
      mac_addr[3],
8010861f:	0f b6 05 83 6e 19 80 	movzbl 0x80196e83,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108626:	0f b6 d8             	movzbl %al,%ebx
      mac_addr[2],
80108629:	0f b6 05 82 6e 19 80 	movzbl 0x80196e82,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108630:	0f b6 c8             	movzbl %al,%ecx
      mac_addr[1],
80108633:	0f b6 05 81 6e 19 80 	movzbl 0x80196e81,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
8010863a:	0f b6 d0             	movzbl %al,%edx
      mac_addr[0],
8010863d:	0f b6 05 80 6e 19 80 	movzbl 0x80196e80,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108644:	0f b6 c0             	movzbl %al,%eax
80108647:	83 ec 04             	sub    $0x4,%esp
8010864a:	57                   	push   %edi
8010864b:	56                   	push   %esi
8010864c:	53                   	push   %ebx
8010864d:	51                   	push   %ecx
8010864e:	52                   	push   %edx
8010864f:	50                   	push   %eax
80108650:	68 38 bf 10 80       	push   $0x8010bf38
80108655:	e8 9a 7d ff ff       	call   801003f4 <cprintf>
8010865a:	83 c4 20             	add    $0x20,%esp

  uint *ral = (uint *)(base_addr + 0x5400);
8010865d:	a1 7c 6e 19 80       	mov    0x80196e7c,%eax
80108662:	05 00 54 00 00       	add    $0x5400,%eax
80108667:	89 45 cc             	mov    %eax,-0x34(%ebp)
  uint *rah = (uint *)(base_addr + 0x5404);
8010866a:	a1 7c 6e 19 80       	mov    0x80196e7c,%eax
8010866f:	05 04 54 00 00       	add    $0x5404,%eax
80108674:	89 45 c8             	mov    %eax,-0x38(%ebp)

  *ral = (data_l | (data_m << 16));
80108677:	8b 45 d4             	mov    -0x2c(%ebp),%eax
8010867a:	c1 e0 10             	shl    $0x10,%eax
8010867d:	0b 45 d8             	or     -0x28(%ebp),%eax
80108680:	89 c2                	mov    %eax,%edx
80108682:	8b 45 cc             	mov    -0x34(%ebp),%eax
80108685:	89 10                	mov    %edx,(%eax)
  *rah = (data_h | I8254_RAH_AS_DEST | I8254_RAH_AV);
80108687:	8b 45 d0             	mov    -0x30(%ebp),%eax
8010868a:	0d 00 00 00 80       	or     $0x80000000,%eax
8010868f:	89 c2                	mov    %eax,%edx
80108691:	8b 45 c8             	mov    -0x38(%ebp),%eax
80108694:	89 10                	mov    %edx,(%eax)

  uint *mta = (uint *)(base_addr + 0x5200);
80108696:	a1 7c 6e 19 80       	mov    0x80196e7c,%eax
8010869b:	05 00 52 00 00       	add    $0x5200,%eax
801086a0:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  for(int i=0;i<128;i++){
801086a3:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
801086aa:	eb 19                	jmp    801086c5 <i8254_init_recv+0x12c>
    mta[i] = 0;
801086ac:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801086af:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801086b6:	8b 45 c4             	mov    -0x3c(%ebp),%eax
801086b9:	01 d0                	add    %edx,%eax
801086bb:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(int i=0;i<128;i++){
801086c1:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
801086c5:	83 7d e4 7f          	cmpl   $0x7f,-0x1c(%ebp)
801086c9:	7e e1                	jle    801086ac <i8254_init_recv+0x113>
  }

  uint *ims = (uint *)(base_addr + 0xD0);
801086cb:	a1 7c 6e 19 80       	mov    0x80196e7c,%eax
801086d0:	05 d0 00 00 00       	add    $0xd0,%eax
801086d5:	89 45 c0             	mov    %eax,-0x40(%ebp)
  *ims = (I8254_IMS_RXT0 | I8254_IMS_RXDMT0 | I8254_IMS_RXSEQ | I8254_IMS_LSC | I8254_IMS_RXO);
801086d8:	8b 45 c0             	mov    -0x40(%ebp),%eax
801086db:	c7 00 dc 00 00 00    	movl   $0xdc,(%eax)
  uint *ics = (uint *)(base_addr + 0xC8);
801086e1:	a1 7c 6e 19 80       	mov    0x80196e7c,%eax
801086e6:	05 c8 00 00 00       	add    $0xc8,%eax
801086eb:	89 45 bc             	mov    %eax,-0x44(%ebp)
  *ics = (I8254_IMS_RXT0 | I8254_IMS_RXDMT0 | I8254_IMS_RXSEQ | I8254_IMS_LSC | I8254_IMS_RXO);
801086ee:	8b 45 bc             	mov    -0x44(%ebp),%eax
801086f1:	c7 00 dc 00 00 00    	movl   $0xdc,(%eax)



  uint *rxdctl = (uint *)(base_addr + 0x2828);
801086f7:	a1 7c 6e 19 80       	mov    0x80196e7c,%eax
801086fc:	05 28 28 00 00       	add    $0x2828,%eax
80108701:	89 45 b8             	mov    %eax,-0x48(%ebp)
  *rxdctl = 0;
80108704:	8b 45 b8             	mov    -0x48(%ebp),%eax
80108707:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  uint *rctl = (uint *)(base_addr + 0x100);
8010870d:	a1 7c 6e 19 80       	mov    0x80196e7c,%eax
80108712:	05 00 01 00 00       	add    $0x100,%eax
80108717:	89 45 b4             	mov    %eax,-0x4c(%ebp)
  *rctl = (I8254_RCTL_UPE | I8254_RCTL_MPE | I8254_RCTL_BAM | I8254_RCTL_BSIZE | I8254_RCTL_SECRC);
8010871a:	8b 45 b4             	mov    -0x4c(%ebp),%eax
8010871d:	c7 00 18 80 00 04    	movl   $0x4008018,(%eax)

  uint recv_desc_addr = (uint)kalloc();
80108723:	e8 78 a0 ff ff       	call   801027a0 <kalloc>
80108728:	89 45 b0             	mov    %eax,-0x50(%ebp)
  uint *rdbal = (uint *)(base_addr + 0x2800);
8010872b:	a1 7c 6e 19 80       	mov    0x80196e7c,%eax
80108730:	05 00 28 00 00       	add    $0x2800,%eax
80108735:	89 45 ac             	mov    %eax,-0x54(%ebp)
  uint *rdbah = (uint *)(base_addr + 0x2804);
80108738:	a1 7c 6e 19 80       	mov    0x80196e7c,%eax
8010873d:	05 04 28 00 00       	add    $0x2804,%eax
80108742:	89 45 a8             	mov    %eax,-0x58(%ebp)
  uint *rdlen = (uint *)(base_addr + 0x2808);
80108745:	a1 7c 6e 19 80       	mov    0x80196e7c,%eax
8010874a:	05 08 28 00 00       	add    $0x2808,%eax
8010874f:	89 45 a4             	mov    %eax,-0x5c(%ebp)
  uint *rdh = (uint *)(base_addr + 0x2810);
80108752:	a1 7c 6e 19 80       	mov    0x80196e7c,%eax
80108757:	05 10 28 00 00       	add    $0x2810,%eax
8010875c:	89 45 a0             	mov    %eax,-0x60(%ebp)
  uint *rdt = (uint *)(base_addr + 0x2818);
8010875f:	a1 7c 6e 19 80       	mov    0x80196e7c,%eax
80108764:	05 18 28 00 00       	add    $0x2818,%eax
80108769:	89 45 9c             	mov    %eax,-0x64(%ebp)

  *rdbal = V2P(recv_desc_addr);
8010876c:	8b 45 b0             	mov    -0x50(%ebp),%eax
8010876f:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80108775:	8b 45 ac             	mov    -0x54(%ebp),%eax
80108778:	89 10                	mov    %edx,(%eax)
  *rdbah = 0;
8010877a:	8b 45 a8             	mov    -0x58(%ebp),%eax
8010877d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *rdlen = sizeof(struct i8254_recv_desc)*I8254_RECV_DESC_NUM;
80108783:	8b 45 a4             	mov    -0x5c(%ebp),%eax
80108786:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  *rdh = 0;
8010878c:	8b 45 a0             	mov    -0x60(%ebp),%eax
8010878f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *rdt = I8254_RECV_DESC_NUM;
80108795:	8b 45 9c             	mov    -0x64(%ebp),%eax
80108798:	c7 00 00 01 00 00    	movl   $0x100,(%eax)

  struct i8254_recv_desc *recv_desc = (struct i8254_recv_desc *)recv_desc_addr;
8010879e:	8b 45 b0             	mov    -0x50(%ebp),%eax
801087a1:	89 45 98             	mov    %eax,-0x68(%ebp)
  for(int i=0;i<I8254_RECV_DESC_NUM;i++){
801087a4:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
801087ab:	eb 73                	jmp    80108820 <i8254_init_recv+0x287>
    recv_desc[i].padding = 0;
801087ad:	8b 45 e0             	mov    -0x20(%ebp),%eax
801087b0:	c1 e0 04             	shl    $0x4,%eax
801087b3:	89 c2                	mov    %eax,%edx
801087b5:	8b 45 98             	mov    -0x68(%ebp),%eax
801087b8:	01 d0                	add    %edx,%eax
801087ba:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    recv_desc[i].len = 0;
801087c1:	8b 45 e0             	mov    -0x20(%ebp),%eax
801087c4:	c1 e0 04             	shl    $0x4,%eax
801087c7:	89 c2                	mov    %eax,%edx
801087c9:	8b 45 98             	mov    -0x68(%ebp),%eax
801087cc:	01 d0                	add    %edx,%eax
801087ce:	66 c7 40 08 00 00    	movw   $0x0,0x8(%eax)
    recv_desc[i].chk_sum = 0;
801087d4:	8b 45 e0             	mov    -0x20(%ebp),%eax
801087d7:	c1 e0 04             	shl    $0x4,%eax
801087da:	89 c2                	mov    %eax,%edx
801087dc:	8b 45 98             	mov    -0x68(%ebp),%eax
801087df:	01 d0                	add    %edx,%eax
801087e1:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
    recv_desc[i].status = 0;
801087e7:	8b 45 e0             	mov    -0x20(%ebp),%eax
801087ea:	c1 e0 04             	shl    $0x4,%eax
801087ed:	89 c2                	mov    %eax,%edx
801087ef:	8b 45 98             	mov    -0x68(%ebp),%eax
801087f2:	01 d0                	add    %edx,%eax
801087f4:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
    recv_desc[i].errors = 0;
801087f8:	8b 45 e0             	mov    -0x20(%ebp),%eax
801087fb:	c1 e0 04             	shl    $0x4,%eax
801087fe:	89 c2                	mov    %eax,%edx
80108800:	8b 45 98             	mov    -0x68(%ebp),%eax
80108803:	01 d0                	add    %edx,%eax
80108805:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
    recv_desc[i].special = 0;
80108809:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010880c:	c1 e0 04             	shl    $0x4,%eax
8010880f:	89 c2                	mov    %eax,%edx
80108811:	8b 45 98             	mov    -0x68(%ebp),%eax
80108814:	01 d0                	add    %edx,%eax
80108816:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
  for(int i=0;i<I8254_RECV_DESC_NUM;i++){
8010881c:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
80108820:	81 7d e0 ff 00 00 00 	cmpl   $0xff,-0x20(%ebp)
80108827:	7e 84                	jle    801087ad <i8254_init_recv+0x214>
  }

  for(int i=0;i<(I8254_RECV_DESC_NUM)/2;i++){
80108829:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
80108830:	eb 57                	jmp    80108889 <i8254_init_recv+0x2f0>
    uint buf_addr = (uint)kalloc();
80108832:	e8 69 9f ff ff       	call   801027a0 <kalloc>
80108837:	89 45 94             	mov    %eax,-0x6c(%ebp)
    if(buf_addr == 0){
8010883a:	83 7d 94 00          	cmpl   $0x0,-0x6c(%ebp)
8010883e:	75 12                	jne    80108852 <i8254_init_recv+0x2b9>
      cprintf("failed to allocate buffer area\n");
80108840:	83 ec 0c             	sub    $0xc,%esp
80108843:	68 58 bf 10 80       	push   $0x8010bf58
80108848:	e8 a7 7b ff ff       	call   801003f4 <cprintf>
8010884d:	83 c4 10             	add    $0x10,%esp
      break;
80108850:	eb 3d                	jmp    8010888f <i8254_init_recv+0x2f6>
    }
    recv_desc[i].buf_addr = V2P(buf_addr);
80108852:	8b 45 dc             	mov    -0x24(%ebp),%eax
80108855:	c1 e0 04             	shl    $0x4,%eax
80108858:	89 c2                	mov    %eax,%edx
8010885a:	8b 45 98             	mov    -0x68(%ebp),%eax
8010885d:	01 d0                	add    %edx,%eax
8010885f:	8b 55 94             	mov    -0x6c(%ebp),%edx
80108862:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80108868:	89 10                	mov    %edx,(%eax)
    recv_desc[i+1].buf_addr = V2P(buf_addr + 0x800);
8010886a:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010886d:	83 c0 01             	add    $0x1,%eax
80108870:	c1 e0 04             	shl    $0x4,%eax
80108873:	89 c2                	mov    %eax,%edx
80108875:	8b 45 98             	mov    -0x68(%ebp),%eax
80108878:	01 d0                	add    %edx,%eax
8010887a:	8b 55 94             	mov    -0x6c(%ebp),%edx
8010887d:	81 ea 00 f8 ff 7f    	sub    $0x7ffff800,%edx
80108883:	89 10                	mov    %edx,(%eax)
  for(int i=0;i<(I8254_RECV_DESC_NUM)/2;i++){
80108885:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
80108889:	83 7d dc 7f          	cmpl   $0x7f,-0x24(%ebp)
8010888d:	7e a3                	jle    80108832 <i8254_init_recv+0x299>
  }

  *rctl |= I8254_RCTL_EN;
8010888f:	8b 45 b4             	mov    -0x4c(%ebp),%eax
80108892:	8b 00                	mov    (%eax),%eax
80108894:	83 c8 02             	or     $0x2,%eax
80108897:	89 c2                	mov    %eax,%edx
80108899:	8b 45 b4             	mov    -0x4c(%ebp),%eax
8010889c:	89 10                	mov    %edx,(%eax)
  cprintf("E1000 Recieve Initialize Done\n");
8010889e:	83 ec 0c             	sub    $0xc,%esp
801088a1:	68 78 bf 10 80       	push   $0x8010bf78
801088a6:	e8 49 7b ff ff       	call   801003f4 <cprintf>
801088ab:	83 c4 10             	add    $0x10,%esp
}
801088ae:	90                   	nop
801088af:	8d 65 f4             	lea    -0xc(%ebp),%esp
801088b2:	5b                   	pop    %ebx
801088b3:	5e                   	pop    %esi
801088b4:	5f                   	pop    %edi
801088b5:	5d                   	pop    %ebp
801088b6:	c3                   	ret    

801088b7 <i8254_init_send>:

void i8254_init_send(){
801088b7:	55                   	push   %ebp
801088b8:	89 e5                	mov    %esp,%ebp
801088ba:	83 ec 48             	sub    $0x48,%esp
  uint *txdctl = (uint *)(base_addr + 0x3828);
801088bd:	a1 7c 6e 19 80       	mov    0x80196e7c,%eax
801088c2:	05 28 38 00 00       	add    $0x3828,%eax
801088c7:	89 45 ec             	mov    %eax,-0x14(%ebp)
  *txdctl = (I8254_TXDCTL_WTHRESH | I8254_TXDCTL_GRAN_DESC);
801088ca:	8b 45 ec             	mov    -0x14(%ebp),%eax
801088cd:	c7 00 00 00 01 01    	movl   $0x1010000,(%eax)

  uint tx_desc_addr = (uint)kalloc();
801088d3:	e8 c8 9e ff ff       	call   801027a0 <kalloc>
801088d8:	89 45 e8             	mov    %eax,-0x18(%ebp)
  uint *tdbal = (uint *)(base_addr + 0x3800);
801088db:	a1 7c 6e 19 80       	mov    0x80196e7c,%eax
801088e0:	05 00 38 00 00       	add    $0x3800,%eax
801088e5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  uint *tdbah = (uint *)(base_addr + 0x3804);
801088e8:	a1 7c 6e 19 80       	mov    0x80196e7c,%eax
801088ed:	05 04 38 00 00       	add    $0x3804,%eax
801088f2:	89 45 e0             	mov    %eax,-0x20(%ebp)
  uint *tdlen = (uint *)(base_addr + 0x3808);
801088f5:	a1 7c 6e 19 80       	mov    0x80196e7c,%eax
801088fa:	05 08 38 00 00       	add    $0x3808,%eax
801088ff:	89 45 dc             	mov    %eax,-0x24(%ebp)

  *tdbal = V2P(tx_desc_addr);
80108902:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108905:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
8010890b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010890e:	89 10                	mov    %edx,(%eax)
  *tdbah = 0;
80108910:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108913:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *tdlen = sizeof(struct i8254_send_desc)*I8254_SEND_DESC_NUM;
80108919:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010891c:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  uint *tdh = (uint *)(base_addr + 0x3810);
80108922:	a1 7c 6e 19 80       	mov    0x80196e7c,%eax
80108927:	05 10 38 00 00       	add    $0x3810,%eax
8010892c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  uint *tdt = (uint *)(base_addr + 0x3818);
8010892f:	a1 7c 6e 19 80       	mov    0x80196e7c,%eax
80108934:	05 18 38 00 00       	add    $0x3818,%eax
80108939:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  
  *tdh = 0;
8010893c:	8b 45 d8             	mov    -0x28(%ebp),%eax
8010893f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *tdt = 0;
80108945:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80108948:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  struct i8254_send_desc *send_desc = (struct i8254_send_desc *)tx_desc_addr;
8010894e:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108951:	89 45 d0             	mov    %eax,-0x30(%ebp)
  for(int i=0;i<I8254_SEND_DESC_NUM;i++){
80108954:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010895b:	e9 82 00 00 00       	jmp    801089e2 <i8254_init_send+0x12b>
    send_desc[i].padding = 0;
80108960:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108963:	c1 e0 04             	shl    $0x4,%eax
80108966:	89 c2                	mov    %eax,%edx
80108968:	8b 45 d0             	mov    -0x30(%ebp),%eax
8010896b:	01 d0                	add    %edx,%eax
8010896d:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    send_desc[i].len = 0;
80108974:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108977:	c1 e0 04             	shl    $0x4,%eax
8010897a:	89 c2                	mov    %eax,%edx
8010897c:	8b 45 d0             	mov    -0x30(%ebp),%eax
8010897f:	01 d0                	add    %edx,%eax
80108981:	66 c7 40 08 00 00    	movw   $0x0,0x8(%eax)
    send_desc[i].cso = 0;
80108987:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010898a:	c1 e0 04             	shl    $0x4,%eax
8010898d:	89 c2                	mov    %eax,%edx
8010898f:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108992:	01 d0                	add    %edx,%eax
80108994:	c6 40 0a 00          	movb   $0x0,0xa(%eax)
    send_desc[i].cmd = 0;
80108998:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010899b:	c1 e0 04             	shl    $0x4,%eax
8010899e:	89 c2                	mov    %eax,%edx
801089a0:	8b 45 d0             	mov    -0x30(%ebp),%eax
801089a3:	01 d0                	add    %edx,%eax
801089a5:	c6 40 0b 00          	movb   $0x0,0xb(%eax)
    send_desc[i].sta = 0;
801089a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089ac:	c1 e0 04             	shl    $0x4,%eax
801089af:	89 c2                	mov    %eax,%edx
801089b1:	8b 45 d0             	mov    -0x30(%ebp),%eax
801089b4:	01 d0                	add    %edx,%eax
801089b6:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
    send_desc[i].css = 0;
801089ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089bd:	c1 e0 04             	shl    $0x4,%eax
801089c0:	89 c2                	mov    %eax,%edx
801089c2:	8b 45 d0             	mov    -0x30(%ebp),%eax
801089c5:	01 d0                	add    %edx,%eax
801089c7:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
    send_desc[i].special = 0;
801089cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089ce:	c1 e0 04             	shl    $0x4,%eax
801089d1:	89 c2                	mov    %eax,%edx
801089d3:	8b 45 d0             	mov    -0x30(%ebp),%eax
801089d6:	01 d0                	add    %edx,%eax
801089d8:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
  for(int i=0;i<I8254_SEND_DESC_NUM;i++){
801089de:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801089e2:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
801089e9:	0f 8e 71 ff ff ff    	jle    80108960 <i8254_init_send+0xa9>
  }

  for(int i=0;i<(I8254_SEND_DESC_NUM)/2;i++){
801089ef:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801089f6:	eb 57                	jmp    80108a4f <i8254_init_send+0x198>
    uint buf_addr = (uint)kalloc();
801089f8:	e8 a3 9d ff ff       	call   801027a0 <kalloc>
801089fd:	89 45 cc             	mov    %eax,-0x34(%ebp)
    if(buf_addr == 0){
80108a00:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
80108a04:	75 12                	jne    80108a18 <i8254_init_send+0x161>
      cprintf("failed to allocate buffer area\n");
80108a06:	83 ec 0c             	sub    $0xc,%esp
80108a09:	68 58 bf 10 80       	push   $0x8010bf58
80108a0e:	e8 e1 79 ff ff       	call   801003f4 <cprintf>
80108a13:	83 c4 10             	add    $0x10,%esp
      break;
80108a16:	eb 3d                	jmp    80108a55 <i8254_init_send+0x19e>
    }
    send_desc[i].buf_addr = V2P(buf_addr);
80108a18:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108a1b:	c1 e0 04             	shl    $0x4,%eax
80108a1e:	89 c2                	mov    %eax,%edx
80108a20:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108a23:	01 d0                	add    %edx,%eax
80108a25:	8b 55 cc             	mov    -0x34(%ebp),%edx
80108a28:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80108a2e:	89 10                	mov    %edx,(%eax)
    send_desc[i+1].buf_addr = V2P(buf_addr + 0x800);
80108a30:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108a33:	83 c0 01             	add    $0x1,%eax
80108a36:	c1 e0 04             	shl    $0x4,%eax
80108a39:	89 c2                	mov    %eax,%edx
80108a3b:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108a3e:	01 d0                	add    %edx,%eax
80108a40:	8b 55 cc             	mov    -0x34(%ebp),%edx
80108a43:	81 ea 00 f8 ff 7f    	sub    $0x7ffff800,%edx
80108a49:	89 10                	mov    %edx,(%eax)
  for(int i=0;i<(I8254_SEND_DESC_NUM)/2;i++){
80108a4b:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80108a4f:	83 7d f0 7f          	cmpl   $0x7f,-0x10(%ebp)
80108a53:	7e a3                	jle    801089f8 <i8254_init_send+0x141>
  }

  uint *tctl = (uint *)(base_addr + 0x400);
80108a55:	a1 7c 6e 19 80       	mov    0x80196e7c,%eax
80108a5a:	05 00 04 00 00       	add    $0x400,%eax
80108a5f:	89 45 c8             	mov    %eax,-0x38(%ebp)
  *tctl = (I8254_TCTL_EN | I8254_TCTL_PSP | I8254_TCTL_COLD | I8254_TCTL_CT);
80108a62:	8b 45 c8             	mov    -0x38(%ebp),%eax
80108a65:	c7 00 fa 00 04 00    	movl   $0x400fa,(%eax)

  uint *tipg = (uint *)(base_addr + 0x410);
80108a6b:	a1 7c 6e 19 80       	mov    0x80196e7c,%eax
80108a70:	05 10 04 00 00       	add    $0x410,%eax
80108a75:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  *tipg = (10 | (10<<10) | (10<<20));
80108a78:	8b 45 c4             	mov    -0x3c(%ebp),%eax
80108a7b:	c7 00 0a 28 a0 00    	movl   $0xa0280a,(%eax)
  cprintf("E1000 Transmit Initialize Done\n");
80108a81:	83 ec 0c             	sub    $0xc,%esp
80108a84:	68 98 bf 10 80       	push   $0x8010bf98
80108a89:	e8 66 79 ff ff       	call   801003f4 <cprintf>
80108a8e:	83 c4 10             	add    $0x10,%esp

}
80108a91:	90                   	nop
80108a92:	c9                   	leave  
80108a93:	c3                   	ret    

80108a94 <i8254_read_eeprom>:
uint i8254_read_eeprom(uint addr){
80108a94:	55                   	push   %ebp
80108a95:	89 e5                	mov    %esp,%ebp
80108a97:	83 ec 18             	sub    $0x18,%esp
  uint *eerd = (uint *)(base_addr + 0x14);
80108a9a:	a1 7c 6e 19 80       	mov    0x80196e7c,%eax
80108a9f:	83 c0 14             	add    $0x14,%eax
80108aa2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  *eerd = (((addr & 0xFF) << 8) | 1);
80108aa5:	8b 45 08             	mov    0x8(%ebp),%eax
80108aa8:	c1 e0 08             	shl    $0x8,%eax
80108aab:	0f b7 c0             	movzwl %ax,%eax
80108aae:	83 c8 01             	or     $0x1,%eax
80108ab1:	89 c2                	mov    %eax,%edx
80108ab3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ab6:	89 10                	mov    %edx,(%eax)
  while(1){
    cprintf("");
80108ab8:	83 ec 0c             	sub    $0xc,%esp
80108abb:	68 b8 bf 10 80       	push   $0x8010bfb8
80108ac0:	e8 2f 79 ff ff       	call   801003f4 <cprintf>
80108ac5:	83 c4 10             	add    $0x10,%esp
    volatile uint data = *eerd;
80108ac8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108acb:	8b 00                	mov    (%eax),%eax
80108acd:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((data & (1<<4)) != 0){
80108ad0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108ad3:	83 e0 10             	and    $0x10,%eax
80108ad6:	85 c0                	test   %eax,%eax
80108ad8:	75 02                	jne    80108adc <i8254_read_eeprom+0x48>
  while(1){
80108ada:	eb dc                	jmp    80108ab8 <i8254_read_eeprom+0x24>
      break;
80108adc:	90                   	nop
    }
  }

  return (*eerd >> 16) & 0xFFFF;
80108add:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ae0:	8b 00                	mov    (%eax),%eax
80108ae2:	c1 e8 10             	shr    $0x10,%eax
}
80108ae5:	c9                   	leave  
80108ae6:	c3                   	ret    

80108ae7 <i8254_recv>:
void i8254_recv(){
80108ae7:	55                   	push   %ebp
80108ae8:	89 e5                	mov    %esp,%ebp
80108aea:	83 ec 28             	sub    $0x28,%esp
  uint *rdh = (uint *)(base_addr + 0x2810);
80108aed:	a1 7c 6e 19 80       	mov    0x80196e7c,%eax
80108af2:	05 10 28 00 00       	add    $0x2810,%eax
80108af7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint *rdt = (uint *)(base_addr + 0x2818);
80108afa:	a1 7c 6e 19 80       	mov    0x80196e7c,%eax
80108aff:	05 18 28 00 00       	add    $0x2818,%eax
80108b04:	89 45 f0             	mov    %eax,-0x10(%ebp)
//  uint *torl = (uint *)(base_addr + 0x40C0);
//  uint *tpr = (uint *)(base_addr + 0x40D0);
//  uint *icr = (uint *)(base_addr + 0xC0);
  uint *rdbal = (uint *)(base_addr + 0x2800);
80108b07:	a1 7c 6e 19 80       	mov    0x80196e7c,%eax
80108b0c:	05 00 28 00 00       	add    $0x2800,%eax
80108b11:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct i8254_recv_desc *recv_desc = (struct i8254_recv_desc *)(P2V(*rdbal));
80108b14:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108b17:	8b 00                	mov    (%eax),%eax
80108b19:	05 00 00 00 80       	add    $0x80000000,%eax
80108b1e:	89 45 e8             	mov    %eax,-0x18(%ebp)
  while(1){
    int rx_available = (I8254_RECV_DESC_NUM - *rdt + *rdh)%I8254_RECV_DESC_NUM;
80108b21:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b24:	8b 10                	mov    (%eax),%edx
80108b26:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108b29:	8b 08                	mov    (%eax),%ecx
80108b2b:	89 d0                	mov    %edx,%eax
80108b2d:	29 c8                	sub    %ecx,%eax
80108b2f:	25 ff 00 00 00       	and    $0xff,%eax
80108b34:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(rx_available > 0){
80108b37:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80108b3b:	7e 37                	jle    80108b74 <i8254_recv+0x8d>
      uint buffer_addr = P2V_WO(recv_desc[*rdt].buf_addr);
80108b3d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108b40:	8b 00                	mov    (%eax),%eax
80108b42:	c1 e0 04             	shl    $0x4,%eax
80108b45:	89 c2                	mov    %eax,%edx
80108b47:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108b4a:	01 d0                	add    %edx,%eax
80108b4c:	8b 00                	mov    (%eax),%eax
80108b4e:	05 00 00 00 80       	add    $0x80000000,%eax
80108b53:	89 45 e0             	mov    %eax,-0x20(%ebp)
      *rdt = (*rdt + 1)%I8254_RECV_DESC_NUM;
80108b56:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108b59:	8b 00                	mov    (%eax),%eax
80108b5b:	83 c0 01             	add    $0x1,%eax
80108b5e:	0f b6 d0             	movzbl %al,%edx
80108b61:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108b64:	89 10                	mov    %edx,(%eax)
      eth_proc(buffer_addr);
80108b66:	83 ec 0c             	sub    $0xc,%esp
80108b69:	ff 75 e0             	push   -0x20(%ebp)
80108b6c:	e8 15 09 00 00       	call   80109486 <eth_proc>
80108b71:	83 c4 10             	add    $0x10,%esp
    }
    if(*rdt == *rdh) {
80108b74:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108b77:	8b 10                	mov    (%eax),%edx
80108b79:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b7c:	8b 00                	mov    (%eax),%eax
80108b7e:	39 c2                	cmp    %eax,%edx
80108b80:	75 9f                	jne    80108b21 <i8254_recv+0x3a>
      (*rdt)--;
80108b82:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108b85:	8b 00                	mov    (%eax),%eax
80108b87:	8d 50 ff             	lea    -0x1(%eax),%edx
80108b8a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108b8d:	89 10                	mov    %edx,(%eax)
  while(1){
80108b8f:	eb 90                	jmp    80108b21 <i8254_recv+0x3a>

80108b91 <i8254_send>:
    }
  }
}

int i8254_send(const uint pkt_addr,uint len){
80108b91:	55                   	push   %ebp
80108b92:	89 e5                	mov    %esp,%ebp
80108b94:	83 ec 28             	sub    $0x28,%esp
  uint *tdh = (uint *)(base_addr + 0x3810);
80108b97:	a1 7c 6e 19 80       	mov    0x80196e7c,%eax
80108b9c:	05 10 38 00 00       	add    $0x3810,%eax
80108ba1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint *tdt = (uint *)(base_addr + 0x3818);
80108ba4:	a1 7c 6e 19 80       	mov    0x80196e7c,%eax
80108ba9:	05 18 38 00 00       	add    $0x3818,%eax
80108bae:	89 45 f0             	mov    %eax,-0x10(%ebp)
  uint *tdbal = (uint *)(base_addr + 0x3800);
80108bb1:	a1 7c 6e 19 80       	mov    0x80196e7c,%eax
80108bb6:	05 00 38 00 00       	add    $0x3800,%eax
80108bbb:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct i8254_send_desc *txdesc = (struct i8254_send_desc *)P2V_WO(*tdbal);
80108bbe:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108bc1:	8b 00                	mov    (%eax),%eax
80108bc3:	05 00 00 00 80       	add    $0x80000000,%eax
80108bc8:	89 45 e8             	mov    %eax,-0x18(%ebp)
  int tx_available = I8254_SEND_DESC_NUM - ((I8254_SEND_DESC_NUM - *tdh + *tdt) % I8254_SEND_DESC_NUM);
80108bcb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108bce:	8b 10                	mov    (%eax),%edx
80108bd0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108bd3:	8b 08                	mov    (%eax),%ecx
80108bd5:	89 d0                	mov    %edx,%eax
80108bd7:	29 c8                	sub    %ecx,%eax
80108bd9:	0f b6 d0             	movzbl %al,%edx
80108bdc:	b8 00 01 00 00       	mov    $0x100,%eax
80108be1:	29 d0                	sub    %edx,%eax
80108be3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  uint index = *tdt%I8254_SEND_DESC_NUM;
80108be6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108be9:	8b 00                	mov    (%eax),%eax
80108beb:	25 ff 00 00 00       	and    $0xff,%eax
80108bf0:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if(tx_available > 0) {
80108bf3:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80108bf7:	0f 8e a8 00 00 00    	jle    80108ca5 <i8254_send+0x114>
    memmove(P2V_WO((void *)txdesc[index].buf_addr),(void *)pkt_addr,len);
80108bfd:	8b 45 08             	mov    0x8(%ebp),%eax
80108c00:	8b 55 e0             	mov    -0x20(%ebp),%edx
80108c03:	89 d1                	mov    %edx,%ecx
80108c05:	c1 e1 04             	shl    $0x4,%ecx
80108c08:	8b 55 e8             	mov    -0x18(%ebp),%edx
80108c0b:	01 ca                	add    %ecx,%edx
80108c0d:	8b 12                	mov    (%edx),%edx
80108c0f:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80108c15:	83 ec 04             	sub    $0x4,%esp
80108c18:	ff 75 0c             	push   0xc(%ebp)
80108c1b:	50                   	push   %eax
80108c1c:	52                   	push   %edx
80108c1d:	e8 1c be ff ff       	call   80104a3e <memmove>
80108c22:	83 c4 10             	add    $0x10,%esp
    txdesc[index].len = len;
80108c25:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108c28:	c1 e0 04             	shl    $0x4,%eax
80108c2b:	89 c2                	mov    %eax,%edx
80108c2d:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108c30:	01 d0                	add    %edx,%eax
80108c32:	8b 55 0c             	mov    0xc(%ebp),%edx
80108c35:	66 89 50 08          	mov    %dx,0x8(%eax)
    txdesc[index].sta = 0;
80108c39:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108c3c:	c1 e0 04             	shl    $0x4,%eax
80108c3f:	89 c2                	mov    %eax,%edx
80108c41:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108c44:	01 d0                	add    %edx,%eax
80108c46:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
    txdesc[index].css = 0;
80108c4a:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108c4d:	c1 e0 04             	shl    $0x4,%eax
80108c50:	89 c2                	mov    %eax,%edx
80108c52:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108c55:	01 d0                	add    %edx,%eax
80108c57:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
    txdesc[index].cmd = 0xb;
80108c5b:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108c5e:	c1 e0 04             	shl    $0x4,%eax
80108c61:	89 c2                	mov    %eax,%edx
80108c63:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108c66:	01 d0                	add    %edx,%eax
80108c68:	c6 40 0b 0b          	movb   $0xb,0xb(%eax)
    txdesc[index].special = 0;
80108c6c:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108c6f:	c1 e0 04             	shl    $0x4,%eax
80108c72:	89 c2                	mov    %eax,%edx
80108c74:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108c77:	01 d0                	add    %edx,%eax
80108c79:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
    txdesc[index].cso = 0;
80108c7f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108c82:	c1 e0 04             	shl    $0x4,%eax
80108c85:	89 c2                	mov    %eax,%edx
80108c87:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108c8a:	01 d0                	add    %edx,%eax
80108c8c:	c6 40 0a 00          	movb   $0x0,0xa(%eax)
    *tdt = (*tdt + 1)%I8254_SEND_DESC_NUM;
80108c90:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108c93:	8b 00                	mov    (%eax),%eax
80108c95:	83 c0 01             	add    $0x1,%eax
80108c98:	0f b6 d0             	movzbl %al,%edx
80108c9b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108c9e:	89 10                	mov    %edx,(%eax)
    return len;
80108ca0:	8b 45 0c             	mov    0xc(%ebp),%eax
80108ca3:	eb 05                	jmp    80108caa <i8254_send+0x119>
  }else{
    return -1;
80108ca5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
  return 0;
}
80108caa:	c9                   	leave  
80108cab:	c3                   	ret    

80108cac <i8254_intr>:

void i8254_intr(){
80108cac:	55                   	push   %ebp
80108cad:	89 e5                	mov    %esp,%ebp
  *intr_addr = 0xEEEEEE;
80108caf:	a1 88 6e 19 80       	mov    0x80196e88,%eax
80108cb4:	c7 00 ee ee ee 00    	movl   $0xeeeeee,(%eax)
}
80108cba:	90                   	nop
80108cbb:	5d                   	pop    %ebp
80108cbc:	c3                   	ret    

80108cbd <arp_proc>:
extern uchar mac_addr[6];
extern uchar my_ip[4];

struct arp_entry arp_table[ARP_TABLE_MAX] = {0};

int arp_proc(uint buffer_addr){
80108cbd:	55                   	push   %ebp
80108cbe:	89 e5                	mov    %esp,%ebp
80108cc0:	83 ec 18             	sub    $0x18,%esp
  struct arp_pkt *arp_p = (struct arp_pkt *)(buffer_addr);
80108cc3:	8b 45 08             	mov    0x8(%ebp),%eax
80108cc6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(arp_p->hrd_type != ARP_HARDWARE_TYPE) return -1;
80108cc9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ccc:	0f b7 00             	movzwl (%eax),%eax
80108ccf:	66 3d 00 01          	cmp    $0x100,%ax
80108cd3:	74 0a                	je     80108cdf <arp_proc+0x22>
80108cd5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108cda:	e9 4f 01 00 00       	jmp    80108e2e <arp_proc+0x171>
  if(arp_p->pro_type != ARP_PROTOCOL_TYPE) return -1;
80108cdf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ce2:	0f b7 40 02          	movzwl 0x2(%eax),%eax
80108ce6:	66 83 f8 08          	cmp    $0x8,%ax
80108cea:	74 0a                	je     80108cf6 <arp_proc+0x39>
80108cec:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108cf1:	e9 38 01 00 00       	jmp    80108e2e <arp_proc+0x171>
  if(arp_p->hrd_len != 6) return -1;
80108cf6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108cf9:	0f b6 40 04          	movzbl 0x4(%eax),%eax
80108cfd:	3c 06                	cmp    $0x6,%al
80108cff:	74 0a                	je     80108d0b <arp_proc+0x4e>
80108d01:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108d06:	e9 23 01 00 00       	jmp    80108e2e <arp_proc+0x171>
  if(arp_p->pro_len != 4) return -1;
80108d0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108d0e:	0f b6 40 05          	movzbl 0x5(%eax),%eax
80108d12:	3c 04                	cmp    $0x4,%al
80108d14:	74 0a                	je     80108d20 <arp_proc+0x63>
80108d16:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108d1b:	e9 0e 01 00 00       	jmp    80108e2e <arp_proc+0x171>
  if(memcmp(my_ip,arp_p->dst_ip,4) != 0 && memcmp(my_ip,arp_p->src_ip,4) != 0) return -1;
80108d20:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108d23:	83 c0 18             	add    $0x18,%eax
80108d26:	83 ec 04             	sub    $0x4,%esp
80108d29:	6a 04                	push   $0x4
80108d2b:	50                   	push   %eax
80108d2c:	68 e4 f4 10 80       	push   $0x8010f4e4
80108d31:	e8 b0 bc ff ff       	call   801049e6 <memcmp>
80108d36:	83 c4 10             	add    $0x10,%esp
80108d39:	85 c0                	test   %eax,%eax
80108d3b:	74 27                	je     80108d64 <arp_proc+0xa7>
80108d3d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108d40:	83 c0 0e             	add    $0xe,%eax
80108d43:	83 ec 04             	sub    $0x4,%esp
80108d46:	6a 04                	push   $0x4
80108d48:	50                   	push   %eax
80108d49:	68 e4 f4 10 80       	push   $0x8010f4e4
80108d4e:	e8 93 bc ff ff       	call   801049e6 <memcmp>
80108d53:	83 c4 10             	add    $0x10,%esp
80108d56:	85 c0                	test   %eax,%eax
80108d58:	74 0a                	je     80108d64 <arp_proc+0xa7>
80108d5a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108d5f:	e9 ca 00 00 00       	jmp    80108e2e <arp_proc+0x171>
  if(arp_p->op == ARP_OPS_REQUEST && memcmp(my_ip,arp_p->dst_ip,4) == 0){
80108d64:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108d67:	0f b7 40 06          	movzwl 0x6(%eax),%eax
80108d6b:	66 3d 00 01          	cmp    $0x100,%ax
80108d6f:	75 69                	jne    80108dda <arp_proc+0x11d>
80108d71:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108d74:	83 c0 18             	add    $0x18,%eax
80108d77:	83 ec 04             	sub    $0x4,%esp
80108d7a:	6a 04                	push   $0x4
80108d7c:	50                   	push   %eax
80108d7d:	68 e4 f4 10 80       	push   $0x8010f4e4
80108d82:	e8 5f bc ff ff       	call   801049e6 <memcmp>
80108d87:	83 c4 10             	add    $0x10,%esp
80108d8a:	85 c0                	test   %eax,%eax
80108d8c:	75 4c                	jne    80108dda <arp_proc+0x11d>
    uint send = (uint)kalloc();
80108d8e:	e8 0d 9a ff ff       	call   801027a0 <kalloc>
80108d93:	89 45 f0             	mov    %eax,-0x10(%ebp)
    uint send_size=0;
80108d96:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
    arp_reply_pkt_create(arp_p,send,&send_size);
80108d9d:	83 ec 04             	sub    $0x4,%esp
80108da0:	8d 45 ec             	lea    -0x14(%ebp),%eax
80108da3:	50                   	push   %eax
80108da4:	ff 75 f0             	push   -0x10(%ebp)
80108da7:	ff 75 f4             	push   -0xc(%ebp)
80108daa:	e8 1f 04 00 00       	call   801091ce <arp_reply_pkt_create>
80108daf:	83 c4 10             	add    $0x10,%esp
    i8254_send(send,send_size);
80108db2:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108db5:	83 ec 08             	sub    $0x8,%esp
80108db8:	50                   	push   %eax
80108db9:	ff 75 f0             	push   -0x10(%ebp)
80108dbc:	e8 d0 fd ff ff       	call   80108b91 <i8254_send>
80108dc1:	83 c4 10             	add    $0x10,%esp
    kfree((char *)send);
80108dc4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108dc7:	83 ec 0c             	sub    $0xc,%esp
80108dca:	50                   	push   %eax
80108dcb:	e8 36 99 ff ff       	call   80102706 <kfree>
80108dd0:	83 c4 10             	add    $0x10,%esp
    return ARP_CREATED_REPLY;
80108dd3:	b8 02 00 00 00       	mov    $0x2,%eax
80108dd8:	eb 54                	jmp    80108e2e <arp_proc+0x171>
  }else if(arp_p->op == ARP_OPS_REPLY && memcmp(my_ip,arp_p->dst_ip,4) == 0){
80108dda:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ddd:	0f b7 40 06          	movzwl 0x6(%eax),%eax
80108de1:	66 3d 00 02          	cmp    $0x200,%ax
80108de5:	75 42                	jne    80108e29 <arp_proc+0x16c>
80108de7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108dea:	83 c0 18             	add    $0x18,%eax
80108ded:	83 ec 04             	sub    $0x4,%esp
80108df0:	6a 04                	push   $0x4
80108df2:	50                   	push   %eax
80108df3:	68 e4 f4 10 80       	push   $0x8010f4e4
80108df8:	e8 e9 bb ff ff       	call   801049e6 <memcmp>
80108dfd:	83 c4 10             	add    $0x10,%esp
80108e00:	85 c0                	test   %eax,%eax
80108e02:	75 25                	jne    80108e29 <arp_proc+0x16c>
    cprintf("ARP TABLE UPDATED\n");
80108e04:	83 ec 0c             	sub    $0xc,%esp
80108e07:	68 bc bf 10 80       	push   $0x8010bfbc
80108e0c:	e8 e3 75 ff ff       	call   801003f4 <cprintf>
80108e11:	83 c4 10             	add    $0x10,%esp
    arp_table_update(arp_p);
80108e14:	83 ec 0c             	sub    $0xc,%esp
80108e17:	ff 75 f4             	push   -0xc(%ebp)
80108e1a:	e8 af 01 00 00       	call   80108fce <arp_table_update>
80108e1f:	83 c4 10             	add    $0x10,%esp
    return ARP_UPDATED_TABLE;
80108e22:	b8 01 00 00 00       	mov    $0x1,%eax
80108e27:	eb 05                	jmp    80108e2e <arp_proc+0x171>
  }else{
    return -1;
80108e29:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
}
80108e2e:	c9                   	leave  
80108e2f:	c3                   	ret    

80108e30 <arp_scan>:

void arp_scan(){
80108e30:	55                   	push   %ebp
80108e31:	89 e5                	mov    %esp,%ebp
80108e33:	83 ec 18             	sub    $0x18,%esp
  uint send_size;
  for(int i=0;i<256;i++){
80108e36:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108e3d:	eb 6f                	jmp    80108eae <arp_scan+0x7e>
    uint send = (uint)kalloc();
80108e3f:	e8 5c 99 ff ff       	call   801027a0 <kalloc>
80108e44:	89 45 ec             	mov    %eax,-0x14(%ebp)
    arp_broadcast(send,&send_size,i);
80108e47:	83 ec 04             	sub    $0x4,%esp
80108e4a:	ff 75 f4             	push   -0xc(%ebp)
80108e4d:	8d 45 e8             	lea    -0x18(%ebp),%eax
80108e50:	50                   	push   %eax
80108e51:	ff 75 ec             	push   -0x14(%ebp)
80108e54:	e8 62 00 00 00       	call   80108ebb <arp_broadcast>
80108e59:	83 c4 10             	add    $0x10,%esp
    uint res = i8254_send(send,send_size);
80108e5c:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108e5f:	83 ec 08             	sub    $0x8,%esp
80108e62:	50                   	push   %eax
80108e63:	ff 75 ec             	push   -0x14(%ebp)
80108e66:	e8 26 fd ff ff       	call   80108b91 <i8254_send>
80108e6b:	83 c4 10             	add    $0x10,%esp
80108e6e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while(res == -1){
80108e71:	eb 22                	jmp    80108e95 <arp_scan+0x65>
      microdelay(1);
80108e73:	83 ec 0c             	sub    $0xc,%esp
80108e76:	6a 01                	push   $0x1
80108e78:	e8 ba 9c ff ff       	call   80102b37 <microdelay>
80108e7d:	83 c4 10             	add    $0x10,%esp
      res = i8254_send(send,send_size);
80108e80:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108e83:	83 ec 08             	sub    $0x8,%esp
80108e86:	50                   	push   %eax
80108e87:	ff 75 ec             	push   -0x14(%ebp)
80108e8a:	e8 02 fd ff ff       	call   80108b91 <i8254_send>
80108e8f:	83 c4 10             	add    $0x10,%esp
80108e92:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while(res == -1){
80108e95:	83 7d f0 ff          	cmpl   $0xffffffff,-0x10(%ebp)
80108e99:	74 d8                	je     80108e73 <arp_scan+0x43>
    }
    kfree((char *)send);
80108e9b:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108e9e:	83 ec 0c             	sub    $0xc,%esp
80108ea1:	50                   	push   %eax
80108ea2:	e8 5f 98 ff ff       	call   80102706 <kfree>
80108ea7:	83 c4 10             	add    $0x10,%esp
  for(int i=0;i<256;i++){
80108eaa:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108eae:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80108eb5:	7e 88                	jle    80108e3f <arp_scan+0xf>
  }
}
80108eb7:	90                   	nop
80108eb8:	90                   	nop
80108eb9:	c9                   	leave  
80108eba:	c3                   	ret    

80108ebb <arp_broadcast>:

void arp_broadcast(uint send,uint *send_size,uint ip){
80108ebb:	55                   	push   %ebp
80108ebc:	89 e5                	mov    %esp,%ebp
80108ebe:	83 ec 28             	sub    $0x28,%esp
  uchar dst_ip[4] = {10,0,1,ip};
80108ec1:	c6 45 ec 0a          	movb   $0xa,-0x14(%ebp)
80108ec5:	c6 45 ed 00          	movb   $0x0,-0x13(%ebp)
80108ec9:	c6 45 ee 01          	movb   $0x1,-0x12(%ebp)
80108ecd:	8b 45 10             	mov    0x10(%ebp),%eax
80108ed0:	88 45 ef             	mov    %al,-0x11(%ebp)
  uchar dst_mac_eth[6] = {0xff,0xff,0xff,0xff,0xff,0xff};
80108ed3:	c7 45 e6 ff ff ff ff 	movl   $0xffffffff,-0x1a(%ebp)
80108eda:	66 c7 45 ea ff ff    	movw   $0xffff,-0x16(%ebp)
  uchar dst_mac_arp[6] = {0,0,0,0,0,0};
80108ee0:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
80108ee7:	66 c7 45 e4 00 00    	movw   $0x0,-0x1c(%ebp)
  
  *send_size = sizeof(struct eth_pkt) + sizeof(struct arp_pkt);
80108eed:	8b 45 0c             	mov    0xc(%ebp),%eax
80108ef0:	c7 00 2c 00 00 00    	movl   $0x2c,(%eax)

  struct eth_pkt *reply_eth = (struct eth_pkt *)send;
80108ef6:	8b 45 08             	mov    0x8(%ebp),%eax
80108ef9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct arp_pkt *reply_arp = (struct arp_pkt *)(send + sizeof(struct eth_pkt));
80108efc:	8b 45 08             	mov    0x8(%ebp),%eax
80108eff:	83 c0 0e             	add    $0xe,%eax
80108f02:	89 45 f0             	mov    %eax,-0x10(%ebp)
  
  reply_eth->type[0] = 0x08;
80108f05:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f08:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  reply_eth->type[1] = 0x06;
80108f0c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f0f:	c6 40 0d 06          	movb   $0x6,0xd(%eax)
  memmove(reply_eth->dst_mac,dst_mac_eth,6);
80108f13:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f16:	83 ec 04             	sub    $0x4,%esp
80108f19:	6a 06                	push   $0x6
80108f1b:	8d 55 e6             	lea    -0x1a(%ebp),%edx
80108f1e:	52                   	push   %edx
80108f1f:	50                   	push   %eax
80108f20:	e8 19 bb ff ff       	call   80104a3e <memmove>
80108f25:	83 c4 10             	add    $0x10,%esp
  memmove(reply_eth->src_mac,mac_addr,6);
80108f28:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f2b:	83 c0 06             	add    $0x6,%eax
80108f2e:	83 ec 04             	sub    $0x4,%esp
80108f31:	6a 06                	push   $0x6
80108f33:	68 80 6e 19 80       	push   $0x80196e80
80108f38:	50                   	push   %eax
80108f39:	e8 00 bb ff ff       	call   80104a3e <memmove>
80108f3e:	83 c4 10             	add    $0x10,%esp

  reply_arp->hrd_type = ARP_HARDWARE_TYPE;
80108f41:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108f44:	66 c7 00 00 01       	movw   $0x100,(%eax)
  reply_arp->pro_type = ARP_PROTOCOL_TYPE;
80108f49:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108f4c:	66 c7 40 02 08 00    	movw   $0x8,0x2(%eax)
  reply_arp->hrd_len = 6;
80108f52:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108f55:	c6 40 04 06          	movb   $0x6,0x4(%eax)
  reply_arp->pro_len = 4;
80108f59:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108f5c:	c6 40 05 04          	movb   $0x4,0x5(%eax)
  reply_arp->op = ARP_OPS_REQUEST;
80108f60:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108f63:	66 c7 40 06 00 01    	movw   $0x100,0x6(%eax)
  memmove(reply_arp->dst_mac,dst_mac_arp,6);
80108f69:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108f6c:	8d 50 12             	lea    0x12(%eax),%edx
80108f6f:	83 ec 04             	sub    $0x4,%esp
80108f72:	6a 06                	push   $0x6
80108f74:	8d 45 e0             	lea    -0x20(%ebp),%eax
80108f77:	50                   	push   %eax
80108f78:	52                   	push   %edx
80108f79:	e8 c0 ba ff ff       	call   80104a3e <memmove>
80108f7e:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->dst_ip,dst_ip,4);
80108f81:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108f84:	8d 50 18             	lea    0x18(%eax),%edx
80108f87:	83 ec 04             	sub    $0x4,%esp
80108f8a:	6a 04                	push   $0x4
80108f8c:	8d 45 ec             	lea    -0x14(%ebp),%eax
80108f8f:	50                   	push   %eax
80108f90:	52                   	push   %edx
80108f91:	e8 a8 ba ff ff       	call   80104a3e <memmove>
80108f96:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_mac,mac_addr,6);
80108f99:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108f9c:	83 c0 08             	add    $0x8,%eax
80108f9f:	83 ec 04             	sub    $0x4,%esp
80108fa2:	6a 06                	push   $0x6
80108fa4:	68 80 6e 19 80       	push   $0x80196e80
80108fa9:	50                   	push   %eax
80108faa:	e8 8f ba ff ff       	call   80104a3e <memmove>
80108faf:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_ip,my_ip,4);
80108fb2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108fb5:	83 c0 0e             	add    $0xe,%eax
80108fb8:	83 ec 04             	sub    $0x4,%esp
80108fbb:	6a 04                	push   $0x4
80108fbd:	68 e4 f4 10 80       	push   $0x8010f4e4
80108fc2:	50                   	push   %eax
80108fc3:	e8 76 ba ff ff       	call   80104a3e <memmove>
80108fc8:	83 c4 10             	add    $0x10,%esp
}
80108fcb:	90                   	nop
80108fcc:	c9                   	leave  
80108fcd:	c3                   	ret    

80108fce <arp_table_update>:

void arp_table_update(struct arp_pkt *recv_arp){
80108fce:	55                   	push   %ebp
80108fcf:	89 e5                	mov    %esp,%ebp
80108fd1:	83 ec 18             	sub    $0x18,%esp
  int index = arp_table_search(recv_arp->src_ip);
80108fd4:	8b 45 08             	mov    0x8(%ebp),%eax
80108fd7:	83 c0 0e             	add    $0xe,%eax
80108fda:	83 ec 0c             	sub    $0xc,%esp
80108fdd:	50                   	push   %eax
80108fde:	e8 bc 00 00 00       	call   8010909f <arp_table_search>
80108fe3:	83 c4 10             	add    $0x10,%esp
80108fe6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(index > -1){
80108fe9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80108fed:	78 2d                	js     8010901c <arp_table_update+0x4e>
    memmove(arp_table[index].mac,recv_arp->src_mac,6);
80108fef:	8b 45 08             	mov    0x8(%ebp),%eax
80108ff2:	8d 48 08             	lea    0x8(%eax),%ecx
80108ff5:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108ff8:	89 d0                	mov    %edx,%eax
80108ffa:	c1 e0 02             	shl    $0x2,%eax
80108ffd:	01 d0                	add    %edx,%eax
80108fff:	01 c0                	add    %eax,%eax
80109001:	01 d0                	add    %edx,%eax
80109003:	05 a0 6e 19 80       	add    $0x80196ea0,%eax
80109008:	83 c0 04             	add    $0x4,%eax
8010900b:	83 ec 04             	sub    $0x4,%esp
8010900e:	6a 06                	push   $0x6
80109010:	51                   	push   %ecx
80109011:	50                   	push   %eax
80109012:	e8 27 ba ff ff       	call   80104a3e <memmove>
80109017:	83 c4 10             	add    $0x10,%esp
8010901a:	eb 70                	jmp    8010908c <arp_table_update+0xbe>
  }else{
    index += 1;
8010901c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    index = -index;
80109020:	f7 5d f4             	negl   -0xc(%ebp)
    memmove(arp_table[index].mac,recv_arp->src_mac,6);
80109023:	8b 45 08             	mov    0x8(%ebp),%eax
80109026:	8d 48 08             	lea    0x8(%eax),%ecx
80109029:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010902c:	89 d0                	mov    %edx,%eax
8010902e:	c1 e0 02             	shl    $0x2,%eax
80109031:	01 d0                	add    %edx,%eax
80109033:	01 c0                	add    %eax,%eax
80109035:	01 d0                	add    %edx,%eax
80109037:	05 a0 6e 19 80       	add    $0x80196ea0,%eax
8010903c:	83 c0 04             	add    $0x4,%eax
8010903f:	83 ec 04             	sub    $0x4,%esp
80109042:	6a 06                	push   $0x6
80109044:	51                   	push   %ecx
80109045:	50                   	push   %eax
80109046:	e8 f3 b9 ff ff       	call   80104a3e <memmove>
8010904b:	83 c4 10             	add    $0x10,%esp
    memmove(arp_table[index].ip,recv_arp->src_ip,4);
8010904e:	8b 45 08             	mov    0x8(%ebp),%eax
80109051:	8d 48 0e             	lea    0xe(%eax),%ecx
80109054:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109057:	89 d0                	mov    %edx,%eax
80109059:	c1 e0 02             	shl    $0x2,%eax
8010905c:	01 d0                	add    %edx,%eax
8010905e:	01 c0                	add    %eax,%eax
80109060:	01 d0                	add    %edx,%eax
80109062:	05 a0 6e 19 80       	add    $0x80196ea0,%eax
80109067:	83 ec 04             	sub    $0x4,%esp
8010906a:	6a 04                	push   $0x4
8010906c:	51                   	push   %ecx
8010906d:	50                   	push   %eax
8010906e:	e8 cb b9 ff ff       	call   80104a3e <memmove>
80109073:	83 c4 10             	add    $0x10,%esp
    arp_table[index].use = 1;
80109076:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109079:	89 d0                	mov    %edx,%eax
8010907b:	c1 e0 02             	shl    $0x2,%eax
8010907e:	01 d0                	add    %edx,%eax
80109080:	01 c0                	add    %eax,%eax
80109082:	01 d0                	add    %edx,%eax
80109084:	05 aa 6e 19 80       	add    $0x80196eaa,%eax
80109089:	c6 00 01             	movb   $0x1,(%eax)
  }
  print_arp_table(arp_table);
8010908c:	83 ec 0c             	sub    $0xc,%esp
8010908f:	68 a0 6e 19 80       	push   $0x80196ea0
80109094:	e8 83 00 00 00       	call   8010911c <print_arp_table>
80109099:	83 c4 10             	add    $0x10,%esp
}
8010909c:	90                   	nop
8010909d:	c9                   	leave  
8010909e:	c3                   	ret    

8010909f <arp_table_search>:

int arp_table_search(uchar *ip){
8010909f:	55                   	push   %ebp
801090a0:	89 e5                	mov    %esp,%ebp
801090a2:	83 ec 18             	sub    $0x18,%esp
  int empty=1;
801090a5:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
  for(int i=0;i<ARP_TABLE_MAX;i++){
801090ac:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801090b3:	eb 59                	jmp    8010910e <arp_table_search+0x6f>
    if(memcmp(arp_table[i].ip,ip,4) == 0){
801090b5:	8b 55 f0             	mov    -0x10(%ebp),%edx
801090b8:	89 d0                	mov    %edx,%eax
801090ba:	c1 e0 02             	shl    $0x2,%eax
801090bd:	01 d0                	add    %edx,%eax
801090bf:	01 c0                	add    %eax,%eax
801090c1:	01 d0                	add    %edx,%eax
801090c3:	05 a0 6e 19 80       	add    $0x80196ea0,%eax
801090c8:	83 ec 04             	sub    $0x4,%esp
801090cb:	6a 04                	push   $0x4
801090cd:	ff 75 08             	push   0x8(%ebp)
801090d0:	50                   	push   %eax
801090d1:	e8 10 b9 ff ff       	call   801049e6 <memcmp>
801090d6:	83 c4 10             	add    $0x10,%esp
801090d9:	85 c0                	test   %eax,%eax
801090db:	75 05                	jne    801090e2 <arp_table_search+0x43>
      return i;
801090dd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801090e0:	eb 38                	jmp    8010911a <arp_table_search+0x7b>
    }
    if(arp_table[i].use == 0 && empty == 1){
801090e2:	8b 55 f0             	mov    -0x10(%ebp),%edx
801090e5:	89 d0                	mov    %edx,%eax
801090e7:	c1 e0 02             	shl    $0x2,%eax
801090ea:	01 d0                	add    %edx,%eax
801090ec:	01 c0                	add    %eax,%eax
801090ee:	01 d0                	add    %edx,%eax
801090f0:	05 aa 6e 19 80       	add    $0x80196eaa,%eax
801090f5:	0f b6 00             	movzbl (%eax),%eax
801090f8:	84 c0                	test   %al,%al
801090fa:	75 0e                	jne    8010910a <arp_table_search+0x6b>
801090fc:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
80109100:	75 08                	jne    8010910a <arp_table_search+0x6b>
      empty = -i;
80109102:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109105:	f7 d8                	neg    %eax
80109107:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(int i=0;i<ARP_TABLE_MAX;i++){
8010910a:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
8010910e:	83 7d f0 3f          	cmpl   $0x3f,-0x10(%ebp)
80109112:	7e a1                	jle    801090b5 <arp_table_search+0x16>
    }
  }
  return empty-1;
80109114:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109117:	83 e8 01             	sub    $0x1,%eax
}
8010911a:	c9                   	leave  
8010911b:	c3                   	ret    

8010911c <print_arp_table>:

void print_arp_table(){
8010911c:	55                   	push   %ebp
8010911d:	89 e5                	mov    %esp,%ebp
8010911f:	83 ec 18             	sub    $0x18,%esp
  for(int i=0;i < ARP_TABLE_MAX;i++){
80109122:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80109129:	e9 92 00 00 00       	jmp    801091c0 <print_arp_table+0xa4>
    if(arp_table[i].use != 0){
8010912e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109131:	89 d0                	mov    %edx,%eax
80109133:	c1 e0 02             	shl    $0x2,%eax
80109136:	01 d0                	add    %edx,%eax
80109138:	01 c0                	add    %eax,%eax
8010913a:	01 d0                	add    %edx,%eax
8010913c:	05 aa 6e 19 80       	add    $0x80196eaa,%eax
80109141:	0f b6 00             	movzbl (%eax),%eax
80109144:	84 c0                	test   %al,%al
80109146:	74 74                	je     801091bc <print_arp_table+0xa0>
      cprintf("Entry Num: %d ",i);
80109148:	83 ec 08             	sub    $0x8,%esp
8010914b:	ff 75 f4             	push   -0xc(%ebp)
8010914e:	68 cf bf 10 80       	push   $0x8010bfcf
80109153:	e8 9c 72 ff ff       	call   801003f4 <cprintf>
80109158:	83 c4 10             	add    $0x10,%esp
      print_ipv4(arp_table[i].ip);
8010915b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010915e:	89 d0                	mov    %edx,%eax
80109160:	c1 e0 02             	shl    $0x2,%eax
80109163:	01 d0                	add    %edx,%eax
80109165:	01 c0                	add    %eax,%eax
80109167:	01 d0                	add    %edx,%eax
80109169:	05 a0 6e 19 80       	add    $0x80196ea0,%eax
8010916e:	83 ec 0c             	sub    $0xc,%esp
80109171:	50                   	push   %eax
80109172:	e8 54 02 00 00       	call   801093cb <print_ipv4>
80109177:	83 c4 10             	add    $0x10,%esp
      cprintf(" ");
8010917a:	83 ec 0c             	sub    $0xc,%esp
8010917d:	68 de bf 10 80       	push   $0x8010bfde
80109182:	e8 6d 72 ff ff       	call   801003f4 <cprintf>
80109187:	83 c4 10             	add    $0x10,%esp
      print_mac(arp_table[i].mac);
8010918a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010918d:	89 d0                	mov    %edx,%eax
8010918f:	c1 e0 02             	shl    $0x2,%eax
80109192:	01 d0                	add    %edx,%eax
80109194:	01 c0                	add    %eax,%eax
80109196:	01 d0                	add    %edx,%eax
80109198:	05 a0 6e 19 80       	add    $0x80196ea0,%eax
8010919d:	83 c0 04             	add    $0x4,%eax
801091a0:	83 ec 0c             	sub    $0xc,%esp
801091a3:	50                   	push   %eax
801091a4:	e8 70 02 00 00       	call   80109419 <print_mac>
801091a9:	83 c4 10             	add    $0x10,%esp
      cprintf("\n");
801091ac:	83 ec 0c             	sub    $0xc,%esp
801091af:	68 e0 bf 10 80       	push   $0x8010bfe0
801091b4:	e8 3b 72 ff ff       	call   801003f4 <cprintf>
801091b9:	83 c4 10             	add    $0x10,%esp
  for(int i=0;i < ARP_TABLE_MAX;i++){
801091bc:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801091c0:	83 7d f4 3f          	cmpl   $0x3f,-0xc(%ebp)
801091c4:	0f 8e 64 ff ff ff    	jle    8010912e <print_arp_table+0x12>
    }
  }
}
801091ca:	90                   	nop
801091cb:	90                   	nop
801091cc:	c9                   	leave  
801091cd:	c3                   	ret    

801091ce <arp_reply_pkt_create>:


void arp_reply_pkt_create(struct arp_pkt *arp_recv,uint send,uint *send_size){
801091ce:	55                   	push   %ebp
801091cf:	89 e5                	mov    %esp,%ebp
801091d1:	83 ec 18             	sub    $0x18,%esp
  *send_size = sizeof(struct eth_pkt) + sizeof(struct arp_pkt);
801091d4:	8b 45 10             	mov    0x10(%ebp),%eax
801091d7:	c7 00 2c 00 00 00    	movl   $0x2c,(%eax)
  
  struct eth_pkt *reply_eth = (struct eth_pkt *)send;
801091dd:	8b 45 0c             	mov    0xc(%ebp),%eax
801091e0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct arp_pkt *reply_arp = (struct arp_pkt *)(send + sizeof(struct eth_pkt));
801091e3:	8b 45 0c             	mov    0xc(%ebp),%eax
801091e6:	83 c0 0e             	add    $0xe,%eax
801091e9:	89 45 f0             	mov    %eax,-0x10(%ebp)

  reply_eth->type[0] = 0x08;
801091ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
801091ef:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  reply_eth->type[1] = 0x06;
801091f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801091f6:	c6 40 0d 06          	movb   $0x6,0xd(%eax)
  memmove(reply_eth->dst_mac,arp_recv->src_mac,6);
801091fa:	8b 45 08             	mov    0x8(%ebp),%eax
801091fd:	8d 50 08             	lea    0x8(%eax),%edx
80109200:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109203:	83 ec 04             	sub    $0x4,%esp
80109206:	6a 06                	push   $0x6
80109208:	52                   	push   %edx
80109209:	50                   	push   %eax
8010920a:	e8 2f b8 ff ff       	call   80104a3e <memmove>
8010920f:	83 c4 10             	add    $0x10,%esp
  memmove(reply_eth->src_mac,mac_addr,6);
80109212:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109215:	83 c0 06             	add    $0x6,%eax
80109218:	83 ec 04             	sub    $0x4,%esp
8010921b:	6a 06                	push   $0x6
8010921d:	68 80 6e 19 80       	push   $0x80196e80
80109222:	50                   	push   %eax
80109223:	e8 16 b8 ff ff       	call   80104a3e <memmove>
80109228:	83 c4 10             	add    $0x10,%esp

  reply_arp->hrd_type = ARP_HARDWARE_TYPE;
8010922b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010922e:	66 c7 00 00 01       	movw   $0x100,(%eax)
  reply_arp->pro_type = ARP_PROTOCOL_TYPE;
80109233:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109236:	66 c7 40 02 08 00    	movw   $0x8,0x2(%eax)
  reply_arp->hrd_len = 6;
8010923c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010923f:	c6 40 04 06          	movb   $0x6,0x4(%eax)
  reply_arp->pro_len = 4;
80109243:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109246:	c6 40 05 04          	movb   $0x4,0x5(%eax)
  reply_arp->op = ARP_OPS_REPLY;
8010924a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010924d:	66 c7 40 06 00 02    	movw   $0x200,0x6(%eax)
  memmove(reply_arp->dst_mac,arp_recv->src_mac,6);
80109253:	8b 45 08             	mov    0x8(%ebp),%eax
80109256:	8d 50 08             	lea    0x8(%eax),%edx
80109259:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010925c:	83 c0 12             	add    $0x12,%eax
8010925f:	83 ec 04             	sub    $0x4,%esp
80109262:	6a 06                	push   $0x6
80109264:	52                   	push   %edx
80109265:	50                   	push   %eax
80109266:	e8 d3 b7 ff ff       	call   80104a3e <memmove>
8010926b:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->dst_ip,arp_recv->src_ip,4);
8010926e:	8b 45 08             	mov    0x8(%ebp),%eax
80109271:	8d 50 0e             	lea    0xe(%eax),%edx
80109274:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109277:	83 c0 18             	add    $0x18,%eax
8010927a:	83 ec 04             	sub    $0x4,%esp
8010927d:	6a 04                	push   $0x4
8010927f:	52                   	push   %edx
80109280:	50                   	push   %eax
80109281:	e8 b8 b7 ff ff       	call   80104a3e <memmove>
80109286:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_mac,mac_addr,6);
80109289:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010928c:	83 c0 08             	add    $0x8,%eax
8010928f:	83 ec 04             	sub    $0x4,%esp
80109292:	6a 06                	push   $0x6
80109294:	68 80 6e 19 80       	push   $0x80196e80
80109299:	50                   	push   %eax
8010929a:	e8 9f b7 ff ff       	call   80104a3e <memmove>
8010929f:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_ip,my_ip,4);
801092a2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801092a5:	83 c0 0e             	add    $0xe,%eax
801092a8:	83 ec 04             	sub    $0x4,%esp
801092ab:	6a 04                	push   $0x4
801092ad:	68 e4 f4 10 80       	push   $0x8010f4e4
801092b2:	50                   	push   %eax
801092b3:	e8 86 b7 ff ff       	call   80104a3e <memmove>
801092b8:	83 c4 10             	add    $0x10,%esp
}
801092bb:	90                   	nop
801092bc:	c9                   	leave  
801092bd:	c3                   	ret    

801092be <print_arp_info>:

void print_arp_info(struct arp_pkt* arp_p){
801092be:	55                   	push   %ebp
801092bf:	89 e5                	mov    %esp,%ebp
801092c1:	83 ec 08             	sub    $0x8,%esp
  cprintf("--------Source-------\n");
801092c4:	83 ec 0c             	sub    $0xc,%esp
801092c7:	68 e2 bf 10 80       	push   $0x8010bfe2
801092cc:	e8 23 71 ff ff       	call   801003f4 <cprintf>
801092d1:	83 c4 10             	add    $0x10,%esp
  print_ipv4(arp_p->src_ip);
801092d4:	8b 45 08             	mov    0x8(%ebp),%eax
801092d7:	83 c0 0e             	add    $0xe,%eax
801092da:	83 ec 0c             	sub    $0xc,%esp
801092dd:	50                   	push   %eax
801092de:	e8 e8 00 00 00       	call   801093cb <print_ipv4>
801092e3:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
801092e6:	83 ec 0c             	sub    $0xc,%esp
801092e9:	68 e0 bf 10 80       	push   $0x8010bfe0
801092ee:	e8 01 71 ff ff       	call   801003f4 <cprintf>
801092f3:	83 c4 10             	add    $0x10,%esp
  print_mac(arp_p->src_mac);
801092f6:	8b 45 08             	mov    0x8(%ebp),%eax
801092f9:	83 c0 08             	add    $0x8,%eax
801092fc:	83 ec 0c             	sub    $0xc,%esp
801092ff:	50                   	push   %eax
80109300:	e8 14 01 00 00       	call   80109419 <print_mac>
80109305:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
80109308:	83 ec 0c             	sub    $0xc,%esp
8010930b:	68 e0 bf 10 80       	push   $0x8010bfe0
80109310:	e8 df 70 ff ff       	call   801003f4 <cprintf>
80109315:	83 c4 10             	add    $0x10,%esp
  cprintf("-----Destination-----\n");
80109318:	83 ec 0c             	sub    $0xc,%esp
8010931b:	68 f9 bf 10 80       	push   $0x8010bff9
80109320:	e8 cf 70 ff ff       	call   801003f4 <cprintf>
80109325:	83 c4 10             	add    $0x10,%esp
  print_ipv4(arp_p->dst_ip);
80109328:	8b 45 08             	mov    0x8(%ebp),%eax
8010932b:	83 c0 18             	add    $0x18,%eax
8010932e:	83 ec 0c             	sub    $0xc,%esp
80109331:	50                   	push   %eax
80109332:	e8 94 00 00 00       	call   801093cb <print_ipv4>
80109337:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
8010933a:	83 ec 0c             	sub    $0xc,%esp
8010933d:	68 e0 bf 10 80       	push   $0x8010bfe0
80109342:	e8 ad 70 ff ff       	call   801003f4 <cprintf>
80109347:	83 c4 10             	add    $0x10,%esp
  print_mac(arp_p->dst_mac);
8010934a:	8b 45 08             	mov    0x8(%ebp),%eax
8010934d:	83 c0 12             	add    $0x12,%eax
80109350:	83 ec 0c             	sub    $0xc,%esp
80109353:	50                   	push   %eax
80109354:	e8 c0 00 00 00       	call   80109419 <print_mac>
80109359:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
8010935c:	83 ec 0c             	sub    $0xc,%esp
8010935f:	68 e0 bf 10 80       	push   $0x8010bfe0
80109364:	e8 8b 70 ff ff       	call   801003f4 <cprintf>
80109369:	83 c4 10             	add    $0x10,%esp
  cprintf("Operation: ");
8010936c:	83 ec 0c             	sub    $0xc,%esp
8010936f:	68 10 c0 10 80       	push   $0x8010c010
80109374:	e8 7b 70 ff ff       	call   801003f4 <cprintf>
80109379:	83 c4 10             	add    $0x10,%esp
  if(arp_p->op == ARP_OPS_REQUEST) cprintf("Request\n");
8010937c:	8b 45 08             	mov    0x8(%ebp),%eax
8010937f:	0f b7 40 06          	movzwl 0x6(%eax),%eax
80109383:	66 3d 00 01          	cmp    $0x100,%ax
80109387:	75 12                	jne    8010939b <print_arp_info+0xdd>
80109389:	83 ec 0c             	sub    $0xc,%esp
8010938c:	68 1c c0 10 80       	push   $0x8010c01c
80109391:	e8 5e 70 ff ff       	call   801003f4 <cprintf>
80109396:	83 c4 10             	add    $0x10,%esp
80109399:	eb 1d                	jmp    801093b8 <print_arp_info+0xfa>
  else if(arp_p->op == ARP_OPS_REPLY) {
8010939b:	8b 45 08             	mov    0x8(%ebp),%eax
8010939e:	0f b7 40 06          	movzwl 0x6(%eax),%eax
801093a2:	66 3d 00 02          	cmp    $0x200,%ax
801093a6:	75 10                	jne    801093b8 <print_arp_info+0xfa>
    cprintf("Reply\n");
801093a8:	83 ec 0c             	sub    $0xc,%esp
801093ab:	68 25 c0 10 80       	push   $0x8010c025
801093b0:	e8 3f 70 ff ff       	call   801003f4 <cprintf>
801093b5:	83 c4 10             	add    $0x10,%esp
  }
  cprintf("\n");
801093b8:	83 ec 0c             	sub    $0xc,%esp
801093bb:	68 e0 bf 10 80       	push   $0x8010bfe0
801093c0:	e8 2f 70 ff ff       	call   801003f4 <cprintf>
801093c5:	83 c4 10             	add    $0x10,%esp
}
801093c8:	90                   	nop
801093c9:	c9                   	leave  
801093ca:	c3                   	ret    

801093cb <print_ipv4>:

void print_ipv4(uchar *ip){
801093cb:	55                   	push   %ebp
801093cc:	89 e5                	mov    %esp,%ebp
801093ce:	53                   	push   %ebx
801093cf:	83 ec 04             	sub    $0x4,%esp
  cprintf("IP address: %d.%d.%d.%d",ip[0],ip[1],ip[2],ip[3]);
801093d2:	8b 45 08             	mov    0x8(%ebp),%eax
801093d5:	83 c0 03             	add    $0x3,%eax
801093d8:	0f b6 00             	movzbl (%eax),%eax
801093db:	0f b6 d8             	movzbl %al,%ebx
801093de:	8b 45 08             	mov    0x8(%ebp),%eax
801093e1:	83 c0 02             	add    $0x2,%eax
801093e4:	0f b6 00             	movzbl (%eax),%eax
801093e7:	0f b6 c8             	movzbl %al,%ecx
801093ea:	8b 45 08             	mov    0x8(%ebp),%eax
801093ed:	83 c0 01             	add    $0x1,%eax
801093f0:	0f b6 00             	movzbl (%eax),%eax
801093f3:	0f b6 d0             	movzbl %al,%edx
801093f6:	8b 45 08             	mov    0x8(%ebp),%eax
801093f9:	0f b6 00             	movzbl (%eax),%eax
801093fc:	0f b6 c0             	movzbl %al,%eax
801093ff:	83 ec 0c             	sub    $0xc,%esp
80109402:	53                   	push   %ebx
80109403:	51                   	push   %ecx
80109404:	52                   	push   %edx
80109405:	50                   	push   %eax
80109406:	68 2c c0 10 80       	push   $0x8010c02c
8010940b:	e8 e4 6f ff ff       	call   801003f4 <cprintf>
80109410:	83 c4 20             	add    $0x20,%esp
}
80109413:	90                   	nop
80109414:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80109417:	c9                   	leave  
80109418:	c3                   	ret    

80109419 <print_mac>:

void print_mac(uchar *mac){
80109419:	55                   	push   %ebp
8010941a:	89 e5                	mov    %esp,%ebp
8010941c:	57                   	push   %edi
8010941d:	56                   	push   %esi
8010941e:	53                   	push   %ebx
8010941f:	83 ec 0c             	sub    $0xc,%esp
  cprintf("MAC address: %x:%x:%x:%x:%x:%x",mac[0],mac[1],mac[2],mac[3],mac[4],mac[5]);
80109422:	8b 45 08             	mov    0x8(%ebp),%eax
80109425:	83 c0 05             	add    $0x5,%eax
80109428:	0f b6 00             	movzbl (%eax),%eax
8010942b:	0f b6 f8             	movzbl %al,%edi
8010942e:	8b 45 08             	mov    0x8(%ebp),%eax
80109431:	83 c0 04             	add    $0x4,%eax
80109434:	0f b6 00             	movzbl (%eax),%eax
80109437:	0f b6 f0             	movzbl %al,%esi
8010943a:	8b 45 08             	mov    0x8(%ebp),%eax
8010943d:	83 c0 03             	add    $0x3,%eax
80109440:	0f b6 00             	movzbl (%eax),%eax
80109443:	0f b6 d8             	movzbl %al,%ebx
80109446:	8b 45 08             	mov    0x8(%ebp),%eax
80109449:	83 c0 02             	add    $0x2,%eax
8010944c:	0f b6 00             	movzbl (%eax),%eax
8010944f:	0f b6 c8             	movzbl %al,%ecx
80109452:	8b 45 08             	mov    0x8(%ebp),%eax
80109455:	83 c0 01             	add    $0x1,%eax
80109458:	0f b6 00             	movzbl (%eax),%eax
8010945b:	0f b6 d0             	movzbl %al,%edx
8010945e:	8b 45 08             	mov    0x8(%ebp),%eax
80109461:	0f b6 00             	movzbl (%eax),%eax
80109464:	0f b6 c0             	movzbl %al,%eax
80109467:	83 ec 04             	sub    $0x4,%esp
8010946a:	57                   	push   %edi
8010946b:	56                   	push   %esi
8010946c:	53                   	push   %ebx
8010946d:	51                   	push   %ecx
8010946e:	52                   	push   %edx
8010946f:	50                   	push   %eax
80109470:	68 44 c0 10 80       	push   $0x8010c044
80109475:	e8 7a 6f ff ff       	call   801003f4 <cprintf>
8010947a:	83 c4 20             	add    $0x20,%esp
}
8010947d:	90                   	nop
8010947e:	8d 65 f4             	lea    -0xc(%ebp),%esp
80109481:	5b                   	pop    %ebx
80109482:	5e                   	pop    %esi
80109483:	5f                   	pop    %edi
80109484:	5d                   	pop    %ebp
80109485:	c3                   	ret    

80109486 <eth_proc>:
#include "arp.h"
#include "types.h"
#include "eth.h"
#include "defs.h"
#include "ipv4.h"
void eth_proc(uint buffer_addr){
80109486:	55                   	push   %ebp
80109487:	89 e5                	mov    %esp,%ebp
80109489:	83 ec 18             	sub    $0x18,%esp
  struct eth_pkt *eth_pkt = (struct eth_pkt *)buffer_addr;
8010948c:	8b 45 08             	mov    0x8(%ebp),%eax
8010948f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint pkt_addr = buffer_addr+sizeof(struct eth_pkt);
80109492:	8b 45 08             	mov    0x8(%ebp),%eax
80109495:	83 c0 0e             	add    $0xe,%eax
80109498:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x06){
8010949b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010949e:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
801094a2:	3c 08                	cmp    $0x8,%al
801094a4:	75 1b                	jne    801094c1 <eth_proc+0x3b>
801094a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801094a9:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
801094ad:	3c 06                	cmp    $0x6,%al
801094af:	75 10                	jne    801094c1 <eth_proc+0x3b>
    arp_proc(pkt_addr);
801094b1:	83 ec 0c             	sub    $0xc,%esp
801094b4:	ff 75 f0             	push   -0x10(%ebp)
801094b7:	e8 01 f8 ff ff       	call   80108cbd <arp_proc>
801094bc:	83 c4 10             	add    $0x10,%esp
  }else if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x00){
    ipv4_proc(buffer_addr);
  }else{
  }
}
801094bf:	eb 24                	jmp    801094e5 <eth_proc+0x5f>
  }else if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x00){
801094c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801094c4:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
801094c8:	3c 08                	cmp    $0x8,%al
801094ca:	75 19                	jne    801094e5 <eth_proc+0x5f>
801094cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801094cf:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
801094d3:	84 c0                	test   %al,%al
801094d5:	75 0e                	jne    801094e5 <eth_proc+0x5f>
    ipv4_proc(buffer_addr);
801094d7:	83 ec 0c             	sub    $0xc,%esp
801094da:	ff 75 08             	push   0x8(%ebp)
801094dd:	e8 a3 00 00 00       	call   80109585 <ipv4_proc>
801094e2:	83 c4 10             	add    $0x10,%esp
}
801094e5:	90                   	nop
801094e6:	c9                   	leave  
801094e7:	c3                   	ret    

801094e8 <N2H_ushort>:

ushort N2H_ushort(ushort value){
801094e8:	55                   	push   %ebp
801094e9:	89 e5                	mov    %esp,%ebp
801094eb:	83 ec 04             	sub    $0x4,%esp
801094ee:	8b 45 08             	mov    0x8(%ebp),%eax
801094f1:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  return (((value)&0xFF)<<8)+(value>>8);
801094f5:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
801094f9:	c1 e0 08             	shl    $0x8,%eax
801094fc:	89 c2                	mov    %eax,%edx
801094fe:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80109502:	66 c1 e8 08          	shr    $0x8,%ax
80109506:	01 d0                	add    %edx,%eax
}
80109508:	c9                   	leave  
80109509:	c3                   	ret    

8010950a <H2N_ushort>:

ushort H2N_ushort(ushort value){
8010950a:	55                   	push   %ebp
8010950b:	89 e5                	mov    %esp,%ebp
8010950d:	83 ec 04             	sub    $0x4,%esp
80109510:	8b 45 08             	mov    0x8(%ebp),%eax
80109513:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  return (((value)&0xFF)<<8)+(value>>8);
80109517:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
8010951b:	c1 e0 08             	shl    $0x8,%eax
8010951e:	89 c2                	mov    %eax,%edx
80109520:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80109524:	66 c1 e8 08          	shr    $0x8,%ax
80109528:	01 d0                	add    %edx,%eax
}
8010952a:	c9                   	leave  
8010952b:	c3                   	ret    

8010952c <H2N_uint>:

uint H2N_uint(uint value){
8010952c:	55                   	push   %ebp
8010952d:	89 e5                	mov    %esp,%ebp
  return ((value&0xF)<<24)+((value&0xF0)<<8)+((value&0xF00)>>8)+((value&0xF000)>>24);
8010952f:	8b 45 08             	mov    0x8(%ebp),%eax
80109532:	c1 e0 18             	shl    $0x18,%eax
80109535:	25 00 00 00 0f       	and    $0xf000000,%eax
8010953a:	89 c2                	mov    %eax,%edx
8010953c:	8b 45 08             	mov    0x8(%ebp),%eax
8010953f:	c1 e0 08             	shl    $0x8,%eax
80109542:	25 00 f0 00 00       	and    $0xf000,%eax
80109547:	09 c2                	or     %eax,%edx
80109549:	8b 45 08             	mov    0x8(%ebp),%eax
8010954c:	c1 e8 08             	shr    $0x8,%eax
8010954f:	83 e0 0f             	and    $0xf,%eax
80109552:	01 d0                	add    %edx,%eax
}
80109554:	5d                   	pop    %ebp
80109555:	c3                   	ret    

80109556 <N2H_uint>:

uint N2H_uint(uint value){
80109556:	55                   	push   %ebp
80109557:	89 e5                	mov    %esp,%ebp
  return ((value&0xFF)<<24)+((value&0xFF00)<<8)+((value&0xFF0000)>>8)+((value&0xFF000000)>>24);
80109559:	8b 45 08             	mov    0x8(%ebp),%eax
8010955c:	c1 e0 18             	shl    $0x18,%eax
8010955f:	89 c2                	mov    %eax,%edx
80109561:	8b 45 08             	mov    0x8(%ebp),%eax
80109564:	c1 e0 08             	shl    $0x8,%eax
80109567:	25 00 00 ff 00       	and    $0xff0000,%eax
8010956c:	01 c2                	add    %eax,%edx
8010956e:	8b 45 08             	mov    0x8(%ebp),%eax
80109571:	c1 e8 08             	shr    $0x8,%eax
80109574:	25 00 ff 00 00       	and    $0xff00,%eax
80109579:	01 c2                	add    %eax,%edx
8010957b:	8b 45 08             	mov    0x8(%ebp),%eax
8010957e:	c1 e8 18             	shr    $0x18,%eax
80109581:	01 d0                	add    %edx,%eax
}
80109583:	5d                   	pop    %ebp
80109584:	c3                   	ret    

80109585 <ipv4_proc>:
extern uchar mac_addr[6];
extern uchar my_ip[4];

int ip_id = -1;
ushort send_id = 0;
void ipv4_proc(uint buffer_addr){
80109585:	55                   	push   %ebp
80109586:	89 e5                	mov    %esp,%ebp
80109588:	83 ec 18             	sub    $0x18,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(buffer_addr+14);
8010958b:	8b 45 08             	mov    0x8(%ebp),%eax
8010958e:	83 c0 0e             	add    $0xe,%eax
80109591:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(ip_id != ipv4_p->id && memcmp(my_ip,ipv4_p->src_ip,4) != 0){
80109594:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109597:	0f b7 40 04          	movzwl 0x4(%eax),%eax
8010959b:	0f b7 d0             	movzwl %ax,%edx
8010959e:	a1 e8 f4 10 80       	mov    0x8010f4e8,%eax
801095a3:	39 c2                	cmp    %eax,%edx
801095a5:	74 60                	je     80109607 <ipv4_proc+0x82>
801095a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801095aa:	83 c0 0c             	add    $0xc,%eax
801095ad:	83 ec 04             	sub    $0x4,%esp
801095b0:	6a 04                	push   $0x4
801095b2:	50                   	push   %eax
801095b3:	68 e4 f4 10 80       	push   $0x8010f4e4
801095b8:	e8 29 b4 ff ff       	call   801049e6 <memcmp>
801095bd:	83 c4 10             	add    $0x10,%esp
801095c0:	85 c0                	test   %eax,%eax
801095c2:	74 43                	je     80109607 <ipv4_proc+0x82>
    ip_id = ipv4_p->id;
801095c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801095c7:	0f b7 40 04          	movzwl 0x4(%eax),%eax
801095cb:	0f b7 c0             	movzwl %ax,%eax
801095ce:	a3 e8 f4 10 80       	mov    %eax,0x8010f4e8
      if(ipv4_p->protocol == IPV4_TYPE_ICMP){
801095d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801095d6:	0f b6 40 09          	movzbl 0x9(%eax),%eax
801095da:	3c 01                	cmp    $0x1,%al
801095dc:	75 10                	jne    801095ee <ipv4_proc+0x69>
        icmp_proc(buffer_addr);
801095de:	83 ec 0c             	sub    $0xc,%esp
801095e1:	ff 75 08             	push   0x8(%ebp)
801095e4:	e8 a3 00 00 00       	call   8010968c <icmp_proc>
801095e9:	83 c4 10             	add    $0x10,%esp
      }else if(ipv4_p->protocol == IPV4_TYPE_TCP){
        tcp_proc(buffer_addr);
      }
  }
}
801095ec:	eb 19                	jmp    80109607 <ipv4_proc+0x82>
      }else if(ipv4_p->protocol == IPV4_TYPE_TCP){
801095ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
801095f1:	0f b6 40 09          	movzbl 0x9(%eax),%eax
801095f5:	3c 06                	cmp    $0x6,%al
801095f7:	75 0e                	jne    80109607 <ipv4_proc+0x82>
        tcp_proc(buffer_addr);
801095f9:	83 ec 0c             	sub    $0xc,%esp
801095fc:	ff 75 08             	push   0x8(%ebp)
801095ff:	e8 b3 03 00 00       	call   801099b7 <tcp_proc>
80109604:	83 c4 10             	add    $0x10,%esp
}
80109607:	90                   	nop
80109608:	c9                   	leave  
80109609:	c3                   	ret    

8010960a <ipv4_chksum>:

ushort ipv4_chksum(uint ipv4_addr){
8010960a:	55                   	push   %ebp
8010960b:	89 e5                	mov    %esp,%ebp
8010960d:	83 ec 10             	sub    $0x10,%esp
  uchar* bin = (uchar *)ipv4_addr;
80109610:	8b 45 08             	mov    0x8(%ebp),%eax
80109613:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uchar len = (bin[0]&0xF)*2;
80109616:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109619:	0f b6 00             	movzbl (%eax),%eax
8010961c:	83 e0 0f             	and    $0xf,%eax
8010961f:	01 c0                	add    %eax,%eax
80109621:	88 45 f3             	mov    %al,-0xd(%ebp)
  uint chk_sum = 0;
80109624:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  for(int i=0;i<len;i++){
8010962b:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80109632:	eb 48                	jmp    8010967c <ipv4_chksum+0x72>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
80109634:	8b 45 f8             	mov    -0x8(%ebp),%eax
80109637:	01 c0                	add    %eax,%eax
80109639:	89 c2                	mov    %eax,%edx
8010963b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010963e:	01 d0                	add    %edx,%eax
80109640:	0f b6 00             	movzbl (%eax),%eax
80109643:	0f b6 c0             	movzbl %al,%eax
80109646:	c1 e0 08             	shl    $0x8,%eax
80109649:	89 c2                	mov    %eax,%edx
8010964b:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010964e:	01 c0                	add    %eax,%eax
80109650:	8d 48 01             	lea    0x1(%eax),%ecx
80109653:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109656:	01 c8                	add    %ecx,%eax
80109658:	0f b6 00             	movzbl (%eax),%eax
8010965b:	0f b6 c0             	movzbl %al,%eax
8010965e:	01 d0                	add    %edx,%eax
80109660:	01 45 fc             	add    %eax,-0x4(%ebp)
    if(chk_sum > 0xFFFF){
80109663:	81 7d fc ff ff 00 00 	cmpl   $0xffff,-0x4(%ebp)
8010966a:	76 0c                	jbe    80109678 <ipv4_chksum+0x6e>
      chk_sum = (chk_sum&0xFFFF)+1;
8010966c:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010966f:	0f b7 c0             	movzwl %ax,%eax
80109672:	83 c0 01             	add    $0x1,%eax
80109675:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(int i=0;i<len;i++){
80109678:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
8010967c:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
80109680:	39 45 f8             	cmp    %eax,-0x8(%ebp)
80109683:	7c af                	jl     80109634 <ipv4_chksum+0x2a>
    }
  }
  return ~(chk_sum);
80109685:	8b 45 fc             	mov    -0x4(%ebp),%eax
80109688:	f7 d0                	not    %eax
}
8010968a:	c9                   	leave  
8010968b:	c3                   	ret    

8010968c <icmp_proc>:
#include "eth.h"

extern uchar mac_addr[6];
extern uchar my_ip[4];
extern ushort send_id;
void icmp_proc(uint buffer_addr){
8010968c:	55                   	push   %ebp
8010968d:	89 e5                	mov    %esp,%ebp
8010968f:	83 ec 18             	sub    $0x18,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(buffer_addr+sizeof(struct eth_pkt));
80109692:	8b 45 08             	mov    0x8(%ebp),%eax
80109695:	83 c0 0e             	add    $0xe,%eax
80109698:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct icmp_echo_pkt *icmp_p = (struct icmp_echo_pkt *)((uint)ipv4_p + (ipv4_p->ver&0xF)*4);
8010969b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010969e:	0f b6 00             	movzbl (%eax),%eax
801096a1:	0f b6 c0             	movzbl %al,%eax
801096a4:	83 e0 0f             	and    $0xf,%eax
801096a7:	c1 e0 02             	shl    $0x2,%eax
801096aa:	89 c2                	mov    %eax,%edx
801096ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
801096af:	01 d0                	add    %edx,%eax
801096b1:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(icmp_p->code == 0){
801096b4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801096b7:	0f b6 40 01          	movzbl 0x1(%eax),%eax
801096bb:	84 c0                	test   %al,%al
801096bd:	75 4f                	jne    8010970e <icmp_proc+0x82>
    if(icmp_p->type == ICMP_TYPE_ECHO_REQUEST){
801096bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
801096c2:	0f b6 00             	movzbl (%eax),%eax
801096c5:	3c 08                	cmp    $0x8,%al
801096c7:	75 45                	jne    8010970e <icmp_proc+0x82>
      uint send_addr = (uint)kalloc();
801096c9:	e8 d2 90 ff ff       	call   801027a0 <kalloc>
801096ce:	89 45 ec             	mov    %eax,-0x14(%ebp)
      uint send_size = 0;
801096d1:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
      icmp_reply_pkt_create(buffer_addr,send_addr,&send_size);
801096d8:	83 ec 04             	sub    $0x4,%esp
801096db:	8d 45 e8             	lea    -0x18(%ebp),%eax
801096de:	50                   	push   %eax
801096df:	ff 75 ec             	push   -0x14(%ebp)
801096e2:	ff 75 08             	push   0x8(%ebp)
801096e5:	e8 78 00 00 00       	call   80109762 <icmp_reply_pkt_create>
801096ea:	83 c4 10             	add    $0x10,%esp
      i8254_send(send_addr,send_size);
801096ed:	8b 45 e8             	mov    -0x18(%ebp),%eax
801096f0:	83 ec 08             	sub    $0x8,%esp
801096f3:	50                   	push   %eax
801096f4:	ff 75 ec             	push   -0x14(%ebp)
801096f7:	e8 95 f4 ff ff       	call   80108b91 <i8254_send>
801096fc:	83 c4 10             	add    $0x10,%esp
      kfree((char *)send_addr);
801096ff:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109702:	83 ec 0c             	sub    $0xc,%esp
80109705:	50                   	push   %eax
80109706:	e8 fb 8f ff ff       	call   80102706 <kfree>
8010970b:	83 c4 10             	add    $0x10,%esp
    }
  }
}
8010970e:	90                   	nop
8010970f:	c9                   	leave  
80109710:	c3                   	ret    

80109711 <icmp_proc_req>:

void icmp_proc_req(struct icmp_echo_pkt * icmp_p){
80109711:	55                   	push   %ebp
80109712:	89 e5                	mov    %esp,%ebp
80109714:	53                   	push   %ebx
80109715:	83 ec 04             	sub    $0x4,%esp
  cprintf("ICMP ID:0x%x SEQ NUM:0x%x\n",N2H_ushort(icmp_p->id),N2H_ushort(icmp_p->seq_num));
80109718:	8b 45 08             	mov    0x8(%ebp),%eax
8010971b:	0f b7 40 06          	movzwl 0x6(%eax),%eax
8010971f:	0f b7 c0             	movzwl %ax,%eax
80109722:	83 ec 0c             	sub    $0xc,%esp
80109725:	50                   	push   %eax
80109726:	e8 bd fd ff ff       	call   801094e8 <N2H_ushort>
8010972b:	83 c4 10             	add    $0x10,%esp
8010972e:	0f b7 d8             	movzwl %ax,%ebx
80109731:	8b 45 08             	mov    0x8(%ebp),%eax
80109734:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80109738:	0f b7 c0             	movzwl %ax,%eax
8010973b:	83 ec 0c             	sub    $0xc,%esp
8010973e:	50                   	push   %eax
8010973f:	e8 a4 fd ff ff       	call   801094e8 <N2H_ushort>
80109744:	83 c4 10             	add    $0x10,%esp
80109747:	0f b7 c0             	movzwl %ax,%eax
8010974a:	83 ec 04             	sub    $0x4,%esp
8010974d:	53                   	push   %ebx
8010974e:	50                   	push   %eax
8010974f:	68 63 c0 10 80       	push   $0x8010c063
80109754:	e8 9b 6c ff ff       	call   801003f4 <cprintf>
80109759:	83 c4 10             	add    $0x10,%esp
}
8010975c:	90                   	nop
8010975d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80109760:	c9                   	leave  
80109761:	c3                   	ret    

80109762 <icmp_reply_pkt_create>:

void icmp_reply_pkt_create(uint recv_addr,uint send_addr,uint *send_size){
80109762:	55                   	push   %ebp
80109763:	89 e5                	mov    %esp,%ebp
80109765:	83 ec 28             	sub    $0x28,%esp
  struct eth_pkt *eth_recv = (struct eth_pkt *)(recv_addr);
80109768:	8b 45 08             	mov    0x8(%ebp),%eax
8010976b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct ipv4_pkt *ipv4_recv = (struct ipv4_pkt *)(recv_addr+sizeof(struct eth_pkt));
8010976e:	8b 45 08             	mov    0x8(%ebp),%eax
80109771:	83 c0 0e             	add    $0xe,%eax
80109774:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct icmp_echo_pkt *icmp_recv = (struct icmp_echo_pkt *)((uint)ipv4_recv+(ipv4_recv->ver&0xF)*4);
80109777:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010977a:	0f b6 00             	movzbl (%eax),%eax
8010977d:	0f b6 c0             	movzbl %al,%eax
80109780:	83 e0 0f             	and    $0xf,%eax
80109783:	c1 e0 02             	shl    $0x2,%eax
80109786:	89 c2                	mov    %eax,%edx
80109788:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010978b:	01 d0                	add    %edx,%eax
8010978d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct eth_pkt *eth_send = (struct eth_pkt *)(send_addr);
80109790:	8b 45 0c             	mov    0xc(%ebp),%eax
80109793:	89 45 e8             	mov    %eax,-0x18(%ebp)
  struct ipv4_pkt *ipv4_send = (struct ipv4_pkt *)(send_addr+sizeof(struct eth_pkt));
80109796:	8b 45 0c             	mov    0xc(%ebp),%eax
80109799:	83 c0 0e             	add    $0xe,%eax
8010979c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct icmp_echo_pkt *icmp_send = (struct icmp_echo_pkt *)((uint)ipv4_send+sizeof(struct ipv4_pkt));
8010979f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801097a2:	83 c0 14             	add    $0x14,%eax
801097a5:	89 45 e0             	mov    %eax,-0x20(%ebp)
  
  *send_size = sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct icmp_echo_pkt);
801097a8:	8b 45 10             	mov    0x10(%ebp),%eax
801097ab:	c7 00 62 00 00 00    	movl   $0x62,(%eax)
  memmove(eth_send->dst_mac,eth_recv->src_mac,6);
801097b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801097b4:	8d 50 06             	lea    0x6(%eax),%edx
801097b7:	8b 45 e8             	mov    -0x18(%ebp),%eax
801097ba:	83 ec 04             	sub    $0x4,%esp
801097bd:	6a 06                	push   $0x6
801097bf:	52                   	push   %edx
801097c0:	50                   	push   %eax
801097c1:	e8 78 b2 ff ff       	call   80104a3e <memmove>
801097c6:	83 c4 10             	add    $0x10,%esp
  memmove(eth_send->src_mac,mac_addr,6);
801097c9:	8b 45 e8             	mov    -0x18(%ebp),%eax
801097cc:	83 c0 06             	add    $0x6,%eax
801097cf:	83 ec 04             	sub    $0x4,%esp
801097d2:	6a 06                	push   $0x6
801097d4:	68 80 6e 19 80       	push   $0x80196e80
801097d9:	50                   	push   %eax
801097da:	e8 5f b2 ff ff       	call   80104a3e <memmove>
801097df:	83 c4 10             	add    $0x10,%esp
  eth_send->type[0] = 0x08;
801097e2:	8b 45 e8             	mov    -0x18(%ebp),%eax
801097e5:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  eth_send->type[1] = 0x00;
801097e9:	8b 45 e8             	mov    -0x18(%ebp),%eax
801097ec:	c6 40 0d 00          	movb   $0x0,0xd(%eax)

  ipv4_send->ver = ((0x4)<<4)+((sizeof(struct ipv4_pkt)/4)&0xF);
801097f0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801097f3:	c6 00 45             	movb   $0x45,(%eax)
  ipv4_send->srv_type = 0;
801097f6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801097f9:	c6 40 01 00          	movb   $0x0,0x1(%eax)
  ipv4_send->total_len = H2N_ushort(sizeof(struct ipv4_pkt) + sizeof(struct icmp_echo_pkt));
801097fd:	83 ec 0c             	sub    $0xc,%esp
80109800:	6a 54                	push   $0x54
80109802:	e8 03 fd ff ff       	call   8010950a <H2N_ushort>
80109807:	83 c4 10             	add    $0x10,%esp
8010980a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010980d:	66 89 42 02          	mov    %ax,0x2(%edx)
  ipv4_send->id = send_id;
80109811:	0f b7 15 60 71 19 80 	movzwl 0x80197160,%edx
80109818:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010981b:	66 89 50 04          	mov    %dx,0x4(%eax)
  send_id++;
8010981f:	0f b7 05 60 71 19 80 	movzwl 0x80197160,%eax
80109826:	83 c0 01             	add    $0x1,%eax
80109829:	66 a3 60 71 19 80    	mov    %ax,0x80197160
  ipv4_send->fragment = H2N_ushort(0x4000);
8010982f:	83 ec 0c             	sub    $0xc,%esp
80109832:	68 00 40 00 00       	push   $0x4000
80109837:	e8 ce fc ff ff       	call   8010950a <H2N_ushort>
8010983c:	83 c4 10             	add    $0x10,%esp
8010983f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80109842:	66 89 42 06          	mov    %ax,0x6(%edx)
  ipv4_send->ttl = 255;
80109846:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109849:	c6 40 08 ff          	movb   $0xff,0x8(%eax)
  ipv4_send->protocol = 0x1;
8010984d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109850:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  memmove(ipv4_send->src_ip,my_ip,4);
80109854:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109857:	83 c0 0c             	add    $0xc,%eax
8010985a:	83 ec 04             	sub    $0x4,%esp
8010985d:	6a 04                	push   $0x4
8010985f:	68 e4 f4 10 80       	push   $0x8010f4e4
80109864:	50                   	push   %eax
80109865:	e8 d4 b1 ff ff       	call   80104a3e <memmove>
8010986a:	83 c4 10             	add    $0x10,%esp
  memmove(ipv4_send->dst_ip,ipv4_recv->src_ip,4);
8010986d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109870:	8d 50 0c             	lea    0xc(%eax),%edx
80109873:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109876:	83 c0 10             	add    $0x10,%eax
80109879:	83 ec 04             	sub    $0x4,%esp
8010987c:	6a 04                	push   $0x4
8010987e:	52                   	push   %edx
8010987f:	50                   	push   %eax
80109880:	e8 b9 b1 ff ff       	call   80104a3e <memmove>
80109885:	83 c4 10             	add    $0x10,%esp
  ipv4_send->chk_sum = 0;
80109888:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010988b:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
  ipv4_send->chk_sum = H2N_ushort(ipv4_chksum((uint)ipv4_send));
80109891:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109894:	83 ec 0c             	sub    $0xc,%esp
80109897:	50                   	push   %eax
80109898:	e8 6d fd ff ff       	call   8010960a <ipv4_chksum>
8010989d:	83 c4 10             	add    $0x10,%esp
801098a0:	0f b7 c0             	movzwl %ax,%eax
801098a3:	83 ec 0c             	sub    $0xc,%esp
801098a6:	50                   	push   %eax
801098a7:	e8 5e fc ff ff       	call   8010950a <H2N_ushort>
801098ac:	83 c4 10             	add    $0x10,%esp
801098af:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801098b2:	66 89 42 0a          	mov    %ax,0xa(%edx)

  icmp_send->type = ICMP_TYPE_ECHO_REPLY;
801098b6:	8b 45 e0             	mov    -0x20(%ebp),%eax
801098b9:	c6 00 00             	movb   $0x0,(%eax)
  icmp_send->code = 0;
801098bc:	8b 45 e0             	mov    -0x20(%ebp),%eax
801098bf:	c6 40 01 00          	movb   $0x0,0x1(%eax)
  icmp_send->id = icmp_recv->id;
801098c3:	8b 45 ec             	mov    -0x14(%ebp),%eax
801098c6:	0f b7 50 04          	movzwl 0x4(%eax),%edx
801098ca:	8b 45 e0             	mov    -0x20(%ebp),%eax
801098cd:	66 89 50 04          	mov    %dx,0x4(%eax)
  icmp_send->seq_num = icmp_recv->seq_num;
801098d1:	8b 45 ec             	mov    -0x14(%ebp),%eax
801098d4:	0f b7 50 06          	movzwl 0x6(%eax),%edx
801098d8:	8b 45 e0             	mov    -0x20(%ebp),%eax
801098db:	66 89 50 06          	mov    %dx,0x6(%eax)
  memmove(icmp_send->time_stamp,icmp_recv->time_stamp,8);
801098df:	8b 45 ec             	mov    -0x14(%ebp),%eax
801098e2:	8d 50 08             	lea    0x8(%eax),%edx
801098e5:	8b 45 e0             	mov    -0x20(%ebp),%eax
801098e8:	83 c0 08             	add    $0x8,%eax
801098eb:	83 ec 04             	sub    $0x4,%esp
801098ee:	6a 08                	push   $0x8
801098f0:	52                   	push   %edx
801098f1:	50                   	push   %eax
801098f2:	e8 47 b1 ff ff       	call   80104a3e <memmove>
801098f7:	83 c4 10             	add    $0x10,%esp
  memmove(icmp_send->data,icmp_recv->data,48);
801098fa:	8b 45 ec             	mov    -0x14(%ebp),%eax
801098fd:	8d 50 10             	lea    0x10(%eax),%edx
80109900:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109903:	83 c0 10             	add    $0x10,%eax
80109906:	83 ec 04             	sub    $0x4,%esp
80109909:	6a 30                	push   $0x30
8010990b:	52                   	push   %edx
8010990c:	50                   	push   %eax
8010990d:	e8 2c b1 ff ff       	call   80104a3e <memmove>
80109912:	83 c4 10             	add    $0x10,%esp
  icmp_send->chk_sum = 0;
80109915:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109918:	66 c7 40 02 00 00    	movw   $0x0,0x2(%eax)
  icmp_send->chk_sum = H2N_ushort(icmp_chksum((uint)icmp_send));
8010991e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109921:	83 ec 0c             	sub    $0xc,%esp
80109924:	50                   	push   %eax
80109925:	e8 1c 00 00 00       	call   80109946 <icmp_chksum>
8010992a:	83 c4 10             	add    $0x10,%esp
8010992d:	0f b7 c0             	movzwl %ax,%eax
80109930:	83 ec 0c             	sub    $0xc,%esp
80109933:	50                   	push   %eax
80109934:	e8 d1 fb ff ff       	call   8010950a <H2N_ushort>
80109939:	83 c4 10             	add    $0x10,%esp
8010993c:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010993f:	66 89 42 02          	mov    %ax,0x2(%edx)
}
80109943:	90                   	nop
80109944:	c9                   	leave  
80109945:	c3                   	ret    

80109946 <icmp_chksum>:

ushort icmp_chksum(uint icmp_addr){
80109946:	55                   	push   %ebp
80109947:	89 e5                	mov    %esp,%ebp
80109949:	83 ec 10             	sub    $0x10,%esp
  uchar* bin = (uchar *)icmp_addr;
8010994c:	8b 45 08             	mov    0x8(%ebp),%eax
8010994f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint chk_sum = 0;
80109952:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  for(int i=0;i<32;i++){
80109959:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80109960:	eb 48                	jmp    801099aa <icmp_chksum+0x64>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
80109962:	8b 45 f8             	mov    -0x8(%ebp),%eax
80109965:	01 c0                	add    %eax,%eax
80109967:	89 c2                	mov    %eax,%edx
80109969:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010996c:	01 d0                	add    %edx,%eax
8010996e:	0f b6 00             	movzbl (%eax),%eax
80109971:	0f b6 c0             	movzbl %al,%eax
80109974:	c1 e0 08             	shl    $0x8,%eax
80109977:	89 c2                	mov    %eax,%edx
80109979:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010997c:	01 c0                	add    %eax,%eax
8010997e:	8d 48 01             	lea    0x1(%eax),%ecx
80109981:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109984:	01 c8                	add    %ecx,%eax
80109986:	0f b6 00             	movzbl (%eax),%eax
80109989:	0f b6 c0             	movzbl %al,%eax
8010998c:	01 d0                	add    %edx,%eax
8010998e:	01 45 fc             	add    %eax,-0x4(%ebp)
    if(chk_sum > 0xFFFF){
80109991:	81 7d fc ff ff 00 00 	cmpl   $0xffff,-0x4(%ebp)
80109998:	76 0c                	jbe    801099a6 <icmp_chksum+0x60>
      chk_sum = (chk_sum&0xFFFF)+1;
8010999a:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010999d:	0f b7 c0             	movzwl %ax,%eax
801099a0:	83 c0 01             	add    $0x1,%eax
801099a3:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(int i=0;i<32;i++){
801099a6:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
801099aa:	83 7d f8 1f          	cmpl   $0x1f,-0x8(%ebp)
801099ae:	7e b2                	jle    80109962 <icmp_chksum+0x1c>
    }
  }
  return ~(chk_sum);
801099b0:	8b 45 fc             	mov    -0x4(%ebp),%eax
801099b3:	f7 d0                	not    %eax
}
801099b5:	c9                   	leave  
801099b6:	c3                   	ret    

801099b7 <tcp_proc>:
extern ushort send_id;
extern uchar mac_addr[6];
extern uchar my_ip[4];
int fin_flag = 0;

void tcp_proc(uint buffer_addr){
801099b7:	55                   	push   %ebp
801099b8:	89 e5                	mov    %esp,%ebp
801099ba:	83 ec 38             	sub    $0x38,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(buffer_addr + sizeof(struct eth_pkt));
801099bd:	8b 45 08             	mov    0x8(%ebp),%eax
801099c0:	83 c0 0e             	add    $0xe,%eax
801099c3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct tcp_pkt *tcp_p = (struct tcp_pkt *)((uint)ipv4_p + (ipv4_p->ver&0xF)*4);
801099c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801099c9:	0f b6 00             	movzbl (%eax),%eax
801099cc:	0f b6 c0             	movzbl %al,%eax
801099cf:	83 e0 0f             	and    $0xf,%eax
801099d2:	c1 e0 02             	shl    $0x2,%eax
801099d5:	89 c2                	mov    %eax,%edx
801099d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801099da:	01 d0                	add    %edx,%eax
801099dc:	89 45 f0             	mov    %eax,-0x10(%ebp)
  char *payload = (char *)((uint)tcp_p + 20);
801099df:	8b 45 f0             	mov    -0x10(%ebp),%eax
801099e2:	83 c0 14             	add    $0x14,%eax
801099e5:	89 45 ec             	mov    %eax,-0x14(%ebp)
  uint send_addr = (uint)kalloc();
801099e8:	e8 b3 8d ff ff       	call   801027a0 <kalloc>
801099ed:	89 45 e8             	mov    %eax,-0x18(%ebp)
  uint send_size = 0;
801099f0:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  if(tcp_p->code_bits[1]&TCP_CODEBITS_SYN){
801099f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801099fa:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
801099fe:	0f b6 c0             	movzbl %al,%eax
80109a01:	83 e0 02             	and    $0x2,%eax
80109a04:	85 c0                	test   %eax,%eax
80109a06:	74 3d                	je     80109a45 <tcp_proc+0x8e>
    tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_ACK | TCP_CODEBITS_SYN,0);
80109a08:	83 ec 0c             	sub    $0xc,%esp
80109a0b:	6a 00                	push   $0x0
80109a0d:	6a 12                	push   $0x12
80109a0f:	8d 45 dc             	lea    -0x24(%ebp),%eax
80109a12:	50                   	push   %eax
80109a13:	ff 75 e8             	push   -0x18(%ebp)
80109a16:	ff 75 08             	push   0x8(%ebp)
80109a19:	e8 a2 01 00 00       	call   80109bc0 <tcp_pkt_create>
80109a1e:	83 c4 20             	add    $0x20,%esp
    i8254_send(send_addr,send_size);
80109a21:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109a24:	83 ec 08             	sub    $0x8,%esp
80109a27:	50                   	push   %eax
80109a28:	ff 75 e8             	push   -0x18(%ebp)
80109a2b:	e8 61 f1 ff ff       	call   80108b91 <i8254_send>
80109a30:	83 c4 10             	add    $0x10,%esp
    seq_num++;
80109a33:	a1 64 71 19 80       	mov    0x80197164,%eax
80109a38:	83 c0 01             	add    $0x1,%eax
80109a3b:	a3 64 71 19 80       	mov    %eax,0x80197164
80109a40:	e9 69 01 00 00       	jmp    80109bae <tcp_proc+0x1f7>
  }else if(tcp_p->code_bits[1] == (TCP_CODEBITS_PSH | TCP_CODEBITS_ACK)){
80109a45:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109a48:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
80109a4c:	3c 18                	cmp    $0x18,%al
80109a4e:	0f 85 10 01 00 00    	jne    80109b64 <tcp_proc+0x1ad>
    if(memcmp(payload,"GET",3)){
80109a54:	83 ec 04             	sub    $0x4,%esp
80109a57:	6a 03                	push   $0x3
80109a59:	68 7e c0 10 80       	push   $0x8010c07e
80109a5e:	ff 75 ec             	push   -0x14(%ebp)
80109a61:	e8 80 af ff ff       	call   801049e6 <memcmp>
80109a66:	83 c4 10             	add    $0x10,%esp
80109a69:	85 c0                	test   %eax,%eax
80109a6b:	74 74                	je     80109ae1 <tcp_proc+0x12a>
      cprintf("ACK PSH\n");
80109a6d:	83 ec 0c             	sub    $0xc,%esp
80109a70:	68 82 c0 10 80       	push   $0x8010c082
80109a75:	e8 7a 69 ff ff       	call   801003f4 <cprintf>
80109a7a:	83 c4 10             	add    $0x10,%esp
      tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_ACK,0);
80109a7d:	83 ec 0c             	sub    $0xc,%esp
80109a80:	6a 00                	push   $0x0
80109a82:	6a 10                	push   $0x10
80109a84:	8d 45 dc             	lea    -0x24(%ebp),%eax
80109a87:	50                   	push   %eax
80109a88:	ff 75 e8             	push   -0x18(%ebp)
80109a8b:	ff 75 08             	push   0x8(%ebp)
80109a8e:	e8 2d 01 00 00       	call   80109bc0 <tcp_pkt_create>
80109a93:	83 c4 20             	add    $0x20,%esp
      i8254_send(send_addr,send_size);
80109a96:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109a99:	83 ec 08             	sub    $0x8,%esp
80109a9c:	50                   	push   %eax
80109a9d:	ff 75 e8             	push   -0x18(%ebp)
80109aa0:	e8 ec f0 ff ff       	call   80108b91 <i8254_send>
80109aa5:	83 c4 10             	add    $0x10,%esp
      uint send_payload = (send_addr + sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt));
80109aa8:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109aab:	83 c0 36             	add    $0x36,%eax
80109aae:	89 45 e0             	mov    %eax,-0x20(%ebp)
      uint payload_size;
      http_proc(0,0,send_payload,&payload_size);
80109ab1:	8d 45 d8             	lea    -0x28(%ebp),%eax
80109ab4:	50                   	push   %eax
80109ab5:	ff 75 e0             	push   -0x20(%ebp)
80109ab8:	6a 00                	push   $0x0
80109aba:	6a 00                	push   $0x0
80109abc:	e8 5a 04 00 00       	call   80109f1b <http_proc>
80109ac1:	83 c4 10             	add    $0x10,%esp
      tcp_pkt_create(buffer_addr,send_addr,&send_size,(TCP_CODEBITS_ACK|TCP_CODEBITS_PSH),payload_size);
80109ac4:	8b 45 d8             	mov    -0x28(%ebp),%eax
80109ac7:	83 ec 0c             	sub    $0xc,%esp
80109aca:	50                   	push   %eax
80109acb:	6a 18                	push   $0x18
80109acd:	8d 45 dc             	lea    -0x24(%ebp),%eax
80109ad0:	50                   	push   %eax
80109ad1:	ff 75 e8             	push   -0x18(%ebp)
80109ad4:	ff 75 08             	push   0x8(%ebp)
80109ad7:	e8 e4 00 00 00       	call   80109bc0 <tcp_pkt_create>
80109adc:	83 c4 20             	add    $0x20,%esp
80109adf:	eb 62                	jmp    80109b43 <tcp_proc+0x18c>
    }else{
     tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_ACK,0);
80109ae1:	83 ec 0c             	sub    $0xc,%esp
80109ae4:	6a 00                	push   $0x0
80109ae6:	6a 10                	push   $0x10
80109ae8:	8d 45 dc             	lea    -0x24(%ebp),%eax
80109aeb:	50                   	push   %eax
80109aec:	ff 75 e8             	push   -0x18(%ebp)
80109aef:	ff 75 08             	push   0x8(%ebp)
80109af2:	e8 c9 00 00 00       	call   80109bc0 <tcp_pkt_create>
80109af7:	83 c4 20             	add    $0x20,%esp
     i8254_send(send_addr,send_size);
80109afa:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109afd:	83 ec 08             	sub    $0x8,%esp
80109b00:	50                   	push   %eax
80109b01:	ff 75 e8             	push   -0x18(%ebp)
80109b04:	e8 88 f0 ff ff       	call   80108b91 <i8254_send>
80109b09:	83 c4 10             	add    $0x10,%esp
      uint send_payload = (send_addr + sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt));
80109b0c:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109b0f:	83 c0 36             	add    $0x36,%eax
80109b12:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      uint payload_size;
      http_proc(0,0,send_payload,&payload_size);
80109b15:	8d 45 d4             	lea    -0x2c(%ebp),%eax
80109b18:	50                   	push   %eax
80109b19:	ff 75 e4             	push   -0x1c(%ebp)
80109b1c:	6a 00                	push   $0x0
80109b1e:	6a 00                	push   $0x0
80109b20:	e8 f6 03 00 00       	call   80109f1b <http_proc>
80109b25:	83 c4 10             	add    $0x10,%esp
      tcp_pkt_create(buffer_addr,send_addr,&send_size,(TCP_CODEBITS_ACK|TCP_CODEBITS_PSH),payload_size);
80109b28:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80109b2b:	83 ec 0c             	sub    $0xc,%esp
80109b2e:	50                   	push   %eax
80109b2f:	6a 18                	push   $0x18
80109b31:	8d 45 dc             	lea    -0x24(%ebp),%eax
80109b34:	50                   	push   %eax
80109b35:	ff 75 e8             	push   -0x18(%ebp)
80109b38:	ff 75 08             	push   0x8(%ebp)
80109b3b:	e8 80 00 00 00       	call   80109bc0 <tcp_pkt_create>
80109b40:	83 c4 20             	add    $0x20,%esp
    }
    i8254_send(send_addr,send_size);
80109b43:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109b46:	83 ec 08             	sub    $0x8,%esp
80109b49:	50                   	push   %eax
80109b4a:	ff 75 e8             	push   -0x18(%ebp)
80109b4d:	e8 3f f0 ff ff       	call   80108b91 <i8254_send>
80109b52:	83 c4 10             	add    $0x10,%esp
    seq_num++;
80109b55:	a1 64 71 19 80       	mov    0x80197164,%eax
80109b5a:	83 c0 01             	add    $0x1,%eax
80109b5d:	a3 64 71 19 80       	mov    %eax,0x80197164
80109b62:	eb 4a                	jmp    80109bae <tcp_proc+0x1f7>
  }else if(tcp_p->code_bits[1] == TCP_CODEBITS_ACK){
80109b64:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109b67:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
80109b6b:	3c 10                	cmp    $0x10,%al
80109b6d:	75 3f                	jne    80109bae <tcp_proc+0x1f7>
    if(fin_flag == 1){
80109b6f:	a1 68 71 19 80       	mov    0x80197168,%eax
80109b74:	83 f8 01             	cmp    $0x1,%eax
80109b77:	75 35                	jne    80109bae <tcp_proc+0x1f7>
      tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_FIN,0);
80109b79:	83 ec 0c             	sub    $0xc,%esp
80109b7c:	6a 00                	push   $0x0
80109b7e:	6a 01                	push   $0x1
80109b80:	8d 45 dc             	lea    -0x24(%ebp),%eax
80109b83:	50                   	push   %eax
80109b84:	ff 75 e8             	push   -0x18(%ebp)
80109b87:	ff 75 08             	push   0x8(%ebp)
80109b8a:	e8 31 00 00 00       	call   80109bc0 <tcp_pkt_create>
80109b8f:	83 c4 20             	add    $0x20,%esp
      i8254_send(send_addr,send_size);
80109b92:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109b95:	83 ec 08             	sub    $0x8,%esp
80109b98:	50                   	push   %eax
80109b99:	ff 75 e8             	push   -0x18(%ebp)
80109b9c:	e8 f0 ef ff ff       	call   80108b91 <i8254_send>
80109ba1:	83 c4 10             	add    $0x10,%esp
      fin_flag = 0;
80109ba4:	c7 05 68 71 19 80 00 	movl   $0x0,0x80197168
80109bab:	00 00 00 
    }
  }
  kfree((char *)send_addr);
80109bae:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109bb1:	83 ec 0c             	sub    $0xc,%esp
80109bb4:	50                   	push   %eax
80109bb5:	e8 4c 8b ff ff       	call   80102706 <kfree>
80109bba:	83 c4 10             	add    $0x10,%esp
}
80109bbd:	90                   	nop
80109bbe:	c9                   	leave  
80109bbf:	c3                   	ret    

80109bc0 <tcp_pkt_create>:

void tcp_pkt_create(uint recv_addr,uint send_addr,uint *send_size,uint pkt_type,uint payload_size){
80109bc0:	55                   	push   %ebp
80109bc1:	89 e5                	mov    %esp,%ebp
80109bc3:	83 ec 28             	sub    $0x28,%esp
  struct eth_pkt *eth_recv = (struct eth_pkt *)(recv_addr);
80109bc6:	8b 45 08             	mov    0x8(%ebp),%eax
80109bc9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct ipv4_pkt *ipv4_recv = (struct ipv4_pkt *)(recv_addr+sizeof(struct eth_pkt));
80109bcc:	8b 45 08             	mov    0x8(%ebp),%eax
80109bcf:	83 c0 0e             	add    $0xe,%eax
80109bd2:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct tcp_pkt *tcp_recv = (struct tcp_pkt *)((uint)ipv4_recv + (ipv4_recv->ver&0xF)*4);
80109bd5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109bd8:	0f b6 00             	movzbl (%eax),%eax
80109bdb:	0f b6 c0             	movzbl %al,%eax
80109bde:	83 e0 0f             	and    $0xf,%eax
80109be1:	c1 e0 02             	shl    $0x2,%eax
80109be4:	89 c2                	mov    %eax,%edx
80109be6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109be9:	01 d0                	add    %edx,%eax
80109beb:	89 45 ec             	mov    %eax,-0x14(%ebp)

  struct eth_pkt *eth_send = (struct eth_pkt *)(send_addr);
80109bee:	8b 45 0c             	mov    0xc(%ebp),%eax
80109bf1:	89 45 e8             	mov    %eax,-0x18(%ebp)
  struct ipv4_pkt *ipv4_send = (struct ipv4_pkt *)(send_addr + sizeof(struct eth_pkt));
80109bf4:	8b 45 0c             	mov    0xc(%ebp),%eax
80109bf7:	83 c0 0e             	add    $0xe,%eax
80109bfa:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct tcp_pkt *tcp_send = (struct tcp_pkt *)((uint)ipv4_send + sizeof(struct ipv4_pkt));
80109bfd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109c00:	83 c0 14             	add    $0x14,%eax
80109c03:	89 45 e0             	mov    %eax,-0x20(%ebp)

  *send_size = sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt) + payload_size;
80109c06:	8b 45 18             	mov    0x18(%ebp),%eax
80109c09:	8d 50 36             	lea    0x36(%eax),%edx
80109c0c:	8b 45 10             	mov    0x10(%ebp),%eax
80109c0f:	89 10                	mov    %edx,(%eax)

  memmove(eth_send->dst_mac,eth_recv->src_mac,6);
80109c11:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109c14:	8d 50 06             	lea    0x6(%eax),%edx
80109c17:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109c1a:	83 ec 04             	sub    $0x4,%esp
80109c1d:	6a 06                	push   $0x6
80109c1f:	52                   	push   %edx
80109c20:	50                   	push   %eax
80109c21:	e8 18 ae ff ff       	call   80104a3e <memmove>
80109c26:	83 c4 10             	add    $0x10,%esp
  memmove(eth_send->src_mac,mac_addr,6);
80109c29:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109c2c:	83 c0 06             	add    $0x6,%eax
80109c2f:	83 ec 04             	sub    $0x4,%esp
80109c32:	6a 06                	push   $0x6
80109c34:	68 80 6e 19 80       	push   $0x80196e80
80109c39:	50                   	push   %eax
80109c3a:	e8 ff ad ff ff       	call   80104a3e <memmove>
80109c3f:	83 c4 10             	add    $0x10,%esp
  eth_send->type[0] = 0x08;
80109c42:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109c45:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  eth_send->type[1] = 0x00;
80109c49:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109c4c:	c6 40 0d 00          	movb   $0x0,0xd(%eax)

  ipv4_send->ver = ((0x4)<<4)+((sizeof(struct ipv4_pkt)/4)&0xF);
80109c50:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109c53:	c6 00 45             	movb   $0x45,(%eax)
  ipv4_send->srv_type = 0;
80109c56:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109c59:	c6 40 01 00          	movb   $0x0,0x1(%eax)
  ipv4_send->total_len = H2N_ushort(sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt) + payload_size);
80109c5d:	8b 45 18             	mov    0x18(%ebp),%eax
80109c60:	83 c0 28             	add    $0x28,%eax
80109c63:	0f b7 c0             	movzwl %ax,%eax
80109c66:	83 ec 0c             	sub    $0xc,%esp
80109c69:	50                   	push   %eax
80109c6a:	e8 9b f8 ff ff       	call   8010950a <H2N_ushort>
80109c6f:	83 c4 10             	add    $0x10,%esp
80109c72:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80109c75:	66 89 42 02          	mov    %ax,0x2(%edx)
  ipv4_send->id = send_id;
80109c79:	0f b7 15 60 71 19 80 	movzwl 0x80197160,%edx
80109c80:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109c83:	66 89 50 04          	mov    %dx,0x4(%eax)
  send_id++;
80109c87:	0f b7 05 60 71 19 80 	movzwl 0x80197160,%eax
80109c8e:	83 c0 01             	add    $0x1,%eax
80109c91:	66 a3 60 71 19 80    	mov    %ax,0x80197160
  ipv4_send->fragment = H2N_ushort(0x0000);
80109c97:	83 ec 0c             	sub    $0xc,%esp
80109c9a:	6a 00                	push   $0x0
80109c9c:	e8 69 f8 ff ff       	call   8010950a <H2N_ushort>
80109ca1:	83 c4 10             	add    $0x10,%esp
80109ca4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80109ca7:	66 89 42 06          	mov    %ax,0x6(%edx)
  ipv4_send->ttl = 255;
80109cab:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109cae:	c6 40 08 ff          	movb   $0xff,0x8(%eax)
  ipv4_send->protocol = IPV4_TYPE_TCP;
80109cb2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109cb5:	c6 40 09 06          	movb   $0x6,0x9(%eax)
  memmove(ipv4_send->src_ip,my_ip,4);
80109cb9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109cbc:	83 c0 0c             	add    $0xc,%eax
80109cbf:	83 ec 04             	sub    $0x4,%esp
80109cc2:	6a 04                	push   $0x4
80109cc4:	68 e4 f4 10 80       	push   $0x8010f4e4
80109cc9:	50                   	push   %eax
80109cca:	e8 6f ad ff ff       	call   80104a3e <memmove>
80109ccf:	83 c4 10             	add    $0x10,%esp
  memmove(ipv4_send->dst_ip,ipv4_recv->src_ip,4);
80109cd2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109cd5:	8d 50 0c             	lea    0xc(%eax),%edx
80109cd8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109cdb:	83 c0 10             	add    $0x10,%eax
80109cde:	83 ec 04             	sub    $0x4,%esp
80109ce1:	6a 04                	push   $0x4
80109ce3:	52                   	push   %edx
80109ce4:	50                   	push   %eax
80109ce5:	e8 54 ad ff ff       	call   80104a3e <memmove>
80109cea:	83 c4 10             	add    $0x10,%esp
  ipv4_send->chk_sum = 0;
80109ced:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109cf0:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
  ipv4_send->chk_sum = H2N_ushort(ipv4_chksum((uint)ipv4_send));
80109cf6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109cf9:	83 ec 0c             	sub    $0xc,%esp
80109cfc:	50                   	push   %eax
80109cfd:	e8 08 f9 ff ff       	call   8010960a <ipv4_chksum>
80109d02:	83 c4 10             	add    $0x10,%esp
80109d05:	0f b7 c0             	movzwl %ax,%eax
80109d08:	83 ec 0c             	sub    $0xc,%esp
80109d0b:	50                   	push   %eax
80109d0c:	e8 f9 f7 ff ff       	call   8010950a <H2N_ushort>
80109d11:	83 c4 10             	add    $0x10,%esp
80109d14:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80109d17:	66 89 42 0a          	mov    %ax,0xa(%edx)
  

  tcp_send->src_port = tcp_recv->dst_port;
80109d1b:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109d1e:	0f b7 50 02          	movzwl 0x2(%eax),%edx
80109d22:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109d25:	66 89 10             	mov    %dx,(%eax)
  tcp_send->dst_port = tcp_recv->src_port;
80109d28:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109d2b:	0f b7 10             	movzwl (%eax),%edx
80109d2e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109d31:	66 89 50 02          	mov    %dx,0x2(%eax)
  tcp_send->seq_num = H2N_uint(seq_num);
80109d35:	a1 64 71 19 80       	mov    0x80197164,%eax
80109d3a:	83 ec 0c             	sub    $0xc,%esp
80109d3d:	50                   	push   %eax
80109d3e:	e8 e9 f7 ff ff       	call   8010952c <H2N_uint>
80109d43:	83 c4 10             	add    $0x10,%esp
80109d46:	8b 55 e0             	mov    -0x20(%ebp),%edx
80109d49:	89 42 04             	mov    %eax,0x4(%edx)
  tcp_send->ack_num = tcp_recv->seq_num + (1<<(8*3));
80109d4c:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109d4f:	8b 40 04             	mov    0x4(%eax),%eax
80109d52:	8d 90 00 00 00 01    	lea    0x1000000(%eax),%edx
80109d58:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109d5b:	89 50 08             	mov    %edx,0x8(%eax)

  tcp_send->code_bits[0] = 0;
80109d5e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109d61:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
  tcp_send->code_bits[1] = 0;
80109d65:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109d68:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
  tcp_send->code_bits[0] = 5<<4;
80109d6c:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109d6f:	c6 40 0c 50          	movb   $0x50,0xc(%eax)
  tcp_send->code_bits[1] = pkt_type;
80109d73:	8b 45 14             	mov    0x14(%ebp),%eax
80109d76:	89 c2                	mov    %eax,%edx
80109d78:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109d7b:	88 50 0d             	mov    %dl,0xd(%eax)

  tcp_send->window = H2N_ushort(14480);
80109d7e:	83 ec 0c             	sub    $0xc,%esp
80109d81:	68 90 38 00 00       	push   $0x3890
80109d86:	e8 7f f7 ff ff       	call   8010950a <H2N_ushort>
80109d8b:	83 c4 10             	add    $0x10,%esp
80109d8e:	8b 55 e0             	mov    -0x20(%ebp),%edx
80109d91:	66 89 42 0e          	mov    %ax,0xe(%edx)
  tcp_send->urgent_ptr = 0;
80109d95:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109d98:	66 c7 40 12 00 00    	movw   $0x0,0x12(%eax)
  tcp_send->chk_sum = 0;
80109d9e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109da1:	66 c7 40 10 00 00    	movw   $0x0,0x10(%eax)

  tcp_send->chk_sum = H2N_ushort(tcp_chksum((uint)(ipv4_send))+8);
80109da7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109daa:	83 ec 0c             	sub    $0xc,%esp
80109dad:	50                   	push   %eax
80109dae:	e8 1f 00 00 00       	call   80109dd2 <tcp_chksum>
80109db3:	83 c4 10             	add    $0x10,%esp
80109db6:	83 c0 08             	add    $0x8,%eax
80109db9:	0f b7 c0             	movzwl %ax,%eax
80109dbc:	83 ec 0c             	sub    $0xc,%esp
80109dbf:	50                   	push   %eax
80109dc0:	e8 45 f7 ff ff       	call   8010950a <H2N_ushort>
80109dc5:	83 c4 10             	add    $0x10,%esp
80109dc8:	8b 55 e0             	mov    -0x20(%ebp),%edx
80109dcb:	66 89 42 10          	mov    %ax,0x10(%edx)


}
80109dcf:	90                   	nop
80109dd0:	c9                   	leave  
80109dd1:	c3                   	ret    

80109dd2 <tcp_chksum>:

ushort tcp_chksum(uint tcp_addr){
80109dd2:	55                   	push   %ebp
80109dd3:	89 e5                	mov    %esp,%ebp
80109dd5:	83 ec 38             	sub    $0x38,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(tcp_addr);
80109dd8:	8b 45 08             	mov    0x8(%ebp),%eax
80109ddb:	89 45 e8             	mov    %eax,-0x18(%ebp)
  struct tcp_pkt *tcp_p = (struct tcp_pkt *)((uint)ipv4_p + sizeof(struct ipv4_pkt));
80109dde:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109de1:	83 c0 14             	add    $0x14,%eax
80109de4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct tcp_dummy tcp_dummy;
  
  memmove(tcp_dummy.src_ip,my_ip,4);
80109de7:	83 ec 04             	sub    $0x4,%esp
80109dea:	6a 04                	push   $0x4
80109dec:	68 e4 f4 10 80       	push   $0x8010f4e4
80109df1:	8d 45 d4             	lea    -0x2c(%ebp),%eax
80109df4:	50                   	push   %eax
80109df5:	e8 44 ac ff ff       	call   80104a3e <memmove>
80109dfa:	83 c4 10             	add    $0x10,%esp
  memmove(tcp_dummy.dst_ip,ipv4_p->src_ip,4);
80109dfd:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109e00:	83 c0 0c             	add    $0xc,%eax
80109e03:	83 ec 04             	sub    $0x4,%esp
80109e06:	6a 04                	push   $0x4
80109e08:	50                   	push   %eax
80109e09:	8d 45 d4             	lea    -0x2c(%ebp),%eax
80109e0c:	83 c0 04             	add    $0x4,%eax
80109e0f:	50                   	push   %eax
80109e10:	e8 29 ac ff ff       	call   80104a3e <memmove>
80109e15:	83 c4 10             	add    $0x10,%esp
  tcp_dummy.padding = 0;
80109e18:	c6 45 dc 00          	movb   $0x0,-0x24(%ebp)
  tcp_dummy.protocol = IPV4_TYPE_TCP;
80109e1c:	c6 45 dd 06          	movb   $0x6,-0x23(%ebp)
  tcp_dummy.tcp_len = H2N_ushort(N2H_ushort(ipv4_p->total_len) - sizeof(struct ipv4_pkt));
80109e20:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109e23:	0f b7 40 02          	movzwl 0x2(%eax),%eax
80109e27:	0f b7 c0             	movzwl %ax,%eax
80109e2a:	83 ec 0c             	sub    $0xc,%esp
80109e2d:	50                   	push   %eax
80109e2e:	e8 b5 f6 ff ff       	call   801094e8 <N2H_ushort>
80109e33:	83 c4 10             	add    $0x10,%esp
80109e36:	83 e8 14             	sub    $0x14,%eax
80109e39:	0f b7 c0             	movzwl %ax,%eax
80109e3c:	83 ec 0c             	sub    $0xc,%esp
80109e3f:	50                   	push   %eax
80109e40:	e8 c5 f6 ff ff       	call   8010950a <H2N_ushort>
80109e45:	83 c4 10             	add    $0x10,%esp
80109e48:	66 89 45 de          	mov    %ax,-0x22(%ebp)
  uint chk_sum = 0;
80109e4c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  uchar *bin = (uchar *)(&tcp_dummy);
80109e53:	8d 45 d4             	lea    -0x2c(%ebp),%eax
80109e56:	89 45 e0             	mov    %eax,-0x20(%ebp)
  for(int i=0;i<6;i++){
80109e59:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80109e60:	eb 33                	jmp    80109e95 <tcp_chksum+0xc3>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
80109e62:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109e65:	01 c0                	add    %eax,%eax
80109e67:	89 c2                	mov    %eax,%edx
80109e69:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109e6c:	01 d0                	add    %edx,%eax
80109e6e:	0f b6 00             	movzbl (%eax),%eax
80109e71:	0f b6 c0             	movzbl %al,%eax
80109e74:	c1 e0 08             	shl    $0x8,%eax
80109e77:	89 c2                	mov    %eax,%edx
80109e79:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109e7c:	01 c0                	add    %eax,%eax
80109e7e:	8d 48 01             	lea    0x1(%eax),%ecx
80109e81:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109e84:	01 c8                	add    %ecx,%eax
80109e86:	0f b6 00             	movzbl (%eax),%eax
80109e89:	0f b6 c0             	movzbl %al,%eax
80109e8c:	01 d0                	add    %edx,%eax
80109e8e:	01 45 f4             	add    %eax,-0xc(%ebp)
  for(int i=0;i<6;i++){
80109e91:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80109e95:	83 7d f0 05          	cmpl   $0x5,-0x10(%ebp)
80109e99:	7e c7                	jle    80109e62 <tcp_chksum+0x90>
  }

  bin = (uchar *)(tcp_p);
80109e9b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109e9e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  for(int i=0;i<(N2H_ushort(tcp_dummy.tcp_len)/2);i++){
80109ea1:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80109ea8:	eb 33                	jmp    80109edd <tcp_chksum+0x10b>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
80109eaa:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109ead:	01 c0                	add    %eax,%eax
80109eaf:	89 c2                	mov    %eax,%edx
80109eb1:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109eb4:	01 d0                	add    %edx,%eax
80109eb6:	0f b6 00             	movzbl (%eax),%eax
80109eb9:	0f b6 c0             	movzbl %al,%eax
80109ebc:	c1 e0 08             	shl    $0x8,%eax
80109ebf:	89 c2                	mov    %eax,%edx
80109ec1:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109ec4:	01 c0                	add    %eax,%eax
80109ec6:	8d 48 01             	lea    0x1(%eax),%ecx
80109ec9:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109ecc:	01 c8                	add    %ecx,%eax
80109ece:	0f b6 00             	movzbl (%eax),%eax
80109ed1:	0f b6 c0             	movzbl %al,%eax
80109ed4:	01 d0                	add    %edx,%eax
80109ed6:	01 45 f4             	add    %eax,-0xc(%ebp)
  for(int i=0;i<(N2H_ushort(tcp_dummy.tcp_len)/2);i++){
80109ed9:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80109edd:	0f b7 45 de          	movzwl -0x22(%ebp),%eax
80109ee1:	0f b7 c0             	movzwl %ax,%eax
80109ee4:	83 ec 0c             	sub    $0xc,%esp
80109ee7:	50                   	push   %eax
80109ee8:	e8 fb f5 ff ff       	call   801094e8 <N2H_ushort>
80109eed:	83 c4 10             	add    $0x10,%esp
80109ef0:	66 d1 e8             	shr    %ax
80109ef3:	0f b7 c0             	movzwl %ax,%eax
80109ef6:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80109ef9:	7c af                	jl     80109eaa <tcp_chksum+0xd8>
  }
  chk_sum += (chk_sum>>8*2);
80109efb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109efe:	c1 e8 10             	shr    $0x10,%eax
80109f01:	01 45 f4             	add    %eax,-0xc(%ebp)
  return ~(chk_sum);
80109f04:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109f07:	f7 d0                	not    %eax
}
80109f09:	c9                   	leave  
80109f0a:	c3                   	ret    

80109f0b <tcp_fin>:

void tcp_fin(){
80109f0b:	55                   	push   %ebp
80109f0c:	89 e5                	mov    %esp,%ebp
  fin_flag =1;
80109f0e:	c7 05 68 71 19 80 01 	movl   $0x1,0x80197168
80109f15:	00 00 00 
}
80109f18:	90                   	nop
80109f19:	5d                   	pop    %ebp
80109f1a:	c3                   	ret    

80109f1b <http_proc>:
#include "defs.h"
#include "types.h"
#include "tcp.h"


void http_proc(uint recv, uint recv_size, uint send, uint *send_size){
80109f1b:	55                   	push   %ebp
80109f1c:	89 e5                	mov    %esp,%ebp
80109f1e:	83 ec 18             	sub    $0x18,%esp
  int len;
  len = http_strcpy((char *)send,"HTTP/1.0 200 OK \r\n",0);
80109f21:	8b 45 10             	mov    0x10(%ebp),%eax
80109f24:	83 ec 04             	sub    $0x4,%esp
80109f27:	6a 00                	push   $0x0
80109f29:	68 8b c0 10 80       	push   $0x8010c08b
80109f2e:	50                   	push   %eax
80109f2f:	e8 65 00 00 00       	call   80109f99 <http_strcpy>
80109f34:	83 c4 10             	add    $0x10,%esp
80109f37:	89 45 f4             	mov    %eax,-0xc(%ebp)
  len += http_strcpy((char *)send,"Content-Type: text/html \r\n",len);
80109f3a:	8b 45 10             	mov    0x10(%ebp),%eax
80109f3d:	83 ec 04             	sub    $0x4,%esp
80109f40:	ff 75 f4             	push   -0xc(%ebp)
80109f43:	68 9e c0 10 80       	push   $0x8010c09e
80109f48:	50                   	push   %eax
80109f49:	e8 4b 00 00 00       	call   80109f99 <http_strcpy>
80109f4e:	83 c4 10             	add    $0x10,%esp
80109f51:	01 45 f4             	add    %eax,-0xc(%ebp)
  len += http_strcpy((char *)send,"\r\nHello World!\r\n",len);
80109f54:	8b 45 10             	mov    0x10(%ebp),%eax
80109f57:	83 ec 04             	sub    $0x4,%esp
80109f5a:	ff 75 f4             	push   -0xc(%ebp)
80109f5d:	68 b9 c0 10 80       	push   $0x8010c0b9
80109f62:	50                   	push   %eax
80109f63:	e8 31 00 00 00       	call   80109f99 <http_strcpy>
80109f68:	83 c4 10             	add    $0x10,%esp
80109f6b:	01 45 f4             	add    %eax,-0xc(%ebp)
  if(len%2 != 0){
80109f6e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109f71:	83 e0 01             	and    $0x1,%eax
80109f74:	85 c0                	test   %eax,%eax
80109f76:	74 11                	je     80109f89 <http_proc+0x6e>
    char *payload = (char *)send;
80109f78:	8b 45 10             	mov    0x10(%ebp),%eax
80109f7b:	89 45 f0             	mov    %eax,-0x10(%ebp)
    payload[len] = 0;
80109f7e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109f81:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109f84:	01 d0                	add    %edx,%eax
80109f86:	c6 00 00             	movb   $0x0,(%eax)
  }
  *send_size = len;
80109f89:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109f8c:	8b 45 14             	mov    0x14(%ebp),%eax
80109f8f:	89 10                	mov    %edx,(%eax)
  tcp_fin();
80109f91:	e8 75 ff ff ff       	call   80109f0b <tcp_fin>
}
80109f96:	90                   	nop
80109f97:	c9                   	leave  
80109f98:	c3                   	ret    

80109f99 <http_strcpy>:

int http_strcpy(char *dst,const char *src,int start_index){
80109f99:	55                   	push   %ebp
80109f9a:	89 e5                	mov    %esp,%ebp
80109f9c:	83 ec 10             	sub    $0x10,%esp
  int i = 0;
80109f9f:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while(src[i]){
80109fa6:	eb 20                	jmp    80109fc8 <http_strcpy+0x2f>
    dst[start_index+i] = src[i];
80109fa8:	8b 55 fc             	mov    -0x4(%ebp),%edx
80109fab:	8b 45 0c             	mov    0xc(%ebp),%eax
80109fae:	01 d0                	add    %edx,%eax
80109fb0:	8b 4d 10             	mov    0x10(%ebp),%ecx
80109fb3:	8b 55 fc             	mov    -0x4(%ebp),%edx
80109fb6:	01 ca                	add    %ecx,%edx
80109fb8:	89 d1                	mov    %edx,%ecx
80109fba:	8b 55 08             	mov    0x8(%ebp),%edx
80109fbd:	01 ca                	add    %ecx,%edx
80109fbf:	0f b6 00             	movzbl (%eax),%eax
80109fc2:	88 02                	mov    %al,(%edx)
    i++;
80109fc4:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  while(src[i]){
80109fc8:	8b 55 fc             	mov    -0x4(%ebp),%edx
80109fcb:	8b 45 0c             	mov    0xc(%ebp),%eax
80109fce:	01 d0                	add    %edx,%eax
80109fd0:	0f b6 00             	movzbl (%eax),%eax
80109fd3:	84 c0                	test   %al,%al
80109fd5:	75 d1                	jne    80109fa8 <http_strcpy+0xf>
  }
  return i;
80109fd7:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80109fda:	c9                   	leave  
80109fdb:	c3                   	ret    

80109fdc <ideinit>:
static int disksize;
static uchar *memdisk;

void
ideinit(void)
{
80109fdc:	55                   	push   %ebp
80109fdd:	89 e5                	mov    %esp,%ebp
  memdisk = _binary_fs_img_start;
80109fdf:	c7 05 70 71 19 80 a2 	movl   $0x8010f5a2,0x80197170
80109fe6:	f5 10 80 
  disksize = (uint)_binary_fs_img_size/BSIZE;
80109fe9:	b8 00 d0 07 00       	mov    $0x7d000,%eax
80109fee:	c1 e8 09             	shr    $0x9,%eax
80109ff1:	a3 6c 71 19 80       	mov    %eax,0x8019716c
}
80109ff6:	90                   	nop
80109ff7:	5d                   	pop    %ebp
80109ff8:	c3                   	ret    

80109ff9 <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
80109ff9:	55                   	push   %ebp
80109ffa:	89 e5                	mov    %esp,%ebp
  // no-op
}
80109ffc:	90                   	nop
80109ffd:	5d                   	pop    %ebp
80109ffe:	c3                   	ret    

80109fff <iderw>:
// Sync buf with disk.
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
80109fff:	55                   	push   %ebp
8010a000:	89 e5                	mov    %esp,%ebp
8010a002:	83 ec 18             	sub    $0x18,%esp
  uchar *p;

  if(!holdingsleep(&b->lock))
8010a005:	8b 45 08             	mov    0x8(%ebp),%eax
8010a008:	83 c0 0c             	add    $0xc,%eax
8010a00b:	83 ec 0c             	sub    $0xc,%esp
8010a00e:	50                   	push   %eax
8010a00f:	e8 64 a6 ff ff       	call   80104678 <holdingsleep>
8010a014:	83 c4 10             	add    $0x10,%esp
8010a017:	85 c0                	test   %eax,%eax
8010a019:	75 0d                	jne    8010a028 <iderw+0x29>
    panic("iderw: buf not locked");
8010a01b:	83 ec 0c             	sub    $0xc,%esp
8010a01e:	68 ca c0 10 80       	push   $0x8010c0ca
8010a023:	e8 81 65 ff ff       	call   801005a9 <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
8010a028:	8b 45 08             	mov    0x8(%ebp),%eax
8010a02b:	8b 00                	mov    (%eax),%eax
8010a02d:	83 e0 06             	and    $0x6,%eax
8010a030:	83 f8 02             	cmp    $0x2,%eax
8010a033:	75 0d                	jne    8010a042 <iderw+0x43>
    panic("iderw: nothing to do");
8010a035:	83 ec 0c             	sub    $0xc,%esp
8010a038:	68 e0 c0 10 80       	push   $0x8010c0e0
8010a03d:	e8 67 65 ff ff       	call   801005a9 <panic>
  if(b->dev != 1)
8010a042:	8b 45 08             	mov    0x8(%ebp),%eax
8010a045:	8b 40 04             	mov    0x4(%eax),%eax
8010a048:	83 f8 01             	cmp    $0x1,%eax
8010a04b:	74 0d                	je     8010a05a <iderw+0x5b>
    panic("iderw: request not for disk 1");
8010a04d:	83 ec 0c             	sub    $0xc,%esp
8010a050:	68 f5 c0 10 80       	push   $0x8010c0f5
8010a055:	e8 4f 65 ff ff       	call   801005a9 <panic>
  if(b->blockno >= disksize)
8010a05a:	8b 45 08             	mov    0x8(%ebp),%eax
8010a05d:	8b 40 08             	mov    0x8(%eax),%eax
8010a060:	8b 15 6c 71 19 80    	mov    0x8019716c,%edx
8010a066:	39 d0                	cmp    %edx,%eax
8010a068:	72 0d                	jb     8010a077 <iderw+0x78>
    panic("iderw: block out of range");
8010a06a:	83 ec 0c             	sub    $0xc,%esp
8010a06d:	68 13 c1 10 80       	push   $0x8010c113
8010a072:	e8 32 65 ff ff       	call   801005a9 <panic>

  p = memdisk + b->blockno*BSIZE;
8010a077:	8b 15 70 71 19 80    	mov    0x80197170,%edx
8010a07d:	8b 45 08             	mov    0x8(%ebp),%eax
8010a080:	8b 40 08             	mov    0x8(%eax),%eax
8010a083:	c1 e0 09             	shl    $0x9,%eax
8010a086:	01 d0                	add    %edx,%eax
8010a088:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(b->flags & B_DIRTY){
8010a08b:	8b 45 08             	mov    0x8(%ebp),%eax
8010a08e:	8b 00                	mov    (%eax),%eax
8010a090:	83 e0 04             	and    $0x4,%eax
8010a093:	85 c0                	test   %eax,%eax
8010a095:	74 2b                	je     8010a0c2 <iderw+0xc3>
    b->flags &= ~B_DIRTY;
8010a097:	8b 45 08             	mov    0x8(%ebp),%eax
8010a09a:	8b 00                	mov    (%eax),%eax
8010a09c:	83 e0 fb             	and    $0xfffffffb,%eax
8010a09f:	89 c2                	mov    %eax,%edx
8010a0a1:	8b 45 08             	mov    0x8(%ebp),%eax
8010a0a4:	89 10                	mov    %edx,(%eax)
    memmove(p, b->data, BSIZE);
8010a0a6:	8b 45 08             	mov    0x8(%ebp),%eax
8010a0a9:	83 c0 5c             	add    $0x5c,%eax
8010a0ac:	83 ec 04             	sub    $0x4,%esp
8010a0af:	68 00 02 00 00       	push   $0x200
8010a0b4:	50                   	push   %eax
8010a0b5:	ff 75 f4             	push   -0xc(%ebp)
8010a0b8:	e8 81 a9 ff ff       	call   80104a3e <memmove>
8010a0bd:	83 c4 10             	add    $0x10,%esp
8010a0c0:	eb 1a                	jmp    8010a0dc <iderw+0xdd>
  } else
    memmove(b->data, p, BSIZE);
8010a0c2:	8b 45 08             	mov    0x8(%ebp),%eax
8010a0c5:	83 c0 5c             	add    $0x5c,%eax
8010a0c8:	83 ec 04             	sub    $0x4,%esp
8010a0cb:	68 00 02 00 00       	push   $0x200
8010a0d0:	ff 75 f4             	push   -0xc(%ebp)
8010a0d3:	50                   	push   %eax
8010a0d4:	e8 65 a9 ff ff       	call   80104a3e <memmove>
8010a0d9:	83 c4 10             	add    $0x10,%esp
  b->flags |= B_VALID;
8010a0dc:	8b 45 08             	mov    0x8(%ebp),%eax
8010a0df:	8b 00                	mov    (%eax),%eax
8010a0e1:	83 c8 02             	or     $0x2,%eax
8010a0e4:	89 c2                	mov    %eax,%edx
8010a0e6:	8b 45 08             	mov    0x8(%ebp),%eax
8010a0e9:	89 10                	mov    %edx,(%eax)
}
8010a0eb:	90                   	nop
8010a0ec:	c9                   	leave  
8010a0ed:	c3                   	ret    
