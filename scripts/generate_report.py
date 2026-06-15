import pandas as pd
from jinja2 import Environment, FileSystemLoader
import os
import argparse


def load_sample_info(file_path):
    if not file_path or not os.path.exists(file_path):
        return None
    try:
        with open(file_path, "r") as f:
            lines = [line.strip() for line in f.readlines()]

        # Expected order: batch, row_id, sample_id, folder, platform, array
        keys = ["batch", "row_id", "sample_id", "folder", "platform", "array"]
        return dict(zip(keys, lines))
    except Exception as e:
        print(f"Warning: Could not load sample info: {e}")
        return None


def load_classifier_result(file_path):
    if not file_path or not os.path.exists(file_path):
        return None
    try:
        with open(file_path, "r") as f:
            return f.readline().strip()
    except Exception as e:
        print(f"Warning: Could not load classifier result: {e}")
        return None


def generate_report(
    results_tsv, template_file, output_html, sample_info_file, plot_dir, classifier_file
):
    # Load results
    df = pd.read_csv(results_tsv, sep="\t")

    # Custom sorting for chromosomes (1, 2, ..., 22, X, Y, etc.)
    def chr_sort_key(chr_val):
        if pd.isna(chr_val):
            return (2, "")
        c = str(chr_val).lower().replace("chr", "")
        if c.isdigit():
            return (0, int(c))
        return (1, c)

    df["chr_sort"] = df["chr"].apply(chr_sort_key)
    df = df.sort_values(by=["chr_sort", "start"]).drop(columns=["chr_sort"])

    # Convert dataframe to list of dictionaries
    genes_data = df.to_dict(orient="records")

    # Load sample info
    sample_info = load_sample_info(sample_info_file)

    # Load classifier result
    classification = load_classifier_result(classifier_file)

    # Setup Jinja2 environment
    env = Environment(
        loader=FileSystemLoader(os.path.dirname(os.path.abspath(template_file)) or ".")
    )
    template = env.get_template(os.path.basename(template_file))

    # Render template
    html_content = template.render(
        genes=genes_data,
        sample=sample_info,
        plot_dir=plot_dir,
        classification=classification,
    )

    # Write to output file
    with open(output_html, "w") as f:
        f.write(html_content)

    print(f"Report generated successfully: {output_html}")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="Generate an HTML report for gene analysis."
    )
    parser.add_argument("--results", required=True, help="Path to results.tsv")
    parser.add_argument("--sample_info", required=True, help="Path to sample_info.txt")
    parser.add_argument("--plot_dir", required=True, help="Path to the plots folder")
    parser.add_argument("--classifier", help="Path to classifier_result.txt")
    parser.add_argument(
        "--output", default="report.html", help="Path for the output HTML file"
    )
    parser.add_argument(
        "--template", default="report_template.html", help="Path to the Jinja2 template"
    )

    args = parser.parse_args()

    generate_report(
        args.results,
        args.template,
        args.output,
        args.sample_info,
        args.plot_dir,
        args.classifier,
    )
