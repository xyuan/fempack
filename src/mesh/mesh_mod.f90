module mesh_mod

    implicit none

type tri_mesh
    integer :: nn,ne,nl
    real(kind=8), dimension(:,:), allocatable :: x
    integer, dimension(:,:), allocatable :: elem,edge,neigh
    integer, dimension(:), allocatable :: bnd,bnd_edge
end type tri_mesh


contains


!--------------------------------------------------------------------------!
subroutine read_mesh(filename,mesh)                                        !
!--------------------------------------------------------------------------!
! Reads in mesh generated by Triangle with file stem "filename", e.g. the  !
! mesh is stored in the files                                              !
!   filename.node, filename.ele, filename.edge, filename.neigh.            !
! Output is writted a triMesh called mesh.                                 !
!--------------------------------------------------------------------------!
    implicit none
    ! input/output variables
    character(len=32), intent(in) :: filename
    type (tri_mesh), intent(out) :: mesh
    ! local varaibles
    integer :: dummy,n
    logical :: ierr

    !-------------------
    ! Read in the nodes
    inquire(file=trim(filename)//'.node', exist=ierr)
    if (ierr) then
        open(unit=10, file=trim(filename)//'.node')
        read(10,*) mesh%nn

        allocate( mesh%x(2,mesh%nn), mesh%bnd(mesh%nn) )

        do n=1,mesh%nn
            read(10,*) dummy, mesh%x(1:2,n), mesh%bnd(n)
        enddo

        close(10)
    else
        print *, trim(filename)//'.node not found!'
    endif

    !----------------------
    ! Read in the elements
    inquire(file=trim(filename)//'.ele', exist=ierr)
    if (ierr) then
        open(unit=20, file=trim(filename)//'.ele')
        read(20,*) mesh%ne

        allocate( mesh%elem(3,mesh%ne) )

        do n=1,mesh%ne
            read(20,*) dummy, mesh%elem(1:3,n)
        enddo

        close(20)
    else
        print *, trim(filename)//'.ele not found!'
    endif


    !-------------------
    ! Read in the edges
    inquire(file=trim(filename)//'.edge', exist=ierr)
    if (ierr) then
        open(unit=30, file=trim(filename)//'.edge')
        read(30,*) mesh%nl

        allocate( mesh%edge(2,mesh%nl), mesh%bnd_edge(mesh%nl) )

        do n=1,mesh%nl
            read(30,*) dummy, mesh%edge(1:2,n), mesh%bnd_edge(n)
        enddo

        close(30)
    else
        print *, trim(filename)//'.edge not found!'
    endif


    !-----------------------
    ! Read in the neighbors
    inquire(file=trim(filename)//'.neigh', exist=ierr)
    if (ierr) then
        open(unit=40, file=trim(filename)//'.neigh')
        read(40,*) dummy

        allocate( mesh%neigh(3,mesh%ne) )

        do n=1,mesh%ne
            read(40,*) dummy, mesh%neigh(1:3,n)
        enddo

        close(40)
    else
        print *, trim(filename)//'.neigh not found!'
    endif

end subroutine read_mesh



end module mesh_mod
