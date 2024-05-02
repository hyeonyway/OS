
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
   6:	c7 05 e0 0d 00 00 00 	movl   $0xe00,0xde0
   d:	0e 00 00 
  current_thread->state = RUNNING;
  10:	a1 e0 0d 00 00       	mov    0xde0,%eax
  15:	c7 80 04 20 00 00 01 	movl   $0x1,0x2004(%eax)
  1c:	00 00 00 
  num_thread = 0;
  1f:	c7 05 20 8e 00 00 00 	movl   $0x0,0x8e20
  26:	00 00 00 
  thread_num(num_thread);
  29:	a1 20 8e 00 00       	mov    0x8e20,%eax
  2e:	83 ec 0c             	sub    $0xc,%esp
  31:	50                   	push   %eax
  32:	e8 b0 05 00 00       	call   5e7 <thread_num>
  37:	83 c4 10             	add    $0x10,%esp
  uthread_init((uint)func);
  3a:	8b 45 08             	mov    0x8(%ebp),%eax
  3d:	83 ec 0c             	sub    $0xc,%esp
  40:	50                   	push   %eax
  41:	e8 99 05 00 00       	call   5df <uthread_init>
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
  if (current_thread->state != FREE && current_thread != &all_thread[0])
  52:	a1 e0 0d 00 00       	mov    0xde0,%eax
  57:	8b 80 04 20 00 00    	mov    0x2004(%eax),%eax
  5d:	85 c0                	test   %eax,%eax
  5f:	74 1b                	je     7c <thread_schedule+0x30>
  61:	a1 e0 0d 00 00       	mov    0xde0,%eax
  66:	3d 00 0e 00 00       	cmp    $0xe00,%eax
  6b:	74 0f                	je     7c <thread_schedule+0x30>
  {
    current_thread->state = RUNNABLE;
  6d:	a1 e0 0d 00 00       	mov    0xde0,%eax
  72:	c7 80 04 20 00 00 02 	movl   $0x2,0x2004(%eax)
  79:	00 00 00 
  }
  thread_p t;
  /* Find another runnable thread. */
  next_thread = 0;
  7c:	c7 05 e4 0d 00 00 00 	movl   $0x0,0xde4
  83:	00 00 00 
  for (t = all_thread; t < all_thread + MAX_THREAD; t++)
  86:	c7 45 f4 00 0e 00 00 	movl   $0xe00,-0xc(%ebp)
  8d:	eb 29                	jmp    b8 <thread_schedule+0x6c>
  {
    if (t->state == RUNNABLE && t != current_thread)
  8f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  92:	8b 80 04 20 00 00    	mov    0x2004(%eax),%eax
  98:	83 f8 02             	cmp    $0x2,%eax
  9b:	75 14                	jne    b1 <thread_schedule+0x65>
  9d:	a1 e0 0d 00 00       	mov    0xde0,%eax
  a2:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  a5:	74 0a                	je     b1 <thread_schedule+0x65>
    {
      next_thread = t;
  a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  aa:	a3 e4 0d 00 00       	mov    %eax,0xde4
      break;
  af:	eb 11                	jmp    c2 <thread_schedule+0x76>
  for (t = all_thread; t < all_thread + MAX_THREAD; t++)
  b1:	81 45 f4 08 20 00 00 	addl   $0x2008,-0xc(%ebp)
  b8:	b8 20 8e 00 00       	mov    $0x8e20,%eax
  bd:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  c0:	72 cd                	jb     8f <thread_schedule+0x43>
    }
  }
  if (t >= all_thread + MAX_THREAD && current_thread->state == RUNNABLE)
  c2:	b8 20 8e 00 00       	mov    $0x8e20,%eax
  c7:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  ca:	72 1a                	jb     e6 <thread_schedule+0x9a>
  cc:	a1 e0 0d 00 00       	mov    0xde0,%eax
  d1:	8b 80 04 20 00 00    	mov    0x2004(%eax),%eax
  d7:	83 f8 02             	cmp    $0x2,%eax
  da:	75 0a                	jne    e6 <thread_schedule+0x9a>
  {
    /* The current thread is the only runnable thread; run it. */
    next_thread = current_thread;
  dc:	a1 e0 0d 00 00       	mov    0xde0,%eax
  e1:	a3 e4 0d 00 00       	mov    %eax,0xde4
  }
  if (next_thread == 0)
  e6:	a1 e4 0d 00 00       	mov    0xde4,%eax
  eb:	85 c0                	test   %eax,%eax
  ed:	75 17                	jne    106 <thread_schedule+0xba>
  {
    printf(2, "thread_schedule: no runnable threads\n");
  ef:	83 ec 08             	sub    $0x8,%esp
  f2:	68 7c 0a 00 00       	push   $0xa7c
  f7:	6a 02                	push   $0x2
  f9:	e8 c5 05 00 00       	call   6c3 <printf>
  fe:	83 c4 10             	add    $0x10,%esp
    exit();
 101:	e8 39 04 00 00       	call   53f <exit>
  }
  if (current_thread != next_thread)
 106:	8b 15 e0 0d 00 00    	mov    0xde0,%edx
 10c:	a1 e4 0d 00 00       	mov    0xde4,%eax
 111:	39 c2                	cmp    %eax,%edx
 113:	74 16                	je     12b <thread_schedule+0xdf>
  { /* switch threads?  */
    next_thread->state = RUNNING;
 115:	a1 e4 0d 00 00       	mov    0xde4,%eax
 11a:	c7 80 04 20 00 00 01 	movl   $0x1,0x2004(%eax)
 121:	00 00 00 
    thread_switch();
 124:	e8 9f 01 00 00       	call   2c8 <thread_switch>
  }

  else
    next_thread = 0;
}
 129:	eb 0a                	jmp    135 <thread_schedule+0xe9>
    next_thread = 0;
 12b:	c7 05 e4 0d 00 00 00 	movl   $0x0,0xde4
 132:	00 00 00 
}
 135:	90                   	nop
 136:	c9                   	leave  
 137:	c3                   	ret    

00000138 <thread_create>:

void thread_create(void (*func)())
{
 138:	55                   	push   %ebp
 139:	89 e5                	mov    %esp,%ebp
 13b:	83 ec 18             	sub    $0x18,%esp
  thread_p t;
  num_thread++;
 13e:	a1 20 8e 00 00       	mov    0x8e20,%eax
 143:	83 c0 01             	add    $0x1,%eax
 146:	a3 20 8e 00 00       	mov    %eax,0x8e20
  thread_num(num_thread);
 14b:	a1 20 8e 00 00       	mov    0x8e20,%eax
 150:	83 ec 0c             	sub    $0xc,%esp
 153:	50                   	push   %eax
 154:	e8 8e 04 00 00       	call   5e7 <thread_num>
 159:	83 c4 10             	add    $0x10,%esp
  for (t = all_thread; t < all_thread + MAX_THREAD; t++)
 15c:	c7 45 f4 00 0e 00 00 	movl   $0xe00,-0xc(%ebp)
 163:	eb 14                	jmp    179 <thread_create+0x41>
  {
    if (t->state == FREE)
 165:	8b 45 f4             	mov    -0xc(%ebp),%eax
 168:	8b 80 04 20 00 00    	mov    0x2004(%eax),%eax
 16e:	85 c0                	test   %eax,%eax
 170:	74 13                	je     185 <thread_create+0x4d>
  for (t = all_thread; t < all_thread + MAX_THREAD; t++)
 172:	81 45 f4 08 20 00 00 	addl   $0x2008,-0xc(%ebp)
 179:	b8 20 8e 00 00       	mov    $0x8e20,%eax
 17e:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 181:	72 e2                	jb     165 <thread_create+0x2d>
 183:	eb 01                	jmp    186 <thread_create+0x4e>
      break;
 185:	90                   	nop
  }
  t->sp = (int)(t->stack + STACK_SIZE); // set sp to the top of the stack
 186:	8b 45 f4             	mov    -0xc(%ebp),%eax
 189:	83 c0 04             	add    $0x4,%eax
 18c:	05 00 20 00 00       	add    $0x2000,%eax
 191:	89 c2                	mov    %eax,%edx
 193:	8b 45 f4             	mov    -0xc(%ebp),%eax
 196:	89 10                	mov    %edx,(%eax)
  t->sp -= 4;                           // space for return address
 198:	8b 45 f4             	mov    -0xc(%ebp),%eax
 19b:	8b 00                	mov    (%eax),%eax
 19d:	8d 50 fc             	lea    -0x4(%eax),%edx
 1a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1a3:	89 10                	mov    %edx,(%eax)
  *(int *)(t->sp) = (int)func;          // push return address on stack
 1a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1a8:	8b 00                	mov    (%eax),%eax
 1aa:	89 c2                	mov    %eax,%edx
 1ac:	8b 45 08             	mov    0x8(%ebp),%eax
 1af:	89 02                	mov    %eax,(%edx)
  t->sp -= 32;                          // space for registers that thread_switch expects
 1b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1b4:	8b 00                	mov    (%eax),%eax
 1b6:	8d 50 e0             	lea    -0x20(%eax),%edx
 1b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1bc:	89 10                	mov    %edx,(%eax)
  t->state = RUNNABLE;
 1be:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1c1:	c7 80 04 20 00 00 02 	movl   $0x2,0x2004(%eax)
 1c8:	00 00 00 
}
 1cb:	90                   	nop
 1cc:	c9                   	leave  
 1cd:	c3                   	ret    

000001ce <thread_yield>:

void thread_yield(void)
{
 1ce:	55                   	push   %ebp
 1cf:	89 e5                	mov    %esp,%ebp
 1d1:	83 ec 08             	sub    $0x8,%esp
  current_thread->state = RUNNABLE;
 1d4:	a1 e0 0d 00 00       	mov    0xde0,%eax
 1d9:	c7 80 04 20 00 00 02 	movl   $0x2,0x2004(%eax)
 1e0:	00 00 00 
  thread_schedule();
 1e3:	e8 64 fe ff ff       	call   4c <thread_schedule>
}
 1e8:	90                   	nop
 1e9:	c9                   	leave  
 1ea:	c3                   	ret    

000001eb <mythread>:

static void
mythread(void)
{
 1eb:	55                   	push   %ebp
 1ec:	89 e5                	mov    %esp,%ebp
 1ee:	83 ec 18             	sub    $0x18,%esp
  int i;
  printf(1, "my thread running\n");
 1f1:	83 ec 08             	sub    $0x8,%esp
 1f4:	68 a2 0a 00 00       	push   $0xaa2
 1f9:	6a 01                	push   $0x1
 1fb:	e8 c3 04 00 00       	call   6c3 <printf>
 200:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < 100; i++)
 203:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 20a:	eb 1c                	jmp    228 <mythread+0x3d>
  {
    printf(1, "my thread 0x%x\n", (int)current_thread);
 20c:	a1 e0 0d 00 00       	mov    0xde0,%eax
 211:	83 ec 04             	sub    $0x4,%esp
 214:	50                   	push   %eax
 215:	68 b5 0a 00 00       	push   $0xab5
 21a:	6a 01                	push   $0x1
 21c:	e8 a2 04 00 00       	call   6c3 <printf>
 221:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < 100; i++)
 224:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 228:	83 7d f4 63          	cmpl   $0x63,-0xc(%ebp)
 22c:	7e de                	jle    20c <mythread+0x21>
    // thread_yield();
  }
  printf(1, "my thread: exit\n");
 22e:	83 ec 08             	sub    $0x8,%esp
 231:	68 c5 0a 00 00       	push   $0xac5
 236:	6a 01                	push   $0x1
 238:	e8 86 04 00 00       	call   6c3 <printf>
 23d:	83 c4 10             	add    $0x10,%esp
  current_thread->state = FREE;
 240:	a1 e0 0d 00 00       	mov    0xde0,%eax
 245:	c7 80 04 20 00 00 00 	movl   $0x0,0x2004(%eax)
 24c:	00 00 00 
  num_thread--;
 24f:	a1 20 8e 00 00       	mov    0x8e20,%eax
 254:	83 e8 01             	sub    $0x1,%eax
 257:	a3 20 8e 00 00       	mov    %eax,0x8e20
  thread_num(num_thread);
 25c:	a1 20 8e 00 00       	mov    0x8e20,%eax
 261:	83 ec 0c             	sub    $0xc,%esp
 264:	50                   	push   %eax
 265:	e8 7d 03 00 00       	call   5e7 <thread_num>
 26a:	83 c4 10             	add    $0x10,%esp
  thread_schedule();
 26d:	e8 da fd ff ff       	call   4c <thread_schedule>
}
 272:	90                   	nop
 273:	c9                   	leave  
 274:	c3                   	ret    

00000275 <main>:

int main(int argc, char *argv[])
{
 275:	8d 4c 24 04          	lea    0x4(%esp),%ecx
 279:	83 e4 f0             	and    $0xfffffff0,%esp
 27c:	ff 71 fc             	push   -0x4(%ecx)
 27f:	55                   	push   %ebp
 280:	89 e5                	mov    %esp,%ebp
 282:	51                   	push   %ecx
 283:	83 ec 04             	sub    $0x4,%esp
  thread_init(thread_schedule);
 286:	83 ec 0c             	sub    $0xc,%esp
 289:	68 4c 00 00 00       	push   $0x4c
 28e:	e8 6d fd ff ff       	call   0 <thread_init>
 293:	83 c4 10             	add    $0x10,%esp
  thread_create(mythread);
 296:	83 ec 0c             	sub    $0xc,%esp
 299:	68 eb 01 00 00       	push   $0x1eb
 29e:	e8 95 fe ff ff       	call   138 <thread_create>
 2a3:	83 c4 10             	add    $0x10,%esp
  thread_create(mythread);
 2a6:	83 ec 0c             	sub    $0xc,%esp
 2a9:	68 eb 01 00 00       	push   $0x1eb
 2ae:	e8 85 fe ff ff       	call   138 <thread_create>
 2b3:	83 c4 10             	add    $0x10,%esp
  thread_schedule();
 2b6:	e8 91 fd ff ff       	call   4c <thread_schedule>
  return 0;
 2bb:	b8 00 00 00 00       	mov    $0x0,%eax
}
 2c0:	8b 4d fc             	mov    -0x4(%ebp),%ecx
 2c3:	c9                   	leave  
 2c4:	8d 61 fc             	lea    -0x4(%ecx),%esp
 2c7:	c3                   	ret    

000002c8 <thread_switch>:
         */

   .globl thread_switch
thread_switch:
   /* YOUR CODE HERE */
   pushal
 2c8:	60                   	pusha  

   movl current_thread, %eax
 2c9:	a1 e0 0d 00 00       	mov    0xde0,%eax
   movl %esp, (%eax)
 2ce:	89 20                	mov    %esp,(%eax)

   movl next_thread, %eax
 2d0:	a1 e4 0d 00 00       	mov    0xde4,%eax
   movl (%eax), %esp
 2d5:	8b 20                	mov    (%eax),%esp

   movl %eax, current_thread
 2d7:	a3 e0 0d 00 00       	mov    %eax,0xde0

   popal
 2dc:	61                   	popa   

   movl $0, next_thread
 2dd:	c7 05 e4 0d 00 00 00 	movl   $0x0,0xde4
 2e4:	00 00 00 


 2e7:	c3                   	ret    

000002e8 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 2e8:	55                   	push   %ebp
 2e9:	89 e5                	mov    %esp,%ebp
 2eb:	57                   	push   %edi
 2ec:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 2ed:	8b 4d 08             	mov    0x8(%ebp),%ecx
 2f0:	8b 55 10             	mov    0x10(%ebp),%edx
 2f3:	8b 45 0c             	mov    0xc(%ebp),%eax
 2f6:	89 cb                	mov    %ecx,%ebx
 2f8:	89 df                	mov    %ebx,%edi
 2fa:	89 d1                	mov    %edx,%ecx
 2fc:	fc                   	cld    
 2fd:	f3 aa                	rep stos %al,%es:(%edi)
 2ff:	89 ca                	mov    %ecx,%edx
 301:	89 fb                	mov    %edi,%ebx
 303:	89 5d 08             	mov    %ebx,0x8(%ebp)
 306:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 309:	90                   	nop
 30a:	5b                   	pop    %ebx
 30b:	5f                   	pop    %edi
 30c:	5d                   	pop    %ebp
 30d:	c3                   	ret    

0000030e <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 30e:	55                   	push   %ebp
 30f:	89 e5                	mov    %esp,%ebp
 311:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 314:	8b 45 08             	mov    0x8(%ebp),%eax
 317:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 31a:	90                   	nop
 31b:	8b 55 0c             	mov    0xc(%ebp),%edx
 31e:	8d 42 01             	lea    0x1(%edx),%eax
 321:	89 45 0c             	mov    %eax,0xc(%ebp)
 324:	8b 45 08             	mov    0x8(%ebp),%eax
 327:	8d 48 01             	lea    0x1(%eax),%ecx
 32a:	89 4d 08             	mov    %ecx,0x8(%ebp)
 32d:	0f b6 12             	movzbl (%edx),%edx
 330:	88 10                	mov    %dl,(%eax)
 332:	0f b6 00             	movzbl (%eax),%eax
 335:	84 c0                	test   %al,%al
 337:	75 e2                	jne    31b <strcpy+0xd>
    ;
  return os;
 339:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 33c:	c9                   	leave  
 33d:	c3                   	ret    

0000033e <strcmp>:

int
strcmp(const char *p, const char *q)
{
 33e:	55                   	push   %ebp
 33f:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 341:	eb 08                	jmp    34b <strcmp+0xd>
    p++, q++;
 343:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 347:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(*p && *p == *q)
 34b:	8b 45 08             	mov    0x8(%ebp),%eax
 34e:	0f b6 00             	movzbl (%eax),%eax
 351:	84 c0                	test   %al,%al
 353:	74 10                	je     365 <strcmp+0x27>
 355:	8b 45 08             	mov    0x8(%ebp),%eax
 358:	0f b6 10             	movzbl (%eax),%edx
 35b:	8b 45 0c             	mov    0xc(%ebp),%eax
 35e:	0f b6 00             	movzbl (%eax),%eax
 361:	38 c2                	cmp    %al,%dl
 363:	74 de                	je     343 <strcmp+0x5>
  return (uchar)*p - (uchar)*q;
 365:	8b 45 08             	mov    0x8(%ebp),%eax
 368:	0f b6 00             	movzbl (%eax),%eax
 36b:	0f b6 d0             	movzbl %al,%edx
 36e:	8b 45 0c             	mov    0xc(%ebp),%eax
 371:	0f b6 00             	movzbl (%eax),%eax
 374:	0f b6 c8             	movzbl %al,%ecx
 377:	89 d0                	mov    %edx,%eax
 379:	29 c8                	sub    %ecx,%eax
}
 37b:	5d                   	pop    %ebp
 37c:	c3                   	ret    

0000037d <strlen>:

uint
strlen(char *s)
{
 37d:	55                   	push   %ebp
 37e:	89 e5                	mov    %esp,%ebp
 380:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 383:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 38a:	eb 04                	jmp    390 <strlen+0x13>
 38c:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 390:	8b 55 fc             	mov    -0x4(%ebp),%edx
 393:	8b 45 08             	mov    0x8(%ebp),%eax
 396:	01 d0                	add    %edx,%eax
 398:	0f b6 00             	movzbl (%eax),%eax
 39b:	84 c0                	test   %al,%al
 39d:	75 ed                	jne    38c <strlen+0xf>
    ;
  return n;
 39f:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 3a2:	c9                   	leave  
 3a3:	c3                   	ret    

000003a4 <memset>:

void*
memset(void *dst, int c, uint n)
{
 3a4:	55                   	push   %ebp
 3a5:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
 3a7:	8b 45 10             	mov    0x10(%ebp),%eax
 3aa:	50                   	push   %eax
 3ab:	ff 75 0c             	push   0xc(%ebp)
 3ae:	ff 75 08             	push   0x8(%ebp)
 3b1:	e8 32 ff ff ff       	call   2e8 <stosb>
 3b6:	83 c4 0c             	add    $0xc,%esp
  return dst;
 3b9:	8b 45 08             	mov    0x8(%ebp),%eax
}
 3bc:	c9                   	leave  
 3bd:	c3                   	ret    

000003be <strchr>:

char*
strchr(const char *s, char c)
{
 3be:	55                   	push   %ebp
 3bf:	89 e5                	mov    %esp,%ebp
 3c1:	83 ec 04             	sub    $0x4,%esp
 3c4:	8b 45 0c             	mov    0xc(%ebp),%eax
 3c7:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 3ca:	eb 14                	jmp    3e0 <strchr+0x22>
    if(*s == c)
 3cc:	8b 45 08             	mov    0x8(%ebp),%eax
 3cf:	0f b6 00             	movzbl (%eax),%eax
 3d2:	38 45 fc             	cmp    %al,-0x4(%ebp)
 3d5:	75 05                	jne    3dc <strchr+0x1e>
      return (char*)s;
 3d7:	8b 45 08             	mov    0x8(%ebp),%eax
 3da:	eb 13                	jmp    3ef <strchr+0x31>
  for(; *s; s++)
 3dc:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 3e0:	8b 45 08             	mov    0x8(%ebp),%eax
 3e3:	0f b6 00             	movzbl (%eax),%eax
 3e6:	84 c0                	test   %al,%al
 3e8:	75 e2                	jne    3cc <strchr+0xe>
  return 0;
 3ea:	b8 00 00 00 00       	mov    $0x0,%eax
}
 3ef:	c9                   	leave  
 3f0:	c3                   	ret    

000003f1 <gets>:

char*
gets(char *buf, int max)
{
 3f1:	55                   	push   %ebp
 3f2:	89 e5                	mov    %esp,%ebp
 3f4:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 3f7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 3fe:	eb 42                	jmp    442 <gets+0x51>
    cc = read(0, &c, 1);
 400:	83 ec 04             	sub    $0x4,%esp
 403:	6a 01                	push   $0x1
 405:	8d 45 ef             	lea    -0x11(%ebp),%eax
 408:	50                   	push   %eax
 409:	6a 00                	push   $0x0
 40b:	e8 47 01 00 00       	call   557 <read>
 410:	83 c4 10             	add    $0x10,%esp
 413:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 416:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 41a:	7e 33                	jle    44f <gets+0x5e>
      break;
    buf[i++] = c;
 41c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 41f:	8d 50 01             	lea    0x1(%eax),%edx
 422:	89 55 f4             	mov    %edx,-0xc(%ebp)
 425:	89 c2                	mov    %eax,%edx
 427:	8b 45 08             	mov    0x8(%ebp),%eax
 42a:	01 c2                	add    %eax,%edx
 42c:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 430:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 432:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 436:	3c 0a                	cmp    $0xa,%al
 438:	74 16                	je     450 <gets+0x5f>
 43a:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 43e:	3c 0d                	cmp    $0xd,%al
 440:	74 0e                	je     450 <gets+0x5f>
  for(i=0; i+1 < max; ){
 442:	8b 45 f4             	mov    -0xc(%ebp),%eax
 445:	83 c0 01             	add    $0x1,%eax
 448:	39 45 0c             	cmp    %eax,0xc(%ebp)
 44b:	7f b3                	jg     400 <gets+0xf>
 44d:	eb 01                	jmp    450 <gets+0x5f>
      break;
 44f:	90                   	nop
      break;
  }
  buf[i] = '\0';
 450:	8b 55 f4             	mov    -0xc(%ebp),%edx
 453:	8b 45 08             	mov    0x8(%ebp),%eax
 456:	01 d0                	add    %edx,%eax
 458:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 45b:	8b 45 08             	mov    0x8(%ebp),%eax
}
 45e:	c9                   	leave  
 45f:	c3                   	ret    

00000460 <stat>:

int
stat(char *n, struct stat *st)
{
 460:	55                   	push   %ebp
 461:	89 e5                	mov    %esp,%ebp
 463:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 466:	83 ec 08             	sub    $0x8,%esp
 469:	6a 00                	push   $0x0
 46b:	ff 75 08             	push   0x8(%ebp)
 46e:	e8 0c 01 00 00       	call   57f <open>
 473:	83 c4 10             	add    $0x10,%esp
 476:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 479:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 47d:	79 07                	jns    486 <stat+0x26>
    return -1;
 47f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 484:	eb 25                	jmp    4ab <stat+0x4b>
  r = fstat(fd, st);
 486:	83 ec 08             	sub    $0x8,%esp
 489:	ff 75 0c             	push   0xc(%ebp)
 48c:	ff 75 f4             	push   -0xc(%ebp)
 48f:	e8 03 01 00 00       	call   597 <fstat>
 494:	83 c4 10             	add    $0x10,%esp
 497:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 49a:	83 ec 0c             	sub    $0xc,%esp
 49d:	ff 75 f4             	push   -0xc(%ebp)
 4a0:	e8 c2 00 00 00       	call   567 <close>
 4a5:	83 c4 10             	add    $0x10,%esp
  return r;
 4a8:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 4ab:	c9                   	leave  
 4ac:	c3                   	ret    

000004ad <atoi>:

int
atoi(const char *s)
{
 4ad:	55                   	push   %ebp
 4ae:	89 e5                	mov    %esp,%ebp
 4b0:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 4b3:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 4ba:	eb 25                	jmp    4e1 <atoi+0x34>
    n = n*10 + *s++ - '0';
 4bc:	8b 55 fc             	mov    -0x4(%ebp),%edx
 4bf:	89 d0                	mov    %edx,%eax
 4c1:	c1 e0 02             	shl    $0x2,%eax
 4c4:	01 d0                	add    %edx,%eax
 4c6:	01 c0                	add    %eax,%eax
 4c8:	89 c1                	mov    %eax,%ecx
 4ca:	8b 45 08             	mov    0x8(%ebp),%eax
 4cd:	8d 50 01             	lea    0x1(%eax),%edx
 4d0:	89 55 08             	mov    %edx,0x8(%ebp)
 4d3:	0f b6 00             	movzbl (%eax),%eax
 4d6:	0f be c0             	movsbl %al,%eax
 4d9:	01 c8                	add    %ecx,%eax
 4db:	83 e8 30             	sub    $0x30,%eax
 4de:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 4e1:	8b 45 08             	mov    0x8(%ebp),%eax
 4e4:	0f b6 00             	movzbl (%eax),%eax
 4e7:	3c 2f                	cmp    $0x2f,%al
 4e9:	7e 0a                	jle    4f5 <atoi+0x48>
 4eb:	8b 45 08             	mov    0x8(%ebp),%eax
 4ee:	0f b6 00             	movzbl (%eax),%eax
 4f1:	3c 39                	cmp    $0x39,%al
 4f3:	7e c7                	jle    4bc <atoi+0xf>
  return n;
 4f5:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 4f8:	c9                   	leave  
 4f9:	c3                   	ret    

000004fa <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 4fa:	55                   	push   %ebp
 4fb:	89 e5                	mov    %esp,%ebp
 4fd:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;

  dst = vdst;
 500:	8b 45 08             	mov    0x8(%ebp),%eax
 503:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 506:	8b 45 0c             	mov    0xc(%ebp),%eax
 509:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 50c:	eb 17                	jmp    525 <memmove+0x2b>
    *dst++ = *src++;
 50e:	8b 55 f8             	mov    -0x8(%ebp),%edx
 511:	8d 42 01             	lea    0x1(%edx),%eax
 514:	89 45 f8             	mov    %eax,-0x8(%ebp)
 517:	8b 45 fc             	mov    -0x4(%ebp),%eax
 51a:	8d 48 01             	lea    0x1(%eax),%ecx
 51d:	89 4d fc             	mov    %ecx,-0x4(%ebp)
 520:	0f b6 12             	movzbl (%edx),%edx
 523:	88 10                	mov    %dl,(%eax)
  while(n-- > 0)
 525:	8b 45 10             	mov    0x10(%ebp),%eax
 528:	8d 50 ff             	lea    -0x1(%eax),%edx
 52b:	89 55 10             	mov    %edx,0x10(%ebp)
 52e:	85 c0                	test   %eax,%eax
 530:	7f dc                	jg     50e <memmove+0x14>
  return vdst;
 532:	8b 45 08             	mov    0x8(%ebp),%eax
}
 535:	c9                   	leave  
 536:	c3                   	ret    

00000537 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 537:	b8 01 00 00 00       	mov    $0x1,%eax
 53c:	cd 40                	int    $0x40
 53e:	c3                   	ret    

0000053f <exit>:
SYSCALL(exit)
 53f:	b8 02 00 00 00       	mov    $0x2,%eax
 544:	cd 40                	int    $0x40
 546:	c3                   	ret    

00000547 <wait>:
SYSCALL(wait)
 547:	b8 03 00 00 00       	mov    $0x3,%eax
 54c:	cd 40                	int    $0x40
 54e:	c3                   	ret    

0000054f <pipe>:
SYSCALL(pipe)
 54f:	b8 04 00 00 00       	mov    $0x4,%eax
 554:	cd 40                	int    $0x40
 556:	c3                   	ret    

00000557 <read>:
SYSCALL(read)
 557:	b8 05 00 00 00       	mov    $0x5,%eax
 55c:	cd 40                	int    $0x40
 55e:	c3                   	ret    

0000055f <write>:
SYSCALL(write)
 55f:	b8 10 00 00 00       	mov    $0x10,%eax
 564:	cd 40                	int    $0x40
 566:	c3                   	ret    

00000567 <close>:
SYSCALL(close)
 567:	b8 15 00 00 00       	mov    $0x15,%eax
 56c:	cd 40                	int    $0x40
 56e:	c3                   	ret    

0000056f <kill>:
SYSCALL(kill)
 56f:	b8 06 00 00 00       	mov    $0x6,%eax
 574:	cd 40                	int    $0x40
 576:	c3                   	ret    

00000577 <exec>:
SYSCALL(exec)
 577:	b8 07 00 00 00       	mov    $0x7,%eax
 57c:	cd 40                	int    $0x40
 57e:	c3                   	ret    

0000057f <open>:
SYSCALL(open)
 57f:	b8 0f 00 00 00       	mov    $0xf,%eax
 584:	cd 40                	int    $0x40
 586:	c3                   	ret    

00000587 <mknod>:
SYSCALL(mknod)
 587:	b8 11 00 00 00       	mov    $0x11,%eax
 58c:	cd 40                	int    $0x40
 58e:	c3                   	ret    

0000058f <unlink>:
SYSCALL(unlink)
 58f:	b8 12 00 00 00       	mov    $0x12,%eax
 594:	cd 40                	int    $0x40
 596:	c3                   	ret    

00000597 <fstat>:
SYSCALL(fstat)
 597:	b8 08 00 00 00       	mov    $0x8,%eax
 59c:	cd 40                	int    $0x40
 59e:	c3                   	ret    

0000059f <link>:
SYSCALL(link)
 59f:	b8 13 00 00 00       	mov    $0x13,%eax
 5a4:	cd 40                	int    $0x40
 5a6:	c3                   	ret    

000005a7 <mkdir>:
SYSCALL(mkdir)
 5a7:	b8 14 00 00 00       	mov    $0x14,%eax
 5ac:	cd 40                	int    $0x40
 5ae:	c3                   	ret    

000005af <chdir>:
SYSCALL(chdir)
 5af:	b8 09 00 00 00       	mov    $0x9,%eax
 5b4:	cd 40                	int    $0x40
 5b6:	c3                   	ret    

000005b7 <dup>:
SYSCALL(dup)
 5b7:	b8 0a 00 00 00       	mov    $0xa,%eax
 5bc:	cd 40                	int    $0x40
 5be:	c3                   	ret    

000005bf <getpid>:
SYSCALL(getpid)
 5bf:	b8 0b 00 00 00       	mov    $0xb,%eax
 5c4:	cd 40                	int    $0x40
 5c6:	c3                   	ret    

000005c7 <sbrk>:
SYSCALL(sbrk)
 5c7:	b8 0c 00 00 00       	mov    $0xc,%eax
 5cc:	cd 40                	int    $0x40
 5ce:	c3                   	ret    

000005cf <sleep>:
SYSCALL(sleep)
 5cf:	b8 0d 00 00 00       	mov    $0xd,%eax
 5d4:	cd 40                	int    $0x40
 5d6:	c3                   	ret    

000005d7 <uptime>:
SYSCALL(uptime)
 5d7:	b8 0e 00 00 00       	mov    $0xe,%eax
 5dc:	cd 40                	int    $0x40
 5de:	c3                   	ret    

000005df <uthread_init>:
SYSCALL(uthread_init)
 5df:	b8 16 00 00 00       	mov    $0x16,%eax
 5e4:	cd 40                	int    $0x40
 5e6:	c3                   	ret    

000005e7 <thread_num>:
 5e7:	b8 17 00 00 00       	mov    $0x17,%eax
 5ec:	cd 40                	int    $0x40
 5ee:	c3                   	ret    

000005ef <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 5ef:	55                   	push   %ebp
 5f0:	89 e5                	mov    %esp,%ebp
 5f2:	83 ec 18             	sub    $0x18,%esp
 5f5:	8b 45 0c             	mov    0xc(%ebp),%eax
 5f8:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 5fb:	83 ec 04             	sub    $0x4,%esp
 5fe:	6a 01                	push   $0x1
 600:	8d 45 f4             	lea    -0xc(%ebp),%eax
 603:	50                   	push   %eax
 604:	ff 75 08             	push   0x8(%ebp)
 607:	e8 53 ff ff ff       	call   55f <write>
 60c:	83 c4 10             	add    $0x10,%esp
}
 60f:	90                   	nop
 610:	c9                   	leave  
 611:	c3                   	ret    

00000612 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 612:	55                   	push   %ebp
 613:	89 e5                	mov    %esp,%ebp
 615:	83 ec 28             	sub    $0x28,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 618:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 61f:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 623:	74 17                	je     63c <printint+0x2a>
 625:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 629:	79 11                	jns    63c <printint+0x2a>
    neg = 1;
 62b:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 632:	8b 45 0c             	mov    0xc(%ebp),%eax
 635:	f7 d8                	neg    %eax
 637:	89 45 ec             	mov    %eax,-0x14(%ebp)
 63a:	eb 06                	jmp    642 <printint+0x30>
  } else {
    x = xx;
 63c:	8b 45 0c             	mov    0xc(%ebp),%eax
 63f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 642:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 649:	8b 4d 10             	mov    0x10(%ebp),%ecx
 64c:	8b 45 ec             	mov    -0x14(%ebp),%eax
 64f:	ba 00 00 00 00       	mov    $0x0,%edx
 654:	f7 f1                	div    %ecx
 656:	89 d1                	mov    %edx,%ecx
 658:	8b 45 f4             	mov    -0xc(%ebp),%eax
 65b:	8d 50 01             	lea    0x1(%eax),%edx
 65e:	89 55 f4             	mov    %edx,-0xc(%ebp)
 661:	0f b6 91 cc 0d 00 00 	movzbl 0xdcc(%ecx),%edx
 668:	88 54 05 dc          	mov    %dl,-0x24(%ebp,%eax,1)
  }while((x /= base) != 0);
 66c:	8b 4d 10             	mov    0x10(%ebp),%ecx
 66f:	8b 45 ec             	mov    -0x14(%ebp),%eax
 672:	ba 00 00 00 00       	mov    $0x0,%edx
 677:	f7 f1                	div    %ecx
 679:	89 45 ec             	mov    %eax,-0x14(%ebp)
 67c:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 680:	75 c7                	jne    649 <printint+0x37>
  if(neg)
 682:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 686:	74 2d                	je     6b5 <printint+0xa3>
    buf[i++] = '-';
 688:	8b 45 f4             	mov    -0xc(%ebp),%eax
 68b:	8d 50 01             	lea    0x1(%eax),%edx
 68e:	89 55 f4             	mov    %edx,-0xc(%ebp)
 691:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 696:	eb 1d                	jmp    6b5 <printint+0xa3>
    putc(fd, buf[i]);
 698:	8d 55 dc             	lea    -0x24(%ebp),%edx
 69b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 69e:	01 d0                	add    %edx,%eax
 6a0:	0f b6 00             	movzbl (%eax),%eax
 6a3:	0f be c0             	movsbl %al,%eax
 6a6:	83 ec 08             	sub    $0x8,%esp
 6a9:	50                   	push   %eax
 6aa:	ff 75 08             	push   0x8(%ebp)
 6ad:	e8 3d ff ff ff       	call   5ef <putc>
 6b2:	83 c4 10             	add    $0x10,%esp
  while(--i >= 0)
 6b5:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 6b9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 6bd:	79 d9                	jns    698 <printint+0x86>
}
 6bf:	90                   	nop
 6c0:	90                   	nop
 6c1:	c9                   	leave  
 6c2:	c3                   	ret    

000006c3 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 6c3:	55                   	push   %ebp
 6c4:	89 e5                	mov    %esp,%ebp
 6c6:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 6c9:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 6d0:	8d 45 0c             	lea    0xc(%ebp),%eax
 6d3:	83 c0 04             	add    $0x4,%eax
 6d6:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 6d9:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 6e0:	e9 59 01 00 00       	jmp    83e <printf+0x17b>
    c = fmt[i] & 0xff;
 6e5:	8b 55 0c             	mov    0xc(%ebp),%edx
 6e8:	8b 45 f0             	mov    -0x10(%ebp),%eax
 6eb:	01 d0                	add    %edx,%eax
 6ed:	0f b6 00             	movzbl (%eax),%eax
 6f0:	0f be c0             	movsbl %al,%eax
 6f3:	25 ff 00 00 00       	and    $0xff,%eax
 6f8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 6fb:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 6ff:	75 2c                	jne    72d <printf+0x6a>
      if(c == '%'){
 701:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 705:	75 0c                	jne    713 <printf+0x50>
        state = '%';
 707:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 70e:	e9 27 01 00 00       	jmp    83a <printf+0x177>
      } else {
        putc(fd, c);
 713:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 716:	0f be c0             	movsbl %al,%eax
 719:	83 ec 08             	sub    $0x8,%esp
 71c:	50                   	push   %eax
 71d:	ff 75 08             	push   0x8(%ebp)
 720:	e8 ca fe ff ff       	call   5ef <putc>
 725:	83 c4 10             	add    $0x10,%esp
 728:	e9 0d 01 00 00       	jmp    83a <printf+0x177>
      }
    } else if(state == '%'){
 72d:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 731:	0f 85 03 01 00 00    	jne    83a <printf+0x177>
      if(c == 'd'){
 737:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 73b:	75 1e                	jne    75b <printf+0x98>
        printint(fd, *ap, 10, 1);
 73d:	8b 45 e8             	mov    -0x18(%ebp),%eax
 740:	8b 00                	mov    (%eax),%eax
 742:	6a 01                	push   $0x1
 744:	6a 0a                	push   $0xa
 746:	50                   	push   %eax
 747:	ff 75 08             	push   0x8(%ebp)
 74a:	e8 c3 fe ff ff       	call   612 <printint>
 74f:	83 c4 10             	add    $0x10,%esp
        ap++;
 752:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 756:	e9 d8 00 00 00       	jmp    833 <printf+0x170>
      } else if(c == 'x' || c == 'p'){
 75b:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 75f:	74 06                	je     767 <printf+0xa4>
 761:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 765:	75 1e                	jne    785 <printf+0xc2>
        printint(fd, *ap, 16, 0);
 767:	8b 45 e8             	mov    -0x18(%ebp),%eax
 76a:	8b 00                	mov    (%eax),%eax
 76c:	6a 00                	push   $0x0
 76e:	6a 10                	push   $0x10
 770:	50                   	push   %eax
 771:	ff 75 08             	push   0x8(%ebp)
 774:	e8 99 fe ff ff       	call   612 <printint>
 779:	83 c4 10             	add    $0x10,%esp
        ap++;
 77c:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 780:	e9 ae 00 00 00       	jmp    833 <printf+0x170>
      } else if(c == 's'){
 785:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 789:	75 43                	jne    7ce <printf+0x10b>
        s = (char*)*ap;
 78b:	8b 45 e8             	mov    -0x18(%ebp),%eax
 78e:	8b 00                	mov    (%eax),%eax
 790:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 793:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 797:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 79b:	75 25                	jne    7c2 <printf+0xff>
          s = "(null)";
 79d:	c7 45 f4 d6 0a 00 00 	movl   $0xad6,-0xc(%ebp)
        while(*s != 0){
 7a4:	eb 1c                	jmp    7c2 <printf+0xff>
          putc(fd, *s);
 7a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7a9:	0f b6 00             	movzbl (%eax),%eax
 7ac:	0f be c0             	movsbl %al,%eax
 7af:	83 ec 08             	sub    $0x8,%esp
 7b2:	50                   	push   %eax
 7b3:	ff 75 08             	push   0x8(%ebp)
 7b6:	e8 34 fe ff ff       	call   5ef <putc>
 7bb:	83 c4 10             	add    $0x10,%esp
          s++;
 7be:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
        while(*s != 0){
 7c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7c5:	0f b6 00             	movzbl (%eax),%eax
 7c8:	84 c0                	test   %al,%al
 7ca:	75 da                	jne    7a6 <printf+0xe3>
 7cc:	eb 65                	jmp    833 <printf+0x170>
        }
      } else if(c == 'c'){
 7ce:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 7d2:	75 1d                	jne    7f1 <printf+0x12e>
        putc(fd, *ap);
 7d4:	8b 45 e8             	mov    -0x18(%ebp),%eax
 7d7:	8b 00                	mov    (%eax),%eax
 7d9:	0f be c0             	movsbl %al,%eax
 7dc:	83 ec 08             	sub    $0x8,%esp
 7df:	50                   	push   %eax
 7e0:	ff 75 08             	push   0x8(%ebp)
 7e3:	e8 07 fe ff ff       	call   5ef <putc>
 7e8:	83 c4 10             	add    $0x10,%esp
        ap++;
 7eb:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 7ef:	eb 42                	jmp    833 <printf+0x170>
      } else if(c == '%'){
 7f1:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 7f5:	75 17                	jne    80e <printf+0x14b>
        putc(fd, c);
 7f7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 7fa:	0f be c0             	movsbl %al,%eax
 7fd:	83 ec 08             	sub    $0x8,%esp
 800:	50                   	push   %eax
 801:	ff 75 08             	push   0x8(%ebp)
 804:	e8 e6 fd ff ff       	call   5ef <putc>
 809:	83 c4 10             	add    $0x10,%esp
 80c:	eb 25                	jmp    833 <printf+0x170>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 80e:	83 ec 08             	sub    $0x8,%esp
 811:	6a 25                	push   $0x25
 813:	ff 75 08             	push   0x8(%ebp)
 816:	e8 d4 fd ff ff       	call   5ef <putc>
 81b:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 81e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 821:	0f be c0             	movsbl %al,%eax
 824:	83 ec 08             	sub    $0x8,%esp
 827:	50                   	push   %eax
 828:	ff 75 08             	push   0x8(%ebp)
 82b:	e8 bf fd ff ff       	call   5ef <putc>
 830:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 833:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(i = 0; fmt[i]; i++){
 83a:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 83e:	8b 55 0c             	mov    0xc(%ebp),%edx
 841:	8b 45 f0             	mov    -0x10(%ebp),%eax
 844:	01 d0                	add    %edx,%eax
 846:	0f b6 00             	movzbl (%eax),%eax
 849:	84 c0                	test   %al,%al
 84b:	0f 85 94 fe ff ff    	jne    6e5 <printf+0x22>
    }
  }
}
 851:	90                   	nop
 852:	90                   	nop
 853:	c9                   	leave  
 854:	c3                   	ret    

00000855 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 855:	55                   	push   %ebp
 856:	89 e5                	mov    %esp,%ebp
 858:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 85b:	8b 45 08             	mov    0x8(%ebp),%eax
 85e:	83 e8 08             	sub    $0x8,%eax
 861:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 864:	a1 2c 8e 00 00       	mov    0x8e2c,%eax
 869:	89 45 fc             	mov    %eax,-0x4(%ebp)
 86c:	eb 24                	jmp    892 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 86e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 871:	8b 00                	mov    (%eax),%eax
 873:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 876:	72 12                	jb     88a <free+0x35>
 878:	8b 45 f8             	mov    -0x8(%ebp),%eax
 87b:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 87e:	77 24                	ja     8a4 <free+0x4f>
 880:	8b 45 fc             	mov    -0x4(%ebp),%eax
 883:	8b 00                	mov    (%eax),%eax
 885:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 888:	72 1a                	jb     8a4 <free+0x4f>
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 88a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 88d:	8b 00                	mov    (%eax),%eax
 88f:	89 45 fc             	mov    %eax,-0x4(%ebp)
 892:	8b 45 f8             	mov    -0x8(%ebp),%eax
 895:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 898:	76 d4                	jbe    86e <free+0x19>
 89a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 89d:	8b 00                	mov    (%eax),%eax
 89f:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 8a2:	73 ca                	jae    86e <free+0x19>
      break;
  if(bp + bp->s.size == p->s.ptr){
 8a4:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8a7:	8b 40 04             	mov    0x4(%eax),%eax
 8aa:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 8b1:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8b4:	01 c2                	add    %eax,%edx
 8b6:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8b9:	8b 00                	mov    (%eax),%eax
 8bb:	39 c2                	cmp    %eax,%edx
 8bd:	75 24                	jne    8e3 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 8bf:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8c2:	8b 50 04             	mov    0x4(%eax),%edx
 8c5:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8c8:	8b 00                	mov    (%eax),%eax
 8ca:	8b 40 04             	mov    0x4(%eax),%eax
 8cd:	01 c2                	add    %eax,%edx
 8cf:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8d2:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 8d5:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8d8:	8b 00                	mov    (%eax),%eax
 8da:	8b 10                	mov    (%eax),%edx
 8dc:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8df:	89 10                	mov    %edx,(%eax)
 8e1:	eb 0a                	jmp    8ed <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 8e3:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8e6:	8b 10                	mov    (%eax),%edx
 8e8:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8eb:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 8ed:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8f0:	8b 40 04             	mov    0x4(%eax),%eax
 8f3:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 8fa:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8fd:	01 d0                	add    %edx,%eax
 8ff:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 902:	75 20                	jne    924 <free+0xcf>
    p->s.size += bp->s.size;
 904:	8b 45 fc             	mov    -0x4(%ebp),%eax
 907:	8b 50 04             	mov    0x4(%eax),%edx
 90a:	8b 45 f8             	mov    -0x8(%ebp),%eax
 90d:	8b 40 04             	mov    0x4(%eax),%eax
 910:	01 c2                	add    %eax,%edx
 912:	8b 45 fc             	mov    -0x4(%ebp),%eax
 915:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 918:	8b 45 f8             	mov    -0x8(%ebp),%eax
 91b:	8b 10                	mov    (%eax),%edx
 91d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 920:	89 10                	mov    %edx,(%eax)
 922:	eb 08                	jmp    92c <free+0xd7>
  } else
    p->s.ptr = bp;
 924:	8b 45 fc             	mov    -0x4(%ebp),%eax
 927:	8b 55 f8             	mov    -0x8(%ebp),%edx
 92a:	89 10                	mov    %edx,(%eax)
  freep = p;
 92c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 92f:	a3 2c 8e 00 00       	mov    %eax,0x8e2c
}
 934:	90                   	nop
 935:	c9                   	leave  
 936:	c3                   	ret    

00000937 <morecore>:

static Header*
morecore(uint nu)
{
 937:	55                   	push   %ebp
 938:	89 e5                	mov    %esp,%ebp
 93a:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 93d:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 944:	77 07                	ja     94d <morecore+0x16>
    nu = 4096;
 946:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 94d:	8b 45 08             	mov    0x8(%ebp),%eax
 950:	c1 e0 03             	shl    $0x3,%eax
 953:	83 ec 0c             	sub    $0xc,%esp
 956:	50                   	push   %eax
 957:	e8 6b fc ff ff       	call   5c7 <sbrk>
 95c:	83 c4 10             	add    $0x10,%esp
 95f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 962:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 966:	75 07                	jne    96f <morecore+0x38>
    return 0;
 968:	b8 00 00 00 00       	mov    $0x0,%eax
 96d:	eb 26                	jmp    995 <morecore+0x5e>
  hp = (Header*)p;
 96f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 972:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 975:	8b 45 f0             	mov    -0x10(%ebp),%eax
 978:	8b 55 08             	mov    0x8(%ebp),%edx
 97b:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 97e:	8b 45 f0             	mov    -0x10(%ebp),%eax
 981:	83 c0 08             	add    $0x8,%eax
 984:	83 ec 0c             	sub    $0xc,%esp
 987:	50                   	push   %eax
 988:	e8 c8 fe ff ff       	call   855 <free>
 98d:	83 c4 10             	add    $0x10,%esp
  return freep;
 990:	a1 2c 8e 00 00       	mov    0x8e2c,%eax
}
 995:	c9                   	leave  
 996:	c3                   	ret    

00000997 <malloc>:

void*
malloc(uint nbytes)
{
 997:	55                   	push   %ebp
 998:	89 e5                	mov    %esp,%ebp
 99a:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 99d:	8b 45 08             	mov    0x8(%ebp),%eax
 9a0:	83 c0 07             	add    $0x7,%eax
 9a3:	c1 e8 03             	shr    $0x3,%eax
 9a6:	83 c0 01             	add    $0x1,%eax
 9a9:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 9ac:	a1 2c 8e 00 00       	mov    0x8e2c,%eax
 9b1:	89 45 f0             	mov    %eax,-0x10(%ebp)
 9b4:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 9b8:	75 23                	jne    9dd <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 9ba:	c7 45 f0 24 8e 00 00 	movl   $0x8e24,-0x10(%ebp)
 9c1:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9c4:	a3 2c 8e 00 00       	mov    %eax,0x8e2c
 9c9:	a1 2c 8e 00 00       	mov    0x8e2c,%eax
 9ce:	a3 24 8e 00 00       	mov    %eax,0x8e24
    base.s.size = 0;
 9d3:	c7 05 28 8e 00 00 00 	movl   $0x0,0x8e28
 9da:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 9dd:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9e0:	8b 00                	mov    (%eax),%eax
 9e2:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 9e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9e8:	8b 40 04             	mov    0x4(%eax),%eax
 9eb:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 9ee:	77 4d                	ja     a3d <malloc+0xa6>
      if(p->s.size == nunits)
 9f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9f3:	8b 40 04             	mov    0x4(%eax),%eax
 9f6:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 9f9:	75 0c                	jne    a07 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 9fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9fe:	8b 10                	mov    (%eax),%edx
 a00:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a03:	89 10                	mov    %edx,(%eax)
 a05:	eb 26                	jmp    a2d <malloc+0x96>
      else {
        p->s.size -= nunits;
 a07:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a0a:	8b 40 04             	mov    0x4(%eax),%eax
 a0d:	2b 45 ec             	sub    -0x14(%ebp),%eax
 a10:	89 c2                	mov    %eax,%edx
 a12:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a15:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 a18:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a1b:	8b 40 04             	mov    0x4(%eax),%eax
 a1e:	c1 e0 03             	shl    $0x3,%eax
 a21:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 a24:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a27:	8b 55 ec             	mov    -0x14(%ebp),%edx
 a2a:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 a2d:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a30:	a3 2c 8e 00 00       	mov    %eax,0x8e2c
      return (void*)(p + 1);
 a35:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a38:	83 c0 08             	add    $0x8,%eax
 a3b:	eb 3b                	jmp    a78 <malloc+0xe1>
    }
    if(p == freep)
 a3d:	a1 2c 8e 00 00       	mov    0x8e2c,%eax
 a42:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 a45:	75 1e                	jne    a65 <malloc+0xce>
      if((p = morecore(nunits)) == 0)
 a47:	83 ec 0c             	sub    $0xc,%esp
 a4a:	ff 75 ec             	push   -0x14(%ebp)
 a4d:	e8 e5 fe ff ff       	call   937 <morecore>
 a52:	83 c4 10             	add    $0x10,%esp
 a55:	89 45 f4             	mov    %eax,-0xc(%ebp)
 a58:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 a5c:	75 07                	jne    a65 <malloc+0xce>
        return 0;
 a5e:	b8 00 00 00 00       	mov    $0x0,%eax
 a63:	eb 13                	jmp    a78 <malloc+0xe1>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a65:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a68:	89 45 f0             	mov    %eax,-0x10(%ebp)
 a6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a6e:	8b 00                	mov    (%eax),%eax
 a70:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 a73:	e9 6d ff ff ff       	jmp    9e5 <malloc+0x4e>
  }
}
 a78:	c9                   	leave  
 a79:	c3                   	ret    
