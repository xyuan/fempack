module jacobi_mod

    use sparse_matrix_mod
    use iterative_solver_mod

    implicit none




type, extends(preconditioner) :: jacobi
    real(kind(1d0)), allocatable, private :: diag(:),p(:),q(:)
contains
    procedure :: init => jacobi_init
    procedure :: precondition => jacobi_precondition
    procedure :: subblock_precondition => jacobi_subblock_precondition
    procedure :: subset_precondition => jacobi_subset_precondition

end type jacobi



contains


!--------------------------------------------------------------------------!
subroutine jacobi_init(pc,A,level)                                         !
!--------------------------------------------------------------------------!
    implicit none
    ! input/output variables
    class(jacobi), intent(inout) :: pc
    class(sparse_matrix), intent(in) :: A
    integer, intent(in) :: level
    ! local variables
    integer :: i

    pc%nn = A%nrow
    pc%level = level
    allocate( pc%diag(pc%nn) )

    do i=1,A%nrow
        pc%diag(i) = 1.d0/A%get_value(i,i)
    enddo

end subroutine jacobi_init



!--------------------------------------------------------------------------!
subroutine jacobi_precondition(pc,A,x,b)                                   !
!--------------------------------------------------------------------------!
    implicit none
    class(jacobi), intent(inout) :: pc
    class(sparse_matrix), intent(in) :: A
    real(kind(1d0)), intent(inout) :: x(:)
    real(kind(1d0)), intent(in) :: b(:)

    x = pc%diag*b

end subroutine jacobi_precondition



!--------------------------------------------------------------------------!
subroutine jacobi_subblock_precondition(pc,A,x,b,i1,i2)                    !
!--------------------------------------------------------------------------!
    implicit none
    class(jacobi), intent(inout) :: pc
    class(sparse_matrix), intent(in) :: A
    real(kind(1d0)), intent(inout) :: x(:)
    real(kind(1d0)), intent(in) :: b(:)
    integer, intent(in) :: i1,i2

    x(i1:i2) = pc%diag(i1:i2)*b(i1:i2)

end subroutine jacobi_subblock_precondition



!--------------------------------------------------------------------------!
subroutine jacobi_subset_precondition(pc,A,x,b,setlist,set)                !
!--------------------------------------------------------------------------!
    implicit none
    class(jacobi), intent(inout) :: pc
    class(sparse_matrix), intent(in) :: A
    real(kind(1d0)), intent(inout) :: x(:)
    real(kind(1d0)), intent(in) :: b(:)
    integer, intent(in) :: setlist(:),set

    where (setlist == set) x = pc%diag*b

end subroutine jacobi_subset_precondition



end module jacobi_mod