
#ifndef _QD_HPP_
#define _QD_HPP_

#include <cppuhelper/implbase1.hxx>

#include <mytools/sheet/XQuadraticEquationAddIn.hpp>

//#include <com/sun/star/lang/XServiceInfo.hpp>
#include <com/sun/star/uno/XComponentContext.hpp>

namespace mytools { namespace sheet {

typedef ::cppu::WeakImplHelper1
    <
    ::mytools::sheet::XQuadraticEquationAddIn
    //, ::com::sun::star::lang::XServiceInfo
    > QuadraticEquationAddIn_Base;


class QuadraticEquationAddIn : public QuadraticEquationAddIn_Base
{
public:
    
    QuadraticEquationAddIn( /* ::com::sun::star::uno::Reference< ::com::sun::star::uno::XComponentContext > const & xContext */ );
    ~QuadraticEquationAddIn();

    static ::com::sun::star::uno::Reference< ::com::sun::star::uno::XInterface > create( const ::com::sun::star::uno::Reference< ::com::sun::star::uno::XComponentContext > & xContext );
    
    // XQuadraticEquationAddIn
    virtual ::com::sun::star::uno::Any SAL_CALL quadratic( double a, double b, double c, ::sal_Int32 nType ) throw (::com::sun::star::lang::IllegalArgumentException, ::com::sun::star::uno::RuntimeException);
    /*
    // XServiceInfo
    virtual ::rtl::OUString SAL_CALL getImplementationName(  ) throw (::com::sun::star::uno::RuntimeException);
    virtual ::sal_Bool SAL_CALL supportsService( const ::rtl::OUString& ServiceName ) throw (::com::sun::star::uno::RuntimeException);
    virtual ::com::sun::star::uno::Sequence< ::rtl::OUString > SAL_CALL getSupportedServiceNames(  ) throw (::com::sun::star::uno::RuntimeException);
    */
    static ::rtl::OUString SAL_CALL getImplementationName_Static();
    static ::com::sun::star::uno::Sequence< ::rtl::OUString > SAL_CALL getSupportedServiceNames_Static();
    
private:
};

} } // namespace
#endif
