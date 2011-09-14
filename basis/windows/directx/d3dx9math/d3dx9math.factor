USING: math classes.struct windows.types alien.syntax windows.directx.d3d9types
windows.com.syntax windows.com windows.directx windows.directx.d3d9 ;
IN: windows.directx.d3dx9math

LIBRARY: d3dx9

CONSTANT: D3DX_PI    3.141592654
CONSTANT: D3DX_1BYPI 0.318309886

: D3DXToRadian ( degree -- radian ) D3DX_PI 180.0 / * ; inline
: D3DXToDegree ( radian -- degree ) 180.0 D3DX_PI / * ; inline

CONSTANT: D3DX_16F_DIG          3
CONSTANT: D3DX_16F_EPSILON      4.8875809e-4
CONSTANT: D3DX_16F_MANT_DIG     11
CONSTANT: D3DX_16F_MAX          6.550400e+004
CONSTANT: D3DX_16F_MAX_10_EXP   4
CONSTANT: D3DX_16F_MAX_EXP      15
CONSTANT: D3DX_16F_MIN          6.1035156e-5
CONSTANT: D3DX_16F_MIN_10_EXP   -4
CONSTANT: D3DX_16F_MIN_EXP      -14
CONSTANT: D3DX_16F_RADIX        2
CONSTANT: D3DX_16F_ROUNDS       1

STRUCT: D3DXFLOAT16
    { value WORD } ;
TYPEDEF: D3DXFLOAT16* LPD3DXFLOAT16

STRUCT: D3DXVECTOR2
    { x FLOAT }
    { y FLOAT } ;
TYPEDEF: D3DXVECTOR2* LPD3DXVECTOR2

STRUCT: D3DXVECTOR2_16F
    { x D3DXFLOAT16 }
    { y D3DXFLOAT16 } ;
TYPEDEF: D3DXVECTOR2_16F* LPD3DXVECTOR2_16F

TYPEDEF: D3DVECTOR D3DXVECTOR3
TYPEDEF: D3DXVECTOR3* LPD3DXVECTOR3

STRUCT: D3DXVECTOR3_16F
    { x D3DXFLOAT16 }
    { y D3DXFLOAT16 }
    { z D3DXFLOAT16 } ;
TYPEDEF: D3DXVECTOR3_16F* LPD3DXVECTOR3_16F

STRUCT: D3DXVECTOR4
    { x FLOAT }
    { y FLOAT }
    { z FLOAT }
    { w FLOAT } ;
TYPEDEF: D3DXVECTOR4* LPD3DXVECTOR4

STRUCT: D3DXVECTOR4_16F
    { x D3DXFLOAT16 }
    { y D3DXFLOAT16 }
    { z D3DXFLOAT16 }
    { w D3DXFLOAT16 } ;
TYPEDEF: D3DXVECTOR4_16F* LPD3DXVECTOR4_16F

TYPEDEF: D3DMATRIX D3DXMATRIX
TYPEDEF: D3DXMATRIX* LPD3DXMATRIX
TYPEDEF: D3DXMATRIX D3DXMATRIXA16
TYPEDEF: D3DXMATRIXA16* LPD3DXMATRIXA16

STRUCT: D3DXQUATERNION
    { x FLOAT }
    { y FLOAT }
    { z FLOAT }
    { w FLOAT } ;
TYPEDEF: D3DXQUATERNION* LPD3DXQUATERNION

STRUCT: D3DXPLANE
    { a FLOAT }
    { b FLOAT }
    { c FLOAT }
    { d FLOAT } ;
TYPEDEF: D3DXPLANE* LPD3DXPLANE

STRUCT: D3DXCOLOR
    { r FLOAT }
    { g FLOAT }
    { b FLOAT }
    { a FLOAT } ;
TYPEDEF: D3DXCOLOR* LPD3DXCOLOR

C-TYPE: ID3DXMatrixStack
TYPEDEF: ID3DXMatrixStack* LPD3DXMATRIXSTACK

COM-INTERFACE: ID3DXMatrixStack IUnknown {C7885BA7-F990-4fe7-922D-8515E477DD85}
    HRESULT Pop ( )
    HRESULT Push ( )
    HRESULT LoadIdentity ( )
    HRESULT LoadMatrix ( D3DXMATRIX* pM  )
    HRESULT MultMatrix ( D3DXMATRIX* pM  )
    HRESULT MultMatrixLocal ( D3DXMATRIX* pM  )
    HRESULT RotateAxis ( D3DXVECTOR3* pV, FLOAT Angle )
    HRESULT RotateAxisLocal ( D3DXVECTOR3* pV, FLOAT Angle )
    HRESULT RotateYawPitchRoll ( FLOAT Yaw, FLOAT Pitch, FLOAT Roll )
    HRESULT RotateYawPitchRollLocal ( FLOAT Yaw, FLOAT Pitch, FLOAT Roll )
    HRESULT Scale ( FLOAT x, FLOAT y, FLOAT z )
    HRESULT ScaleLocal ( FLOAT x, FLOAT y, FLOAT z )
    HRESULT Translate ( FLOAT x, FLOAT y, FLOAT z  )
    HRESULT TranslateLocal ( FLOAT x, FLOAT y, FLOAT z )
    D3DXMATRIX* GetTop ( ) ;

FUNCTION: HRESULT D3DXCreateMatrixStack (
        DWORD               Flags,
        LPD3DXMATRIXSTACK*  ppStack ) ;

CONSTANT: D3DXSH_MINORDER 2
CONSTANT: D3DXSH_MAXORDER 6

FUNCTION: FLOAT* D3DXSHEvalDirection
    ( FLOAT* Out, UINT Order, D3DXVECTOR3 *pDir ) ;

FUNCTION: FLOAT* D3DXSHRotate
    ( FLOAT* Out, UINT Order, D3DXMATRIX *pMatrix, FLOAT* In ) ;

FUNCTION: FLOAT* D3DXSHRotateZ
    ( FLOAT* Out, UINT Order, FLOAT Angle, FLOAT* In ) ;

FUNCTION: FLOAT* D3DXSHAdd
    ( FLOAT* Out, UINT Order, FLOAT* A, FLOAT* B ) ;

FUNCTION: FLOAT* D3DXSHScale
    ( FLOAT* Out, UINT Order, FLOAT* In, FLOAT Scale ) ;

FUNCTION: FLOAT WINAPI ( UINT Order, FLOAT* A, FLOAT* B ) ;

FUNCTION: FLOAT* D3DXSHMultiply2 ( FLOAT* Out, FLOAT* F, FLOAT* G ) ;
FUNCTION: FLOAT* D3DXSHMultiply3 ( FLOAT* Out, FLOAT* F, FLOAT* G ) ;
FUNCTION: FLOAT* D3DXSHMultiply4 ( FLOAT* Out, FLOAT* F, FLOAT* G ) ;
FUNCTION: FLOAT* D3DXSHMultiply5 ( FLOAT* Out, FLOAT* F, FLOAT* G ) ;
FUNCTION: FLOAT* D3DXSHMultiply6 ( FLOAT* Out, FLOAT* F, FLOAT* G ) ;

FUNCTION: HRESULT D3DXSHEvalDirectionalLight
    ( UINT Order, D3DXVECTOR3* pDir,
      FLOAT RIntensity, FLOAT GIntensity, FLOAT BIntensity,
      FLOAT* ROut, FLOAT* GOut, FLOAT* BOut ) ;

FUNCTION: HRESULT D3DXSHEvalSphericalLight
    ( UINT Order, D3DXVECTOR3* pPos, FLOAT Radius,
      FLOAT RIntensity, FLOAT GIntensity, FLOAT BIntensity,
      FLOAT* ROut, FLOAT* GOut, FLOAT* BOut ) ;

FUNCTION: HRESULT D3DXSHEvalConeLight
    ( UINT Order, D3DXVECTOR3* pDir, FLOAT Radius,
      FLOAT RIntensity, FLOAT GIntensity, FLOAT BIntensity,
      FLOAT* ROut, FLOAT* GOut, FLOAT* BOut ) ;

FUNCTION: HRESULT D3DXSHEvalHemisphereLight
    ( UINT Order, D3DXVECTOR3* pDir, D3DXCOLOR Top, D3DXCOLOR Bottom,
      FLOAT* ROut, FLOAT* GOut, FLOAT* BOut ) ;

FUNCTION: HRESULT D3DXSHProjectCubeMap
    ( UINT uOrder, LPDIRECT3DCUBETEXTURE9 pCubeMap,
      FLOAT* ROut, FLOAT* GOut, FLOAT* BOut ) ;

