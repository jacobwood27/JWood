using CSV
using DataFrames

# keep the numeric code column as a string so we don't wipe leading zeros
df = CSV.read("projects/birdie_brigade/LND01.csv", DataFrame, types=Dict(2=>String))

function gini(Y) #https://en.wikipedia.org/wiki/Gini_coefficient
    n = length(Y)
    2 * sum([i * y for (i,y) in enumerate(Y)]) / n / sum(Y) - (n + 1)/n
end

# Get all the state names
states = Dict()
for row in eachrow(df)
    #states end with 000, but we don't want United States or DC
    if row.STCOU[3:5]=="000" && row.STCOU[1:2]!="00" && row.STCOU[1:2]!="11"
        states[row.STCOU[1:2]] = row.Areaname
    end
end

gini_df = DataFrame(state = String[], gini = Float64[])
for (k,v) in states
    Y = [row.LND110210D for row in eachrow(df) if row.STCOU[1:2]==k && row.STCOU[3:5]!="000"]
    push!(gini_df, [v, gini(sort(Y))])
end
sort!(gini_df,:gini)

#Data from pixel count
Y2 = [  652035, 85537, 68347, 132239, 148672, 
        144864, 58396, 87449, 146416, 109556, 
        175960, 95408, 22489, 48258, 34507, 
        57059, 129303, 61193, 164995, 336881, 
        350866, 63771, 50841, 852818, 609101, 
        507403, 296592, 543643, 726209, 2298115]
        
gini(sort!(Y2))

using Plots
bar(sort!(Y2),
    ylabel="Area [as proxied by pixel count]",
    xlabel="Golf Course Puzzle Pieces [sorted in ascending area order]",
    legend=false,
    grid=false,
    xticks=false,
    yticks=false,
    left_margin=10*Plots.PlotMeasures.mm,
    bottom_margin=10*Plots.PlotMeasures.mm,
    yguidefontsize=18,
    xguidefontsize=18,
    size=(1000,600))
savefig("projects/birdie_brigade/piece_area_bar.png")