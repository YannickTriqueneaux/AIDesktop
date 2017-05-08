// THIS CODE AND INFORMATION IS PROVIDED "AS IS" WITHOUT WARRANTY OF
// ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO
// THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
// PARTICULAR PURPOSE.
//
// Copyright (c) Microsoft Corporation. All rights reserved
//----------------------------------------------------------------------

Texture2D tx : register( t0 );
SamplerState samLinear : register( s0 );

float Epsilon = 1e-10;

//float3 RGBtoHCV(in float3 RGB)
//{
//    // Based on work by Sam Hocevar and Emil Persson
//    float4 P = (RGB.g < RGB.b) ? float4(RGB.bg, -1.0, 2.0 / 3.0) : float4(RGB.gb, 0.0, -1.0 / 3.0);
//    float4 Q = (RGB.r < P.x) ? float4(P.xyw, RGB.r) : float4(RGB.r, P.yzx);
//    float C = Q.x - min(Q.w, Q.y);
//    float H = abs((Q.w - Q.y) / (6 * C + Epsilon) + Q.z);
//    return float3(H, C, Q.x);
//}
//float3 RGBtoHSV(in float3 RGB)
//{
//    float3 HCV = RGBtoHCV(RGB);
//    float S = HCV.y / (HCV.z + Epsilon);
//    return float3(HCV.x, S, HCV.z);
//}
//float3 HUEtoRGB(in float H)
//{
//    float R = abs(H * 6 - 3) - 1;
//    float G = 2 - abs(H * 6 - 2);
//    float B = 2 - abs(H * 6 - 4);
//    return saturate(float3(R, G, B));
//}
//float3 HSVtoRGB(in float3 HSV)
//{
//    float3 RGB = HUEtoRGB(HSV.x);
//    return ((RGB - 1) * HSV.y + 1) * HSV.z;
//}
//float3 RGBtoHSL(in float3 RGB)
//{
//    float3 HCV = RGBtoHCV(RGB);
//    float L = HCV.z - HCV.y * 0.5;
//    float S = HCV.y / (1 - abs(L * 2 - 1) + Epsilon);
//    return float3(HCV.x, S, L);
//}
float RGBtoLigntness(in float3 RGB)
{
    float4 P = (RGB.g < RGB.b) ? float4(RGB.bg, -1.0, 2.0 / 3.0) : float4(RGB.gb, 0.0, -1.0 / 3.0);
    float4 Q = (RGB.r < P.x) ? float4(P.xyw, RGB.r) : float4(RGB.r, P.yzx);
    float C = Q.x - min(Q.w, Q.y);
    float L = Q.x - C * 0.5;
    return L;
}

struct PS_INPUT
{
    float4 Pos : SV_POSITION;
    float2 Tex : TEXCOORD;
};



//--------------------------------------------------------------------------------------
// Pixel Shader
//--------------------------------------------------------------------------------------
float4 PS(PS_INPUT input) : SV_Target
{
    float filtered = 0.5f;

    float4 color = tx.Sample(samLinear, input.Tex);

    // TOP ROW
    float s12 = step(RGBtoLigntness(tx.Sample(samLinear, input.Tex + float2(0, -1.0f / 1080.0f)).xyz), filtered);                 // MIDDLE

                                                                                                  // MIDDLE ROW
    float s21 = step(RGBtoLigntness(tx.Sample(samLinear, input.Tex + float2(-1.0f / 1920.0f, 0)).xyz), filtered);                // LEFT
    float s22 = step(RGBtoLigntness(color.xyz), filtered);                // CENTER
    float s23 = step(RGBtoLigntness(tx.Sample(samLinear, input.Tex + float2(-1.0f / 1920.0f, 0)).xyz), filtered);                // RIGHT

                                                                                                  // LAST ROW
    float s32 = step(RGBtoLigntness(tx.Sample(samLinear, input.Tex + float2(0, 1.0f / 1080.0f)).xyz), filtered);              // MIDDLE

    float factor = s12 + s21 + s22 + s23 + s32;
    factor = factor / 5.0f;


    if (factor > 0.9f) {
        color = float4(0, 0, 0, 1);
    }
    return float4(1.0 - color.xyz,1);
}