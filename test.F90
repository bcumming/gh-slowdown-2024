module my_time
contains
  function prk_get_wtime() result(t)
    use, intrinsic :: iso_fortran_env
    implicit none
    real(kind=REAL64) ::  t
    integer(kind=INT64) :: c, r
    call system_clock(count = c, count_rate = r)
    t = real(c,REAL64) / real(r,REAL64)
  end function
end module
program p

use mpi
use nvtx
use my_time
integer :: ii, i, j, ierr, required, provided, myrank

interface
    function usleep(useconds) bind(c, name='usleep')
        import :: c_int, c_int32_t
        implicit none
        integer(kind=c_int32_t), value :: useconds
        integer(kind=c_int)            :: usleep
    end function usleep
end interface
real(4), allocatable :: a(:,:)
real(8) :: t0, t1

required = mpi_thread_serialized
call mpi_init_thread(required, provided, ierr)

allocate(a(100000, 20))
a = 0

call mpi_comm_rank(mpi_comm_world, myrank, ierr)

do j = 1, 1000
  !$omp parallel

  call nvtxStartRange("iter")
  do i = 1, 21
      if (i == 10) t0 = prk_get_wtime()
      call nvtxStartRange("iter")
      !$omp barrier
      !$omp single
        call nvtxStartRange("compute")
        a(:,:) = a(:,:) + 1
        call nvtxEndRange
        call mpi_barrier(mpi_comm_world, ierr)
      !$omp end single
      !$omp barrier
      call nvtxEndRange
  enddo
  call nvtxEndRange
  !$omp end parallel

  t1 = prk_get_wtime()

  if (myrank == 0) then
    print '("Took ",F8.4," ms/it")', (t1 - t0) / 10 * 1000
    flush(6)
  endif
enddo

call mpi_finalize(ierr)

end program
