
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
   6:	c7 05 00 0f 00 00 20 	movl   $0xf20,0xf00
   d:	0f 00 00 
  current_thread->state = RUNNING;
  10:	a1 00 0f 00 00       	mov    0xf00,%eax
  15:	c7 80 04 20 00 00 01 	movl   $0x1,0x2004(%eax)
  1c:	00 00 00 
  num_thread = 0;
  1f:	c7 05 40 8f 00 00 00 	movl   $0x0,0x8f40
  26:	00 00 00 
  thread_num(num_thread);
  29:	a1 40 8f 00 00       	mov    0x8f40,%eax
  2e:	83 ec 0c             	sub    $0xc,%esp
  31:	50                   	push   %eax
  32:	e8 52 06 00 00       	call   689 <thread_num>
  37:	83 c4 10             	add    $0x10,%esp
  uthread_init((uint)func);
  3a:	8b 45 08             	mov    0x8(%ebp),%eax
  3d:	83 ec 0c             	sub    $0xc,%esp
  40:	50                   	push   %eax
  41:	e8 3b 06 00 00       	call   681 <uthread_init>
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
  55:	68 1c 0b 00 00       	push   $0xb1c
  5a:	6a 01                	push   $0x1
  5c:	e8 04 07 00 00       	call   765 <printf>
  61:	83 c4 10             	add    $0x10,%esp
  //if(current_thread->state != FREE)
  //{
  //  current_thread->state = RUNNABLE;
  //  printf(1, "start 2\n");
  //}
  printf(1, "start 3\n");
  64:	83 ec 08             	sub    $0x8,%esp
  67:	68 25 0b 00 00       	push   $0xb25
  6c:	6a 01                	push   $0x1
  6e:	e8 f2 06 00 00       	call   765 <printf>
  73:	83 c4 10             	add    $0x10,%esp
  thread_p t;
  /* Find another runnable thread. */
  next_thread = 0;
  76:	c7 05 04 0f 00 00 00 	movl   $0x0,0xf04
  7d:	00 00 00 
  for (t = all_thread; t < all_thread + MAX_THREAD; t++)
  80:	c7 45 f4 20 0f 00 00 	movl   $0xf20,-0xc(%ebp)
  87:	eb 3b                	jmp    c4 <thread_schedule+0x78>
  {
    if (t->state == RUNNABLE && t != current_thread)
  89:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8c:	8b 80 04 20 00 00    	mov    0x2004(%eax),%eax
  92:	83 f8 02             	cmp    $0x2,%eax
  95:	75 26                	jne    bd <thread_schedule+0x71>
  97:	a1 00 0f 00 00       	mov    0xf00,%eax
  9c:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  9f:	74 1c                	je     bd <thread_schedule+0x71>
    {
      printf(1, "start 4\n");
  a1:	83 ec 08             	sub    $0x8,%esp
  a4:	68 2e 0b 00 00       	push   $0xb2e
  a9:	6a 01                	push   $0x1
  ab:	e8 b5 06 00 00       	call   765 <printf>
  b0:	83 c4 10             	add    $0x10,%esp
      next_thread = t;
  b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  b6:	a3 04 0f 00 00       	mov    %eax,0xf04
      break;
  bb:	eb 11                	jmp    ce <thread_schedule+0x82>
  for (t = all_thread; t < all_thread + MAX_THREAD; t++)
  bd:	81 45 f4 08 20 00 00 	addl   $0x2008,-0xc(%ebp)
  c4:	b8 40 8f 00 00       	mov    $0x8f40,%eax
  c9:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  cc:	72 bb                	jb     89 <thread_schedule+0x3d>
    }
  }
  printf(1, "start 5\n");
  ce:	83 ec 08             	sub    $0x8,%esp
  d1:	68 37 0b 00 00       	push   $0xb37
  d6:	6a 01                	push   $0x1
  d8:	e8 88 06 00 00       	call   765 <printf>
  dd:	83 c4 10             	add    $0x10,%esp
  if (t >= all_thread + MAX_THREAD && current_thread->state == RUNNABLE)
  e0:	b8 40 8f 00 00       	mov    $0x8f40,%eax
  e5:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  e8:	72 2c                	jb     116 <thread_schedule+0xca>
  ea:	a1 00 0f 00 00       	mov    0xf00,%eax
  ef:	8b 80 04 20 00 00    	mov    0x2004(%eax),%eax
  f5:	83 f8 02             	cmp    $0x2,%eax
  f8:	75 1c                	jne    116 <thread_schedule+0xca>
  {
    /* The current thread is the only runnable thread; run it. */
    next_thread = current_thread;
  fa:	a1 00 0f 00 00       	mov    0xf00,%eax
  ff:	a3 04 0f 00 00       	mov    %eax,0xf04
    printf(1, "start 6\n");
 104:	83 ec 08             	sub    $0x8,%esp
 107:	68 40 0b 00 00       	push   $0xb40
 10c:	6a 01                	push   $0x1
 10e:	e8 52 06 00 00       	call   765 <printf>
 113:	83 c4 10             	add    $0x10,%esp
  }
  printf(1, "start 7\n");
 116:	83 ec 08             	sub    $0x8,%esp
 119:	68 49 0b 00 00       	push   $0xb49
 11e:	6a 01                	push   $0x1
 120:	e8 40 06 00 00       	call   765 <printf>
 125:	83 c4 10             	add    $0x10,%esp
  if (next_thread == 0)
 128:	a1 04 0f 00 00       	mov    0xf04,%eax
 12d:	85 c0                	test   %eax,%eax
 12f:	75 29                	jne    15a <thread_schedule+0x10e>
  {
    printf(1, "start 8\n");
 131:	83 ec 08             	sub    $0x8,%esp
 134:	68 52 0b 00 00       	push   $0xb52
 139:	6a 01                	push   $0x1
 13b:	e8 25 06 00 00       	call   765 <printf>
 140:	83 c4 10             	add    $0x10,%esp
    printf(2, "thread_schedule: no runnable threads\n");
 143:	83 ec 08             	sub    $0x8,%esp
 146:	68 5c 0b 00 00       	push   $0xb5c
 14b:	6a 02                	push   $0x2
 14d:	e8 13 06 00 00       	call   765 <printf>
 152:	83 c4 10             	add    $0x10,%esp
    exit();
 155:	e8 87 04 00 00       	call   5e1 <exit>
  }
  printf(1, "start 9\n");
 15a:	83 ec 08             	sub    $0x8,%esp
 15d:	68 82 0b 00 00       	push   $0xb82
 162:	6a 01                	push   $0x1
 164:	e8 fc 05 00 00       	call   765 <printf>
 169:	83 c4 10             	add    $0x10,%esp
  if (current_thread != next_thread)
 16c:	8b 15 00 0f 00 00    	mov    0xf00,%edx
 172:	a1 04 0f 00 00       	mov    0xf04,%eax
 177:	39 c2                	cmp    %eax,%edx
 179:	74 3a                	je     1b5 <thread_schedule+0x169>
  { /* switch threads?  */
    next_thread->state = RUNNING;
 17b:	a1 04 0f 00 00       	mov    0xf04,%eax
 180:	c7 80 04 20 00 00 01 	movl   $0x1,0x2004(%eax)
 187:	00 00 00 
    printf(1, "start 10\n");
 18a:	83 ec 08             	sub    $0x8,%esp
 18d:	68 8b 0b 00 00       	push   $0xb8b
 192:	6a 01                	push   $0x1
 194:	e8 cc 05 00 00       	call   765 <printf>
 199:	83 c4 10             	add    $0x10,%esp
    thread_switch();
 19c:	e8 c9 01 00 00       	call   36a <thread_switch>
    printf(1, "start 11\n");
 1a1:	83 ec 08             	sub    $0x8,%esp
 1a4:	68 95 0b 00 00       	push   $0xb95
 1a9:	6a 01                	push   $0x1
 1ab:	e8 b5 05 00 00       	call   765 <printf>
 1b0:	83 c4 10             	add    $0x10,%esp
  }
  
  else
    next_thread = 0;
}
 1b3:	eb 0a                	jmp    1bf <thread_schedule+0x173>
    next_thread = 0;
 1b5:	c7 05 04 0f 00 00 00 	movl   $0x0,0xf04
 1bc:	00 00 00 
}
 1bf:	90                   	nop
 1c0:	c9                   	leave  
 1c1:	c3                   	ret    

000001c2 <thread_create>:

void thread_create(void (*func)())
{
 1c2:	55                   	push   %ebp
 1c3:	89 e5                	mov    %esp,%ebp
 1c5:	83 ec 18             	sub    $0x18,%esp
  thread_p t;
  num_thread++;
 1c8:	a1 40 8f 00 00       	mov    0x8f40,%eax
 1cd:	83 c0 01             	add    $0x1,%eax
 1d0:	a3 40 8f 00 00       	mov    %eax,0x8f40
  thread_num(num_thread);
 1d5:	a1 40 8f 00 00       	mov    0x8f40,%eax
 1da:	83 ec 0c             	sub    $0xc,%esp
 1dd:	50                   	push   %eax
 1de:	e8 a6 04 00 00       	call   689 <thread_num>
 1e3:	83 c4 10             	add    $0x10,%esp
  for (t = all_thread; t < all_thread + MAX_THREAD; t++)
 1e6:	c7 45 f4 20 0f 00 00 	movl   $0xf20,-0xc(%ebp)
 1ed:	eb 14                	jmp    203 <thread_create+0x41>
  {
    if (t->state == FREE)
 1ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1f2:	8b 80 04 20 00 00    	mov    0x2004(%eax),%eax
 1f8:	85 c0                	test   %eax,%eax
 1fa:	74 13                	je     20f <thread_create+0x4d>
  for (t = all_thread; t < all_thread + MAX_THREAD; t++)
 1fc:	81 45 f4 08 20 00 00 	addl   $0x2008,-0xc(%ebp)
 203:	b8 40 8f 00 00       	mov    $0x8f40,%eax
 208:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 20b:	72 e2                	jb     1ef <thread_create+0x2d>
 20d:	eb 01                	jmp    210 <thread_create+0x4e>
      break;
 20f:	90                   	nop
  }
  t->sp = (int)(t->stack + STACK_SIZE); // set sp to the top of the stack
 210:	8b 45 f4             	mov    -0xc(%ebp),%eax
 213:	83 c0 04             	add    $0x4,%eax
 216:	05 00 20 00 00       	add    $0x2000,%eax
 21b:	89 c2                	mov    %eax,%edx
 21d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 220:	89 10                	mov    %edx,(%eax)
  t->sp -= 4;                           // space for return address
 222:	8b 45 f4             	mov    -0xc(%ebp),%eax
 225:	8b 00                	mov    (%eax),%eax
 227:	8d 50 fc             	lea    -0x4(%eax),%edx
 22a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 22d:	89 10                	mov    %edx,(%eax)
  *(int *)(t->sp) = (int)func;          // push return address on stack
 22f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 232:	8b 00                	mov    (%eax),%eax
 234:	89 c2                	mov    %eax,%edx
 236:	8b 45 08             	mov    0x8(%ebp),%eax
 239:	89 02                	mov    %eax,(%edx)
  t->sp -= 32;                          // space for registers that thread_switch expects
 23b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 23e:	8b 00                	mov    (%eax),%eax
 240:	8d 50 e0             	lea    -0x20(%eax),%edx
 243:	8b 45 f4             	mov    -0xc(%ebp),%eax
 246:	89 10                	mov    %edx,(%eax)
  t->state = RUNNABLE;
 248:	8b 45 f4             	mov    -0xc(%ebp),%eax
 24b:	c7 80 04 20 00 00 02 	movl   $0x2,0x2004(%eax)
 252:	00 00 00 
  
}
 255:	90                   	nop
 256:	c9                   	leave  
 257:	c3                   	ret    

00000258 <thread_yield>:

void thread_yield(void)
{
 258:	55                   	push   %ebp
 259:	89 e5                	mov    %esp,%ebp
 25b:	83 ec 08             	sub    $0x8,%esp
  current_thread->state = RUNNABLE;
 25e:	a1 00 0f 00 00       	mov    0xf00,%eax
 263:	c7 80 04 20 00 00 02 	movl   $0x2,0x2004(%eax)
 26a:	00 00 00 
  thread_schedule();
 26d:	e8 da fd ff ff       	call   4c <thread_schedule>
}
 272:	90                   	nop
 273:	c9                   	leave  
 274:	c3                   	ret    

00000275 <mythread>:

static void
mythread(void)
{
 275:	55                   	push   %ebp
 276:	89 e5                	mov    %esp,%ebp
 278:	83 ec 18             	sub    $0x18,%esp
  int i;
  printf(1, "my thread running\n");
 27b:	83 ec 08             	sub    $0x8,%esp
 27e:	68 9f 0b 00 00       	push   $0xb9f
 283:	6a 01                	push   $0x1
 285:	e8 db 04 00 00       	call   765 <printf>
 28a:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < 100; i++)
 28d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 294:	eb 1c                	jmp    2b2 <mythread+0x3d>
  {
    printf(1, "%d my thread 0x%x\n", i, (int)current_thread);
 296:	a1 00 0f 00 00       	mov    0xf00,%eax
 29b:	50                   	push   %eax
 29c:	ff 75 f4             	push   -0xc(%ebp)
 29f:	68 b2 0b 00 00       	push   $0xbb2
 2a4:	6a 01                	push   $0x1
 2a6:	e8 ba 04 00 00       	call   765 <printf>
 2ab:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < 100; i++)
 2ae:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 2b2:	83 7d f4 63          	cmpl   $0x63,-0xc(%ebp)
 2b6:	7e de                	jle    296 <mythread+0x21>
    // thread_yield();
  }
  printf(1, "my thread: exit\n");
 2b8:	83 ec 08             	sub    $0x8,%esp
 2bb:	68 c5 0b 00 00       	push   $0xbc5
 2c0:	6a 01                	push   $0x1
 2c2:	e8 9e 04 00 00       	call   765 <printf>
 2c7:	83 c4 10             	add    $0x10,%esp
  current_thread->state = FREE;
 2ca:	a1 00 0f 00 00       	mov    0xf00,%eax
 2cf:	c7 80 04 20 00 00 00 	movl   $0x0,0x2004(%eax)
 2d6:	00 00 00 
  num_thread--;
 2d9:	a1 40 8f 00 00       	mov    0x8f40,%eax
 2de:	83 e8 01             	sub    $0x1,%eax
 2e1:	a3 40 8f 00 00       	mov    %eax,0x8f40
  thread_num(num_thread);
 2e6:	a1 40 8f 00 00       	mov    0x8f40,%eax
 2eb:	83 ec 0c             	sub    $0xc,%esp
 2ee:	50                   	push   %eax
 2ef:	e8 95 03 00 00       	call   689 <thread_num>
 2f4:	83 c4 10             	add    $0x10,%esp
  thread_schedule();
 2f7:	e8 50 fd ff ff       	call   4c <thread_schedule>
}
 2fc:	90                   	nop
 2fd:	c9                   	leave  
 2fe:	c3                   	ret    

000002ff <main>:

int main(int argc, char *argv[])
{
 2ff:	8d 4c 24 04          	lea    0x4(%esp),%ecx
 303:	83 e4 f0             	and    $0xfffffff0,%esp
 306:	ff 71 fc             	push   -0x4(%ecx)
 309:	55                   	push   %ebp
 30a:	89 e5                	mov    %esp,%ebp
 30c:	51                   	push   %ecx
 30d:	83 ec 04             	sub    $0x4,%esp
  printf(1, "addr : %d", (uint)thread_schedule);
 310:	b8 4c 00 00 00       	mov    $0x4c,%eax
 315:	83 ec 04             	sub    $0x4,%esp
 318:	50                   	push   %eax
 319:	68 d6 0b 00 00       	push   $0xbd6
 31e:	6a 01                	push   $0x1
 320:	e8 40 04 00 00       	call   765 <printf>
 325:	83 c4 10             	add    $0x10,%esp
  thread_init(thread_schedule);
 328:	83 ec 0c             	sub    $0xc,%esp
 32b:	68 4c 00 00 00       	push   $0x4c
 330:	e8 cb fc ff ff       	call   0 <thread_init>
 335:	83 c4 10             	add    $0x10,%esp
  thread_create(mythread);
 338:	83 ec 0c             	sub    $0xc,%esp
 33b:	68 75 02 00 00       	push   $0x275
 340:	e8 7d fe ff ff       	call   1c2 <thread_create>
 345:	83 c4 10             	add    $0x10,%esp
  thread_create(mythread);
 348:	83 ec 0c             	sub    $0xc,%esp
 34b:	68 75 02 00 00       	push   $0x275
 350:	e8 6d fe ff ff       	call   1c2 <thread_create>
 355:	83 c4 10             	add    $0x10,%esp
  thread_schedule();
 358:	e8 ef fc ff ff       	call   4c <thread_schedule>
  return 0;
 35d:	b8 00 00 00 00       	mov    $0x0,%eax
 362:	8b 4d fc             	mov    -0x4(%ebp),%ecx
 365:	c9                   	leave  
 366:	8d 61 fc             	lea    -0x4(%ecx),%esp
 369:	c3                   	ret    

0000036a <thread_switch>:
         */

   .globl thread_switch
thread_switch:
   /* YOUR CODE HERE */
   pushal
 36a:	60                   	pusha  

   movl current_thread, %eax
 36b:	a1 00 0f 00 00       	mov    0xf00,%eax
   movl %esp, (%eax)
 370:	89 20                	mov    %esp,(%eax)

   movl next_thread, %eax
 372:	a1 04 0f 00 00       	mov    0xf04,%eax
   movl (%eax), %esp
 377:	8b 20                	mov    (%eax),%esp

   movl %eax, current_thread
 379:	a3 00 0f 00 00       	mov    %eax,0xf00

   popal
 37e:	61                   	popa   

   movl $0, next_thread
 37f:	c7 05 04 0f 00 00 00 	movl   $0x0,0xf04
 386:	00 00 00 


 389:	c3                   	ret    

0000038a <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 38a:	55                   	push   %ebp
 38b:	89 e5                	mov    %esp,%ebp
 38d:	57                   	push   %edi
 38e:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 38f:	8b 4d 08             	mov    0x8(%ebp),%ecx
 392:	8b 55 10             	mov    0x10(%ebp),%edx
 395:	8b 45 0c             	mov    0xc(%ebp),%eax
 398:	89 cb                	mov    %ecx,%ebx
 39a:	89 df                	mov    %ebx,%edi
 39c:	89 d1                	mov    %edx,%ecx
 39e:	fc                   	cld    
 39f:	f3 aa                	rep stos %al,%es:(%edi)
 3a1:	89 ca                	mov    %ecx,%edx
 3a3:	89 fb                	mov    %edi,%ebx
 3a5:	89 5d 08             	mov    %ebx,0x8(%ebp)
 3a8:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 3ab:	90                   	nop
 3ac:	5b                   	pop    %ebx
 3ad:	5f                   	pop    %edi
 3ae:	5d                   	pop    %ebp
 3af:	c3                   	ret    

000003b0 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 3b0:	55                   	push   %ebp
 3b1:	89 e5                	mov    %esp,%ebp
 3b3:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 3b6:	8b 45 08             	mov    0x8(%ebp),%eax
 3b9:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 3bc:	90                   	nop
 3bd:	8b 55 0c             	mov    0xc(%ebp),%edx
 3c0:	8d 42 01             	lea    0x1(%edx),%eax
 3c3:	89 45 0c             	mov    %eax,0xc(%ebp)
 3c6:	8b 45 08             	mov    0x8(%ebp),%eax
 3c9:	8d 48 01             	lea    0x1(%eax),%ecx
 3cc:	89 4d 08             	mov    %ecx,0x8(%ebp)
 3cf:	0f b6 12             	movzbl (%edx),%edx
 3d2:	88 10                	mov    %dl,(%eax)
 3d4:	0f b6 00             	movzbl (%eax),%eax
 3d7:	84 c0                	test   %al,%al
 3d9:	75 e2                	jne    3bd <strcpy+0xd>
    ;
  return os;
 3db:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 3de:	c9                   	leave  
 3df:	c3                   	ret    

000003e0 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 3e0:	55                   	push   %ebp
 3e1:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 3e3:	eb 08                	jmp    3ed <strcmp+0xd>
    p++, q++;
 3e5:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 3e9:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(*p && *p == *q)
 3ed:	8b 45 08             	mov    0x8(%ebp),%eax
 3f0:	0f b6 00             	movzbl (%eax),%eax
 3f3:	84 c0                	test   %al,%al
 3f5:	74 10                	je     407 <strcmp+0x27>
 3f7:	8b 45 08             	mov    0x8(%ebp),%eax
 3fa:	0f b6 10             	movzbl (%eax),%edx
 3fd:	8b 45 0c             	mov    0xc(%ebp),%eax
 400:	0f b6 00             	movzbl (%eax),%eax
 403:	38 c2                	cmp    %al,%dl
 405:	74 de                	je     3e5 <strcmp+0x5>
  return (uchar)*p - (uchar)*q;
 407:	8b 45 08             	mov    0x8(%ebp),%eax
 40a:	0f b6 00             	movzbl (%eax),%eax
 40d:	0f b6 d0             	movzbl %al,%edx
 410:	8b 45 0c             	mov    0xc(%ebp),%eax
 413:	0f b6 00             	movzbl (%eax),%eax
 416:	0f b6 c8             	movzbl %al,%ecx
 419:	89 d0                	mov    %edx,%eax
 41b:	29 c8                	sub    %ecx,%eax
}
 41d:	5d                   	pop    %ebp
 41e:	c3                   	ret    

0000041f <strlen>:

uint
strlen(char *s)
{
 41f:	55                   	push   %ebp
 420:	89 e5                	mov    %esp,%ebp
 422:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 425:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 42c:	eb 04                	jmp    432 <strlen+0x13>
 42e:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 432:	8b 55 fc             	mov    -0x4(%ebp),%edx
 435:	8b 45 08             	mov    0x8(%ebp),%eax
 438:	01 d0                	add    %edx,%eax
 43a:	0f b6 00             	movzbl (%eax),%eax
 43d:	84 c0                	test   %al,%al
 43f:	75 ed                	jne    42e <strlen+0xf>
    ;
  return n;
 441:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 444:	c9                   	leave  
 445:	c3                   	ret    

00000446 <memset>:

void*
memset(void *dst, int c, uint n)
{
 446:	55                   	push   %ebp
 447:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
 449:	8b 45 10             	mov    0x10(%ebp),%eax
 44c:	50                   	push   %eax
 44d:	ff 75 0c             	push   0xc(%ebp)
 450:	ff 75 08             	push   0x8(%ebp)
 453:	e8 32 ff ff ff       	call   38a <stosb>
 458:	83 c4 0c             	add    $0xc,%esp
  return dst;
 45b:	8b 45 08             	mov    0x8(%ebp),%eax
}
 45e:	c9                   	leave  
 45f:	c3                   	ret    

00000460 <strchr>:

char*
strchr(const char *s, char c)
{
 460:	55                   	push   %ebp
 461:	89 e5                	mov    %esp,%ebp
 463:	83 ec 04             	sub    $0x4,%esp
 466:	8b 45 0c             	mov    0xc(%ebp),%eax
 469:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 46c:	eb 14                	jmp    482 <strchr+0x22>
    if(*s == c)
 46e:	8b 45 08             	mov    0x8(%ebp),%eax
 471:	0f b6 00             	movzbl (%eax),%eax
 474:	38 45 fc             	cmp    %al,-0x4(%ebp)
 477:	75 05                	jne    47e <strchr+0x1e>
      return (char*)s;
 479:	8b 45 08             	mov    0x8(%ebp),%eax
 47c:	eb 13                	jmp    491 <strchr+0x31>
  for(; *s; s++)
 47e:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 482:	8b 45 08             	mov    0x8(%ebp),%eax
 485:	0f b6 00             	movzbl (%eax),%eax
 488:	84 c0                	test   %al,%al
 48a:	75 e2                	jne    46e <strchr+0xe>
  return 0;
 48c:	b8 00 00 00 00       	mov    $0x0,%eax
}
 491:	c9                   	leave  
 492:	c3                   	ret    

00000493 <gets>:

char*
gets(char *buf, int max)
{
 493:	55                   	push   %ebp
 494:	89 e5                	mov    %esp,%ebp
 496:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 499:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 4a0:	eb 42                	jmp    4e4 <gets+0x51>
    cc = read(0, &c, 1);
 4a2:	83 ec 04             	sub    $0x4,%esp
 4a5:	6a 01                	push   $0x1
 4a7:	8d 45 ef             	lea    -0x11(%ebp),%eax
 4aa:	50                   	push   %eax
 4ab:	6a 00                	push   $0x0
 4ad:	e8 47 01 00 00       	call   5f9 <read>
 4b2:	83 c4 10             	add    $0x10,%esp
 4b5:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 4b8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 4bc:	7e 33                	jle    4f1 <gets+0x5e>
      break;
    buf[i++] = c;
 4be:	8b 45 f4             	mov    -0xc(%ebp),%eax
 4c1:	8d 50 01             	lea    0x1(%eax),%edx
 4c4:	89 55 f4             	mov    %edx,-0xc(%ebp)
 4c7:	89 c2                	mov    %eax,%edx
 4c9:	8b 45 08             	mov    0x8(%ebp),%eax
 4cc:	01 c2                	add    %eax,%edx
 4ce:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 4d2:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 4d4:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 4d8:	3c 0a                	cmp    $0xa,%al
 4da:	74 16                	je     4f2 <gets+0x5f>
 4dc:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 4e0:	3c 0d                	cmp    $0xd,%al
 4e2:	74 0e                	je     4f2 <gets+0x5f>
  for(i=0; i+1 < max; ){
 4e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 4e7:	83 c0 01             	add    $0x1,%eax
 4ea:	39 45 0c             	cmp    %eax,0xc(%ebp)
 4ed:	7f b3                	jg     4a2 <gets+0xf>
 4ef:	eb 01                	jmp    4f2 <gets+0x5f>
      break;
 4f1:	90                   	nop
      break;
  }
  buf[i] = '\0';
 4f2:	8b 55 f4             	mov    -0xc(%ebp),%edx
 4f5:	8b 45 08             	mov    0x8(%ebp),%eax
 4f8:	01 d0                	add    %edx,%eax
 4fa:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 4fd:	8b 45 08             	mov    0x8(%ebp),%eax
}
 500:	c9                   	leave  
 501:	c3                   	ret    

00000502 <stat>:

int
stat(char *n, struct stat *st)
{
 502:	55                   	push   %ebp
 503:	89 e5                	mov    %esp,%ebp
 505:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 508:	83 ec 08             	sub    $0x8,%esp
 50b:	6a 00                	push   $0x0
 50d:	ff 75 08             	push   0x8(%ebp)
 510:	e8 0c 01 00 00       	call   621 <open>
 515:	83 c4 10             	add    $0x10,%esp
 518:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 51b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 51f:	79 07                	jns    528 <stat+0x26>
    return -1;
 521:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 526:	eb 25                	jmp    54d <stat+0x4b>
  r = fstat(fd, st);
 528:	83 ec 08             	sub    $0x8,%esp
 52b:	ff 75 0c             	push   0xc(%ebp)
 52e:	ff 75 f4             	push   -0xc(%ebp)
 531:	e8 03 01 00 00       	call   639 <fstat>
 536:	83 c4 10             	add    $0x10,%esp
 539:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 53c:	83 ec 0c             	sub    $0xc,%esp
 53f:	ff 75 f4             	push   -0xc(%ebp)
 542:	e8 c2 00 00 00       	call   609 <close>
 547:	83 c4 10             	add    $0x10,%esp
  return r;
 54a:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 54d:	c9                   	leave  
 54e:	c3                   	ret    

0000054f <atoi>:

int
atoi(const char *s)
{
 54f:	55                   	push   %ebp
 550:	89 e5                	mov    %esp,%ebp
 552:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 555:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 55c:	eb 25                	jmp    583 <atoi+0x34>
    n = n*10 + *s++ - '0';
 55e:	8b 55 fc             	mov    -0x4(%ebp),%edx
 561:	89 d0                	mov    %edx,%eax
 563:	c1 e0 02             	shl    $0x2,%eax
 566:	01 d0                	add    %edx,%eax
 568:	01 c0                	add    %eax,%eax
 56a:	89 c1                	mov    %eax,%ecx
 56c:	8b 45 08             	mov    0x8(%ebp),%eax
 56f:	8d 50 01             	lea    0x1(%eax),%edx
 572:	89 55 08             	mov    %edx,0x8(%ebp)
 575:	0f b6 00             	movzbl (%eax),%eax
 578:	0f be c0             	movsbl %al,%eax
 57b:	01 c8                	add    %ecx,%eax
 57d:	83 e8 30             	sub    $0x30,%eax
 580:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 583:	8b 45 08             	mov    0x8(%ebp),%eax
 586:	0f b6 00             	movzbl (%eax),%eax
 589:	3c 2f                	cmp    $0x2f,%al
 58b:	7e 0a                	jle    597 <atoi+0x48>
 58d:	8b 45 08             	mov    0x8(%ebp),%eax
 590:	0f b6 00             	movzbl (%eax),%eax
 593:	3c 39                	cmp    $0x39,%al
 595:	7e c7                	jle    55e <atoi+0xf>
  return n;
 597:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 59a:	c9                   	leave  
 59b:	c3                   	ret    

0000059c <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 59c:	55                   	push   %ebp
 59d:	89 e5                	mov    %esp,%ebp
 59f:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;

  dst = vdst;
 5a2:	8b 45 08             	mov    0x8(%ebp),%eax
 5a5:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 5a8:	8b 45 0c             	mov    0xc(%ebp),%eax
 5ab:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 5ae:	eb 17                	jmp    5c7 <memmove+0x2b>
    *dst++ = *src++;
 5b0:	8b 55 f8             	mov    -0x8(%ebp),%edx
 5b3:	8d 42 01             	lea    0x1(%edx),%eax
 5b6:	89 45 f8             	mov    %eax,-0x8(%ebp)
 5b9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 5bc:	8d 48 01             	lea    0x1(%eax),%ecx
 5bf:	89 4d fc             	mov    %ecx,-0x4(%ebp)
 5c2:	0f b6 12             	movzbl (%edx),%edx
 5c5:	88 10                	mov    %dl,(%eax)
  while(n-- > 0)
 5c7:	8b 45 10             	mov    0x10(%ebp),%eax
 5ca:	8d 50 ff             	lea    -0x1(%eax),%edx
 5cd:	89 55 10             	mov    %edx,0x10(%ebp)
 5d0:	85 c0                	test   %eax,%eax
 5d2:	7f dc                	jg     5b0 <memmove+0x14>
  return vdst;
 5d4:	8b 45 08             	mov    0x8(%ebp),%eax
}
 5d7:	c9                   	leave  
 5d8:	c3                   	ret    

000005d9 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 5d9:	b8 01 00 00 00       	mov    $0x1,%eax
 5de:	cd 40                	int    $0x40
 5e0:	c3                   	ret    

000005e1 <exit>:
SYSCALL(exit)
 5e1:	b8 02 00 00 00       	mov    $0x2,%eax
 5e6:	cd 40                	int    $0x40
 5e8:	c3                   	ret    

000005e9 <wait>:
SYSCALL(wait)
 5e9:	b8 03 00 00 00       	mov    $0x3,%eax
 5ee:	cd 40                	int    $0x40
 5f0:	c3                   	ret    

000005f1 <pipe>:
SYSCALL(pipe)
 5f1:	b8 04 00 00 00       	mov    $0x4,%eax
 5f6:	cd 40                	int    $0x40
 5f8:	c3                   	ret    

000005f9 <read>:
SYSCALL(read)
 5f9:	b8 05 00 00 00       	mov    $0x5,%eax
 5fe:	cd 40                	int    $0x40
 600:	c3                   	ret    

00000601 <write>:
SYSCALL(write)
 601:	b8 10 00 00 00       	mov    $0x10,%eax
 606:	cd 40                	int    $0x40
 608:	c3                   	ret    

00000609 <close>:
SYSCALL(close)
 609:	b8 15 00 00 00       	mov    $0x15,%eax
 60e:	cd 40                	int    $0x40
 610:	c3                   	ret    

00000611 <kill>:
SYSCALL(kill)
 611:	b8 06 00 00 00       	mov    $0x6,%eax
 616:	cd 40                	int    $0x40
 618:	c3                   	ret    

00000619 <exec>:
SYSCALL(exec)
 619:	b8 07 00 00 00       	mov    $0x7,%eax
 61e:	cd 40                	int    $0x40
 620:	c3                   	ret    

00000621 <open>:
SYSCALL(open)
 621:	b8 0f 00 00 00       	mov    $0xf,%eax
 626:	cd 40                	int    $0x40
 628:	c3                   	ret    

00000629 <mknod>:
SYSCALL(mknod)
 629:	b8 11 00 00 00       	mov    $0x11,%eax
 62e:	cd 40                	int    $0x40
 630:	c3                   	ret    

00000631 <unlink>:
SYSCALL(unlink)
 631:	b8 12 00 00 00       	mov    $0x12,%eax
 636:	cd 40                	int    $0x40
 638:	c3                   	ret    

00000639 <fstat>:
SYSCALL(fstat)
 639:	b8 08 00 00 00       	mov    $0x8,%eax
 63e:	cd 40                	int    $0x40
 640:	c3                   	ret    

00000641 <link>:
SYSCALL(link)
 641:	b8 13 00 00 00       	mov    $0x13,%eax
 646:	cd 40                	int    $0x40
 648:	c3                   	ret    

00000649 <mkdir>:
SYSCALL(mkdir)
 649:	b8 14 00 00 00       	mov    $0x14,%eax
 64e:	cd 40                	int    $0x40
 650:	c3                   	ret    

00000651 <chdir>:
SYSCALL(chdir)
 651:	b8 09 00 00 00       	mov    $0x9,%eax
 656:	cd 40                	int    $0x40
 658:	c3                   	ret    

00000659 <dup>:
SYSCALL(dup)
 659:	b8 0a 00 00 00       	mov    $0xa,%eax
 65e:	cd 40                	int    $0x40
 660:	c3                   	ret    

00000661 <getpid>:
SYSCALL(getpid)
 661:	b8 0b 00 00 00       	mov    $0xb,%eax
 666:	cd 40                	int    $0x40
 668:	c3                   	ret    

00000669 <sbrk>:
SYSCALL(sbrk)
 669:	b8 0c 00 00 00       	mov    $0xc,%eax
 66e:	cd 40                	int    $0x40
 670:	c3                   	ret    

00000671 <sleep>:
SYSCALL(sleep)
 671:	b8 0d 00 00 00       	mov    $0xd,%eax
 676:	cd 40                	int    $0x40
 678:	c3                   	ret    

00000679 <uptime>:
SYSCALL(uptime)
 679:	b8 0e 00 00 00       	mov    $0xe,%eax
 67e:	cd 40                	int    $0x40
 680:	c3                   	ret    

00000681 <uthread_init>:
SYSCALL(uthread_init)
 681:	b8 16 00 00 00       	mov    $0x16,%eax
 686:	cd 40                	int    $0x40
 688:	c3                   	ret    

00000689 <thread_num>:
 689:	b8 17 00 00 00       	mov    $0x17,%eax
 68e:	cd 40                	int    $0x40
 690:	c3                   	ret    

00000691 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 691:	55                   	push   %ebp
 692:	89 e5                	mov    %esp,%ebp
 694:	83 ec 18             	sub    $0x18,%esp
 697:	8b 45 0c             	mov    0xc(%ebp),%eax
 69a:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 69d:	83 ec 04             	sub    $0x4,%esp
 6a0:	6a 01                	push   $0x1
 6a2:	8d 45 f4             	lea    -0xc(%ebp),%eax
 6a5:	50                   	push   %eax
 6a6:	ff 75 08             	push   0x8(%ebp)
 6a9:	e8 53 ff ff ff       	call   601 <write>
 6ae:	83 c4 10             	add    $0x10,%esp
}
 6b1:	90                   	nop
 6b2:	c9                   	leave  
 6b3:	c3                   	ret    

000006b4 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 6b4:	55                   	push   %ebp
 6b5:	89 e5                	mov    %esp,%ebp
 6b7:	83 ec 28             	sub    $0x28,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 6ba:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 6c1:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 6c5:	74 17                	je     6de <printint+0x2a>
 6c7:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 6cb:	79 11                	jns    6de <printint+0x2a>
    neg = 1;
 6cd:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 6d4:	8b 45 0c             	mov    0xc(%ebp),%eax
 6d7:	f7 d8                	neg    %eax
 6d9:	89 45 ec             	mov    %eax,-0x14(%ebp)
 6dc:	eb 06                	jmp    6e4 <printint+0x30>
  } else {
    x = xx;
 6de:	8b 45 0c             	mov    0xc(%ebp),%eax
 6e1:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 6e4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 6eb:	8b 4d 10             	mov    0x10(%ebp),%ecx
 6ee:	8b 45 ec             	mov    -0x14(%ebp),%eax
 6f1:	ba 00 00 00 00       	mov    $0x0,%edx
 6f6:	f7 f1                	div    %ecx
 6f8:	89 d1                	mov    %edx,%ecx
 6fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
 6fd:	8d 50 01             	lea    0x1(%eax),%edx
 700:	89 55 f4             	mov    %edx,-0xc(%ebp)
 703:	0f b6 91 d4 0e 00 00 	movzbl 0xed4(%ecx),%edx
 70a:	88 54 05 dc          	mov    %dl,-0x24(%ebp,%eax,1)
  }while((x /= base) != 0);
 70e:	8b 4d 10             	mov    0x10(%ebp),%ecx
 711:	8b 45 ec             	mov    -0x14(%ebp),%eax
 714:	ba 00 00 00 00       	mov    $0x0,%edx
 719:	f7 f1                	div    %ecx
 71b:	89 45 ec             	mov    %eax,-0x14(%ebp)
 71e:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 722:	75 c7                	jne    6eb <printint+0x37>
  if(neg)
 724:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 728:	74 2d                	je     757 <printint+0xa3>
    buf[i++] = '-';
 72a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 72d:	8d 50 01             	lea    0x1(%eax),%edx
 730:	89 55 f4             	mov    %edx,-0xc(%ebp)
 733:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 738:	eb 1d                	jmp    757 <printint+0xa3>
    putc(fd, buf[i]);
 73a:	8d 55 dc             	lea    -0x24(%ebp),%edx
 73d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 740:	01 d0                	add    %edx,%eax
 742:	0f b6 00             	movzbl (%eax),%eax
 745:	0f be c0             	movsbl %al,%eax
 748:	83 ec 08             	sub    $0x8,%esp
 74b:	50                   	push   %eax
 74c:	ff 75 08             	push   0x8(%ebp)
 74f:	e8 3d ff ff ff       	call   691 <putc>
 754:	83 c4 10             	add    $0x10,%esp
  while(--i >= 0)
 757:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 75b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 75f:	79 d9                	jns    73a <printint+0x86>
}
 761:	90                   	nop
 762:	90                   	nop
 763:	c9                   	leave  
 764:	c3                   	ret    

00000765 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 765:	55                   	push   %ebp
 766:	89 e5                	mov    %esp,%ebp
 768:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 76b:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 772:	8d 45 0c             	lea    0xc(%ebp),%eax
 775:	83 c0 04             	add    $0x4,%eax
 778:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 77b:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 782:	e9 59 01 00 00       	jmp    8e0 <printf+0x17b>
    c = fmt[i] & 0xff;
 787:	8b 55 0c             	mov    0xc(%ebp),%edx
 78a:	8b 45 f0             	mov    -0x10(%ebp),%eax
 78d:	01 d0                	add    %edx,%eax
 78f:	0f b6 00             	movzbl (%eax),%eax
 792:	0f be c0             	movsbl %al,%eax
 795:	25 ff 00 00 00       	and    $0xff,%eax
 79a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 79d:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 7a1:	75 2c                	jne    7cf <printf+0x6a>
      if(c == '%'){
 7a3:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 7a7:	75 0c                	jne    7b5 <printf+0x50>
        state = '%';
 7a9:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 7b0:	e9 27 01 00 00       	jmp    8dc <printf+0x177>
      } else {
        putc(fd, c);
 7b5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 7b8:	0f be c0             	movsbl %al,%eax
 7bb:	83 ec 08             	sub    $0x8,%esp
 7be:	50                   	push   %eax
 7bf:	ff 75 08             	push   0x8(%ebp)
 7c2:	e8 ca fe ff ff       	call   691 <putc>
 7c7:	83 c4 10             	add    $0x10,%esp
 7ca:	e9 0d 01 00 00       	jmp    8dc <printf+0x177>
      }
    } else if(state == '%'){
 7cf:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 7d3:	0f 85 03 01 00 00    	jne    8dc <printf+0x177>
      if(c == 'd'){
 7d9:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 7dd:	75 1e                	jne    7fd <printf+0x98>
        printint(fd, *ap, 10, 1);
 7df:	8b 45 e8             	mov    -0x18(%ebp),%eax
 7e2:	8b 00                	mov    (%eax),%eax
 7e4:	6a 01                	push   $0x1
 7e6:	6a 0a                	push   $0xa
 7e8:	50                   	push   %eax
 7e9:	ff 75 08             	push   0x8(%ebp)
 7ec:	e8 c3 fe ff ff       	call   6b4 <printint>
 7f1:	83 c4 10             	add    $0x10,%esp
        ap++;
 7f4:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 7f8:	e9 d8 00 00 00       	jmp    8d5 <printf+0x170>
      } else if(c == 'x' || c == 'p'){
 7fd:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 801:	74 06                	je     809 <printf+0xa4>
 803:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 807:	75 1e                	jne    827 <printf+0xc2>
        printint(fd, *ap, 16, 0);
 809:	8b 45 e8             	mov    -0x18(%ebp),%eax
 80c:	8b 00                	mov    (%eax),%eax
 80e:	6a 00                	push   $0x0
 810:	6a 10                	push   $0x10
 812:	50                   	push   %eax
 813:	ff 75 08             	push   0x8(%ebp)
 816:	e8 99 fe ff ff       	call   6b4 <printint>
 81b:	83 c4 10             	add    $0x10,%esp
        ap++;
 81e:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 822:	e9 ae 00 00 00       	jmp    8d5 <printf+0x170>
      } else if(c == 's'){
 827:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 82b:	75 43                	jne    870 <printf+0x10b>
        s = (char*)*ap;
 82d:	8b 45 e8             	mov    -0x18(%ebp),%eax
 830:	8b 00                	mov    (%eax),%eax
 832:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 835:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 839:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 83d:	75 25                	jne    864 <printf+0xff>
          s = "(null)";
 83f:	c7 45 f4 e0 0b 00 00 	movl   $0xbe0,-0xc(%ebp)
        while(*s != 0){
 846:	eb 1c                	jmp    864 <printf+0xff>
          putc(fd, *s);
 848:	8b 45 f4             	mov    -0xc(%ebp),%eax
 84b:	0f b6 00             	movzbl (%eax),%eax
 84e:	0f be c0             	movsbl %al,%eax
 851:	83 ec 08             	sub    $0x8,%esp
 854:	50                   	push   %eax
 855:	ff 75 08             	push   0x8(%ebp)
 858:	e8 34 fe ff ff       	call   691 <putc>
 85d:	83 c4 10             	add    $0x10,%esp
          s++;
 860:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
        while(*s != 0){
 864:	8b 45 f4             	mov    -0xc(%ebp),%eax
 867:	0f b6 00             	movzbl (%eax),%eax
 86a:	84 c0                	test   %al,%al
 86c:	75 da                	jne    848 <printf+0xe3>
 86e:	eb 65                	jmp    8d5 <printf+0x170>
        }
      } else if(c == 'c'){
 870:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 874:	75 1d                	jne    893 <printf+0x12e>
        putc(fd, *ap);
 876:	8b 45 e8             	mov    -0x18(%ebp),%eax
 879:	8b 00                	mov    (%eax),%eax
 87b:	0f be c0             	movsbl %al,%eax
 87e:	83 ec 08             	sub    $0x8,%esp
 881:	50                   	push   %eax
 882:	ff 75 08             	push   0x8(%ebp)
 885:	e8 07 fe ff ff       	call   691 <putc>
 88a:	83 c4 10             	add    $0x10,%esp
        ap++;
 88d:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 891:	eb 42                	jmp    8d5 <printf+0x170>
      } else if(c == '%'){
 893:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 897:	75 17                	jne    8b0 <printf+0x14b>
        putc(fd, c);
 899:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 89c:	0f be c0             	movsbl %al,%eax
 89f:	83 ec 08             	sub    $0x8,%esp
 8a2:	50                   	push   %eax
 8a3:	ff 75 08             	push   0x8(%ebp)
 8a6:	e8 e6 fd ff ff       	call   691 <putc>
 8ab:	83 c4 10             	add    $0x10,%esp
 8ae:	eb 25                	jmp    8d5 <printf+0x170>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 8b0:	83 ec 08             	sub    $0x8,%esp
 8b3:	6a 25                	push   $0x25
 8b5:	ff 75 08             	push   0x8(%ebp)
 8b8:	e8 d4 fd ff ff       	call   691 <putc>
 8bd:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 8c0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 8c3:	0f be c0             	movsbl %al,%eax
 8c6:	83 ec 08             	sub    $0x8,%esp
 8c9:	50                   	push   %eax
 8ca:	ff 75 08             	push   0x8(%ebp)
 8cd:	e8 bf fd ff ff       	call   691 <putc>
 8d2:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 8d5:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(i = 0; fmt[i]; i++){
 8dc:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 8e0:	8b 55 0c             	mov    0xc(%ebp),%edx
 8e3:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8e6:	01 d0                	add    %edx,%eax
 8e8:	0f b6 00             	movzbl (%eax),%eax
 8eb:	84 c0                	test   %al,%al
 8ed:	0f 85 94 fe ff ff    	jne    787 <printf+0x22>
    }
  }
}
 8f3:	90                   	nop
 8f4:	90                   	nop
 8f5:	c9                   	leave  
 8f6:	c3                   	ret    

000008f7 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 8f7:	55                   	push   %ebp
 8f8:	89 e5                	mov    %esp,%ebp
 8fa:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 8fd:	8b 45 08             	mov    0x8(%ebp),%eax
 900:	83 e8 08             	sub    $0x8,%eax
 903:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 906:	a1 4c 8f 00 00       	mov    0x8f4c,%eax
 90b:	89 45 fc             	mov    %eax,-0x4(%ebp)
 90e:	eb 24                	jmp    934 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 910:	8b 45 fc             	mov    -0x4(%ebp),%eax
 913:	8b 00                	mov    (%eax),%eax
 915:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 918:	72 12                	jb     92c <free+0x35>
 91a:	8b 45 f8             	mov    -0x8(%ebp),%eax
 91d:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 920:	77 24                	ja     946 <free+0x4f>
 922:	8b 45 fc             	mov    -0x4(%ebp),%eax
 925:	8b 00                	mov    (%eax),%eax
 927:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 92a:	72 1a                	jb     946 <free+0x4f>
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 92c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 92f:	8b 00                	mov    (%eax),%eax
 931:	89 45 fc             	mov    %eax,-0x4(%ebp)
 934:	8b 45 f8             	mov    -0x8(%ebp),%eax
 937:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 93a:	76 d4                	jbe    910 <free+0x19>
 93c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 93f:	8b 00                	mov    (%eax),%eax
 941:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 944:	73 ca                	jae    910 <free+0x19>
      break;
  if(bp + bp->s.size == p->s.ptr){
 946:	8b 45 f8             	mov    -0x8(%ebp),%eax
 949:	8b 40 04             	mov    0x4(%eax),%eax
 94c:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 953:	8b 45 f8             	mov    -0x8(%ebp),%eax
 956:	01 c2                	add    %eax,%edx
 958:	8b 45 fc             	mov    -0x4(%ebp),%eax
 95b:	8b 00                	mov    (%eax),%eax
 95d:	39 c2                	cmp    %eax,%edx
 95f:	75 24                	jne    985 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 961:	8b 45 f8             	mov    -0x8(%ebp),%eax
 964:	8b 50 04             	mov    0x4(%eax),%edx
 967:	8b 45 fc             	mov    -0x4(%ebp),%eax
 96a:	8b 00                	mov    (%eax),%eax
 96c:	8b 40 04             	mov    0x4(%eax),%eax
 96f:	01 c2                	add    %eax,%edx
 971:	8b 45 f8             	mov    -0x8(%ebp),%eax
 974:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 977:	8b 45 fc             	mov    -0x4(%ebp),%eax
 97a:	8b 00                	mov    (%eax),%eax
 97c:	8b 10                	mov    (%eax),%edx
 97e:	8b 45 f8             	mov    -0x8(%ebp),%eax
 981:	89 10                	mov    %edx,(%eax)
 983:	eb 0a                	jmp    98f <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 985:	8b 45 fc             	mov    -0x4(%ebp),%eax
 988:	8b 10                	mov    (%eax),%edx
 98a:	8b 45 f8             	mov    -0x8(%ebp),%eax
 98d:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 98f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 992:	8b 40 04             	mov    0x4(%eax),%eax
 995:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 99c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 99f:	01 d0                	add    %edx,%eax
 9a1:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 9a4:	75 20                	jne    9c6 <free+0xcf>
    p->s.size += bp->s.size;
 9a6:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9a9:	8b 50 04             	mov    0x4(%eax),%edx
 9ac:	8b 45 f8             	mov    -0x8(%ebp),%eax
 9af:	8b 40 04             	mov    0x4(%eax),%eax
 9b2:	01 c2                	add    %eax,%edx
 9b4:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9b7:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 9ba:	8b 45 f8             	mov    -0x8(%ebp),%eax
 9bd:	8b 10                	mov    (%eax),%edx
 9bf:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9c2:	89 10                	mov    %edx,(%eax)
 9c4:	eb 08                	jmp    9ce <free+0xd7>
  } else
    p->s.ptr = bp;
 9c6:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9c9:	8b 55 f8             	mov    -0x8(%ebp),%edx
 9cc:	89 10                	mov    %edx,(%eax)
  freep = p;
 9ce:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9d1:	a3 4c 8f 00 00       	mov    %eax,0x8f4c
}
 9d6:	90                   	nop
 9d7:	c9                   	leave  
 9d8:	c3                   	ret    

000009d9 <morecore>:

static Header*
morecore(uint nu)
{
 9d9:	55                   	push   %ebp
 9da:	89 e5                	mov    %esp,%ebp
 9dc:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 9df:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 9e6:	77 07                	ja     9ef <morecore+0x16>
    nu = 4096;
 9e8:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 9ef:	8b 45 08             	mov    0x8(%ebp),%eax
 9f2:	c1 e0 03             	shl    $0x3,%eax
 9f5:	83 ec 0c             	sub    $0xc,%esp
 9f8:	50                   	push   %eax
 9f9:	e8 6b fc ff ff       	call   669 <sbrk>
 9fe:	83 c4 10             	add    $0x10,%esp
 a01:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 a04:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 a08:	75 07                	jne    a11 <morecore+0x38>
    return 0;
 a0a:	b8 00 00 00 00       	mov    $0x0,%eax
 a0f:	eb 26                	jmp    a37 <morecore+0x5e>
  hp = (Header*)p;
 a11:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a14:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 a17:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a1a:	8b 55 08             	mov    0x8(%ebp),%edx
 a1d:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 a20:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a23:	83 c0 08             	add    $0x8,%eax
 a26:	83 ec 0c             	sub    $0xc,%esp
 a29:	50                   	push   %eax
 a2a:	e8 c8 fe ff ff       	call   8f7 <free>
 a2f:	83 c4 10             	add    $0x10,%esp
  return freep;
 a32:	a1 4c 8f 00 00       	mov    0x8f4c,%eax
}
 a37:	c9                   	leave  
 a38:	c3                   	ret    

00000a39 <malloc>:

void*
malloc(uint nbytes)
{
 a39:	55                   	push   %ebp
 a3a:	89 e5                	mov    %esp,%ebp
 a3c:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 a3f:	8b 45 08             	mov    0x8(%ebp),%eax
 a42:	83 c0 07             	add    $0x7,%eax
 a45:	c1 e8 03             	shr    $0x3,%eax
 a48:	83 c0 01             	add    $0x1,%eax
 a4b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 a4e:	a1 4c 8f 00 00       	mov    0x8f4c,%eax
 a53:	89 45 f0             	mov    %eax,-0x10(%ebp)
 a56:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 a5a:	75 23                	jne    a7f <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 a5c:	c7 45 f0 44 8f 00 00 	movl   $0x8f44,-0x10(%ebp)
 a63:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a66:	a3 4c 8f 00 00       	mov    %eax,0x8f4c
 a6b:	a1 4c 8f 00 00       	mov    0x8f4c,%eax
 a70:	a3 44 8f 00 00       	mov    %eax,0x8f44
    base.s.size = 0;
 a75:	c7 05 48 8f 00 00 00 	movl   $0x0,0x8f48
 a7c:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a7f:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a82:	8b 00                	mov    (%eax),%eax
 a84:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 a87:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a8a:	8b 40 04             	mov    0x4(%eax),%eax
 a8d:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 a90:	77 4d                	ja     adf <malloc+0xa6>
      if(p->s.size == nunits)
 a92:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a95:	8b 40 04             	mov    0x4(%eax),%eax
 a98:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 a9b:	75 0c                	jne    aa9 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 a9d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 aa0:	8b 10                	mov    (%eax),%edx
 aa2:	8b 45 f0             	mov    -0x10(%ebp),%eax
 aa5:	89 10                	mov    %edx,(%eax)
 aa7:	eb 26                	jmp    acf <malloc+0x96>
      else {
        p->s.size -= nunits;
 aa9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 aac:	8b 40 04             	mov    0x4(%eax),%eax
 aaf:	2b 45 ec             	sub    -0x14(%ebp),%eax
 ab2:	89 c2                	mov    %eax,%edx
 ab4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 ab7:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 aba:	8b 45 f4             	mov    -0xc(%ebp),%eax
 abd:	8b 40 04             	mov    0x4(%eax),%eax
 ac0:	c1 e0 03             	shl    $0x3,%eax
 ac3:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 ac6:	8b 45 f4             	mov    -0xc(%ebp),%eax
 ac9:	8b 55 ec             	mov    -0x14(%ebp),%edx
 acc:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 acf:	8b 45 f0             	mov    -0x10(%ebp),%eax
 ad2:	a3 4c 8f 00 00       	mov    %eax,0x8f4c
      return (void*)(p + 1);
 ad7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 ada:	83 c0 08             	add    $0x8,%eax
 add:	eb 3b                	jmp    b1a <malloc+0xe1>
    }
    if(p == freep)
 adf:	a1 4c 8f 00 00       	mov    0x8f4c,%eax
 ae4:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 ae7:	75 1e                	jne    b07 <malloc+0xce>
      if((p = morecore(nunits)) == 0)
 ae9:	83 ec 0c             	sub    $0xc,%esp
 aec:	ff 75 ec             	push   -0x14(%ebp)
 aef:	e8 e5 fe ff ff       	call   9d9 <morecore>
 af4:	83 c4 10             	add    $0x10,%esp
 af7:	89 45 f4             	mov    %eax,-0xc(%ebp)
 afa:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 afe:	75 07                	jne    b07 <malloc+0xce>
        return 0;
 b00:	b8 00 00 00 00       	mov    $0x0,%eax
 b05:	eb 13                	jmp    b1a <malloc+0xe1>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 b07:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b0a:	89 45 f0             	mov    %eax,-0x10(%ebp)
 b0d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b10:	8b 00                	mov    (%eax),%eax
 b12:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 b15:	e9 6d ff ff ff       	jmp    a87 <malloc+0x4e>
  }
}
 b1a:	c9                   	leave  
 b1b:	c3                   	ret    
