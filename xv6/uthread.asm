
_uthread:     file format elf32-i386


Disassembly of section .text:

00000000 <thread_init>:
static int num_thread = 0;

static void thread_schedule(void);

void thread_init(void)
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
  32:	e8 95 05 00 00       	call   5cc <thread_num>
  37:	83 c4 10             	add    $0x10,%esp
  uthread_init((uint)thread_schedule);
  3a:	b8 4e 00 00 00       	mov    $0x4e,%eax
  3f:	83 ec 0c             	sub    $0xc,%esp
  42:	50                   	push   %eax
  43:	e8 7c 05 00 00       	call   5c4 <uthread_init>
  48:	83 c4 10             	add    $0x10,%esp
}
  4b:	90                   	nop
  4c:	c9                   	leave  
  4d:	c3                   	ret    

0000004e <thread_schedule>:

static void
thread_schedule(void)
{
  4e:	55                   	push   %ebp
  4f:	89 e5                	mov    %esp,%ebp
  51:	83 ec 18             	sub    $0x18,%esp
  thread_p t;

  /* Find another runnable thread. */
  next_thread = 0;
  54:	c7 05 e4 0d 00 00 00 	movl   $0x0,0xde4
  5b:	00 00 00 
  for (t = all_thread; t < all_thread + MAX_THREAD; t++)
  5e:	c7 45 f4 00 0e 00 00 	movl   $0xe00,-0xc(%ebp)
  65:	eb 29                	jmp    90 <thread_schedule+0x42>
  {
    if (t->state == RUNNABLE && t != current_thread)
  67:	8b 45 f4             	mov    -0xc(%ebp),%eax
  6a:	8b 80 04 20 00 00    	mov    0x2004(%eax),%eax
  70:	83 f8 02             	cmp    $0x2,%eax
  73:	75 14                	jne    89 <thread_schedule+0x3b>
  75:	a1 e0 0d 00 00       	mov    0xde0,%eax
  7a:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  7d:	74 0a                	je     89 <thread_schedule+0x3b>
    {
      next_thread = t;
  7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  82:	a3 e4 0d 00 00       	mov    %eax,0xde4
      break;
  87:	eb 11                	jmp    9a <thread_schedule+0x4c>
  for (t = all_thread; t < all_thread + MAX_THREAD; t++)
  89:	81 45 f4 08 20 00 00 	addl   $0x2008,-0xc(%ebp)
  90:	b8 20 8e 00 00       	mov    $0x8e20,%eax
  95:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  98:	72 cd                	jb     67 <thread_schedule+0x19>
    }
  }

  if (t >= all_thread + MAX_THREAD && current_thread->state == RUNNABLE)
  9a:	b8 20 8e 00 00       	mov    $0x8e20,%eax
  9f:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  a2:	72 1a                	jb     be <thread_schedule+0x70>
  a4:	a1 e0 0d 00 00       	mov    0xde0,%eax
  a9:	8b 80 04 20 00 00    	mov    0x2004(%eax),%eax
  af:	83 f8 02             	cmp    $0x2,%eax
  b2:	75 0a                	jne    be <thread_schedule+0x70>
  {
    /* The current thread is the only runnable thread; run it. */
    next_thread = current_thread;
  b4:	a1 e0 0d 00 00       	mov    0xde0,%eax
  b9:	a3 e4 0d 00 00       	mov    %eax,0xde4
  }

  if (next_thread == 0)
  be:	a1 e4 0d 00 00       	mov    0xde4,%eax
  c3:	85 c0                	test   %eax,%eax
  c5:	75 17                	jne    de <thread_schedule+0x90>
  {
    printf(2, "thread_schedule: no runnable threads\n");
  c7:	83 ec 08             	sub    $0x8,%esp
  ca:	68 60 0a 00 00       	push   $0xa60
  cf:	6a 02                	push   $0x2
  d1:	e8 d2 05 00 00       	call   6a8 <printf>
  d6:	83 c4 10             	add    $0x10,%esp
    exit();
  d9:	e8 46 04 00 00       	call   524 <exit>
  }

  if (current_thread != next_thread)
  de:	8b 15 e0 0d 00 00    	mov    0xde0,%edx
  e4:	a1 e4 0d 00 00       	mov    0xde4,%eax
  e9:	39 c2                	cmp    %eax,%edx
  eb:	74 16                	je     103 <thread_schedule+0xb5>
  { /* switch threads?  */
    next_thread->state = RUNNING;
  ed:	a1 e4 0d 00 00       	mov    0xde4,%eax
  f2:	c7 80 04 20 00 00 01 	movl   $0x1,0x2004(%eax)
  f9:	00 00 00 
    thread_switch();
  fc:	e8 ac 01 00 00       	call   2ad <thread_switch>
  }
  else
    next_thread = 0;
}
 101:	eb 0a                	jmp    10d <thread_schedule+0xbf>
    next_thread = 0;
 103:	c7 05 e4 0d 00 00 00 	movl   $0x0,0xde4
 10a:	00 00 00 
}
 10d:	90                   	nop
 10e:	c9                   	leave  
 10f:	c3                   	ret    

00000110 <thread_create>:

void thread_create(void (*func)())
{
 110:	55                   	push   %ebp
 111:	89 e5                	mov    %esp,%ebp
 113:	83 ec 18             	sub    $0x18,%esp
  thread_p t;
  num_thread++;
 116:	a1 20 8e 00 00       	mov    0x8e20,%eax
 11b:	83 c0 01             	add    $0x1,%eax
 11e:	a3 20 8e 00 00       	mov    %eax,0x8e20
  thread_num(num_thread);
 123:	a1 20 8e 00 00       	mov    0x8e20,%eax
 128:	83 ec 0c             	sub    $0xc,%esp
 12b:	50                   	push   %eax
 12c:	e8 9b 04 00 00       	call   5cc <thread_num>
 131:	83 c4 10             	add    $0x10,%esp
  for (t = all_thread; t < all_thread + MAX_THREAD; t++)
 134:	c7 45 f4 00 0e 00 00 	movl   $0xe00,-0xc(%ebp)
 13b:	eb 14                	jmp    151 <thread_create+0x41>
  {
    if (t->state == FREE)
 13d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 140:	8b 80 04 20 00 00    	mov    0x2004(%eax),%eax
 146:	85 c0                	test   %eax,%eax
 148:	74 13                	je     15d <thread_create+0x4d>
  for (t = all_thread; t < all_thread + MAX_THREAD; t++)
 14a:	81 45 f4 08 20 00 00 	addl   $0x2008,-0xc(%ebp)
 151:	b8 20 8e 00 00       	mov    $0x8e20,%eax
 156:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 159:	72 e2                	jb     13d <thread_create+0x2d>
 15b:	eb 01                	jmp    15e <thread_create+0x4e>
      break;
 15d:	90                   	nop
  }
  t->sp = (int)(t->stack + STACK_SIZE); // set sp to the top of the stack
 15e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 161:	83 c0 04             	add    $0x4,%eax
 164:	05 00 20 00 00       	add    $0x2000,%eax
 169:	89 c2                	mov    %eax,%edx
 16b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 16e:	89 10                	mov    %edx,(%eax)
  t->sp -= 4;                           // space for return address
 170:	8b 45 f4             	mov    -0xc(%ebp),%eax
 173:	8b 00                	mov    (%eax),%eax
 175:	8d 50 fc             	lea    -0x4(%eax),%edx
 178:	8b 45 f4             	mov    -0xc(%ebp),%eax
 17b:	89 10                	mov    %edx,(%eax)
  *(int *)(t->sp) = (int)func;          // push return address on stack
 17d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 180:	8b 00                	mov    (%eax),%eax
 182:	89 c2                	mov    %eax,%edx
 184:	8b 45 08             	mov    0x8(%ebp),%eax
 187:	89 02                	mov    %eax,(%edx)
  t->sp -= 32;                          // space for registers that thread_switch expects
 189:	8b 45 f4             	mov    -0xc(%ebp),%eax
 18c:	8b 00                	mov    (%eax),%eax
 18e:	8d 50 e0             	lea    -0x20(%eax),%edx
 191:	8b 45 f4             	mov    -0xc(%ebp),%eax
 194:	89 10                	mov    %edx,(%eax)
  t->state = RUNNABLE;
 196:	8b 45 f4             	mov    -0xc(%ebp),%eax
 199:	c7 80 04 20 00 00 02 	movl   $0x2,0x2004(%eax)
 1a0:	00 00 00 
  
}
 1a3:	90                   	nop
 1a4:	c9                   	leave  
 1a5:	c3                   	ret    

000001a6 <thread_yield>:

void thread_yield(void)
{
 1a6:	55                   	push   %ebp
 1a7:	89 e5                	mov    %esp,%ebp
 1a9:	83 ec 08             	sub    $0x8,%esp
  current_thread->state = RUNNABLE;
 1ac:	a1 e0 0d 00 00       	mov    0xde0,%eax
 1b1:	c7 80 04 20 00 00 02 	movl   $0x2,0x2004(%eax)
 1b8:	00 00 00 
  thread_schedule();
 1bb:	e8 8e fe ff ff       	call   4e <thread_schedule>
}
 1c0:	90                   	nop
 1c1:	c9                   	leave  
 1c2:	c3                   	ret    

000001c3 <mythread>:

static void
mythread(void)
{
 1c3:	55                   	push   %ebp
 1c4:	89 e5                	mov    %esp,%ebp
 1c6:	83 ec 18             	sub    $0x18,%esp
  int i;
  printf(1, "my thread running\n");
 1c9:	83 ec 08             	sub    $0x8,%esp
 1cc:	68 86 0a 00 00       	push   $0xa86
 1d1:	6a 01                	push   $0x1
 1d3:	e8 d0 04 00 00       	call   6a8 <printf>
 1d8:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < 100; i++)
 1db:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 1e2:	eb 1c                	jmp    200 <mythread+0x3d>
  {
    printf(1, "%d my thread 0x%x\n", i, (int)current_thread);
 1e4:	a1 e0 0d 00 00       	mov    0xde0,%eax
 1e9:	50                   	push   %eax
 1ea:	ff 75 f4             	push   -0xc(%ebp)
 1ed:	68 99 0a 00 00       	push   $0xa99
 1f2:	6a 01                	push   $0x1
 1f4:	e8 af 04 00 00       	call   6a8 <printf>
 1f9:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < 100; i++)
 1fc:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 200:	83 7d f4 63          	cmpl   $0x63,-0xc(%ebp)
 204:	7e de                	jle    1e4 <mythread+0x21>
    // thread_yield();
  }
  printf(1, "my thread: exit\n");
 206:	83 ec 08             	sub    $0x8,%esp
 209:	68 ac 0a 00 00       	push   $0xaac
 20e:	6a 01                	push   $0x1
 210:	e8 93 04 00 00       	call   6a8 <printf>
 215:	83 c4 10             	add    $0x10,%esp
  current_thread->state = FREE;
 218:	a1 e0 0d 00 00       	mov    0xde0,%eax
 21d:	c7 80 04 20 00 00 00 	movl   $0x0,0x2004(%eax)
 224:	00 00 00 
  num_thread--;
 227:	a1 20 8e 00 00       	mov    0x8e20,%eax
 22c:	83 e8 01             	sub    $0x1,%eax
 22f:	a3 20 8e 00 00       	mov    %eax,0x8e20
  thread_num(num_thread);
 234:	a1 20 8e 00 00       	mov    0x8e20,%eax
 239:	83 ec 0c             	sub    $0xc,%esp
 23c:	50                   	push   %eax
 23d:	e8 8a 03 00 00       	call   5cc <thread_num>
 242:	83 c4 10             	add    $0x10,%esp
  thread_schedule();
 245:	e8 04 fe ff ff       	call   4e <thread_schedule>
}
 24a:	90                   	nop
 24b:	c9                   	leave  
 24c:	c3                   	ret    

0000024d <main>:

int main(int argc, char *argv[])
{
 24d:	8d 4c 24 04          	lea    0x4(%esp),%ecx
 251:	83 e4 f0             	and    $0xfffffff0,%esp
 254:	ff 71 fc             	push   -0x4(%ecx)
 257:	55                   	push   %ebp
 258:	89 e5                	mov    %esp,%ebp
 25a:	51                   	push   %ecx
 25b:	83 ec 04             	sub    $0x4,%esp
  printf(1, "addr : %d", (uint)thread_schedule);
 25e:	b8 4e 00 00 00       	mov    $0x4e,%eax
 263:	83 ec 04             	sub    $0x4,%esp
 266:	50                   	push   %eax
 267:	68 bd 0a 00 00       	push   $0xabd
 26c:	6a 01                	push   $0x1
 26e:	e8 35 04 00 00       	call   6a8 <printf>
 273:	83 c4 10             	add    $0x10,%esp
  thread_init();
 276:	e8 85 fd ff ff       	call   0 <thread_init>
  thread_create(mythread);
 27b:	83 ec 0c             	sub    $0xc,%esp
 27e:	68 c3 01 00 00       	push   $0x1c3
 283:	e8 88 fe ff ff       	call   110 <thread_create>
 288:	83 c4 10             	add    $0x10,%esp
  thread_create(mythread);
 28b:	83 ec 0c             	sub    $0xc,%esp
 28e:	68 c3 01 00 00       	push   $0x1c3
 293:	e8 78 fe ff ff       	call   110 <thread_create>
 298:	83 c4 10             	add    $0x10,%esp
  thread_schedule();
 29b:	e8 ae fd ff ff       	call   4e <thread_schedule>
  return 0;
 2a0:	b8 00 00 00 00       	mov    $0x0,%eax
 2a5:	8b 4d fc             	mov    -0x4(%ebp),%ecx
 2a8:	c9                   	leave  
 2a9:	8d 61 fc             	lea    -0x4(%ecx),%esp
 2ac:	c3                   	ret    

000002ad <thread_switch>:
         */

   .globl thread_switch
thread_switch:
   /* YOUR CODE HERE */
   pushal
 2ad:	60                   	pusha  

   movl current_thread, %eax
 2ae:	a1 e0 0d 00 00       	mov    0xde0,%eax
   movl %esp, (%eax)
 2b3:	89 20                	mov    %esp,(%eax)

   movl next_thread, %eax
 2b5:	a1 e4 0d 00 00       	mov    0xde4,%eax
   movl (%eax), %esp
 2ba:	8b 20                	mov    (%eax),%esp

   movl %eax, current_thread
 2bc:	a3 e0 0d 00 00       	mov    %eax,0xde0

   popal
 2c1:	61                   	popa   

   movl $0, next_thread
 2c2:	c7 05 e4 0d 00 00 00 	movl   $0x0,0xde4
 2c9:	00 00 00 


 2cc:	c3                   	ret    

000002cd <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 2cd:	55                   	push   %ebp
 2ce:	89 e5                	mov    %esp,%ebp
 2d0:	57                   	push   %edi
 2d1:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 2d2:	8b 4d 08             	mov    0x8(%ebp),%ecx
 2d5:	8b 55 10             	mov    0x10(%ebp),%edx
 2d8:	8b 45 0c             	mov    0xc(%ebp),%eax
 2db:	89 cb                	mov    %ecx,%ebx
 2dd:	89 df                	mov    %ebx,%edi
 2df:	89 d1                	mov    %edx,%ecx
 2e1:	fc                   	cld    
 2e2:	f3 aa                	rep stos %al,%es:(%edi)
 2e4:	89 ca                	mov    %ecx,%edx
 2e6:	89 fb                	mov    %edi,%ebx
 2e8:	89 5d 08             	mov    %ebx,0x8(%ebp)
 2eb:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 2ee:	90                   	nop
 2ef:	5b                   	pop    %ebx
 2f0:	5f                   	pop    %edi
 2f1:	5d                   	pop    %ebp
 2f2:	c3                   	ret    

000002f3 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 2f3:	55                   	push   %ebp
 2f4:	89 e5                	mov    %esp,%ebp
 2f6:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 2f9:	8b 45 08             	mov    0x8(%ebp),%eax
 2fc:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 2ff:	90                   	nop
 300:	8b 55 0c             	mov    0xc(%ebp),%edx
 303:	8d 42 01             	lea    0x1(%edx),%eax
 306:	89 45 0c             	mov    %eax,0xc(%ebp)
 309:	8b 45 08             	mov    0x8(%ebp),%eax
 30c:	8d 48 01             	lea    0x1(%eax),%ecx
 30f:	89 4d 08             	mov    %ecx,0x8(%ebp)
 312:	0f b6 12             	movzbl (%edx),%edx
 315:	88 10                	mov    %dl,(%eax)
 317:	0f b6 00             	movzbl (%eax),%eax
 31a:	84 c0                	test   %al,%al
 31c:	75 e2                	jne    300 <strcpy+0xd>
    ;
  return os;
 31e:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 321:	c9                   	leave  
 322:	c3                   	ret    

00000323 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 323:	55                   	push   %ebp
 324:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 326:	eb 08                	jmp    330 <strcmp+0xd>
    p++, q++;
 328:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 32c:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(*p && *p == *q)
 330:	8b 45 08             	mov    0x8(%ebp),%eax
 333:	0f b6 00             	movzbl (%eax),%eax
 336:	84 c0                	test   %al,%al
 338:	74 10                	je     34a <strcmp+0x27>
 33a:	8b 45 08             	mov    0x8(%ebp),%eax
 33d:	0f b6 10             	movzbl (%eax),%edx
 340:	8b 45 0c             	mov    0xc(%ebp),%eax
 343:	0f b6 00             	movzbl (%eax),%eax
 346:	38 c2                	cmp    %al,%dl
 348:	74 de                	je     328 <strcmp+0x5>
  return (uchar)*p - (uchar)*q;
 34a:	8b 45 08             	mov    0x8(%ebp),%eax
 34d:	0f b6 00             	movzbl (%eax),%eax
 350:	0f b6 d0             	movzbl %al,%edx
 353:	8b 45 0c             	mov    0xc(%ebp),%eax
 356:	0f b6 00             	movzbl (%eax),%eax
 359:	0f b6 c8             	movzbl %al,%ecx
 35c:	89 d0                	mov    %edx,%eax
 35e:	29 c8                	sub    %ecx,%eax
}
 360:	5d                   	pop    %ebp
 361:	c3                   	ret    

00000362 <strlen>:

uint
strlen(char *s)
{
 362:	55                   	push   %ebp
 363:	89 e5                	mov    %esp,%ebp
 365:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 368:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 36f:	eb 04                	jmp    375 <strlen+0x13>
 371:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 375:	8b 55 fc             	mov    -0x4(%ebp),%edx
 378:	8b 45 08             	mov    0x8(%ebp),%eax
 37b:	01 d0                	add    %edx,%eax
 37d:	0f b6 00             	movzbl (%eax),%eax
 380:	84 c0                	test   %al,%al
 382:	75 ed                	jne    371 <strlen+0xf>
    ;
  return n;
 384:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 387:	c9                   	leave  
 388:	c3                   	ret    

00000389 <memset>:

void*
memset(void *dst, int c, uint n)
{
 389:	55                   	push   %ebp
 38a:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
 38c:	8b 45 10             	mov    0x10(%ebp),%eax
 38f:	50                   	push   %eax
 390:	ff 75 0c             	push   0xc(%ebp)
 393:	ff 75 08             	push   0x8(%ebp)
 396:	e8 32 ff ff ff       	call   2cd <stosb>
 39b:	83 c4 0c             	add    $0xc,%esp
  return dst;
 39e:	8b 45 08             	mov    0x8(%ebp),%eax
}
 3a1:	c9                   	leave  
 3a2:	c3                   	ret    

000003a3 <strchr>:

char*
strchr(const char *s, char c)
{
 3a3:	55                   	push   %ebp
 3a4:	89 e5                	mov    %esp,%ebp
 3a6:	83 ec 04             	sub    $0x4,%esp
 3a9:	8b 45 0c             	mov    0xc(%ebp),%eax
 3ac:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 3af:	eb 14                	jmp    3c5 <strchr+0x22>
    if(*s == c)
 3b1:	8b 45 08             	mov    0x8(%ebp),%eax
 3b4:	0f b6 00             	movzbl (%eax),%eax
 3b7:	38 45 fc             	cmp    %al,-0x4(%ebp)
 3ba:	75 05                	jne    3c1 <strchr+0x1e>
      return (char*)s;
 3bc:	8b 45 08             	mov    0x8(%ebp),%eax
 3bf:	eb 13                	jmp    3d4 <strchr+0x31>
  for(; *s; s++)
 3c1:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 3c5:	8b 45 08             	mov    0x8(%ebp),%eax
 3c8:	0f b6 00             	movzbl (%eax),%eax
 3cb:	84 c0                	test   %al,%al
 3cd:	75 e2                	jne    3b1 <strchr+0xe>
  return 0;
 3cf:	b8 00 00 00 00       	mov    $0x0,%eax
}
 3d4:	c9                   	leave  
 3d5:	c3                   	ret    

000003d6 <gets>:

char*
gets(char *buf, int max)
{
 3d6:	55                   	push   %ebp
 3d7:	89 e5                	mov    %esp,%ebp
 3d9:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 3dc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 3e3:	eb 42                	jmp    427 <gets+0x51>
    cc = read(0, &c, 1);
 3e5:	83 ec 04             	sub    $0x4,%esp
 3e8:	6a 01                	push   $0x1
 3ea:	8d 45 ef             	lea    -0x11(%ebp),%eax
 3ed:	50                   	push   %eax
 3ee:	6a 00                	push   $0x0
 3f0:	e8 47 01 00 00       	call   53c <read>
 3f5:	83 c4 10             	add    $0x10,%esp
 3f8:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 3fb:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 3ff:	7e 33                	jle    434 <gets+0x5e>
      break;
    buf[i++] = c;
 401:	8b 45 f4             	mov    -0xc(%ebp),%eax
 404:	8d 50 01             	lea    0x1(%eax),%edx
 407:	89 55 f4             	mov    %edx,-0xc(%ebp)
 40a:	89 c2                	mov    %eax,%edx
 40c:	8b 45 08             	mov    0x8(%ebp),%eax
 40f:	01 c2                	add    %eax,%edx
 411:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 415:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 417:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 41b:	3c 0a                	cmp    $0xa,%al
 41d:	74 16                	je     435 <gets+0x5f>
 41f:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 423:	3c 0d                	cmp    $0xd,%al
 425:	74 0e                	je     435 <gets+0x5f>
  for(i=0; i+1 < max; ){
 427:	8b 45 f4             	mov    -0xc(%ebp),%eax
 42a:	83 c0 01             	add    $0x1,%eax
 42d:	39 45 0c             	cmp    %eax,0xc(%ebp)
 430:	7f b3                	jg     3e5 <gets+0xf>
 432:	eb 01                	jmp    435 <gets+0x5f>
      break;
 434:	90                   	nop
      break;
  }
  buf[i] = '\0';
 435:	8b 55 f4             	mov    -0xc(%ebp),%edx
 438:	8b 45 08             	mov    0x8(%ebp),%eax
 43b:	01 d0                	add    %edx,%eax
 43d:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 440:	8b 45 08             	mov    0x8(%ebp),%eax
}
 443:	c9                   	leave  
 444:	c3                   	ret    

00000445 <stat>:

int
stat(char *n, struct stat *st)
{
 445:	55                   	push   %ebp
 446:	89 e5                	mov    %esp,%ebp
 448:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 44b:	83 ec 08             	sub    $0x8,%esp
 44e:	6a 00                	push   $0x0
 450:	ff 75 08             	push   0x8(%ebp)
 453:	e8 0c 01 00 00       	call   564 <open>
 458:	83 c4 10             	add    $0x10,%esp
 45b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 45e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 462:	79 07                	jns    46b <stat+0x26>
    return -1;
 464:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 469:	eb 25                	jmp    490 <stat+0x4b>
  r = fstat(fd, st);
 46b:	83 ec 08             	sub    $0x8,%esp
 46e:	ff 75 0c             	push   0xc(%ebp)
 471:	ff 75 f4             	push   -0xc(%ebp)
 474:	e8 03 01 00 00       	call   57c <fstat>
 479:	83 c4 10             	add    $0x10,%esp
 47c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 47f:	83 ec 0c             	sub    $0xc,%esp
 482:	ff 75 f4             	push   -0xc(%ebp)
 485:	e8 c2 00 00 00       	call   54c <close>
 48a:	83 c4 10             	add    $0x10,%esp
  return r;
 48d:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 490:	c9                   	leave  
 491:	c3                   	ret    

00000492 <atoi>:

int
atoi(const char *s)
{
 492:	55                   	push   %ebp
 493:	89 e5                	mov    %esp,%ebp
 495:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 498:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 49f:	eb 25                	jmp    4c6 <atoi+0x34>
    n = n*10 + *s++ - '0';
 4a1:	8b 55 fc             	mov    -0x4(%ebp),%edx
 4a4:	89 d0                	mov    %edx,%eax
 4a6:	c1 e0 02             	shl    $0x2,%eax
 4a9:	01 d0                	add    %edx,%eax
 4ab:	01 c0                	add    %eax,%eax
 4ad:	89 c1                	mov    %eax,%ecx
 4af:	8b 45 08             	mov    0x8(%ebp),%eax
 4b2:	8d 50 01             	lea    0x1(%eax),%edx
 4b5:	89 55 08             	mov    %edx,0x8(%ebp)
 4b8:	0f b6 00             	movzbl (%eax),%eax
 4bb:	0f be c0             	movsbl %al,%eax
 4be:	01 c8                	add    %ecx,%eax
 4c0:	83 e8 30             	sub    $0x30,%eax
 4c3:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 4c6:	8b 45 08             	mov    0x8(%ebp),%eax
 4c9:	0f b6 00             	movzbl (%eax),%eax
 4cc:	3c 2f                	cmp    $0x2f,%al
 4ce:	7e 0a                	jle    4da <atoi+0x48>
 4d0:	8b 45 08             	mov    0x8(%ebp),%eax
 4d3:	0f b6 00             	movzbl (%eax),%eax
 4d6:	3c 39                	cmp    $0x39,%al
 4d8:	7e c7                	jle    4a1 <atoi+0xf>
  return n;
 4da:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 4dd:	c9                   	leave  
 4de:	c3                   	ret    

000004df <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 4df:	55                   	push   %ebp
 4e0:	89 e5                	mov    %esp,%ebp
 4e2:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;

  dst = vdst;
 4e5:	8b 45 08             	mov    0x8(%ebp),%eax
 4e8:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 4eb:	8b 45 0c             	mov    0xc(%ebp),%eax
 4ee:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 4f1:	eb 17                	jmp    50a <memmove+0x2b>
    *dst++ = *src++;
 4f3:	8b 55 f8             	mov    -0x8(%ebp),%edx
 4f6:	8d 42 01             	lea    0x1(%edx),%eax
 4f9:	89 45 f8             	mov    %eax,-0x8(%ebp)
 4fc:	8b 45 fc             	mov    -0x4(%ebp),%eax
 4ff:	8d 48 01             	lea    0x1(%eax),%ecx
 502:	89 4d fc             	mov    %ecx,-0x4(%ebp)
 505:	0f b6 12             	movzbl (%edx),%edx
 508:	88 10                	mov    %dl,(%eax)
  while(n-- > 0)
 50a:	8b 45 10             	mov    0x10(%ebp),%eax
 50d:	8d 50 ff             	lea    -0x1(%eax),%edx
 510:	89 55 10             	mov    %edx,0x10(%ebp)
 513:	85 c0                	test   %eax,%eax
 515:	7f dc                	jg     4f3 <memmove+0x14>
  return vdst;
 517:	8b 45 08             	mov    0x8(%ebp),%eax
}
 51a:	c9                   	leave  
 51b:	c3                   	ret    

0000051c <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 51c:	b8 01 00 00 00       	mov    $0x1,%eax
 521:	cd 40                	int    $0x40
 523:	c3                   	ret    

00000524 <exit>:
SYSCALL(exit)
 524:	b8 02 00 00 00       	mov    $0x2,%eax
 529:	cd 40                	int    $0x40
 52b:	c3                   	ret    

0000052c <wait>:
SYSCALL(wait)
 52c:	b8 03 00 00 00       	mov    $0x3,%eax
 531:	cd 40                	int    $0x40
 533:	c3                   	ret    

00000534 <pipe>:
SYSCALL(pipe)
 534:	b8 04 00 00 00       	mov    $0x4,%eax
 539:	cd 40                	int    $0x40
 53b:	c3                   	ret    

0000053c <read>:
SYSCALL(read)
 53c:	b8 05 00 00 00       	mov    $0x5,%eax
 541:	cd 40                	int    $0x40
 543:	c3                   	ret    

00000544 <write>:
SYSCALL(write)
 544:	b8 10 00 00 00       	mov    $0x10,%eax
 549:	cd 40                	int    $0x40
 54b:	c3                   	ret    

0000054c <close>:
SYSCALL(close)
 54c:	b8 15 00 00 00       	mov    $0x15,%eax
 551:	cd 40                	int    $0x40
 553:	c3                   	ret    

00000554 <kill>:
SYSCALL(kill)
 554:	b8 06 00 00 00       	mov    $0x6,%eax
 559:	cd 40                	int    $0x40
 55b:	c3                   	ret    

0000055c <exec>:
SYSCALL(exec)
 55c:	b8 07 00 00 00       	mov    $0x7,%eax
 561:	cd 40                	int    $0x40
 563:	c3                   	ret    

00000564 <open>:
SYSCALL(open)
 564:	b8 0f 00 00 00       	mov    $0xf,%eax
 569:	cd 40                	int    $0x40
 56b:	c3                   	ret    

0000056c <mknod>:
SYSCALL(mknod)
 56c:	b8 11 00 00 00       	mov    $0x11,%eax
 571:	cd 40                	int    $0x40
 573:	c3                   	ret    

00000574 <unlink>:
SYSCALL(unlink)
 574:	b8 12 00 00 00       	mov    $0x12,%eax
 579:	cd 40                	int    $0x40
 57b:	c3                   	ret    

0000057c <fstat>:
SYSCALL(fstat)
 57c:	b8 08 00 00 00       	mov    $0x8,%eax
 581:	cd 40                	int    $0x40
 583:	c3                   	ret    

00000584 <link>:
SYSCALL(link)
 584:	b8 13 00 00 00       	mov    $0x13,%eax
 589:	cd 40                	int    $0x40
 58b:	c3                   	ret    

0000058c <mkdir>:
SYSCALL(mkdir)
 58c:	b8 14 00 00 00       	mov    $0x14,%eax
 591:	cd 40                	int    $0x40
 593:	c3                   	ret    

00000594 <chdir>:
SYSCALL(chdir)
 594:	b8 09 00 00 00       	mov    $0x9,%eax
 599:	cd 40                	int    $0x40
 59b:	c3                   	ret    

0000059c <dup>:
SYSCALL(dup)
 59c:	b8 0a 00 00 00       	mov    $0xa,%eax
 5a1:	cd 40                	int    $0x40
 5a3:	c3                   	ret    

000005a4 <getpid>:
SYSCALL(getpid)
 5a4:	b8 0b 00 00 00       	mov    $0xb,%eax
 5a9:	cd 40                	int    $0x40
 5ab:	c3                   	ret    

000005ac <sbrk>:
SYSCALL(sbrk)
 5ac:	b8 0c 00 00 00       	mov    $0xc,%eax
 5b1:	cd 40                	int    $0x40
 5b3:	c3                   	ret    

000005b4 <sleep>:
SYSCALL(sleep)
 5b4:	b8 0d 00 00 00       	mov    $0xd,%eax
 5b9:	cd 40                	int    $0x40
 5bb:	c3                   	ret    

000005bc <uptime>:
SYSCALL(uptime)
 5bc:	b8 0e 00 00 00       	mov    $0xe,%eax
 5c1:	cd 40                	int    $0x40
 5c3:	c3                   	ret    

000005c4 <uthread_init>:
SYSCALL(uthread_init)
 5c4:	b8 16 00 00 00       	mov    $0x16,%eax
 5c9:	cd 40                	int    $0x40
 5cb:	c3                   	ret    

000005cc <thread_num>:
 5cc:	b8 17 00 00 00       	mov    $0x17,%eax
 5d1:	cd 40                	int    $0x40
 5d3:	c3                   	ret    

000005d4 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 5d4:	55                   	push   %ebp
 5d5:	89 e5                	mov    %esp,%ebp
 5d7:	83 ec 18             	sub    $0x18,%esp
 5da:	8b 45 0c             	mov    0xc(%ebp),%eax
 5dd:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 5e0:	83 ec 04             	sub    $0x4,%esp
 5e3:	6a 01                	push   $0x1
 5e5:	8d 45 f4             	lea    -0xc(%ebp),%eax
 5e8:	50                   	push   %eax
 5e9:	ff 75 08             	push   0x8(%ebp)
 5ec:	e8 53 ff ff ff       	call   544 <write>
 5f1:	83 c4 10             	add    $0x10,%esp
}
 5f4:	90                   	nop
 5f5:	c9                   	leave  
 5f6:	c3                   	ret    

000005f7 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 5f7:	55                   	push   %ebp
 5f8:	89 e5                	mov    %esp,%ebp
 5fa:	83 ec 28             	sub    $0x28,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 5fd:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 604:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 608:	74 17                	je     621 <printint+0x2a>
 60a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 60e:	79 11                	jns    621 <printint+0x2a>
    neg = 1;
 610:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 617:	8b 45 0c             	mov    0xc(%ebp),%eax
 61a:	f7 d8                	neg    %eax
 61c:	89 45 ec             	mov    %eax,-0x14(%ebp)
 61f:	eb 06                	jmp    627 <printint+0x30>
  } else {
    x = xx;
 621:	8b 45 0c             	mov    0xc(%ebp),%eax
 624:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 627:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 62e:	8b 4d 10             	mov    0x10(%ebp),%ecx
 631:	8b 45 ec             	mov    -0x14(%ebp),%eax
 634:	ba 00 00 00 00       	mov    $0x0,%edx
 639:	f7 f1                	div    %ecx
 63b:	89 d1                	mov    %edx,%ecx
 63d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 640:	8d 50 01             	lea    0x1(%eax),%edx
 643:	89 55 f4             	mov    %edx,-0xc(%ebp)
 646:	0f b6 91 bc 0d 00 00 	movzbl 0xdbc(%ecx),%edx
 64d:	88 54 05 dc          	mov    %dl,-0x24(%ebp,%eax,1)
  }while((x /= base) != 0);
 651:	8b 4d 10             	mov    0x10(%ebp),%ecx
 654:	8b 45 ec             	mov    -0x14(%ebp),%eax
 657:	ba 00 00 00 00       	mov    $0x0,%edx
 65c:	f7 f1                	div    %ecx
 65e:	89 45 ec             	mov    %eax,-0x14(%ebp)
 661:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 665:	75 c7                	jne    62e <printint+0x37>
  if(neg)
 667:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 66b:	74 2d                	je     69a <printint+0xa3>
    buf[i++] = '-';
 66d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 670:	8d 50 01             	lea    0x1(%eax),%edx
 673:	89 55 f4             	mov    %edx,-0xc(%ebp)
 676:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 67b:	eb 1d                	jmp    69a <printint+0xa3>
    putc(fd, buf[i]);
 67d:	8d 55 dc             	lea    -0x24(%ebp),%edx
 680:	8b 45 f4             	mov    -0xc(%ebp),%eax
 683:	01 d0                	add    %edx,%eax
 685:	0f b6 00             	movzbl (%eax),%eax
 688:	0f be c0             	movsbl %al,%eax
 68b:	83 ec 08             	sub    $0x8,%esp
 68e:	50                   	push   %eax
 68f:	ff 75 08             	push   0x8(%ebp)
 692:	e8 3d ff ff ff       	call   5d4 <putc>
 697:	83 c4 10             	add    $0x10,%esp
  while(--i >= 0)
 69a:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 69e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 6a2:	79 d9                	jns    67d <printint+0x86>
}
 6a4:	90                   	nop
 6a5:	90                   	nop
 6a6:	c9                   	leave  
 6a7:	c3                   	ret    

000006a8 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 6a8:	55                   	push   %ebp
 6a9:	89 e5                	mov    %esp,%ebp
 6ab:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 6ae:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 6b5:	8d 45 0c             	lea    0xc(%ebp),%eax
 6b8:	83 c0 04             	add    $0x4,%eax
 6bb:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 6be:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 6c5:	e9 59 01 00 00       	jmp    823 <printf+0x17b>
    c = fmt[i] & 0xff;
 6ca:	8b 55 0c             	mov    0xc(%ebp),%edx
 6cd:	8b 45 f0             	mov    -0x10(%ebp),%eax
 6d0:	01 d0                	add    %edx,%eax
 6d2:	0f b6 00             	movzbl (%eax),%eax
 6d5:	0f be c0             	movsbl %al,%eax
 6d8:	25 ff 00 00 00       	and    $0xff,%eax
 6dd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 6e0:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 6e4:	75 2c                	jne    712 <printf+0x6a>
      if(c == '%'){
 6e6:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 6ea:	75 0c                	jne    6f8 <printf+0x50>
        state = '%';
 6ec:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 6f3:	e9 27 01 00 00       	jmp    81f <printf+0x177>
      } else {
        putc(fd, c);
 6f8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 6fb:	0f be c0             	movsbl %al,%eax
 6fe:	83 ec 08             	sub    $0x8,%esp
 701:	50                   	push   %eax
 702:	ff 75 08             	push   0x8(%ebp)
 705:	e8 ca fe ff ff       	call   5d4 <putc>
 70a:	83 c4 10             	add    $0x10,%esp
 70d:	e9 0d 01 00 00       	jmp    81f <printf+0x177>
      }
    } else if(state == '%'){
 712:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 716:	0f 85 03 01 00 00    	jne    81f <printf+0x177>
      if(c == 'd'){
 71c:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 720:	75 1e                	jne    740 <printf+0x98>
        printint(fd, *ap, 10, 1);
 722:	8b 45 e8             	mov    -0x18(%ebp),%eax
 725:	8b 00                	mov    (%eax),%eax
 727:	6a 01                	push   $0x1
 729:	6a 0a                	push   $0xa
 72b:	50                   	push   %eax
 72c:	ff 75 08             	push   0x8(%ebp)
 72f:	e8 c3 fe ff ff       	call   5f7 <printint>
 734:	83 c4 10             	add    $0x10,%esp
        ap++;
 737:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 73b:	e9 d8 00 00 00       	jmp    818 <printf+0x170>
      } else if(c == 'x' || c == 'p'){
 740:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 744:	74 06                	je     74c <printf+0xa4>
 746:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 74a:	75 1e                	jne    76a <printf+0xc2>
        printint(fd, *ap, 16, 0);
 74c:	8b 45 e8             	mov    -0x18(%ebp),%eax
 74f:	8b 00                	mov    (%eax),%eax
 751:	6a 00                	push   $0x0
 753:	6a 10                	push   $0x10
 755:	50                   	push   %eax
 756:	ff 75 08             	push   0x8(%ebp)
 759:	e8 99 fe ff ff       	call   5f7 <printint>
 75e:	83 c4 10             	add    $0x10,%esp
        ap++;
 761:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 765:	e9 ae 00 00 00       	jmp    818 <printf+0x170>
      } else if(c == 's'){
 76a:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 76e:	75 43                	jne    7b3 <printf+0x10b>
        s = (char*)*ap;
 770:	8b 45 e8             	mov    -0x18(%ebp),%eax
 773:	8b 00                	mov    (%eax),%eax
 775:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 778:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 77c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 780:	75 25                	jne    7a7 <printf+0xff>
          s = "(null)";
 782:	c7 45 f4 c7 0a 00 00 	movl   $0xac7,-0xc(%ebp)
        while(*s != 0){
 789:	eb 1c                	jmp    7a7 <printf+0xff>
          putc(fd, *s);
 78b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 78e:	0f b6 00             	movzbl (%eax),%eax
 791:	0f be c0             	movsbl %al,%eax
 794:	83 ec 08             	sub    $0x8,%esp
 797:	50                   	push   %eax
 798:	ff 75 08             	push   0x8(%ebp)
 79b:	e8 34 fe ff ff       	call   5d4 <putc>
 7a0:	83 c4 10             	add    $0x10,%esp
          s++;
 7a3:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
        while(*s != 0){
 7a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7aa:	0f b6 00             	movzbl (%eax),%eax
 7ad:	84 c0                	test   %al,%al
 7af:	75 da                	jne    78b <printf+0xe3>
 7b1:	eb 65                	jmp    818 <printf+0x170>
        }
      } else if(c == 'c'){
 7b3:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 7b7:	75 1d                	jne    7d6 <printf+0x12e>
        putc(fd, *ap);
 7b9:	8b 45 e8             	mov    -0x18(%ebp),%eax
 7bc:	8b 00                	mov    (%eax),%eax
 7be:	0f be c0             	movsbl %al,%eax
 7c1:	83 ec 08             	sub    $0x8,%esp
 7c4:	50                   	push   %eax
 7c5:	ff 75 08             	push   0x8(%ebp)
 7c8:	e8 07 fe ff ff       	call   5d4 <putc>
 7cd:	83 c4 10             	add    $0x10,%esp
        ap++;
 7d0:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 7d4:	eb 42                	jmp    818 <printf+0x170>
      } else if(c == '%'){
 7d6:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 7da:	75 17                	jne    7f3 <printf+0x14b>
        putc(fd, c);
 7dc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 7df:	0f be c0             	movsbl %al,%eax
 7e2:	83 ec 08             	sub    $0x8,%esp
 7e5:	50                   	push   %eax
 7e6:	ff 75 08             	push   0x8(%ebp)
 7e9:	e8 e6 fd ff ff       	call   5d4 <putc>
 7ee:	83 c4 10             	add    $0x10,%esp
 7f1:	eb 25                	jmp    818 <printf+0x170>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 7f3:	83 ec 08             	sub    $0x8,%esp
 7f6:	6a 25                	push   $0x25
 7f8:	ff 75 08             	push   0x8(%ebp)
 7fb:	e8 d4 fd ff ff       	call   5d4 <putc>
 800:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 803:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 806:	0f be c0             	movsbl %al,%eax
 809:	83 ec 08             	sub    $0x8,%esp
 80c:	50                   	push   %eax
 80d:	ff 75 08             	push   0x8(%ebp)
 810:	e8 bf fd ff ff       	call   5d4 <putc>
 815:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 818:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(i = 0; fmt[i]; i++){
 81f:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 823:	8b 55 0c             	mov    0xc(%ebp),%edx
 826:	8b 45 f0             	mov    -0x10(%ebp),%eax
 829:	01 d0                	add    %edx,%eax
 82b:	0f b6 00             	movzbl (%eax),%eax
 82e:	84 c0                	test   %al,%al
 830:	0f 85 94 fe ff ff    	jne    6ca <printf+0x22>
    }
  }
}
 836:	90                   	nop
 837:	90                   	nop
 838:	c9                   	leave  
 839:	c3                   	ret    

0000083a <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 83a:	55                   	push   %ebp
 83b:	89 e5                	mov    %esp,%ebp
 83d:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 840:	8b 45 08             	mov    0x8(%ebp),%eax
 843:	83 e8 08             	sub    $0x8,%eax
 846:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 849:	a1 2c 8e 00 00       	mov    0x8e2c,%eax
 84e:	89 45 fc             	mov    %eax,-0x4(%ebp)
 851:	eb 24                	jmp    877 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 853:	8b 45 fc             	mov    -0x4(%ebp),%eax
 856:	8b 00                	mov    (%eax),%eax
 858:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 85b:	72 12                	jb     86f <free+0x35>
 85d:	8b 45 f8             	mov    -0x8(%ebp),%eax
 860:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 863:	77 24                	ja     889 <free+0x4f>
 865:	8b 45 fc             	mov    -0x4(%ebp),%eax
 868:	8b 00                	mov    (%eax),%eax
 86a:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 86d:	72 1a                	jb     889 <free+0x4f>
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 86f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 872:	8b 00                	mov    (%eax),%eax
 874:	89 45 fc             	mov    %eax,-0x4(%ebp)
 877:	8b 45 f8             	mov    -0x8(%ebp),%eax
 87a:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 87d:	76 d4                	jbe    853 <free+0x19>
 87f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 882:	8b 00                	mov    (%eax),%eax
 884:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 887:	73 ca                	jae    853 <free+0x19>
      break;
  if(bp + bp->s.size == p->s.ptr){
 889:	8b 45 f8             	mov    -0x8(%ebp),%eax
 88c:	8b 40 04             	mov    0x4(%eax),%eax
 88f:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 896:	8b 45 f8             	mov    -0x8(%ebp),%eax
 899:	01 c2                	add    %eax,%edx
 89b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 89e:	8b 00                	mov    (%eax),%eax
 8a0:	39 c2                	cmp    %eax,%edx
 8a2:	75 24                	jne    8c8 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 8a4:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8a7:	8b 50 04             	mov    0x4(%eax),%edx
 8aa:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8ad:	8b 00                	mov    (%eax),%eax
 8af:	8b 40 04             	mov    0x4(%eax),%eax
 8b2:	01 c2                	add    %eax,%edx
 8b4:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8b7:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 8ba:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8bd:	8b 00                	mov    (%eax),%eax
 8bf:	8b 10                	mov    (%eax),%edx
 8c1:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8c4:	89 10                	mov    %edx,(%eax)
 8c6:	eb 0a                	jmp    8d2 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 8c8:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8cb:	8b 10                	mov    (%eax),%edx
 8cd:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8d0:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 8d2:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8d5:	8b 40 04             	mov    0x4(%eax),%eax
 8d8:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 8df:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8e2:	01 d0                	add    %edx,%eax
 8e4:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 8e7:	75 20                	jne    909 <free+0xcf>
    p->s.size += bp->s.size;
 8e9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8ec:	8b 50 04             	mov    0x4(%eax),%edx
 8ef:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8f2:	8b 40 04             	mov    0x4(%eax),%eax
 8f5:	01 c2                	add    %eax,%edx
 8f7:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8fa:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 8fd:	8b 45 f8             	mov    -0x8(%ebp),%eax
 900:	8b 10                	mov    (%eax),%edx
 902:	8b 45 fc             	mov    -0x4(%ebp),%eax
 905:	89 10                	mov    %edx,(%eax)
 907:	eb 08                	jmp    911 <free+0xd7>
  } else
    p->s.ptr = bp;
 909:	8b 45 fc             	mov    -0x4(%ebp),%eax
 90c:	8b 55 f8             	mov    -0x8(%ebp),%edx
 90f:	89 10                	mov    %edx,(%eax)
  freep = p;
 911:	8b 45 fc             	mov    -0x4(%ebp),%eax
 914:	a3 2c 8e 00 00       	mov    %eax,0x8e2c
}
 919:	90                   	nop
 91a:	c9                   	leave  
 91b:	c3                   	ret    

0000091c <morecore>:

static Header*
morecore(uint nu)
{
 91c:	55                   	push   %ebp
 91d:	89 e5                	mov    %esp,%ebp
 91f:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 922:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 929:	77 07                	ja     932 <morecore+0x16>
    nu = 4096;
 92b:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 932:	8b 45 08             	mov    0x8(%ebp),%eax
 935:	c1 e0 03             	shl    $0x3,%eax
 938:	83 ec 0c             	sub    $0xc,%esp
 93b:	50                   	push   %eax
 93c:	e8 6b fc ff ff       	call   5ac <sbrk>
 941:	83 c4 10             	add    $0x10,%esp
 944:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 947:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 94b:	75 07                	jne    954 <morecore+0x38>
    return 0;
 94d:	b8 00 00 00 00       	mov    $0x0,%eax
 952:	eb 26                	jmp    97a <morecore+0x5e>
  hp = (Header*)p;
 954:	8b 45 f4             	mov    -0xc(%ebp),%eax
 957:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 95a:	8b 45 f0             	mov    -0x10(%ebp),%eax
 95d:	8b 55 08             	mov    0x8(%ebp),%edx
 960:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 963:	8b 45 f0             	mov    -0x10(%ebp),%eax
 966:	83 c0 08             	add    $0x8,%eax
 969:	83 ec 0c             	sub    $0xc,%esp
 96c:	50                   	push   %eax
 96d:	e8 c8 fe ff ff       	call   83a <free>
 972:	83 c4 10             	add    $0x10,%esp
  return freep;
 975:	a1 2c 8e 00 00       	mov    0x8e2c,%eax
}
 97a:	c9                   	leave  
 97b:	c3                   	ret    

0000097c <malloc>:

void*
malloc(uint nbytes)
{
 97c:	55                   	push   %ebp
 97d:	89 e5                	mov    %esp,%ebp
 97f:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 982:	8b 45 08             	mov    0x8(%ebp),%eax
 985:	83 c0 07             	add    $0x7,%eax
 988:	c1 e8 03             	shr    $0x3,%eax
 98b:	83 c0 01             	add    $0x1,%eax
 98e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 991:	a1 2c 8e 00 00       	mov    0x8e2c,%eax
 996:	89 45 f0             	mov    %eax,-0x10(%ebp)
 999:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 99d:	75 23                	jne    9c2 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 99f:	c7 45 f0 24 8e 00 00 	movl   $0x8e24,-0x10(%ebp)
 9a6:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9a9:	a3 2c 8e 00 00       	mov    %eax,0x8e2c
 9ae:	a1 2c 8e 00 00       	mov    0x8e2c,%eax
 9b3:	a3 24 8e 00 00       	mov    %eax,0x8e24
    base.s.size = 0;
 9b8:	c7 05 28 8e 00 00 00 	movl   $0x0,0x8e28
 9bf:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 9c2:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9c5:	8b 00                	mov    (%eax),%eax
 9c7:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 9ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9cd:	8b 40 04             	mov    0x4(%eax),%eax
 9d0:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 9d3:	77 4d                	ja     a22 <malloc+0xa6>
      if(p->s.size == nunits)
 9d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9d8:	8b 40 04             	mov    0x4(%eax),%eax
 9db:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 9de:	75 0c                	jne    9ec <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 9e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9e3:	8b 10                	mov    (%eax),%edx
 9e5:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9e8:	89 10                	mov    %edx,(%eax)
 9ea:	eb 26                	jmp    a12 <malloc+0x96>
      else {
        p->s.size -= nunits;
 9ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9ef:	8b 40 04             	mov    0x4(%eax),%eax
 9f2:	2b 45 ec             	sub    -0x14(%ebp),%eax
 9f5:	89 c2                	mov    %eax,%edx
 9f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9fa:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 9fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a00:	8b 40 04             	mov    0x4(%eax),%eax
 a03:	c1 e0 03             	shl    $0x3,%eax
 a06:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 a09:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a0c:	8b 55 ec             	mov    -0x14(%ebp),%edx
 a0f:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 a12:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a15:	a3 2c 8e 00 00       	mov    %eax,0x8e2c
      return (void*)(p + 1);
 a1a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a1d:	83 c0 08             	add    $0x8,%eax
 a20:	eb 3b                	jmp    a5d <malloc+0xe1>
    }
    if(p == freep)
 a22:	a1 2c 8e 00 00       	mov    0x8e2c,%eax
 a27:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 a2a:	75 1e                	jne    a4a <malloc+0xce>
      if((p = morecore(nunits)) == 0)
 a2c:	83 ec 0c             	sub    $0xc,%esp
 a2f:	ff 75 ec             	push   -0x14(%ebp)
 a32:	e8 e5 fe ff ff       	call   91c <morecore>
 a37:	83 c4 10             	add    $0x10,%esp
 a3a:	89 45 f4             	mov    %eax,-0xc(%ebp)
 a3d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 a41:	75 07                	jne    a4a <malloc+0xce>
        return 0;
 a43:	b8 00 00 00 00       	mov    $0x0,%eax
 a48:	eb 13                	jmp    a5d <malloc+0xe1>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a4a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a4d:	89 45 f0             	mov    %eax,-0x10(%ebp)
 a50:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a53:	8b 00                	mov    (%eax),%eax
 a55:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 a58:	e9 6d ff ff ff       	jmp    9ca <malloc+0x4e>
  }
}
 a5d:	c9                   	leave  
 a5e:	c3                   	ret    
