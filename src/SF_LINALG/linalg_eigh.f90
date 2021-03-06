!-------------------------------------------------------------------------------------------
!PURPOSE:  eigenvalue/-vector problem for real symmetric/complex hermitian matrices:
!-------------------------------------------------------------------------------------------
subroutine deigh_generalized(Am, Bm, lam, c)
  ! solves generalized eigen value problem for all eigenvalues and eigenvectors
  ! Am must by symmetric, Bm symmetric positive definite. ! Only the lower triangular part of Am and Bm is used.
  real(8), intent(in)  :: Am(:,:)   ! LHS matrix: Am c = lam Bm c
  real(8), intent(in)  :: Bm(:,:)   ! RHS matrix: Am c = lam Bm c
  real(8), intent(out) :: lam(:)   ! eigenvalues: Am c = lam Bm c
  real(8), intent(out) :: c(:,:)   ! eigenvectors: Am c = lam Bm c; c(i,j) = ith component of jth vec.
  integer              :: n
  ! lapack variables
  integer              :: lwork, liwork, info
  integer, allocatable :: iwork(:)
  real(8), allocatable :: Bmt(:,:), work(:)
  ! solve
  n = size(Am,1)
  call assert_shape(Am, [n, n], "eigh", "Am")
  call assert_shape(Bm, [n, n], "eigh", "B")
  call assert_shape(c, [n, n], "eigh", "c")
  lwork = 1 + 6*n + 2*n**2
  liwork = 3 + 5*n
  allocate(Bmt(n,n), work(lwork), iwork(liwork))
  c = Am; Bmt = Bm  ! Bmt temporaries overwritten by dsygvd
  call dsygvd(1,'V','L',n,c,n,Bmt,n,lam,work,lwork,iwork,liwork,info)
  if (info /= 0) then
     print *, "dsygvd returned info =", info
     if (info < 0) then
        print *, "the", -info, "-th argument had an illegal value"
     else if (info <= n) then
        print *, "the algorithm failed to compute an eigenvalue while working"
        print *, "on the submatrix lying in rows and columns", 1d0*info/(n+1)
        print *, "through", mod(info, n+1)
     else
        print *, "The leading minor of order ", info-n, &
             "of B is not positive definite. The factorization of B could ", &
             "not be completed and no eigenvalues or eigenvectors were computed."
     end if
     stop 'deigh_generalized error: dsygvd'
  end if
end subroutine deigh_generalized
!
subroutine zeigh_generalized(Am, Bm, lam, c)
  ! solves generalized eigen value problem for all eigenvalues and eigenvectors
  ! Am must by hermitian, Bm hermitian positive definite.
  ! Only the lower triangular part of Am and Bm is used.
  complex(8), intent(in)  :: Am(:,:)   ! LHS matrix: Am c = lam Bm c
  complex(8), intent(in)  :: Bm(:,:)   ! RHS matrix: Am c = lam Bm c
  real(8), intent(out)    :: lam(:)      ! eigenvalues: Am c = lam Bm c
  complex(8), intent(out) :: c(:,:)   ! eigenvectors: Am c = lam Bm c; c(i,j) = ith component of jth vec.
  ! lapack variables
  integer                 :: info, liwork, lrwork, lwork, n
  integer, allocatable    :: iwork(:)
  real(8), allocatable    :: rwork(:)
  complex(8), allocatable :: Bmt(:,:), work(:)
  n = size(Am,1)
  call assert_shape(Am, [n, n], "eigh", "Am")
  call assert_shape(Bm, [n, n], "eigh", "Bm")
  call assert_shape(c, [n, n], "eigh", "c")
  lwork = 2*n + n**2
  lrwork = 1 + 5*N + 2*n**2
  liwork = 3 + 5*n
  allocate(Bmt(n,n), work(lwork), rwork(lrwork), iwork(liwork))
  c = Am; Bmt = Bm  ! Bmt temporary overwritten by zhegvd
  call zhegvd(1,'V','L',n,c,n,Bmt,n,lam,work,lwork,rwork,lrwork,iwork,liwork,info)
  if (info /= 0) then
     print *, "zhegvd returned info =", info
     if (info < 0) then
        print *, "the", -info, "-th argument had an illegal value"
     else if (info <= n) then
        print *, "the algorithm failed to compute an eigenvalue while working"
        print *, "on the submatrix lying in rows and columns", 1d0*info/(n+1)
        print *, "through", mod(info, n+1)
     else
        print *, "The leading minor of order ", info-n, &
             "of B is not positive definite. The factorization of B could ", &
             "not be completed and no eigenvalues or eigenvectors were computed."
     end if
     stop 'deigh_generalized error: zhegvd'
  end if
end subroutine zeigh_generalized


subroutine deigh_simple(M,E,jobz,uplo)
  real(8),dimension(:,:),intent(inout) :: M ! M v = E v/v(i,j) = ith component of jth vec.
  real(8),dimension(:),intent(inout)   :: E ! eigenvalues
  character(len=1),optional            :: jobz,uplo
  character(len=1)                     :: jobz_,uplo_
  integer                              :: i,j,n,lda,info,lwork
  real(8),dimension(:),allocatable     :: work
  real(8),dimension(1)                 :: lwork_guess
  jobz_='V';if(present(jobz))jobz_=jobz
  uplo_='U';if(present(uplo))uplo_=uplo
  lda = max(1,size(M,1))
  n   = size(M,2)
  call assert_shape(M,[n,n],"eigh","M")
  Call dsyev(jobz_,uplo_,n,M,lda,E,lwork_guess,-1,info)
  if (info /= 0) then
     print*, "dsyevd returned info =", info
     if (info < 0) then
        print*, "the", -info, "-th argument had an illegal value"
     else
        print*, "the algorithm failed to compute an eigenvalue while working"
        print*, "on the submatrix lying in rows and columns", 1d0*info/(n+1)
        print*, "through", mod(info, n+1)
     end if
     stop 'error deigh: 1st call dsyev'
  end if
  lwork=lwork_guess(1)
  allocate(work(lwork))
  call dsyev(jobz_,uplo_,n,M,lda,E,work,lwork,info)
  if (info /= 0) then
     print*, "dsyevd returned info =", info
     if (info < 0) then
        print*, "the", -info, "-th argument had an illegal value"
     else
        print*, "the algorithm failed to compute an eigenvalue while working"
        print*, "on the submatrix lying in rows and columns", 1d0*info/(n+1)
        print*, "through", mod(info, n+1)
     end if
     stop 'error deigh: 2nd call dsyev'
  end if
  deallocate(work)
end subroutine deigh_simple
!-----------------------------
subroutine zeigh_simple(M,E,jobz,uplo)
  complex(8),dimension(:,:),intent(inout) :: M! M v = E v/v(i,j) = ith component of jth vec.
  real(8),dimension(:),intent(inout)      :: E! eigenvalues
  character(len=1),optional               :: jobz,uplo
  character(len=1)                        :: jobz_,uplo_
  integer                                 :: i,j,n,lda,info,lwork
  complex(8),dimension(1)                 :: lwork_guess
  complex(8),dimension(:),allocatable     :: work
  real(8),dimension(:),allocatable        :: rwork
  !write(*,*)"matrix_diagonalization called with: jobz="//jobz_//" uplo="//uplo_
  jobz_='V';if(present(jobz))jobz_=jobz
  uplo_='U';if(present(uplo))uplo_=uplo
  lda = max(1,size(M,1))
  n   = size(M,2)
  call assert_shape(M,[n,n],"eigh","M")
  allocate(rwork(max(1,3*N-2)))
  call zheev(jobz_,uplo_,n,M,lda,E,lwork_guess,-1,rwork,info)
  if(info/=0) then
     print*, "zheev returned info =", info
     if (info < 0) then
        print*, "the", -info, "-th argument had an illegal value"
     else
        print*, "the algorithm failed to compute an eigenvalue while working"
        print*, "on the submatrix lying in rows and columns", 1d0*info/(n+1)
        print*, "through", mod(info, n+1)
     end if
     stop 'error zeigh: 1st call zheev'
  end if
  lwork=lwork_guess(1) ; allocate(work(lwork))
  call zheev(jobz_,uplo_,n,M,lda,E,work,lwork,rwork,info)
  if(info/=0) then
     print*, "zheev returned info =", info
     if (info < 0) then
        print*, "the", -info, "-th argument had an illegal value"
     else
        print*, "the algorithm failed to compute an eigenvalue while working"
        print*, "on the submatrix lying in rows and columns", 1d0*info/(n+1)
        print*, "through", mod(info, n+1)
     end if
     stop 'error zeigh: 2nd call zheev'
  end if
  deallocate(work,rwork)
end subroutine zeigh_simple




subroutine deigh_tridiag(D,U,Ev,Irange,Vrange)
  real(8),dimension(:)                :: d
  real(8),dimension(max(1,size(d)-1)) :: u
  real(8),dimension(:,:),optional     :: Ev
  integer,dimension(2),optional       :: Irange
  integer,dimension(2),optional       :: Vrange
  !
  integer                             :: n
  ! = 'N':  Compute eigenvalues only;
  ! = 'V':  Compute eigenvalues and eigenvectors.
  character                           :: jobz_
  ! = 'A': all eigenvalues will be found
  ! = 'V': all eigenvalues in the half-open interval (VL,VU] will be found.
  ! = 'I': the IL-th through IU-th eigenvalues will be found.
  ! For RANGE = 'V' or 'I' and IU - IL < N - 1, DSTEBZ and
  ! DSTEIN are called
  character                           :: range_
  real(8)                             :: vl,vu 
  integer                             :: il,iu
  real(8),dimension(size(d))          :: w
  real(8),dimension(:,:),allocatable  :: z
  integer,dimension(:),allocatable    :: isuppz
  integer                             :: lwork,liwork
  real(8),dimension(:),allocatable    :: work
  integer,dimension(:),allocatable    :: iwork
  real(8)                             :: abstol = 0d0 !tolerance on approximation error of eigenvalues
  integer                             :: m
  integer                             :: ldz
  integer                             :: info
  !
  n = size(d)
  !
  jobz_ = 'N'; if(present(Ev))jobz_='V'
  !
  range_= 'A'
  m     = n
  if(present(Irange).AND.present(Vrange))stop "EIGH_T: Irange & Vrange both present"
  if(present(Irange))then
     range_ = 'I'
     il = Irange(1)
     iu = Irange(2)
     m  = iu-il+1
  endif
  if(present(Vrange))then
     range_ = 'V'
     vl     = Vrange(1)
     vu     = Vrange(2)
     m      = n
  endif
  !
  if(present(Ev))then
     if(any(shape(Ev)/=[n,m]))stop "EIGH_T ERROR: wrong dimension in Ev"
  endif
  !
  ldz = n
  !
  allocate(z(n,m), isuppz(2*max(1,m)))
  allocate(work(1),iwork(1))
  call dstevr(jobz_,range_,n,d,u,vl,vu,il,iu,abstol,m,w,z,ldz,isuppz,work,-1,iwork,-1,info)
  if(info/=0) then
     print*, "dstevr returned info =", info
     if (info < 0) then
        print*, "the", -info, "-th argument had an illegal value"
     else
        print*, "Internal error"
     end if
     stop 'error dstevr: 1st call dstevr'
  end if
  !
  lwork  = work(1)
  liwork = iwork(1)
  deallocate(work,iwork);allocate(work(lwork),iwork(liwork))
  !
  call dstevr(jobz_,range_,n,d,u,vl,vu,il,iu,abstol,m,w,z,ldz,isuppz,work,lwork,iwork,liwork,info)
  if(info/=0) then
     print*, "dstevr returned info =", info
     if (info < 0) then
        print*, "the", -info, "-th argument had an illegal value"
     else
        print*, "Internal error"
     end if
     stop 'error dstevr: 2nd call dstevr'
  end if
  !
  d  = w
  if(present(Ev)) Ev = z
  !
  deallocate(work,iwork,isuppz,z)
  !
end subroutine deigh_tridiag
