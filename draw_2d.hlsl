Texture1D<float4> IniParams : register(t120);

struct vs2ps {
	float4 pos : SV_Position0;
	float2 uv : TEXCOORD1;
};

#ifdef VERTEX_SHADER
void main(
		out vs2ps output,
		uint vertex : SV_VertexID)
{
	// Not using vertex buffers so manufacture our own coordinates.
	switch(vertex) {
		case 0:
			output.pos.xy = float2(1, 1);
			output.uv = float2(0,1);
			break;
		case 1:
			output.pos.xy = float2(1, -1);
			output.uv = float2(0,0);
			break;
		case 2:
			output.pos.xy = float2(-1, 1);
			output.uv = float2(1,1);
			break;
		case 3:
			output.pos.xy = float2(-1, -1);
			output.uv = float2(1,0);
			break;
		default:
			output.pos.xy = 0;
			output.uv = float2(0,0);
			break;
	};
	output.pos.zw = float2(0, 1);
}
#endif

#ifdef PIXEL_SHADER
#define screenConfig IniParams[55].xyzw
#define fillColor IniParams[56].xyzw
#define background IniParams[57].x
#define backgroundType IniParams[57].y

Texture2D<float4> t33 : register(t33);
Texture2D<float4> t34 : register(t34);

SamplerState s0_s : register(s0);

#define GAUSSIAN_BLUR_RADIUS 10

float4 GaussianBlur(float2 uv, float2 texelSize, Texture2D tex)
{
    float4 result = 0.0;
    
    const int matrixSize = (GAUSSIAN_BLUR_RADIUS * 2 + 1);
    float gaussianMatrix[matrixSize];
    float sum = 0.0;
	int i;
    for (i = -GAUSSIAN_BLUR_RADIUS; i <= GAUSSIAN_BLUR_RADIUS; ++i)
    {
        float weight = exp(-0.5 * (i * i) / (GAUSSIAN_BLUR_RADIUS * GAUSSIAN_BLUR_RADIUS));
        gaussianMatrix[i + GAUSSIAN_BLUR_RADIUS] = weight;
        sum += weight;
    }
	
    for (i = 0; i < matrixSize; ++i)
    {
        gaussianMatrix[i] /= sum;
    }
    
    for (i = -GAUSSIAN_BLUR_RADIUS; i <= GAUSSIAN_BLUR_RADIUS; ++i)
    {
        for (int j = -GAUSSIAN_BLUR_RADIUS; j <= GAUSSIAN_BLUR_RADIUS; ++j)
        {
            result += gaussianMatrix[i + GAUSSIAN_BLUR_RADIUS] * gaussianMatrix[j + GAUSSIAN_BLUR_RADIUS] * tex.SampleLevel(s0_s, uv + float2(i, j) * texelSize, 0);
        }
    }
    
    return result;
}

void main(vs2ps input, out float4 result : SV_Target0)
{
	float scaleType = screenConfig.z;
	float fillType = screenConfig.w;
	
	float width, height;
	width = screenConfig.x;
	height = screenConfig.y;
		
	float t33_width, t33_height;
	t33.GetDimensions(t33_width, t33_height);
	float2 texelSize = 1.0 / float2(t33_width, t33_height);
	input.uv.xy = 1 - input.uv.xy;
	
	float ad = (height/width)/(t33_height/t33_width);
		
	if (scaleType == 0){
		if (t33_height >= t33_width) {
			scaleType = 1;
		}
		else {
			scaleType = 2;
		}
	}
	
	bool isFill = false;
	
	result = float4(0,0,0,0);
	
	float xAxis = (input.uv.x / ad) - 0.5 / ad + 0.5;
	float yAxis = (input.uv.y * ad) - 0.5 * ad + 0.5;
	
	switch (scaleType)
	{
		case 1:
			if (xAxis > 0 && xAxis < 1 ) {
				result = t33.Sample(s0_s, float2((input.uv.x / ad) - 0.5 / ad - 0.5,input.uv.y)).xyzw;
			}
			else {
				isFill = true;
			}
			break;
		case 2:
			if (yAxis > 0 && yAxis < 1 ) {
				result = t33.Sample(s0_s, float2(input.uv.x,(input.uv.y * ad) - 0.5 * ad + 0.5)).xyzw;
			}
			else {
				isFill = true;
			}
			break;
		default:
			break;
	}
	if (background == 1){
		float4 backgroundIMG;
		
		float t34_width, t34_height;
		t34.GetDimensions(t34_width, t34_height);
		
		float2 texelSize_back = 1.0 / float2(t34_width, t34_height);
		
		float ad_back = (height/width)/(t34_height/t34_width);
				
		switch (backgroundType)
		{
			case 0:
				if (width >= height) backgroundIMG = t34.Sample(s0_s, float2((input.uv.x / ad_back) - 0.5 / ad_back - 0.5,input.uv.y)).xyzw;
				else backgroundIMG = t34.Sample(s0_s, float2(input.uv.x,(input.uv.y * ad_back) - 0.5 * ad_back + 0.5)).xyzw;
				break;
			case 1:
				if (width >= height) backgroundIMG = GaussianBlur(float2(input.uv.x,(input.uv.y * ad_back) - 0.5 * ad_back + 0.5), texelSize, t34);
				else backgroundIMG = GaussianBlur(float2((input.uv.x / ad_back) - 0.5 / ad_back - 0.5,input.uv.y), texelSize, t34);
				break;
			default:
				backgroundIMG = float4(0,0,0,0);
				break;
		}
		float3 blend = smoothstep(0.0, 1.0, result.w);
		result.xyz = lerp(backgroundIMG.xyz, result.xyz, blend);
		result.w = 1;
		isFill = false;
	}
	
	if (isFill){
		switch (fillType)
			{
				case 0:
					if (width >= height) result = GaussianBlur(float2(input.uv.x,(input.uv.y * ad) - 0.5 * ad + 0.5), texelSize, t33);
					else result = GaussianBlur(float2((input.uv.x / ad) - 0.5 / ad - 0.5,input.uv.y), texelSize, t33);
					break;
				case 1:
					result = float4(exp2(log2(fillColor.xyz) * 2.2 / 1.0),fillColor.w);
					break;
				default:
					break;
			}
	}
}
#endif
