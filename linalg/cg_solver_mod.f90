module cg_solver_mod

    use sparse_matrix_mod
    use iterative_solver_mod

    implicit none




type, extends(iterative_solver) :: cg_solver
    real(kind(1d0)), allocatable :: p(:),q(:),r(:),z(:)
contains
    procedure :: init => cg_init
    procedure :: solve => cg_solve
    procedure :: subblock_solve => cg_subblock_solve
    procedure :: subset_solve => cg_subset_solve
    procedure :: destroy => cg_destroy
end type cg_solver



contains


!--------------------------------------------------------------------------!
subroutine cg_init(solver,nn,tolerance)                                    !
!--------------------------------------------------------------------------!
    implicit none
    class(cg_solver), intent(inout) :: solver
    integer, intent(in) :: nn
    real(kind(1d0)), intent(in) :: tolerance

    solver%nn = nn
    solver%tolerance = tolerance
    solver%iterations = 0

    allocate(solver%p(nn),solver%q(nn),solver%r(nn),solver%z(nn))

end subroutine cg_init



!--------------------------------------------------------------------------!
subroutine cg_solve(solver,A,x,b)                                          !
!--------------------------------------------------------------------------!
    implicit none
    ! input/output variables
    class(cg_solver), intent(inout) :: solver
    class(sparse_matrix), intent(in) :: A
    real(kind(1d0)), intent(inout) :: x(:)
    real(kind(1d0)), intent(in) :: b(:)
    ! local variables
    real(kind(1d0)) :: alpha,beta,dpr,res2

    call A%matvec(x,solver%q)
    solver%r = b-solver%q
    solver%p = solver%r
    res2 = dot_product( solver%r,solver%r )

    do while ( dsqrt(res2)>solver%tolerance )
        call A%matvec(solver%p,solver%q)
        dpr = dot_product(solver%p,solver%q)
        alpha = res2/dpr
        x = x+alpha*solver%p
        solver%r = solver%r-alpha*solver%q
        dpr = dot_product(solver%r,solver%r)
        beta = dpr/res2
        solver%p = solver%r+beta*solver%p
        res2 = dpr
        solver%iterations = solver%iterations+1
    enddo

end subroutine cg_solve



!--------------------------------------------------------------------------!
subroutine cg_subblock_solve(solver,A,x,b,i1,i2)                           !
!--------------------------------------------------------------------------!
    implicit none
    ! input/output variables
    class(cg_solver), intent(inout) :: solver
    class(sparse_matrix), intent(in) :: A
    real(kind(1d0)), intent(inout) :: x(:)
    real(kind(1d0)), intent(in) :: b(:)
    integer, intent(in) :: i1,i2
    ! local variables
    real(kind(1d0)) :: alpha,beta,dpr,res2
    integer :: i

    call A%subblock_matvec(x,solver%q,i1,i2,i1,i2)
    solver%r = b-solver%q
    do i=1,i1-2
        solver%r(i) = 0.d0
    enddo
    do i=i2+1,solver%nn
        solver%r(i) = 0.d0
    enddo
    solver%p = solver%r
    res2 = dot_product(solver%r,solver%r)

    do while ( dsqrt(res2)>solver%tolerance )
        call A%subblock_matvec(solver%p,solver%q,i1,i2,i1,i2)
        dpr = dot_product(solver%p,solver%q)
        alpha = res2/dpr
        x = x+alpha*solver%p
        solver%r = solver%r-alpha*solver%q
        dpr = dot_product(solver%r,solver%r)
        beta = dpr/res2
        solver%p = solver%r+beta*solver%p
        res2 = dpr
        solver%iterations = solver%iterations+1
    enddo

end subroutine cg_subblock_solve



!--------------------------------------------------------------------------!
subroutine cg_subset_solve(solver,A,x,b,setlist,set)                       !
!--------------------------------------------------------------------------!
    implicit none
    ! input/output variables
    class(cg_solver), intent(inout) :: solver
    class(sparse_matrix), intent(in) :: A
    real(kind(1d0)), intent(inout) :: x(:)
    real(kind(1d0)), intent(in) :: b(:)
    integer, intent(in) :: setlist(:),set
    ! local variables
    real(kind(1d0)) :: alpha,beta,dpr,res2
    integer :: i

    call A%subset_matvec(x,solver%q,setlist,set,set)
    solver%r = b-solver%q
    do i=1,solver%nn
        if (setlist(i) /= set) solver%r(i) = 0.d0
    enddo
    solver%p = solver%r
    res2 = dot_product(solver%r,solver%r)

    do while ( dsqrt(res2)>solver%tolerance )
        call A%subset_matvec(solver%p,solver%q,setlist,set,set)
        dpr = dot_product(solver%p,solver%q)
        alpha = res2/dpr
        x = x+alpha*solver%p
        solver%r = solver%r-alpha*solver%q
        dpr = dot_product(solver%r,solver%r)
        beta = dpr/res2
        solver%p = solver%r+beta*solver%p
        res2 = dpr
        solver%iterations = solver%iterations+1
    enddo

end subroutine cg_subset_solve



!--------------------------------------------------------------------------!
subroutine cg_destroy(solver)                                              !
!--------------------------------------------------------------------------!
    implicit none
    class(cg_solver), intent(inout) :: solver

    deallocate( solver%p, solver%q, solver%r, solver%z )
    solver%iterations = 0
    solver%nn = 0
    solver%tolerance = 0.d0

end subroutine cg_destroy




end module cg_solver_mod