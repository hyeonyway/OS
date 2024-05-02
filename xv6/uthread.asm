
_uthread:     file format elf32-i386


Disassembly of section .text:

00000000 <thread_init>:
static int num_thread = 0;

static void thread_schedule(void);

void thread_init(void (*func)())
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	83 ec 08             	sub    $0x8,%esp
  // main() is thread 0, which will make the first invocation to
  // thread_schedule().  it needs a stack so that the first thread_switch() can
  // save thread 0's state.  thread_schedule() won't run the main thread ever
  // again, because its state is set to RUNNING, and thread_schedule() selects
  // a RUNNABLE thread.
  current_thread = &all_thread[0];
   6:	c7 05 e0 0f 00 00 00 	movl   $0x1000,0xfe0
   d:	10 00 00 
  current_thread->state = RUNNING;
  10:	a1 e0 0f 00 00       	mov    0xfe0,%eax
  15:	c7 80 04 20 00 00 01 	movl   $0x1,0x2004(%eax)
  1c:	00 00 00 
  num_thread = 0;
  1f:	c7 05 20 90 00 00 00 	movl   $0x0,0x9020
  26:	00 00 00 
  thread_num(num_thread);
  29:	a1 20 90 00 00       	mov    0x9020,%eax
  2e:	83 ec 0c             	sub    $0xc,%esp
  31:	50                   	push   %eax
  32:	e8 d9 06 00 00       	call   710 <thread_num>
  37:	83 c4 10             	add    $0x10,%esp
  uthread_init((uint)func);
  3a:	8b 45 08             	mov    0x8(%ebp),%eax
  3d:	83 ec 0c             	sub    $0xc,%esp
  40:	50                   	push   %eax
  41:	e8 c2 06 00 00       	call   708 <uthread_init>
  46:	83 c4 10             	add    $0x10,%esp
}
  49:	90                   	nop
  4a:	c9                   	leave  
  4b:	c3                   	ret    

0000004c <thread_schedule>:

static void
thread_schedule(void)
{
  4c:	55                   	push   %ebp
  4d:	89 e5                	mov    %esp,%ebp
  4f:	83 ec 18             	sub    $0x18,%esp
  printf(1, "start 1\n");
  52:	83 ec 08             	sub    $0x8,%esp
  55:	68 a4 0b 00 00       	push   $0xba4
  5a:	6a 01                	push   $0x1
  5c:	e8 8b 07 00 00       	call   7ec <printf>
  61:	83 c4 10             	add    $0x10,%esp
  if(current_thread->state != FREE)
  64:	a1 e0 0f 00 00       	mov    0xfe0,%eax
  69:	8b 80 04 20 00 00    	mov    0x2004(%eax),%eax
  6f:	85 c0                	test   %eax,%eax
  71:	74 0f                	je     82 <thread_schedule+0x36>
  {
    current_thread->state = RUNNABLE; 
  73:	a1 e0 0f 00 00       	mov    0xfe0,%eax
  78:	c7 80 04 20 00 00 02 	movl   $0x2,0x2004(%eax)
  7f:	00 00 00 
  }
  printf(1, "start 3\n");
  82:	83 ec 08             	sub    $0x8,%esp
  85:	68 ad 0b 00 00       	push   $0xbad
  8a:	6a 01                	push   $0x1
  8c:	e8 5b 07 00 00       	call   7ec <printf>
  91:	83 c4 10             	add    $0x10,%esp
  printf(1, "current thread addr : %d\n", &current_thread);
  94:	83 ec 04             	sub    $0x4,%esp
  97:	68 e0 0f 00 00       	push   $0xfe0
  9c:	68 b6 0b 00 00       	push   $0xbb6
  a1:	6a 01                	push   $0x1
  a3:	e8 44 07 00 00       	call   7ec <printf>
  a8:	83 c4 10             	add    $0x10,%esp
  thread_p t;
  /* Find another runnable thread. */
  next_thread = 0;
  ab:	c7 05 e4 0f 00 00 00 	movl   $0x0,0xfe4
  b2:	00 00 00 
  for (t = all_thread; t < all_thread + MAX_THREAD; t++)
  b5:	c7 45 f4 00 10 00 00 	movl   $0x1000,-0xc(%ebp)
  bc:	eb 3b                	jmp    f9 <thread_schedule+0xad>
  {
    if (t->state == RUNNABLE && t != current_thread)
  be:	8b 45 f4             	mov    -0xc(%ebp),%eax
  c1:	8b 80 04 20 00 00    	mov    0x2004(%eax),%eax
  c7:	83 f8 02             	cmp    $0x2,%eax
  ca:	75 26                	jne    f2 <thread_schedule+0xa6>
  cc:	a1 e0 0f 00 00       	mov    0xfe0,%eax
  d1:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  d4:	74 1c                	je     f2 <thread_schedule+0xa6>
    {
      printf(1, "start 4\n");
  d6:	83 ec 08             	sub    $0x8,%esp
  d9:	68 d0 0b 00 00       	push   $0xbd0
  de:	6a 01                	push   $0x1
  e0:	e8 07 07 00 00       	call   7ec <printf>
  e5:	83 c4 10             	add    $0x10,%esp
      next_thread = t;
  e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  eb:	a3 e4 0f 00 00       	mov    %eax,0xfe4
      break;
  f0:	eb 11                	jmp    103 <thread_schedule+0xb7>
  for (t = all_thread; t < all_thread + MAX_THREAD; t++)
  f2:	81 45 f4 08 20 00 00 	addl   $0x2008,-0xc(%ebp)
  f9:	b8 20 90 00 00       	mov    $0x9020,%eax
  fe:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 101:	72 bb                	jb     be <thread_schedule+0x72>
    }
  }
  printf(1, "start 5\n");
 103:	83 ec 08             	sub    $0x8,%esp
 106:	68 d9 0b 00 00       	push   $0xbd9
 10b:	6a 01                	push   $0x1
 10d:	e8 da 06 00 00       	call   7ec <printf>
 112:	83 c4 10             	add    $0x10,%esp
  if (t >= all_thread + MAX_THREAD && current_thread->state == RUNNABLE)
 115:	b8 20 90 00 00       	mov    $0x9020,%eax
 11a:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 11d:	72 2c                	jb     14b <thread_schedule+0xff>
 11f:	a1 e0 0f 00 00       	mov    0xfe0,%eax
 124:	8b 80 04 20 00 00    	mov    0x2004(%eax),%eax
 12a:	83 f8 02             	cmp    $0x2,%eax
 12d:	75 1c                	jne    14b <thread_schedule+0xff>
  {
    /* The current thread is the only runnable thread; run it. */
    next_thread = current_thread;
 12f:	a1 e0 0f 00 00       	mov    0xfe0,%eax
 134:	a3 e4 0f 00 00       	mov    %eax,0xfe4
    printf(1, "start 6\n");
 139:	83 ec 08             	sub    $0x8,%esp
 13c:	68 e2 0b 00 00       	push   $0xbe2
 141:	6a 01                	push   $0x1
 143:	e8 a4 06 00 00       	call   7ec <printf>
 148:	83 c4 10             	add    $0x10,%esp
  }
  printf(1, "start 7\n");
 14b:	83 ec 08             	sub    $0x8,%esp
 14e:	68 eb 0b 00 00       	push   $0xbeb
 153:	6a 01                	push   $0x1
 155:	e8 92 06 00 00       	call   7ec <printf>
 15a:	83 c4 10             	add    $0x10,%esp
  if (next_thread == 0)
 15d:	a1 e4 0f 00 00       	mov    0xfe4,%eax
 162:	85 c0                	test   %eax,%eax
 164:	75 29                	jne    18f <thread_schedule+0x143>
  {
    printf(1, "start 8\n");
 166:	83 ec 08             	sub    $0x8,%esp
 169:	68 f4 0b 00 00       	push   $0xbf4
 16e:	6a 01                	push   $0x1
 170:	e8 77 06 00 00       	call   7ec <printf>
 175:	83 c4 10             	add    $0x10,%esp
    printf(2, "thread_schedule: no runnable threads\n");
 178:	83 ec 08             	sub    $0x8,%esp
 17b:	68 00 0c 00 00       	push   $0xc00
 180:	6a 02                	push   $0x2
 182:	e8 65 06 00 00       	call   7ec <printf>
 187:	83 c4 10             	add    $0x10,%esp
    exit();
 18a:	e8 d9 04 00 00       	call   668 <exit>
  }
  printf(1, "middle current thread addr : %d\n", &current_thread);
 18f:	83 ec 04             	sub    $0x4,%esp
 192:	68 e0 0f 00 00       	push   $0xfe0
 197:	68 28 0c 00 00       	push   $0xc28
 19c:	6a 01                	push   $0x1
 19e:	e8 49 06 00 00       	call   7ec <printf>
 1a3:	83 c4 10             	add    $0x10,%esp
  printf(1, "start 9\n");
 1a6:	83 ec 08             	sub    $0x8,%esp
 1a9:	68 49 0c 00 00       	push   $0xc49
 1ae:	6a 01                	push   $0x1
 1b0:	e8 37 06 00 00       	call   7ec <printf>
 1b5:	83 c4 10             	add    $0x10,%esp
  if (current_thread != next_thread)
 1b8:	8b 15 e0 0f 00 00    	mov    0xfe0,%edx
 1be:	a1 e4 0f 00 00       	mov    0xfe4,%eax
 1c3:	39 c2                	cmp    %eax,%edx
 1c5:	74 28                	je     1ef <thread_schedule+0x1a3>
  { /* switch threads?  */
    next_thread->state = RUNNING;
 1c7:	a1 e4 0f 00 00       	mov    0xfe4,%eax
 1cc:	c7 80 04 20 00 00 01 	movl   $0x1,0x2004(%eax)
 1d3:	00 00 00 
    printf(1, "start 10\n");
 1d6:	83 ec 08             	sub    $0x8,%esp
 1d9:	68 52 0c 00 00       	push   $0xc52
 1de:	6a 01                	push   $0x1
 1e0:	e8 07 06 00 00       	call   7ec <printf>
 1e5:	83 c4 10             	add    $0x10,%esp
    thread_switch();
 1e8:	e8 04 02 00 00       	call   3f1 <thread_switch>
 1ed:	eb 0a                	jmp    1f9 <thread_schedule+0x1ad>
  }
  
  else
    next_thread = 0;
 1ef:	c7 05 e4 0f 00 00 00 	movl   $0x0,0xfe4
 1f6:	00 00 00 
  printf(1, "end current thread addr : %d\n", &current_thread);
 1f9:	83 ec 04             	sub    $0x4,%esp
 1fc:	68 e0 0f 00 00       	push   $0xfe0
 201:	68 5c 0c 00 00       	push   $0xc5c
 206:	6a 01                	push   $0x1
 208:	e8 df 05 00 00       	call   7ec <printf>
 20d:	83 c4 10             	add    $0x10,%esp
}
 210:	90                   	nop
 211:	c9                   	leave  
 212:	c3                   	ret    

00000213 <thread_create>:

void thread_create(void (*func)())
{
 213:	55                   	push   %ebp
 214:	89 e5                	mov    %esp,%ebp
 216:	83 ec 18             	sub    $0x18,%esp
  thread_p t;
  num_thread++;
 219:	a1 20 90 00 00       	mov    0x9020,%eax
 21e:	83 c0 01             	add    $0x1,%eax
 221:	a3 20 90 00 00       	mov    %eax,0x9020
  thread_num(num_thread);
 226:	a1 20 90 00 00       	mov    0x9020,%eax
 22b:	83 ec 0c             	sub    $0xc,%esp
 22e:	50                   	push   %eax
 22f:	e8 dc 04 00 00       	call   710 <thread_num>
 234:	83 c4 10             	add    $0x10,%esp
  for (t = all_thread; t < all_thread + MAX_THREAD; t++)
 237:	c7 45 f4 00 10 00 00 	movl   $0x1000,-0xc(%ebp)
 23e:	eb 14                	jmp    254 <thread_create+0x41>
  {
    if (t->state == FREE)
 240:	8b 45 f4             	mov    -0xc(%ebp),%eax
 243:	8b 80 04 20 00 00    	mov    0x2004(%eax),%eax
 249:	85 c0                	test   %eax,%eax
 24b:	74 13                	je     260 <thread_create+0x4d>
  for (t = all_thread; t < all_thread + MAX_THREAD; t++)
 24d:	81 45 f4 08 20 00 00 	addl   $0x2008,-0xc(%ebp)
 254:	b8 20 90 00 00       	mov    $0x9020,%eax
 259:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 25c:	72 e2                	jb     240 <thread_create+0x2d>
 25e:	eb 01                	jmp    261 <thread_create+0x4e>
      break;
 260:	90                   	nop
  }
  t->sp = (int)(t->stack + STACK_SIZE); // set sp to the top of the stack
 261:	8b 45 f4             	mov    -0xc(%ebp),%eax
 264:	83 c0 04             	add    $0x4,%eax
 267:	05 00 20 00 00       	add    $0x2000,%eax
 26c:	89 c2                	mov    %eax,%edx
 26e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 271:	89 10                	mov    %edx,(%eax)
  t->sp -= 4;                           // space for return address
 273:	8b 45 f4             	mov    -0xc(%ebp),%eax
 276:	8b 00                	mov    (%eax),%eax
 278:	8d 50 fc             	lea    -0x4(%eax),%edx
 27b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 27e:	89 10                	mov    %edx,(%eax)
  *(int *)(t->sp) = (int)func;          // push return address on stack
 280:	8b 45 f4             	mov    -0xc(%ebp),%eax
 283:	8b 00                	mov    (%eax),%eax
 285:	89 c2                	mov    %eax,%edx
 287:	8b 45 08             	mov    0x8(%ebp),%eax
 28a:	89 02                	mov    %eax,(%edx)
  t->sp -= 32;                          // space for registers that thread_switch expects
 28c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 28f:	8b 00                	mov    (%eax),%eax
 291:	8d 50 e0             	lea    -0x20(%eax),%edx
 294:	8b 45 f4             	mov    -0xc(%ebp),%eax
 297:	89 10                	mov    %edx,(%eax)
  t->state = RUNNABLE;
 299:	8b 45 f4             	mov    -0xc(%ebp),%eax
 29c:	c7 80 04 20 00 00 02 	movl   $0x2,0x2004(%eax)
 2a3:	00 00 00 
  
}
 2a6:	90                   	nop
 2a7:	c9                   	leave  
 2a8:	c3                   	ret    

000002a9 <thread_yield>:

void thread_yield(void)
{
 2a9:	55                   	push   %ebp
 2aa:	89 e5                	mov    %esp,%ebp
 2ac:	83 ec 08             	sub    $0x8,%esp
  current_thread->state = RUNNABLE;
 2af:	a1 e0 0f 00 00       	mov    0xfe0,%eax
 2b4:	c7 80 04 20 00 00 02 	movl   $0x2,0x2004(%eax)
 2bb:	00 00 00 
  thread_schedule();
 2be:	e8 89 fd ff ff       	call   4c <thread_schedule>
}
 2c3:	90                   	nop
 2c4:	c9                   	leave  
 2c5:	c3                   	ret    

000002c6 <mythread>:

static void
mythread(void)
{
 2c6:	55                   	push   %ebp
 2c7:	89 e5                	mov    %esp,%ebp
 2c9:	83 ec 18             	sub    $0x18,%esp
  int i;
  printf(1, "my thread running\n");
 2cc:	83 ec 08             	sub    $0x8,%esp
 2cf:	68 7a 0c 00 00       	push   $0xc7a
 2d4:	6a 01                	push   $0x1
 2d6:	e8 11 05 00 00       	call   7ec <printf>
 2db:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < 100; i++)
 2de:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 2e5:	eb 1c                	jmp    303 <mythread+0x3d>
  {
    printf(1, "%d my thread 0x%x\n", i, (int)current_thread);
 2e7:	a1 e0 0f 00 00       	mov    0xfe0,%eax
 2ec:	50                   	push   %eax
 2ed:	ff 75 f4             	push   -0xc(%ebp)
 2f0:	68 8d 0c 00 00       	push   $0xc8d
 2f5:	6a 01                	push   $0x1
 2f7:	e8 f0 04 00 00       	call   7ec <printf>
 2fc:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < 100; i++)
 2ff:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 303:	83 7d f4 63          	cmpl   $0x63,-0xc(%ebp)
 307:	7e de                	jle    2e7 <mythread+0x21>
    // thread_yield();
  }
  printf(1, "my thread: exit\n");
 309:	83 ec 08             	sub    $0x8,%esp
 30c:	68 a0 0c 00 00       	push   $0xca0
 311:	6a 01                	push   $0x1
 313:	e8 d4 04 00 00       	call   7ec <printf>
 318:	83 c4 10             	add    $0x10,%esp
  current_thread->state = FREE;
 31b:	a1 e0 0f 00 00       	mov    0xfe0,%eax
 320:	c7 80 04 20 00 00 00 	movl   $0x0,0x2004(%eax)
 327:	00 00 00 
  num_thread--;
 32a:	a1 20 90 00 00       	mov    0x9020,%eax
 32f:	83 e8 01             	sub    $0x1,%eax
 332:	a3 20 90 00 00       	mov    %eax,0x9020
  thread_num(num_thread);
 337:	a1 20 90 00 00       	mov    0x9020,%eax
 33c:	83 ec 0c             	sub    $0xc,%esp
 33f:	50                   	push   %eax
 340:	e8 cb 03 00 00       	call   710 <thread_num>
 345:	83 c4 10             	add    $0x10,%esp
  thread_schedule();
 348:	e8 ff fc ff ff       	call   4c <thread_schedule>
}
 34d:	90                   	nop
 34e:	c9                   	leave  
 34f:	c3                   	ret    

00000350 <main>:

int main(int argc, char *argv[])
{
 350:	8d 4c 24 04          	lea    0x4(%esp),%ecx
 354:	83 e4 f0             	and    $0xfffffff0,%esp
 357:	ff 71 fc             	push   -0x4(%ecx)
 35a:	55                   	push   %ebp
 35b:	89 e5                	mov    %esp,%ebp
 35d:	51                   	push   %ecx
 35e:	83 ec 04             	sub    $0x4,%esp
  printf(1, "addr : %d", (uint)thread_schedule);
 361:	b8 4c 00 00 00       	mov    $0x4c,%eax
 366:	83 ec 04             	sub    $0x4,%esp
 369:	50                   	push   %eax
 36a:	68 b1 0c 00 00       	push   $0xcb1
 36f:	6a 01                	push   $0x1
 371:	e8 76 04 00 00       	call   7ec <printf>
 376:	83 c4 10             	add    $0x10,%esp
  thread_init(thread_schedule);
 379:	83 ec 0c             	sub    $0xc,%esp
 37c:	68 4c 00 00 00       	push   $0x4c
 381:	e8 7a fc ff ff       	call   0 <thread_init>
 386:	83 c4 10             	add    $0x10,%esp
  thread_create(mythread);
 389:	83 ec 0c             	sub    $0xc,%esp
 38c:	68 c6 02 00 00       	push   $0x2c6
 391:	e8 7d fe ff ff       	call   213 <thread_create>
 396:	83 c4 10             	add    $0x10,%esp
  printf(1, "a\n");
 399:	83 ec 08             	sub    $0x8,%esp
 39c:	68 bb 0c 00 00       	push   $0xcbb
 3a1:	6a 01                	push   $0x1
 3a3:	e8 44 04 00 00       	call   7ec <printf>
 3a8:	83 c4 10             	add    $0x10,%esp
  thread_create(mythread);
 3ab:	83 ec 0c             	sub    $0xc,%esp
 3ae:	68 c6 02 00 00       	push   $0x2c6
 3b3:	e8 5b fe ff ff       	call   213 <thread_create>
 3b8:	83 c4 10             	add    $0x10,%esp
  printf(1, "b\n");
 3bb:	83 ec 08             	sub    $0x8,%esp
 3be:	68 be 0c 00 00       	push   $0xcbe
 3c3:	6a 01                	push   $0x1
 3c5:	e8 22 04 00 00       	call   7ec <printf>
 3ca:	83 c4 10             	add    $0x10,%esp
  thread_schedule();
 3cd:	e8 7a fc ff ff       	call   4c <thread_schedule>
  printf(1, "c\n");
 3d2:	83 ec 08             	sub    $0x8,%esp
 3d5:	68 c1 0c 00 00       	push   $0xcc1
 3da:	6a 01                	push   $0x1
 3dc:	e8 0b 04 00 00       	call   7ec <printf>
 3e1:	83 c4 10             	add    $0x10,%esp
  return 0;
 3e4:	b8 00 00 00 00       	mov    $0x0,%eax
 3e9:	8b 4d fc             	mov    -0x4(%ebp),%ecx
 3ec:	c9                   	leave  
 3ed:	8d 61 fc             	lea    -0x4(%ecx),%esp
 3f0:	c3                   	ret    

000003f1 <thread_switch>:
         */

   .globl thread_switch
thread_switch:
   /* YOUR CODE HERE */
   pushal
 3f1:	60                   	pusha  

   movl current_thread, %eax
 3f2:	a1 e0 0f 00 00       	mov    0xfe0,%eax
   movl %esp, (%eax)
 3f7:	89 20                	mov    %esp,(%eax)

   movl next_thread, %eax
 3f9:	a1 e4 0f 00 00       	mov    0xfe4,%eax
   movl (%eax), %esp
 3fe:	8b 20                	mov    (%eax),%esp

   movl %eax, current_thread
 400:	a3 e0 0f 00 00       	mov    %eax,0xfe0

   popal
 405:	61                   	popa   

   movl $0, next_thread
 406:	c7 05 e4 0f 00 00 00 	movl   $0x0,0xfe4
 40d:	00 00 00 


 410:	c3                   	ret    

00000411 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 411:	55                   	push   %ebp
 412:	89 e5                	mov    %esp,%ebp
 414:	57                   	push   %edi
 415:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 416:	8b 4d 08             	mov    0x8(%ebp),%ecx
 419:	8b 55 10             	mov    0x10(%ebp),%edx
 41c:	8b 45 0c             	mov    0xc(%ebp),%eax
 41f:	89 cb                	mov    %ecx,%ebx
 421:	89 df                	mov    %ebx,%edi
 423:	89 d1                	mov    %edx,%ecx
 425:	fc                   	cld    
 426:	f3 aa                	rep stos %al,%es:(%edi)
 428:	89 ca                	mov    %ecx,%edx
 42a:	89 fb                	mov    %edi,%ebx
 42c:	89 5d 08             	mov    %ebx,0x8(%ebp)
 42f:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 432:	90                   	nop
 433:	5b                   	pop    %ebx
 434:	5f                   	pop    %edi
 435:	5d                   	pop    %ebp
 436:	c3                   	ret    

00000437 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 437:	55                   	push   %ebp
 438:	89 e5                	mov    %esp,%ebp
 43a:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 43d:	8b 45 08             	mov    0x8(%ebp),%eax
 440:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 443:	90                   	nop
 444:	8b 55 0c             	mov    0xc(%ebp),%edx
 447:	8d 42 01             	lea    0x1(%edx),%eax
 44a:	89 45 0c             	mov    %eax,0xc(%ebp)
 44d:	8b 45 08             	mov    0x8(%ebp),%eax
 450:	8d 48 01             	lea    0x1(%eax),%ecx
 453:	89 4d 08             	mov    %ecx,0x8(%ebp)
 456:	0f b6 12             	movzbl (%edx),%edx
 459:	88 10                	mov    %dl,(%eax)
 45b:	0f b6 00             	movzbl (%eax),%eax
 45e:	84 c0                	test   %al,%al
 460:	75 e2                	jne    444 <strcpy+0xd>
    ;
  return os;
 462:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 465:	c9                   	leave  
 466:	c3                   	ret    

00000467 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 467:	55                   	push   %ebp
 468:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 46a:	eb 08                	jmp    474 <strcmp+0xd>
    p++, q++;
 46c:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 470:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(*p && *p == *q)
 474:	8b 45 08             	mov    0x8(%ebp),%eax
 477:	0f b6 00             	movzbl (%eax),%eax
 47a:	84 c0                	test   %al,%al
 47c:	74 10                	je     48e <strcmp+0x27>
 47e:	8b 45 08             	mov    0x8(%ebp),%eax
 481:	0f b6 10             	movzbl (%eax),%edx
 484:	8b 45 0c             	mov    0xc(%ebp),%eax
 487:	0f b6 00             	movzbl (%eax),%eax
 48a:	38 c2                	cmp    %al,%dl
 48c:	74 de                	je     46c <strcmp+0x5>
  return (uchar)*p - (uchar)*q;
 48e:	8b 45 08             	mov    0x8(%ebp),%eax
 491:	0f b6 00             	movzbl (%eax),%eax
 494:	0f b6 d0             	movzbl %al,%edx
 497:	8b 45 0c             	mov    0xc(%ebp),%eax
 49a:	0f b6 00             	movzbl (%eax),%eax
 49d:	0f b6 c8             	movzbl %al,%ecx
 4a0:	89 d0                	mov    %edx,%eax
 4a2:	29 c8                	sub    %ecx,%eax
}
 4a4:	5d                   	pop    %ebp
 4a5:	c3                   	ret    

000004a6 <strlen>:

uint
strlen(char *s)
{
 4a6:	55                   	push   %ebp
 4a7:	89 e5                	mov    %esp,%ebp
 4a9:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 4ac:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 4b3:	eb 04                	jmp    4b9 <strlen+0x13>
 4b5:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 4b9:	8b 55 fc             	mov    -0x4(%ebp),%edx
 4bc:	8b 45 08             	mov    0x8(%ebp),%eax
 4bf:	01 d0                	add    %edx,%eax
 4c1:	0f b6 00             	movzbl (%eax),%eax
 4c4:	84 c0                	test   %al,%al
 4c6:	75 ed                	jne    4b5 <strlen+0xf>
    ;
  return n;
 4c8:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 4cb:	c9                   	leave  
 4cc:	c3                   	ret    

000004cd <memset>:

void*
memset(void *dst, int c, uint n)
{
 4cd:	55                   	push   %ebp
 4ce:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
 4d0:	8b 45 10             	mov    0x10(%ebp),%eax
 4d3:	50                   	push   %eax
 4d4:	ff 75 0c             	push   0xc(%ebp)
 4d7:	ff 75 08             	push   0x8(%ebp)
 4da:	e8 32 ff ff ff       	call   411 <stosb>
 4df:	83 c4 0c             	add    $0xc,%esp
  return dst;
 4e2:	8b 45 08             	mov    0x8(%ebp),%eax
}
 4e5:	c9                   	leave  
 4e6:	c3                   	ret    

000004e7 <strchr>:

char*
strchr(const char *s, char c)
{
 4e7:	55                   	push   %ebp
 4e8:	89 e5                	mov    %esp,%ebp
 4ea:	83 ec 04             	sub    $0x4,%esp
 4ed:	8b 45 0c             	mov    0xc(%ebp),%eax
 4f0:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 4f3:	eb 14                	jmp    509 <strchr+0x22>
    if(*s == c)
 4f5:	8b 45 08             	mov    0x8(%ebp),%eax
 4f8:	0f b6 00             	movzbl (%eax),%eax
 4fb:	38 45 fc             	cmp    %al,-0x4(%ebp)
 4fe:	75 05                	jne    505 <strchr+0x1e>
      return (char*)s;
 500:	8b 45 08             	mov    0x8(%ebp),%eax
 503:	eb 13                	jmp    518 <strchr+0x31>
  for(; *s; s++)
 505:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 509:	8b 45 08             	mov    0x8(%ebp),%eax
 50c:	0f b6 00             	movzbl (%eax),%eax
 50f:	84 c0                	test   %al,%al
 511:	75 e2                	jne    4f5 <strchr+0xe>
  return 0;
 513:	b8 00 00 00 00       	mov    $0x0,%eax
}
 518:	c9                   	leave  
 519:	c3                   	ret    

0000051a <gets>:

char*
gets(char *buf, int max)
{
 51a:	55                   	push   %ebp
 51b:	89 e5                	mov    %esp,%ebp
 51d:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 520:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 527:	eb 42                	jmp    56b <gets+0x51>
    cc = read(0, &c, 1);
 529:	83 ec 04             	sub    $0x4,%esp
 52c:	6a 01                	push   $0x1
 52e:	8d 45 ef             	lea    -0x11(%ebp),%eax
 531:	50                   	push   %eax
 532:	6a 00                	push   $0x0
 534:	e8 47 01 00 00       	call   680 <read>
 539:	83 c4 10             	add    $0x10,%esp
 53c:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 53f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 543:	7e 33                	jle    578 <gets+0x5e>
      break;
    buf[i++] = c;
 545:	8b 45 f4             	mov    -0xc(%ebp),%eax
 548:	8d 50 01             	lea    0x1(%eax),%edx
 54b:	89 55 f4             	mov    %edx,-0xc(%ebp)
 54e:	89 c2                	mov    %eax,%edx
 550:	8b 45 08             	mov    0x8(%ebp),%eax
 553:	01 c2                	add    %eax,%edx
 555:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 559:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 55b:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 55f:	3c 0a                	cmp    $0xa,%al
 561:	74 16                	je     579 <gets+0x5f>
 563:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 567:	3c 0d                	cmp    $0xd,%al
 569:	74 0e                	je     579 <gets+0x5f>
  for(i=0; i+1 < max; ){
 56b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 56e:	83 c0 01             	add    $0x1,%eax
 571:	39 45 0c             	cmp    %eax,0xc(%ebp)
 574:	7f b3                	jg     529 <gets+0xf>
 576:	eb 01                	jmp    579 <gets+0x5f>
      break;
 578:	90                   	nop
      break;
  }
  buf[i] = '\0';
 579:	8b 55 f4             	mov    -0xc(%ebp),%edx
 57c:	8b 45 08             	mov    0x8(%ebp),%eax
 57f:	01 d0                	add    %edx,%eax
 581:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 584:	8b 45 08             	mov    0x8(%ebp),%eax
}
 587:	c9                   	leave  
 588:	c3                   	ret    

00000589 <stat>:

int
stat(char *n, struct stat *st)
{
 589:	55                   	push   %ebp
 58a:	89 e5                	mov    %esp,%ebp
 58c:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 58f:	83 ec 08             	sub    $0x8,%esp
 592:	6a 00                	push   $0x0
 594:	ff 75 08             	push   0x8(%ebp)
 597:	e8 0c 01 00 00       	call   6a8 <open>
 59c:	83 c4 10             	add    $0x10,%esp
 59f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 5a2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 5a6:	79 07                	jns    5af <stat+0x26>
    return -1;
 5a8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 5ad:	eb 25                	jmp    5d4 <stat+0x4b>
  r = fstat(fd, st);
 5af:	83 ec 08             	sub    $0x8,%esp
 5b2:	ff 75 0c             	push   0xc(%ebp)
 5b5:	ff 75 f4             	push   -0xc(%ebp)
 5b8:	e8 03 01 00 00       	call   6c0 <fstat>
 5bd:	83 c4 10             	add    $0x10,%esp
 5c0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 5c3:	83 ec 0c             	sub    $0xc,%esp
 5c6:	ff 75 f4             	push   -0xc(%ebp)
 5c9:	e8 c2 00 00 00       	call   690 <close>
 5ce:	83 c4 10             	add    $0x10,%esp
  return r;
 5d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 5d4:	c9                   	leave  
 5d5:	c3                   	ret    

000005d6 <atoi>:

int
atoi(const char *s)
{
 5d6:	55                   	push   %ebp
 5d7:	89 e5                	mov    %esp,%ebp
 5d9:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 5dc:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 5e3:	eb 25                	jmp    60a <atoi+0x34>
    n = n*10 + *s++ - '0';
 5e5:	8b 55 fc             	mov    -0x4(%ebp),%edx
 5e8:	89 d0                	mov    %edx,%eax
 5ea:	c1 e0 02             	shl    $0x2,%eax
 5ed:	01 d0                	add    %edx,%eax
 5ef:	01 c0                	add    %eax,%eax
 5f1:	89 c1                	mov    %eax,%ecx
 5f3:	8b 45 08             	mov    0x8(%ebp),%eax
 5f6:	8d 50 01             	lea    0x1(%eax),%edx
 5f9:	89 55 08             	mov    %edx,0x8(%ebp)
 5fc:	0f b6 00             	movzbl (%eax),%eax
 5ff:	0f be c0             	movsbl %al,%eax
 602:	01 c8                	add    %ecx,%eax
 604:	83 e8 30             	sub    $0x30,%eax
 607:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 60a:	8b 45 08             	mov    0x8(%ebp),%eax
 60d:	0f b6 00             	movzbl (%eax),%eax
 610:	3c 2f                	cmp    $0x2f,%al
 612:	7e 0a                	jle    61e <atoi+0x48>
 614:	8b 45 08             	mov    0x8(%ebp),%eax
 617:	0f b6 00             	movzbl (%eax),%eax
 61a:	3c 39                	cmp    $0x39,%al
 61c:	7e c7                	jle    5e5 <atoi+0xf>
  return n;
 61e:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 621:	c9                   	leave  
 622:	c3                   	ret    

00000623 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 623:	55                   	push   %ebp
 624:	89 e5                	mov    %esp,%ebp
 626:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;

  dst = vdst;
 629:	8b 45 08             	mov    0x8(%ebp),%eax
 62c:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 62f:	8b 45 0c             	mov    0xc(%ebp),%eax
 632:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 635:	eb 17                	jmp    64e <memmove+0x2b>
    *dst++ = *src++;
 637:	8b 55 f8             	mov    -0x8(%ebp),%edx
 63a:	8d 42 01             	lea    0x1(%edx),%eax
 63d:	89 45 f8             	mov    %eax,-0x8(%ebp)
 640:	8b 45 fc             	mov    -0x4(%ebp),%eax
 643:	8d 48 01             	lea    0x1(%eax),%ecx
 646:	89 4d fc             	mov    %ecx,-0x4(%ebp)
 649:	0f b6 12             	movzbl (%edx),%edx
 64c:	88 10                	mov    %dl,(%eax)
  while(n-- > 0)
 64e:	8b 45 10             	mov    0x10(%ebp),%eax
 651:	8d 50 ff             	lea    -0x1(%eax),%edx
 654:	89 55 10             	mov    %edx,0x10(%ebp)
 657:	85 c0                	test   %eax,%eax
 659:	7f dc                	jg     637 <memmove+0x14>
  return vdst;
 65b:	8b 45 08             	mov    0x8(%ebp),%eax
}
 65e:	c9                   	leave  
 65f:	c3                   	ret    

00000660 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 660:	b8 01 00 00 00       	mov    $0x1,%eax
 665:	cd 40                	int    $0x40
 667:	c3                   	ret    

00000668 <exit>:
SYSCALL(exit)
 668:	b8 02 00 00 00       	mov    $0x2,%eax
 66d:	cd 40                	int    $0x40
 66f:	c3                   	ret    

00000670 <wait>:
SYSCALL(wait)
 670:	b8 03 00 00 00       	mov    $0x3,%eax
 675:	cd 40                	int    $0x40
 677:	c3                   	ret    

00000678 <pipe>:
SYSCALL(pipe)
 678:	b8 04 00 00 00       	mov    $0x4,%eax
 67d:	cd 40                	int    $0x40
 67f:	c3                   	ret    

00000680 <read>:
SYSCALL(read)
 680:	b8 05 00 00 00       	mov    $0x5,%eax
 685:	cd 40                	int    $0x40
 687:	c3                   	ret    

00000688 <write>:
SYSCALL(write)
 688:	b8 10 00 00 00       	mov    $0x10,%eax
 68d:	cd 40                	int    $0x40
 68f:	c3                   	ret    

00000690 <close>:
SYSCALL(close)
 690:	b8 15 00 00 00       	mov    $0x15,%eax
 695:	cd 40                	int    $0x40
 697:	c3                   	ret    

00000698 <kill>:
SYSCALL(kill)
 698:	b8 06 00 00 00       	mov    $0x6,%eax
 69d:	cd 40                	int    $0x40
 69f:	c3                   	ret    

000006a0 <exec>:
SYSCALL(exec)
 6a0:	b8 07 00 00 00       	mov    $0x7,%eax
 6a5:	cd 40                	int    $0x40
 6a7:	c3                   	ret    

000006a8 <open>:
SYSCALL(open)
 6a8:	b8 0f 00 00 00       	mov    $0xf,%eax
 6ad:	cd 40                	int    $0x40
 6af:	c3                   	ret    

000006b0 <mknod>:
SYSCALL(mknod)
 6b0:	b8 11 00 00 00       	mov    $0x11,%eax
 6b5:	cd 40                	int    $0x40
 6b7:	c3                   	ret    

000006b8 <unlink>:
SYSCALL(unlink)
 6b8:	b8 12 00 00 00       	mov    $0x12,%eax
 6bd:	cd 40                	int    $0x40
 6bf:	c3                   	ret    

000006c0 <fstat>:
SYSCALL(fstat)
 6c0:	b8 08 00 00 00       	mov    $0x8,%eax
 6c5:	cd 40                	int    $0x40
 6c7:	c3                   	ret    

000006c8 <link>:
SYSCALL(link)
 6c8:	b8 13 00 00 00       	mov    $0x13,%eax
 6cd:	cd 40                	int    $0x40
 6cf:	c3                   	ret    

000006d0 <mkdir>:
SYSCALL(mkdir)
 6d0:	b8 14 00 00 00       	mov    $0x14,%eax
 6d5:	cd 40                	int    $0x40
 6d7:	c3                   	ret    

000006d8 <chdir>:
SYSCALL(chdir)
 6d8:	b8 09 00 00 00       	mov    $0x9,%eax
 6dd:	cd 40                	int    $0x40
 6df:	c3                   	ret    

000006e0 <dup>:
SYSCALL(dup)
 6e0:	b8 0a 00 00 00       	mov    $0xa,%eax
 6e5:	cd 40                	int    $0x40
 6e7:	c3                   	ret    

000006e8 <getpid>:
SYSCALL(getpid)
 6e8:	b8 0b 00 00 00       	mov    $0xb,%eax
 6ed:	cd 40                	int    $0x40
 6ef:	c3                   	ret    

000006f0 <sbrk>:
SYSCALL(sbrk)
 6f0:	b8 0c 00 00 00       	mov    $0xc,%eax
 6f5:	cd 40                	int    $0x40
 6f7:	c3                   	ret    

000006f8 <sleep>:
SYSCALL(sleep)
 6f8:	b8 0d 00 00 00       	mov    $0xd,%eax
 6fd:	cd 40                	int    $0x40
 6ff:	c3                   	ret    

00000700 <uptime>:
SYSCALL(uptime)
 700:	b8 0e 00 00 00       	mov    $0xe,%eax
 705:	cd 40                	int    $0x40
 707:	c3                   	ret    

00000708 <uthread_init>:
SYSCALL(uthread_init)
 708:	b8 16 00 00 00       	mov    $0x16,%eax
 70d:	cd 40                	int    $0x40
 70f:	c3                   	ret    

00000710 <thread_num>:
 710:	b8 17 00 00 00       	mov    $0x17,%eax
 715:	cd 40                	int    $0x40
 717:	c3                   	ret    

00000718 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 718:	55                   	push   %ebp
 719:	89 e5                	mov    %esp,%ebp
 71b:	83 ec 18             	sub    $0x18,%esp
 71e:	8b 45 0c             	mov    0xc(%ebp),%eax
 721:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 724:	83 ec 04             	sub    $0x4,%esp
 727:	6a 01                	push   $0x1
 729:	8d 45 f4             	lea    -0xc(%ebp),%eax
 72c:	50                   	push   %eax
 72d:	ff 75 08             	push   0x8(%ebp)
 730:	e8 53 ff ff ff       	call   688 <write>
 735:	83 c4 10             	add    $0x10,%esp
}
 738:	90                   	nop
 739:	c9                   	leave  
 73a:	c3                   	ret    

0000073b <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 73b:	55                   	push   %ebp
 73c:	89 e5                	mov    %esp,%ebp
 73e:	83 ec 28             	sub    $0x28,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 741:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 748:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 74c:	74 17                	je     765 <printint+0x2a>
 74e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 752:	79 11                	jns    765 <printint+0x2a>
    neg = 1;
 754:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 75b:	8b 45 0c             	mov    0xc(%ebp),%eax
 75e:	f7 d8                	neg    %eax
 760:	89 45 ec             	mov    %eax,-0x14(%ebp)
 763:	eb 06                	jmp    76b <printint+0x30>
  } else {
    x = xx;
 765:	8b 45 0c             	mov    0xc(%ebp),%eax
 768:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 76b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 772:	8b 4d 10             	mov    0x10(%ebp),%ecx
 775:	8b 45 ec             	mov    -0x14(%ebp),%eax
 778:	ba 00 00 00 00       	mov    $0x0,%edx
 77d:	f7 f1                	div    %ecx
 77f:	89 d1                	mov    %edx,%ecx
 781:	8b 45 f4             	mov    -0xc(%ebp),%eax
 784:	8d 50 01             	lea    0x1(%eax),%edx
 787:	89 55 f4             	mov    %edx,-0xc(%ebp)
 78a:	0f b6 91 b8 0f 00 00 	movzbl 0xfb8(%ecx),%edx
 791:	88 54 05 dc          	mov    %dl,-0x24(%ebp,%eax,1)
  }while((x /= base) != 0);
 795:	8b 4d 10             	mov    0x10(%ebp),%ecx
 798:	8b 45 ec             	mov    -0x14(%ebp),%eax
 79b:	ba 00 00 00 00       	mov    $0x0,%edx
 7a0:	f7 f1                	div    %ecx
 7a2:	89 45 ec             	mov    %eax,-0x14(%ebp)
 7a5:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 7a9:	75 c7                	jne    772 <printint+0x37>
  if(neg)
 7ab:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 7af:	74 2d                	je     7de <printint+0xa3>
    buf[i++] = '-';
 7b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7b4:	8d 50 01             	lea    0x1(%eax),%edx
 7b7:	89 55 f4             	mov    %edx,-0xc(%ebp)
 7ba:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 7bf:	eb 1d                	jmp    7de <printint+0xa3>
    putc(fd, buf[i]);
 7c1:	8d 55 dc             	lea    -0x24(%ebp),%edx
 7c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7c7:	01 d0                	add    %edx,%eax
 7c9:	0f b6 00             	movzbl (%eax),%eax
 7cc:	0f be c0             	movsbl %al,%eax
 7cf:	83 ec 08             	sub    $0x8,%esp
 7d2:	50                   	push   %eax
 7d3:	ff 75 08             	push   0x8(%ebp)
 7d6:	e8 3d ff ff ff       	call   718 <putc>
 7db:	83 c4 10             	add    $0x10,%esp
  while(--i >= 0)
 7de:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 7e2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 7e6:	79 d9                	jns    7c1 <printint+0x86>
}
 7e8:	90                   	nop
 7e9:	90                   	nop
 7ea:	c9                   	leave  
 7eb:	c3                   	ret    

000007ec <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 7ec:	55                   	push   %ebp
 7ed:	89 e5                	mov    %esp,%ebp
 7ef:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 7f2:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 7f9:	8d 45 0c             	lea    0xc(%ebp),%eax
 7fc:	83 c0 04             	add    $0x4,%eax
 7ff:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 802:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 809:	e9 59 01 00 00       	jmp    967 <printf+0x17b>
    c = fmt[i] & 0xff;
 80e:	8b 55 0c             	mov    0xc(%ebp),%edx
 811:	8b 45 f0             	mov    -0x10(%ebp),%eax
 814:	01 d0                	add    %edx,%eax
 816:	0f b6 00             	movzbl (%eax),%eax
 819:	0f be c0             	movsbl %al,%eax
 81c:	25 ff 00 00 00       	and    $0xff,%eax
 821:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 824:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 828:	75 2c                	jne    856 <printf+0x6a>
      if(c == '%'){
 82a:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 82e:	75 0c                	jne    83c <printf+0x50>
        state = '%';
 830:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 837:	e9 27 01 00 00       	jmp    963 <printf+0x177>
      } else {
        putc(fd, c);
 83c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 83f:	0f be c0             	movsbl %al,%eax
 842:	83 ec 08             	sub    $0x8,%esp
 845:	50                   	push   %eax
 846:	ff 75 08             	push   0x8(%ebp)
 849:	e8 ca fe ff ff       	call   718 <putc>
 84e:	83 c4 10             	add    $0x10,%esp
 851:	e9 0d 01 00 00       	jmp    963 <printf+0x177>
      }
    } else if(state == '%'){
 856:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 85a:	0f 85 03 01 00 00    	jne    963 <printf+0x177>
      if(c == 'd'){
 860:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 864:	75 1e                	jne    884 <printf+0x98>
        printint(fd, *ap, 10, 1);
 866:	8b 45 e8             	mov    -0x18(%ebp),%eax
 869:	8b 00                	mov    (%eax),%eax
 86b:	6a 01                	push   $0x1
 86d:	6a 0a                	push   $0xa
 86f:	50                   	push   %eax
 870:	ff 75 08             	push   0x8(%ebp)
 873:	e8 c3 fe ff ff       	call   73b <printint>
 878:	83 c4 10             	add    $0x10,%esp
        ap++;
 87b:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 87f:	e9 d8 00 00 00       	jmp    95c <printf+0x170>
      } else if(c == 'x' || c == 'p'){
 884:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 888:	74 06                	je     890 <printf+0xa4>
 88a:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 88e:	75 1e                	jne    8ae <printf+0xc2>
        printint(fd, *ap, 16, 0);
 890:	8b 45 e8             	mov    -0x18(%ebp),%eax
 893:	8b 00                	mov    (%eax),%eax
 895:	6a 00                	push   $0x0
 897:	6a 10                	push   $0x10
 899:	50                   	push   %eax
 89a:	ff 75 08             	push   0x8(%ebp)
 89d:	e8 99 fe ff ff       	call   73b <printint>
 8a2:	83 c4 10             	add    $0x10,%esp
        ap++;
 8a5:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 8a9:	e9 ae 00 00 00       	jmp    95c <printf+0x170>
      } else if(c == 's'){
 8ae:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 8b2:	75 43                	jne    8f7 <printf+0x10b>
        s = (char*)*ap;
 8b4:	8b 45 e8             	mov    -0x18(%ebp),%eax
 8b7:	8b 00                	mov    (%eax),%eax
 8b9:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 8bc:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 8c0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 8c4:	75 25                	jne    8eb <printf+0xff>
          s = "(null)";
 8c6:	c7 45 f4 c4 0c 00 00 	movl   $0xcc4,-0xc(%ebp)
        while(*s != 0){
 8cd:	eb 1c                	jmp    8eb <printf+0xff>
          putc(fd, *s);
 8cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8d2:	0f b6 00             	movzbl (%eax),%eax
 8d5:	0f be c0             	movsbl %al,%eax
 8d8:	83 ec 08             	sub    $0x8,%esp
 8db:	50                   	push   %eax
 8dc:	ff 75 08             	push   0x8(%ebp)
 8df:	e8 34 fe ff ff       	call   718 <putc>
 8e4:	83 c4 10             	add    $0x10,%esp
          s++;
 8e7:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
        while(*s != 0){
 8eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8ee:	0f b6 00             	movzbl (%eax),%eax
 8f1:	84 c0                	test   %al,%al
 8f3:	75 da                	jne    8cf <printf+0xe3>
 8f5:	eb 65                	jmp    95c <printf+0x170>
        }
      } else if(c == 'c'){
 8f7:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 8fb:	75 1d                	jne    91a <printf+0x12e>
        putc(fd, *ap);
 8fd:	8b 45 e8             	mov    -0x18(%ebp),%eax
 900:	8b 00                	mov    (%eax),%eax
 902:	0f be c0             	movsbl %al,%eax
 905:	83 ec 08             	sub    $0x8,%esp
 908:	50                   	push   %eax
 909:	ff 75 08             	push   0x8(%ebp)
 90c:	e8 07 fe ff ff       	call   718 <putc>
 911:	83 c4 10             	add    $0x10,%esp
        ap++;
 914:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 918:	eb 42                	jmp    95c <printf+0x170>
      } else if(c == '%'){
 91a:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 91e:	75 17                	jne    937 <printf+0x14b>
        putc(fd, c);
 920:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 923:	0f be c0             	movsbl %al,%eax
 926:	83 ec 08             	sub    $0x8,%esp
 929:	50                   	push   %eax
 92a:	ff 75 08             	push   0x8(%ebp)
 92d:	e8 e6 fd ff ff       	call   718 <putc>
 932:	83 c4 10             	add    $0x10,%esp
 935:	eb 25                	jmp    95c <printf+0x170>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 937:	83 ec 08             	sub    $0x8,%esp
 93a:	6a 25                	push   $0x25
 93c:	ff 75 08             	push   0x8(%ebp)
 93f:	e8 d4 fd ff ff       	call   718 <putc>
 944:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 947:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 94a:	0f be c0             	movsbl %al,%eax
 94d:	83 ec 08             	sub    $0x8,%esp
 950:	50                   	push   %eax
 951:	ff 75 08             	push   0x8(%ebp)
 954:	e8 bf fd ff ff       	call   718 <putc>
 959:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 95c:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(i = 0; fmt[i]; i++){
 963:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 967:	8b 55 0c             	mov    0xc(%ebp),%edx
 96a:	8b 45 f0             	mov    -0x10(%ebp),%eax
 96d:	01 d0                	add    %edx,%eax
 96f:	0f b6 00             	movzbl (%eax),%eax
 972:	84 c0                	test   %al,%al
 974:	0f 85 94 fe ff ff    	jne    80e <printf+0x22>
    }
  }
}
 97a:	90                   	nop
 97b:	90                   	nop
 97c:	c9                   	leave  
 97d:	c3                   	ret    

0000097e <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 97e:	55                   	push   %ebp
 97f:	89 e5                	mov    %esp,%ebp
 981:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 984:	8b 45 08             	mov    0x8(%ebp),%eax
 987:	83 e8 08             	sub    $0x8,%eax
 98a:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 98d:	a1 2c 90 00 00       	mov    0x902c,%eax
 992:	89 45 fc             	mov    %eax,-0x4(%ebp)
 995:	eb 24                	jmp    9bb <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 997:	8b 45 fc             	mov    -0x4(%ebp),%eax
 99a:	8b 00                	mov    (%eax),%eax
 99c:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 99f:	72 12                	jb     9b3 <free+0x35>
 9a1:	8b 45 f8             	mov    -0x8(%ebp),%eax
 9a4:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 9a7:	77 24                	ja     9cd <free+0x4f>
 9a9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9ac:	8b 00                	mov    (%eax),%eax
 9ae:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 9b1:	72 1a                	jb     9cd <free+0x4f>
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 9b3:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9b6:	8b 00                	mov    (%eax),%eax
 9b8:	89 45 fc             	mov    %eax,-0x4(%ebp)
 9bb:	8b 45 f8             	mov    -0x8(%ebp),%eax
 9be:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 9c1:	76 d4                	jbe    997 <free+0x19>
 9c3:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9c6:	8b 00                	mov    (%eax),%eax
 9c8:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 9cb:	73 ca                	jae    997 <free+0x19>
      break;
  if(bp + bp->s.size == p->s.ptr){
 9cd:	8b 45 f8             	mov    -0x8(%ebp),%eax
 9d0:	8b 40 04             	mov    0x4(%eax),%eax
 9d3:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 9da:	8b 45 f8             	mov    -0x8(%ebp),%eax
 9dd:	01 c2                	add    %eax,%edx
 9df:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9e2:	8b 00                	mov    (%eax),%eax
 9e4:	39 c2                	cmp    %eax,%edx
 9e6:	75 24                	jne    a0c <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 9e8:	8b 45 f8             	mov    -0x8(%ebp),%eax
 9eb:	8b 50 04             	mov    0x4(%eax),%edx
 9ee:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9f1:	8b 00                	mov    (%eax),%eax
 9f3:	8b 40 04             	mov    0x4(%eax),%eax
 9f6:	01 c2                	add    %eax,%edx
 9f8:	8b 45 f8             	mov    -0x8(%ebp),%eax
 9fb:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 9fe:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a01:	8b 00                	mov    (%eax),%eax
 a03:	8b 10                	mov    (%eax),%edx
 a05:	8b 45 f8             	mov    -0x8(%ebp),%eax
 a08:	89 10                	mov    %edx,(%eax)
 a0a:	eb 0a                	jmp    a16 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 a0c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a0f:	8b 10                	mov    (%eax),%edx
 a11:	8b 45 f8             	mov    -0x8(%ebp),%eax
 a14:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 a16:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a19:	8b 40 04             	mov    0x4(%eax),%eax
 a1c:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 a23:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a26:	01 d0                	add    %edx,%eax
 a28:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 a2b:	75 20                	jne    a4d <free+0xcf>
    p->s.size += bp->s.size;
 a2d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a30:	8b 50 04             	mov    0x4(%eax),%edx
 a33:	8b 45 f8             	mov    -0x8(%ebp),%eax
 a36:	8b 40 04             	mov    0x4(%eax),%eax
 a39:	01 c2                	add    %eax,%edx
 a3b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a3e:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 a41:	8b 45 f8             	mov    -0x8(%ebp),%eax
 a44:	8b 10                	mov    (%eax),%edx
 a46:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a49:	89 10                	mov    %edx,(%eax)
 a4b:	eb 08                	jmp    a55 <free+0xd7>
  } else
    p->s.ptr = bp;
 a4d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a50:	8b 55 f8             	mov    -0x8(%ebp),%edx
 a53:	89 10                	mov    %edx,(%eax)
  freep = p;
 a55:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a58:	a3 2c 90 00 00       	mov    %eax,0x902c
}
 a5d:	90                   	nop
 a5e:	c9                   	leave  
 a5f:	c3                   	ret    

00000a60 <morecore>:

static Header*
morecore(uint nu)
{
 a60:	55                   	push   %ebp
 a61:	89 e5                	mov    %esp,%ebp
 a63:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 a66:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 a6d:	77 07                	ja     a76 <morecore+0x16>
    nu = 4096;
 a6f:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 a76:	8b 45 08             	mov    0x8(%ebp),%eax
 a79:	c1 e0 03             	shl    $0x3,%eax
 a7c:	83 ec 0c             	sub    $0xc,%esp
 a7f:	50                   	push   %eax
 a80:	e8 6b fc ff ff       	call   6f0 <sbrk>
 a85:	83 c4 10             	add    $0x10,%esp
 a88:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 a8b:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 a8f:	75 07                	jne    a98 <morecore+0x38>
    return 0;
 a91:	b8 00 00 00 00       	mov    $0x0,%eax
 a96:	eb 26                	jmp    abe <morecore+0x5e>
  hp = (Header*)p;
 a98:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a9b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 a9e:	8b 45 f0             	mov    -0x10(%ebp),%eax
 aa1:	8b 55 08             	mov    0x8(%ebp),%edx
 aa4:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 aa7:	8b 45 f0             	mov    -0x10(%ebp),%eax
 aaa:	83 c0 08             	add    $0x8,%eax
 aad:	83 ec 0c             	sub    $0xc,%esp
 ab0:	50                   	push   %eax
 ab1:	e8 c8 fe ff ff       	call   97e <free>
 ab6:	83 c4 10             	add    $0x10,%esp
  return freep;
 ab9:	a1 2c 90 00 00       	mov    0x902c,%eax
}
 abe:	c9                   	leave  
 abf:	c3                   	ret    

00000ac0 <malloc>:

void*
malloc(uint nbytes)
{
 ac0:	55                   	push   %ebp
 ac1:	89 e5                	mov    %esp,%ebp
 ac3:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 ac6:	8b 45 08             	mov    0x8(%ebp),%eax
 ac9:	83 c0 07             	add    $0x7,%eax
 acc:	c1 e8 03             	shr    $0x3,%eax
 acf:	83 c0 01             	add    $0x1,%eax
 ad2:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 ad5:	a1 2c 90 00 00       	mov    0x902c,%eax
 ada:	89 45 f0             	mov    %eax,-0x10(%ebp)
 add:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 ae1:	75 23                	jne    b06 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 ae3:	c7 45 f0 24 90 00 00 	movl   $0x9024,-0x10(%ebp)
 aea:	8b 45 f0             	mov    -0x10(%ebp),%eax
 aed:	a3 2c 90 00 00       	mov    %eax,0x902c
 af2:	a1 2c 90 00 00       	mov    0x902c,%eax
 af7:	a3 24 90 00 00       	mov    %eax,0x9024
    base.s.size = 0;
 afc:	c7 05 28 90 00 00 00 	movl   $0x0,0x9028
 b03:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 b06:	8b 45 f0             	mov    -0x10(%ebp),%eax
 b09:	8b 00                	mov    (%eax),%eax
 b0b:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 b0e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b11:	8b 40 04             	mov    0x4(%eax),%eax
 b14:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 b17:	77 4d                	ja     b66 <malloc+0xa6>
      if(p->s.size == nunits)
 b19:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b1c:	8b 40 04             	mov    0x4(%eax),%eax
 b1f:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 b22:	75 0c                	jne    b30 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 b24:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b27:	8b 10                	mov    (%eax),%edx
 b29:	8b 45 f0             	mov    -0x10(%ebp),%eax
 b2c:	89 10                	mov    %edx,(%eax)
 b2e:	eb 26                	jmp    b56 <malloc+0x96>
      else {
        p->s.size -= nunits;
 b30:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b33:	8b 40 04             	mov    0x4(%eax),%eax
 b36:	2b 45 ec             	sub    -0x14(%ebp),%eax
 b39:	89 c2                	mov    %eax,%edx
 b3b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b3e:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 b41:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b44:	8b 40 04             	mov    0x4(%eax),%eax
 b47:	c1 e0 03             	shl    $0x3,%eax
 b4a:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 b4d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b50:	8b 55 ec             	mov    -0x14(%ebp),%edx
 b53:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 b56:	8b 45 f0             	mov    -0x10(%ebp),%eax
 b59:	a3 2c 90 00 00       	mov    %eax,0x902c
      return (void*)(p + 1);
 b5e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b61:	83 c0 08             	add    $0x8,%eax
 b64:	eb 3b                	jmp    ba1 <malloc+0xe1>
    }
    if(p == freep)
 b66:	a1 2c 90 00 00       	mov    0x902c,%eax
 b6b:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 b6e:	75 1e                	jne    b8e <malloc+0xce>
      if((p = morecore(nunits)) == 0)
 b70:	83 ec 0c             	sub    $0xc,%esp
 b73:	ff 75 ec             	push   -0x14(%ebp)
 b76:	e8 e5 fe ff ff       	call   a60 <morecore>
 b7b:	83 c4 10             	add    $0x10,%esp
 b7e:	89 45 f4             	mov    %eax,-0xc(%ebp)
 b81:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 b85:	75 07                	jne    b8e <malloc+0xce>
        return 0;
 b87:	b8 00 00 00 00       	mov    $0x0,%eax
 b8c:	eb 13                	jmp    ba1 <malloc+0xe1>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 b8e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b91:	89 45 f0             	mov    %eax,-0x10(%ebp)
 b94:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b97:	8b 00                	mov    (%eax),%eax
 b99:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 b9c:	e9 6d ff ff ff       	jmp    b0e <malloc+0x4e>
  }
}
 ba1:	c9                   	leave  
 ba2:	c3                   	ret    
