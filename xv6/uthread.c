#include "types.h"
#include "stat.h"
#include "user.h"

/* Possible states of a thread; */
#define FREE 0x0
#define RUNNING 0x1
#define RUNNABLE 0x2

#define STACK_SIZE 8192
#define MAX_THREAD 4

typedef struct thread thread_t, *thread_p;
typedef struct mutex mutex_t, *mutex_p;

struct thread
{
  int sp;                 /* saved stack pointer */
  char stack[STACK_SIZE]; /* the thread's stack */
  int state;              /* FREE, RUNNING, RUNNABLE */
};
static thread_t all_thread[MAX_THREAD];
thread_p current_thread;
thread_p next_thread;
extern void thread_switch(void);
static int num_thread = 0;

static void thread_schedule(void);

void thread_init(void (*func)())
{
  // main() is thread 0, which will make the first invocation to
  // thread_schedule().  it needs a stack so that the first thread_switch() can
  // save thread 0's state.  thread_schedule() won't run the main thread ever
  // again, because its state is set to RUNNING, and thread_schedule() selects
  // a RUNNABLE thread.
  current_thread = &all_thread[0];
  current_thread->state = RUNNING;
  num_thread = 0;
  thread_num(num_thread);
  uthread_init((uint)func);
}

static void
thread_schedule(void)
{
  printf(1, "start 1\n");
  if(current_thread->state != FREE)
  {
    current_thread->state = RUNNABLE; 
  }
  printf(1, "start 3\n");
  printf(1, "current thread addr : %d\n", &current_thread);
  thread_p t;
  /* Find another runnable thread. */
  next_thread = 0;
  for (t = all_thread; t < all_thread + MAX_THREAD; t++)
  {
    if (t->state == RUNNABLE && t != current_thread)
    {
      printf(1, "start 4\n");
      next_thread = t;
      break;
    }
  }
  printf(1, "start 5\n");
  if (t >= all_thread + MAX_THREAD && current_thread->state == RUNNABLE)
  {
    /* The current thread is the only runnable thread; run it. */
    next_thread = current_thread;
    printf(1, "start 6\n");
  }
  printf(1, "start 7\n");
  if (next_thread == 0)
  {
    printf(1, "start 8\n");
    printf(2, "thread_schedule: no runnable threads\n");
    exit();
  }
  printf(1, "middle current thread addr : %d\n", &current_thread);
  printf(1, "start 9\n");
  if (current_thread != next_thread)
  { /* switch threads?  */
    next_thread->state = RUNNING;
    printf(1, "start 10\n");
    thread_switch();
  }
  
  else
    next_thread = 0;
  printf(1, "end current thread addr : %d\n", &current_thread);
}

void thread_create(void (*func)())
{
  thread_p t;
  num_thread++;
  thread_num(num_thread);
  for (t = all_thread; t < all_thread + MAX_THREAD; t++)
  {
    if (t->state == FREE)
      break;
  }
  t->sp = (int)(t->stack + STACK_SIZE); // set sp to the top of the stack
  t->sp -= 4;                           // space for return address
  *(int *)(t->sp) = (int)func;          // push return address on stack
  t->sp -= 32;                          // space for registers that thread_switch expects
  t->state = RUNNABLE;
  
}

void thread_yield(void)
{
  current_thread->state = RUNNABLE;
  thread_schedule();
}

static void
mythread(void)
{
  int i;
  printf(1, "my thread running\n");
  for (i = 0; i < 100; i++)
  {
    printf(1, "%d my thread 0x%x\n", i, (int)current_thread);
    // thread_yield();
  }
  printf(1, "my thread: exit\n");
  current_thread->state = FREE;
  num_thread--;
  thread_num(num_thread);
  thread_schedule();
}

int main(int argc, char *argv[])
{
  printf(1, "addr : %d", (uint)thread_schedule);
  thread_init(thread_schedule);
  thread_create(mythread);
  printf(1, "a\n");
  thread_create(mythread);
  printf(1, "b\n");
  thread_schedule();
  printf(1, "c\n");
  return 0;
}