import rasterio as rio
import geopandas as gpd
import numpy as np
import pandas as pd
from rasterstats import zonal_stats
import os
import time
import argparse
import sys # Save print statements to text file
import jenkspy # natural break method

def compute_ds_index(drought_dist):
    total_pixels = sum(drought_dist.values())
    ds_index = 0
    for i, (_, v) in enumerate(drought_dist.items()):
        ds_index += i*(v/total_pixels)
    return ds_index

# explicit function to normalize array
def normalize(arr, t_min, t_max):
    norm_arr = []
    diff = t_max - t_min
    diff_arr = max(arr) - min(arr)    
    for i in arr:
        temp = (((i - min(arr))*diff)/diff_arr) + t_min
        norm_arr.append(temp)
    return norm_arr

def generate_ds_index(startDate, endDate, shp_path, tif_path, output_path):

    start_time = time.time()

    date_range = pd.date_range(startDate, endDate, freq='M').strftime('%Y_%m')
    boundaries = gpd.read_file(shp_path)
    boundaries = boundaries.to_crs('EPSG:4326')
    repeated_rows = [boundaries.iloc[:161]]
    output_df = pd.DataFrame()

    for date in date_range:
        print(f"Generating drought severity index in {date}...")
        tif_sample = os.path.join(tif_path, f"{date}.tif")
        with rio.open(tif_sample) as src:
            drought_labels = src.read(1)

        new_df = pd.concat(repeated_rows, ignore_index=False)

        drought_labels = np.nan_to_num(drought_labels, nan=-1)
        stats = zonal_stats(boundaries, drought_labels, affine=src.transform, categorical=True)
        new_df['Month'] = date.split('_')[1]
        new_df['Year'] = date.split('_')[0]
        new_df['Drought Distribution'] = stats
        new_df['Drought Severity Index'] = [compute_ds_index(new_df['Drought Distribution'][i]) for i in range(len(new_df))]
        new_df['Norm Drought Severity Index'] = normalize(new_df['Drought Severity Index'], 0, 1)
        breaks = jenkspy.jenks_breaks(new_df['Norm Drought Severity Index'], n_classes=4)
        new_df['Drought Severity Classes'] = pd.cut(new_df['Norm Drought Severity Index'], bins=breaks, labels=[0,1,2,3], include_lowest=True)
        output_df = pd.concat([output_df, new_df], ignore_index=True)
    
    output_gdf = gpd.GeoDataFrame(output_df, crs='epsg:4326')
    gpd.GeoDataFrame.to_csv(output_gdf, os.path.join(output_path, f'mun_ds_index_{date_range[0]}-{date_range[-1]}.csv'), index=False)
    
    end_time = time.time()
    elapsed_time = end_time - start_time
    print(f"Script finished running in {elapsed_time: .2f} seconds")
    return output_gdf

def main():
    parser = argparse.ArgumentParser(description="Generate Drought Severity Index")
    parser.add_argument('startDate', type=str, help="Start date in MM/YYYY format")
    parser.add_argument('endDate', type=str, help="End date in MM/YYYY format")
    parser.add_argument('shp_path', type=str, help="Path to shapefile")
    parser.add_argument('tif_path', type=str, help="Path to directory containing TIFF files")
    parser.add_argument('output_path', type=str, help="Path to output directory")

    args = parser.parse_args()

    # Redirect stdout to a file
    with open(os.path.join(args.output_path, f'output.txt'), 'w') as f:
        sys.stdout = f
        generate_ds_index(args.startDate, args.endDate, args.shp_path, args.tif_path, args.output_path)

if __name__ == "__main__":
    main()