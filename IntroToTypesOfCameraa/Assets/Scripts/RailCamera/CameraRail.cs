using UnityEngine;

public class CameraRail : MonoBehaviour
{
    // An array of Transform components that represent the control points for the Bezier curves.
    public Transform[] controlPoints;

    // Calculates the position on the Bezier curve based on a parameter t, where t ranges from 0 to 1.
    public Vector3 GetPositionAt(float t)
    {
        // Assuming the controlPoints array is structured for a cubic Bezier curve, which requires a length of n*3+1
        // Calculate the total number of segments in the curve based on the number of control points.
        int segmentCount = controlPoints.Length / 3;

        // Determine the current segment of the curve based on the value of t, ensuring it doesn't exceed the last segment index.
        int currentSegment = Mathf.Min(Mathf.FloorToInt(t * segmentCount), segmentCount - 1);

        // Calculate the index of the first control point of the current segment.
        int p0Index = currentSegment * 3;

        // Normalize t for the current segment to find the exact position within that segment.
        float normalizedT = (t * segmentCount) - currentSegment;

        // Retrieve the positions of the four control points defining the current segment of the Bezier curve.
        Vector3 p0 = controlPoints[p0Index].position;     // Start point
        Vector3 p1 = controlPoints[p0Index + 1].position; // Control point 1
        Vector3 p2 = controlPoints[p0Index + 2].position; // Control point 2
        Vector3 p3 = controlPoints[p0Index + 3].position; // End point

        // Calculate the position on the Bezier curve for the normalized t using the four control points.
        return CalculateBezierPoint(normalizedT, p0, p1, p2, p3);
    }

    // Calculates a single point on a cubic Bezier curve based on a given t, where t ranges from 0 to 1.
    Vector3 CalculateBezierPoint(float t, Vector3 p0, Vector3 p1, Vector3 p2, Vector3 p3)
    {
        // Calculate the polynomial coefficients.
        float u = 1 - t;
        float tt = t * t;
        float uu = u * u;
        float uuu = uu * u;
        float ttt = tt * t;

        // Calculate the Bezier point using the Bernstein polynomials for a cubic Bezier curve.
        Vector3 p = uuu * p0;              // The first term with the start point
        p += 3 * uu * t * p1;              // The second term with the first control point
        p += 3 * u * tt * p2;              // The third term with the second control point
        p += ttt * p3;                     // The fourth term with the end point

        // Return the calculated point on the curve.
        return p;
    }
}