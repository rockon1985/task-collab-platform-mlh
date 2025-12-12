import { toast } from '@/lib/toast'

beforeEach(() => {
  document.body.innerHTML = ''
  jest.useFakeTimers()
})

test('creates container and appends toast', () => {
  expect(document.querySelector('#toast-container')).toBeNull()
  const el = toast.info('Hello!')
  const container = document.querySelector('#toast-container') as HTMLDivElement
  expect(container).not.toBeNull()
  expect(container.childElementCount).toBe(1)
  expect(el.textContent).toContain('Hello!')
})

test('renders types with correct classes', () => {
  const s = toast.success('ok')
  const e = toast.error('bad')
  const w = toast.warning('warn')
  const i = toast.info('info')
  expect(s.className).toContain('bg-green-50')
  expect(e.className).toContain('bg-red-50')
  expect(w.className).toContain('bg-yellow-50')
  expect(i.className).toContain('bg-blue-50')
})

test('reuses same container on subsequent toasts', () => {
  const el1 = toast.info('first')
  const container1 = document.querySelector('#toast-container') as HTMLDivElement
  expect(container1).not.toBeNull()
  const el2 = toast.info('second')
  const container2 = document.querySelector('#toast-container') as HTMLDivElement
  expect(container2).toBe(container1)
  expect(container1.childElementCount).toBe(2)
  expect(el1.parentElement).toBe(container1)
  expect(el2.parentElement).toBe(container2)
})

test('auto-dismisses after default and custom durations', () => {
  toast.info('bye')
  const container = document.querySelector('#toast-container') as HTMLDivElement
  expect(container.childElementCount).toBe(1)
  jest.advanceTimersByTime(3000)
  expect(container.childElementCount).toBe(1)
  jest.advanceTimersByTime(300)
  expect(container.childElementCount).toBe(0)

  toast.info('bye2', { duration: 1000 })
  expect(container.childElementCount).toBe(1)
  jest.advanceTimersByTime(1000)
  jest.advanceTimersByTime(300)
  expect(container.childElementCount).toBe(0)
})

test('close button removes toast immediately', () => {
  const el = toast.info('close me')
  const btn = el.querySelector('button') as HTMLButtonElement
  ;(btn as any).onclick.call(btn)
  const container = document.querySelector('#toast-container') as HTMLDivElement
  expect(container.childElementCount).toBe(0)
})

test('recreates container if reference is detached from DOM', () => {
  // Create initial container and toast
  toast.info('first')
  let container = document.querySelector('#toast-container') as HTMLDivElement
  expect(container).not.toBeNull()

  // Detach container from DOM (simulate DOM reset without resetting singleton)
  document.body.innerHTML = ''
  expect(document.querySelector('#toast-container')).toBeNull()

  // Next toast should recreate container since previous reference is detached
  toast.info('second')
  container = document.querySelector('#toast-container') as HTMLDivElement
  expect(container).not.toBeNull()
  expect(container.childElementCount).toBe(1)
})

test('uses default type when not provided', () => {
  const anyToast: any = toast
  const el = anyToast.show('default')
  expect(el.className).toContain('bg-blue-50') // info color
})
