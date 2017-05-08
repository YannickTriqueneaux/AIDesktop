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

float3 RGBtoHCV(in float3 RGB)
{
    // Based on work by Sam Hocevar and Emil Persson
    float4 P = (RGB.g < RGB.b) ? float4(RGB.bg, -1.0, 2.0 / 3.0) : float4(RGB.gb, 0.0, -1.0 / 3.0);
    float4 Q = (RGB.r < P.x) ? float4(P.xyw, RGB.r) : float4(RGB.r, P.yzx);
    float C = Q.x - min(Q.w, Q.y);
    float H = abs((Q.w - Q.y) / (6 * C + Epsilon) + Q.z);
    return float3(H, C, Q.x);
}
float3 RGBtoHSV(in float3 RGB)
{
    float3 HCV = RGBtoHCV(RGB);
    float S = HCV.y / (HCV.z + Epsilon);
    return float3(HCV.x, S, HCV.z);
}
float3 HUEtoRGB(in float H)
{
    float R = abs(H * 6 - 3) - 1;
    float G = 2 - abs(H * 6 - 2);
    float B = 2 - abs(H * 6 - 4);
    return saturate(float3(R, G, B));
}
float3 HSVtoRGB(in float3 HSV)
{
    float3 RGB = HUEtoRGB(HSV.x);
    return ((RGB - 1) * HSV.y + 1) * HSV.z;
}
float3 RGBtoHSL(in float3 RGB)
{
    float3 HCV = RGBtoHCV(RGB);
    float L = HCV.z - HCV.y * 0.5;
    float S = HCV.y / (1 - abs(L * 2 - 1) + Epsilon);
    return float3(HCV.x, S, L);
}
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
    /*float4 texColor = tx.Sample(samLinear, input.Tex);
    float3 hsv = RGBtoHSL(texColor.xyz);
    float lightness = RGBtoLigntness(texColor.xyz);
    float filtered = smoothstep(0.65,1.0, lightness);
    return float4(filtered, filtered, filtered, texColor.w);*/

    float4 lum = float4(0.30, 0.59, 0.11, 1);
    // TOP ROW
    float s11 = dot(tx.Sample(samLinear, input.Tex + float2(-1.0f / 1920.0f, -1.0f / 1080.0f)), lum);   // LEFT
    float s12 = dot(tx.Sample(samLinear, input.Tex + float2(0, -1.0f / 1080.0f)), lum);                 // MIDDLE
    float s13 = dot(tx.Sample(samLinear, input.Tex + float2(1.0f / 1920.0f, -1.0f / 1080.0f)), lum);    // RIGHT

                                                                                                       // MIDDLE ROW
    float s21 = dot(tx.Sample(samLinear, input.Tex + float2(-1.0f / 1920.0f, 0)), lum);                // LEFT
                                                                                                       // Omit center
    float s23 = dot(tx.Sample(samLinear, input.Tex + float2(-1.0f / 1920.0f, 0)), lum);                // RIGHT

                                                                                                       // LAST ROW
    float s31 = dot(tx.Sample(samLinear, input.Tex + float2(-1.0f / 1920.0f, 1.0f / 1080.0f)), lum);    // LEFT
    float s32 = dot(tx.Sample(samLinear, input.Tex + float2(0, 1.0f / 1080.0f)), lum);              // MIDDLE
    float s33 = dot(tx.Sample(samLinear, input.Tex + float2(1.0f / 1920.0f, 1.0f / 1080.0f)), lum); // RIGHT
    float t1 = s13 + s33 + (2 * s23) - s11 - (2 * s21) - s31;
    float t2 = s31 + (2 * s32) + s33 - s11 - (2 * s12) - s13;

    float4 col;

    if (((t1 * t1) + (t2 * t2)) > 0.05) {
        col = float4(0,0,0,1);
    }
    else {
        col = float4(1,1,1,1);
    }
    return col;
}